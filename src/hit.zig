const std = @import("std");
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

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f32,
    front_face: bool,

    pub inline fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = vec.dot(r.direction, outward_normal) < 0.0;
        self.normal = if (self.front_face) outward_normal else -outward_normal;
    }
};

pub const Hittable = union(enum) {
    Sphere: Sphere,

    const Self = @This();

    pub fn hit(self: Self, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        switch (self) {
            .Sphere => |sphere| return sphere.hit(r, t_min, t_max),
            else => return null,
        }
    }
};

pub const Sphere = struct {
    center: Point3,
    radius: f32,

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
                // todo set a constructor for HitRecord
                .normal = undefined,
                .front_face = undefined,
            };

            hit_record.setFaceNormal(r, outward_normal);
            return hit_record;
        }
    }
};
