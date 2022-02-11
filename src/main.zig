const std = @import("std");
const math = std.math;
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const ray = @import("./ray.zig");
const Ray = ray.Ray;
const vec = @import("./vec.zig");
const dot = vec.dot;
const mul = vec.mul;
const Vec3 = vec.Vec3;
const vec3 = vec.vec3;
const point = vec.point;
const point3 = point.point3;
const Point3 = point.Point3;
const col = vec.color;
const color = col.color;
const Color = col.Color;
const colorToPixel = col.colorToPixel;

const hit = @import("./hit.zig");
const Hittable = hit.Hittable;
const World = hit.World;

const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, c.SDL_WINDOWPOS_UNDEFINED_MASK);

// Image constants

const aspect_ratio: f32 = 16.0 / 9.0;
const window_width: c_int = 400;
const window_height: c_int = @floatToInt(c_int, @intToFloat(f32, window_width) / aspect_ratio);

// Camera constants

const viewport_height: f32 = 2.0;
const viewport_width: f32 = aspect_ratio * viewport_height;
const focal_length: f32 = 1.0;
const origin = point3(0.0, 0.0, 0.0);
const horizontal = point3(viewport_width, 0.0, 0.0);
const vertical = point3(0.0, viewport_height, 0.0);

// zig fmt: off
const lower_left_corner = origin
    - mul(@as(f32, 0.5), horizontal)
    - mul(@as(f32, 0.5), vertical)
    - point3(0.0, 0.0, focal_length);
// zig fmt: on

pub fn main() !void {

    // SDL Setup

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("raytracer", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    // Does this need to be destroyed also?
    var surface = c.SDL_GetWindowSurface(window) orelse {
        c.SDL_Log("Unable to get Window surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    // World setup

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var world = World.init(allocator);
    defer world.deinit();
    try world.add(Hittable{ .sphere = .{
        .center = point3(0.0, 0.0, -1.0),
        .radius = 0.5,
    } });
    try world.add(Hittable{ .sphere = .{
        .center = point3(0.0, -100.5, -1.0),
        .radius = 100,
    } });

    // render

    _ = c.SDL_LockSurface(surface);

    var h: c_int = 0;
    while (h < window_height) : (h += 1) {
        var w: c_int = 0;
        while (w < window_width) : (w += 1) {
            const u = @intToFloat(f32, w) / @intToFloat(f32, window_width - 1);
            const v = @intToFloat(f32, window_height - h) / @intToFloat(f32, window_height - 1);

            // TODO check why subtract origin?
            // zig fmt: off
            const r = Ray.new(origin,
                lower_left_corner
                + mul(u, horizontal)
                + mul(v, vertical)
                - origin);
            // zig fmt: on

            const pixel_color = rayColor(r, world);
            const pixel = colorToPixel(pixel_color);
            setPixel(surface, w, h, pixel);
        }
    }

    c.SDL_UnlockSurface(surface);

    if (c.SDL_UpdateWindowSurface(window) != 0) {
        c.SDL_Log("Error updating window surface: %s", c.SDL_GetError());
        return error.SDLUpdateWindowFailed;
    }

    // Keep window open until receiving quit event

    var running = true;
    while (running) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    running = false;
                },
                else => {},
            }
        }
        c.SDL_Delay(16);
    }
}

fn setPixel(surf: *c.SDL_Surface, x: c_int, y: c_int, pixel: u32) void {
    // looks like calculating pointer offset
    // - pitch is length of a row of pixels in bytes
    // - x is multiplied times 4 because a pixel is 4 bytes
    const target_pixel = @ptrToInt(surf.pixels) +
        @intCast(usize, y) * @intCast(usize, surf.pitch) +
        @intCast(usize, x) * 4;
    @intToPtr(*u32, target_pixel).* = pixel;
}

fn rayColor(r: Ray, world: World) Color {
    if (world.hit(r, 0.0, std.math.inf(f32))) |hit_record| {
        return mul(@as(f32, 0.5), hit_record.normal + color(1.0, 1.0, 1.0));
    } else {
        const unit_direction = vec.unitVector(r.direction);
        const t = 0.5 * (point.y(unit_direction) + 1.0);
        return mul(1.0 - t, color(1.0, 1.0, 1.0)) + mul(t, color(0.5, 0.7, 1.0));
    }
}

inline fn degrees_to_radians(degrees: f32) f32 {
    return degrees * math.pi / 180.0;
}

test {
    std.testing.refAllDecls(@This());
}
