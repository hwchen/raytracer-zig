const vec = @import("./vec.zig");
const Vec3 = vec.Vec3;

// x, y, z correspond to r, g, b
pub const Color = Vec3;

// bytes from high to low:
// - alpha
// - red
// - green
// - blue
pub fn colorToPixel(color: Color) u32 {
    const r = @floatToInt(u32, 255.99 * color.x);
    const g = @floatToInt(u32, 255.99 * color.y);
    const b = @floatToInt(u32, 255.99 * color.z);
    return 255 << 24 | r << 16 | g << 8 | b;
}
