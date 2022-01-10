pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    const Self = @This();

    pub fn new(x: f32, y: f32, z: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn length(self: Self) f32 {
        return @sqrt(self.length_square());
    }

    pub fn length_square(self: Self) f32 {
        return self.x * self.x +
            self.y * self.y +
            self.z * self.z;
    }

    pub fn dot(u: Self, v: Self) f32 {
        return u.x * v.x +
            u.y * v.y +
            u.z * v.z;
    }

    pub fn cross(u: Self, v: Self) Self {
        return Self{
            .x = u.y * v.z - u.z * v.y,
            .y = u.z * v.x - u.x * v.z,
            .z = u.x * v.y - u.y * v.x,
        };
    }

    pub fn unit_vector(self: Self) Self {
        const inv_length = 1 / self.length();
        return Self{
            .x = self.x * inv_length,
            .y = self.y * inv_length,
            .z = self.z * inv_length,
        };
    }
};

pub const Point3 = Vec3;
