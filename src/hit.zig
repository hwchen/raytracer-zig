const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const vec = @import("./vec.zig");
const dot = vec.dot;
const mul = vec.mul;
const Vec3 = vec.Vec3;
const vec3 = vec.vec3;
const point = vec.point;
const point3 = point.point3;
const Point3 = point.Point3;
const ray = @import("./ray.zig");
const Ray = ray.Ray;
const Material = @import("./material.zig").Material;

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    material: Material,
    t: f32,
    front_face: bool,

    pub inline fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = vec.dot(r.direction, outward_normal) < 0.0;
        self.normal = if (self.front_face) outward_normal else -outward_normal;
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,

    const Self = @This();

    pub fn hit(self: Self, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        switch (self) {
            .sphere => |sphere| return sphere.hit(r, t_min, t_max),
        }
    }
};

pub const Sphere = struct {
    center: Point3,
    radius: f32,
    material: Material,

    const Self = @This();

    pub fn hit(self: Self, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        const oc = r.origin - self.center;
        const a = vec.lengthSq(r.direction);
        const half_b = dot(oc, r.direction);
        const _c = vec.lengthSq(oc) - self.radius * self.radius;
        const discriminant = half_b * half_b - a * _c;
        if (discriminant < 0) {
            return null;
        } else {
            // figure out which root is in the acceptable range
            const sqrt_d = std.math.sqrt(discriminant);
            var root = (-half_b - sqrt_d) / a;
            if (root < t_min or t_max < root) {
                root = (-half_b + sqrt_d) / a;
                if (root < t_min or t_max < root) {
                    // if root doesn't fit in either range, return null.
                    return null;
                }
            }

            const p = r.at(root);
            const outward_normal = vec.mul(1.0 / self.radius, p - self.center);
            var hit_record = HitRecord{
                .t = root,
                .p = p,
                // ugly to set this directly first,
                // todo maybe set a constructor for HitRecord
                .normal = undefined,
                .front_face = undefined,
                .material = self.material,
            };

            hit_record.setFaceNormal(r, outward_normal);
            return hit_record;
        }
    }
};

// Unlike in the book, we don't implement a Hittable trait, we just implement
// a method to call.
pub const World = struct {
    hittable: ArrayList(Hittable),

    const Self = @This();

    pub fn init(alloc: Allocator) Self {
        return Self{
            .hittable = ArrayList(Hittable).init(alloc),
        };
    }

    pub fn deinit(self: Self) void {
        self.hittable.deinit();
    }

    pub fn add(self: *Self, hittable: Hittable) !void {
        try self.hittable.append(hittable);
    }

    pub fn clear(self: *Self) void {
        self.hittable.clearRetainingCapacity();
    }

    // For the ray, check whether it hits any of the hittables.
    // If it does, update the result HitRecord if it's closer than the
    // current result
    pub fn hit(self: Self, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        // the interval tmin -> tmax controls whether or not a hit is
        // "counted". In order to get the closest hit in the interval,
        // `closest_so_far` keeps track of the max side of the interval,
        // and shrinks the interval any time another candidate hit is
        // found.
        var closest_so_far = t_max;
        var res: ?HitRecord = null;

        for (self.hittable.items) |hittable| {
            if (hittable.hit(r, t_min, closest_so_far)) |hit_record| {
                closest_so_far = hit_record.t;
                res = hit_record;
            }
        }

        return res;
    }
};
