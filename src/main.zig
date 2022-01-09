const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, c.SDL_WINDOWPOS_UNDEFINED_MASK);

const window_width: c_int = 256;
const window_height: c_int = 256;

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

    // render

    setPixel(surface, 2, 2, 0);
    //var w: c_int = 0;
    //var h: c_int = 0;
    //while (w < window_width) : (w += 1) {
    //    while (h < window_height) : (h += 1) {
    //        const r = @intToFloat(f32, w) / @intToFloat(f32, window_width - 1);
    //        const g = @intToFloat(f32, h) / @intToFloat(f32, window_height - 1);
    //        const b = 0.25;
    //        const pixel = rgbToPixel(
    //            @floatToInt(u32, 255.99 * r),
    //            @floatToInt(u32, 255.99 * g),
    //            @floatToInt(u32, 255.99 * b),
    //        );
    //        setPixel(surface, w, h, pixel);
    //    }
    //}

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

// TODO figure out how rgb maps to the u32
fn rgbToPixel(r: u32, g: u32, b: u32) u32 {
    return 255 << 24 | r << 16 | g << 8 | b;
}
