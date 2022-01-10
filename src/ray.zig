const vec = @import("./vec.zig");
const Point3 = vec.Point3;
const Vec3 = vec.Vec3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    const Self = @This();

    pub fn new(origin: Point3, direction: Vec3) Self {
        return Self{
            .origin = origin,
            .direction = direction,
        };
    }

    pub fn at(self: Self, t: f32) Point3 {
        return self.origin.add(self.direction.scalarMul(t));
    }
};

const testing = @import("std").testing;

test "ray at" {
    const r = Ray.new(
        Point3.new(0.0, 0.0, 0.0),
        Vec3.new(0.0, 0.0, 0.0),
    );
    try testing.expectEqual(Point3.new(0.0, 0.0, 0.0), r.at(0.0));
}
