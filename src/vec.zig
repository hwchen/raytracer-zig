const zmath = @import("./lib/zmath.zig");

pub const Vec3 = zmath.F32x4;
pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return .{ x, y, z, 0.0 };
}

pub const cross = zmath.cross3;
pub const lengthSq = zmath.lengthSq3;
pub const length = zmath.length3;
pub const mul = zmath.mul;
pub const unitVector = zmath.normalize3;
/// Not sure why zmath returns dot product as a vector
pub fn dot(v0: Vec3, v1: Vec3) f32 {
    return zmath.dot3(v0, v1)[0];
}

pub const point = struct {
    pub const Point3 = Vec3;
    // x, y, z
    pub const point3 = vec3;

    pub fn x(p: Point3) f32 {
        return p[0];
    }

    pub fn y(p: Point3) f32 {
        return p[1];
    }

    pub fn z(p: Point3) f32 {
        return p[2];
    }
};

pub const color = struct {
    pub const Color = Vec3;
    // r, g, b
    pub const color = vec3;

    // bytes from high to low:
    // - alpha
    // - red
    // - green
    // - blue
    pub fn colorToPixel(col: Color) u32 {
        const r = @floatToInt(u32, 255.99 * col[0]);
        const g = @floatToInt(u32, 255.99 * col[1]);
        const b = @floatToInt(u32, 255.99 * col[2]);
        return 255 << 24 | r << 16 | g << 8 | b;
    }
};
