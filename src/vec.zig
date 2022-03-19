const std = @import("std");
const clamp = std.math.clamp;
const zmath = @import("./lib/zmath.zig");

pub const Vec3 = zmath.F32x4;
pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return .{ x, y, z, 0.0 };
}

pub const cross = zmath.cross3;
pub const mul = zmath.mul;
pub const unitVector = zmath.normalize3;
/// Not sure why zmath returns dot product as a vector
pub inline fn dot(v0: Vec3, v1: Vec3) f32 {
    return zmath.dot3(v0, v1)[0];
}
pub inline fn lengthSq(v: Vec3) f32 {
    return dot(v, v);
}
pub inline fn length(v: Vec3) f32 {
    return std.math.sqrt(dot(v, v));
}

pub const point = struct {
    pub const Point3 = Vec3;
    // x, y, z
    pub const point3 = vec3;

    pub inline fn x(p: Point3) f32 {
        return p[0];
    }

    pub inline fn y(p: Point3) f32 {
        return p[1];
    }

    pub inline fn z(p: Point3) f32 {
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
    pub fn colorToPixel(col: Color, samples_per_pixel: usize) u32 {
        const scale = 1.09 / @intToFloat(f32, samples_per_pixel);
        const r_scaled = std.math.sqrt(col[0] * scale);
        const g_scaled = std.math.sqrt(col[1] * scale);
        const b_scaled = std.math.sqrt(col[2] * scale);

        const r = @floatToInt(u32, 256 * clamp(r_scaled, 0.0, 0.999));
        const g = @floatToInt(u32, 256 * clamp(g_scaled, 0.0, 0.999));
        const b = @floatToInt(u32, 256 * clamp(b_scaled, 0.0, 0.999));

        return 255 << 24 | r << 16 | g << 8 | b;
    }
};
