const std = @import("std");

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

// Camera constants ========================

pub const aspect_ratio: f32 = 16.0 / 9.0;
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

// begin Camera struct ============================
// no fields is a bit weird, but for this exercise
// we're just using constants anyways. Will fix when
// camera becomes configurable

const Self = @This();

pub fn getRay(u: f32, v: f32) Ray {
    // TODO check why subtract origin?
    return Ray.new(origin, lower_left_corner + mul(u, horizontal) + mul(v, vertical) - origin);
}
