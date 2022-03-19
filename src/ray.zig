const vec = @import("./vec.zig");
const Point3 = vec.point.Point3;
const Vec3 = vec.Vec3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    const Self = @This();

    // TODO to be consistent with vec3, initializer could be `ray`
    pub fn new(origin: Point3, direction: Vec3) Self {
        return Self{
            .origin = origin,
            .direction = direction,
        };
    }

    pub fn at(self: Self, t: f32) Point3 {
        return self.origin + vec.mul(t, self.direction);
    }
};

const testing = @import("std").testing;

test "ray at" {
    const r = Ray.new(
        vec.point.point3(0.0, 0.0, 0.0),
        vec.vec3(0.0, 0.0, 0.0),
    );
    try testing.expectEqual(vec.point.point3(0.0, 0.0, 0.0), r.at(0.0));
}
