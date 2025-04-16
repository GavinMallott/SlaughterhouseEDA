// -----------------------------------------------------------------------------------//
//                                  Vector Primatives                                 //
// -----------------------------------------------------------------------------------//
pub const std = @import("std");

pub fn Vector2(comptime T: type) type {
    return struct {
        v: Vector,

        pub const dim = 2;

        pub const Vector = @Vector(dim, T);

        const Self = @This();

        const Operations = VectorOperations(T, Self);

        pub inline fn init(ix: T, iy: T) Self {
            return .{ .v = .{ix, iy} };
        }

        pub inline fn x(self: *const Self) T {
            return self.v[0];
        }

        pub inline fn y(self: *const Self) T {
            return self.v[1];
        }

        pub const add = Operations.add;
        pub const sub = Operations.sub;
        pub const mul = Operations.mul;
        pub const div = Operations.div;

        pub const addScalar = Operations.addScalar;
        pub const subScalar = Operations.subScalar;
        pub const mulScalar = Operations.mulScalar;
        pub const divScalar = Operations.divScalar;

        pub const splat = Operations.splat;

        pub const lt = Operations.lt;
        pub const gt = Operations.gt;
        pub const lteq = Operations.lteq;
        pub const gteq = Operations.gteq;

        pub const eqlApprox = Operations.eqlApprox;
        pub const eql = Operations.eql;

        pub const magnitude_squared = Operations.magnitude_squared;
        pub const magnitude = Operations.magnitude;

        pub const inverse = Operations.inverse;
        pub const negate = Operations.negate;

        pub const normalize = Operations.normalize;
        pub const dist = Operations.dist;

        pub const disp = Operations.disp;
        pub const update = Operations.update;

        pub const idx = Operations.idx;
        pub const idy = Operations.idy;
    };
}

pub fn Vector3(comptime T: type) type {
    return struct {
        v: Vector,

        pub const dim = 3;

        pub const Vector = @Vector(dim, T);

        const Self = @This();

        const Operations = VectorOperations(T, Self);

        pub inline fn init(ix: T, iy: T, iz: T) Self {
            return .{ .v = .{ix, iy, iz} };
        }

        pub inline fn x(self: *const Self) T {
            return self.v[0];
        }

        pub inline fn y(self: *const Self) T {
            return self.v[1];
        }

        pub inline fn z(self: *const Self) T {
            return self.v[2];
        }

        pub const add = Operations.add;
        pub const sub = Operations.sub;
        pub const mul = Operations.mul;
        pub const div = Operations.div;

        pub const addScalar = Operations.addScalar;
        pub const subScalar = Operations.subScalar;
        pub const mulScalar = Operations.mulScalar;
        pub const divScalar = Operations.divScalar;

        pub const splat = Operations.splat;

        pub const lt = Operations.lt;
        pub const gt = Operations.gt;
        pub const lteq = Operations.lteq;
        pub const gteq = Operations.gteq;

        pub const eqlApprox = Operations.eqlApprox;
        pub const eql = Operations.eql;

        pub const magnitude_squared = Operations.magnitude_squared;
        pub const magnitude = Operations.magnitude;

        pub const inverse = Operations.inverse;
        pub const negate = Operations.negate;

        pub const normalize = Operations.normalize;
        pub const dist = Operations.dist;

        pub const disp = Operations.disp;
        pub const update = Operations.update;

        pub const idx = Operations.idx;
        pub const idy = Operations.idy;
        pub const idz = Operations.idz;
    };
}

pub fn Vector4(comptime T: type) type {
    return struct {
        v: Vector,

        pub const dim = 4;

        pub const Vector = @Vector(dim, T);

        const Self = @This();

        const Operations = VectorOperations(T, Self);

        pub inline fn init(ix: T, iy: T, iz: T, iw: T) Self {
            return .{ .v = .{ix, iy, iz, iw} };
        }

        pub inline fn x(self: *const Self) T {
            return self.v[0];
        }

        pub inline fn y(self: *const Self) T {
            return self.v[1];
        }

        pub inline fn z(self: *const Self) T {
            return self.v[2];
        }

        pub inline fn w(self: *const Self) T {
            return self.v[3];
        }

        pub const add = Operations.add;
        pub const sub = Operations.sub;
        pub const mul = Operations.mul;
        pub const div = Operations.div;

        pub const addScalar = Operations.addScalar;
        pub const subScalar = Operations.subScalar;
        pub const mulScalar = Operations.mulScalar;
        pub const divScalar = Operations.divScalar;

        pub const splat = Operations.splat;

        pub const lt = Operations.lt;
        pub const gt = Operations.gt;
        pub const lteq = Operations.lteq;
        pub const gteq = Operations.gteq;

        pub const eqlApprox = Operations.eqlApprox;
        pub const eql = Operations.eql;

        pub const magnitude_squared = Operations.magnitude_squared;
        pub const magnitude = Operations.magnitude;

        pub const inverse = Operations.inverse;
        pub const negate = Operations.negate;

        pub const normalize = Operations.normalize;
        pub const dist = Operations.dist;
        
        pub const disp = Operations.disp;
        pub const update = Operations.update;

        pub const idx = Operations.idx;
        pub const idy = Operations.idy;
        pub const idz = Operations.idz;
        pub const idw = Operations.idw;
    };
}

pub fn VectorGen(comptime ctx: type, comptime len: u64) type {
    return struct {
        v: Vector,

        pub const Vector = @Vector(dim, ctx);
        pub const dim = len;
        const Self = @This();

        const Operations = VectorOperations(ctx, Self);

        pub fn init(initialize: [dim]ctx) Self {
            var vec: Vector = @splat(0);
            for (0..dim) |i| {
                vec[i] = initialize[i];
            }
            return .{ .v = vec};
        }

        pub const add = Operations.add;
        pub const sub = Operations.sub;
        pub const mul = Operations.mul;
        pub const div = Operations.div;

        pub const addScalar = Operations.addScalar;
        pub const subScalar = Operations.subScalar;
        pub const mulScalar = Operations.mulScalar;
        pub const divScalar = Operations.divScalar;

        pub const splat = Operations.splat;

        pub const lt = Operations.lt;
        pub const gt = Operations.gt;
        pub const lteq = Operations.lteq;
        pub const gteq = Operations.gteq;

        pub const eqlApprox = Operations.eqlApprox;
        pub const eql = Operations.eql;

        pub const magnitude_squared = Operations.magnitude_squared;
        pub const magnitude = Operations.magnitude;

        pub const inverse = Operations.inverse;
        pub const negate = Operations.negate;

        pub const normalize = Operations.normalize;
        pub const dist = Operations.dist;

        pub const disp = Operations.disp;
        pub const update = Operations.update;

        pub const idx = Operations.idx;
        pub const idy = Operations.idy;
        pub const idz = Operations.idz;
        pub const idw = Operations.idw;
        pub const idn = Operations.idn;
    };
}

pub fn VectorOperations(comptime ctx: type, comptime VectorN: type) type {
    return struct {
        ///Element-wise addition
        pub inline fn add(a: *const VectorN, b: *const VectorN) VectorN {
            return VectorN{ .v = a.v + b.v };
        }

        ///Element-wise subtraction
        pub inline fn sub(a: *const VectorN, b: *const VectorN) VectorN {
            return VectorN{ .v = a.v - b.v };
        }
        
        ///Element-wise multiplicaiton
        pub inline fn mul(a: *const VectorN, b: *const VectorN) VectorN {
            return VectorN{ .v = a.v * b.v };
        }

        ///Element-wise division
        pub inline fn div(a: *const VectorN, b: *const VectorN) VectorN {
            return VectorN{ .v = a.v / b.v };
        }

        ///Add by scalar
        pub inline fn addScalar(a: *const VectorN, s: ctx) VectorN {
            return VectorN{ .v = a.v + VectorN.splat(s).v };
        }

        ///Subtract by scalar
        pub inline fn subScalar(a: *const VectorN, s: ctx) VectorN {
            return VectorN{ .v = a.v - VectorN.splat(s).v };
        }
        
        ///Multiply by scalar
        pub inline fn mulScalar(a: *const VectorN, s: ctx) VectorN {
            return VectorN{ .v = a.v * VectorN.splat(s).v };
        }

        ///Divide by scalar
        pub inline fn divScalar(a: *const VectorN, s: ctx) VectorN {
            return VectorN{ .v = a.v / VectorN.splat(s).v };
        }

        ///Initialize vector with given scalar
        pub inline fn splat(scalar: ctx) VectorN {
            return VectorN{ . v = @splat(scalar) };
        }

        ///Vector a < Vector b
        pub inline fn lt(a: *const VectorN, b: *const VectorN) bool {
            return a.v < b.v;
        }

        ///Vector a > Vector b
        pub inline fn lteq(a: *const VectorN, b: *const VectorN) bool {
            return a.v <= b.v;
        }

        ///Vector a <= Vector b
        pub inline fn gt(a: *const VectorN, b: *const VectorN) bool {
            return a.v > b.v;
        }

        ///Vector a >= Vector b
        pub inline fn gteq(a: *const VectorN, b: *const VectorN) bool {
            return a.v >= b.v;
        }

        /// Checks for approximate (absolute tolerance) equality between two vectors
        /// of the same type and dimensions
        pub inline fn eqlApprox(a: *const VectorN, b: *const VectorN, tolerance: ctx) bool {
            var i: usize = 0;
            while (i < VectorN.dim) : (i += 1) {
                if (!std.math.eql(ctx, a.v[i], b.v[i], tolerance)) {
                    return false;
                }
            }
            return true;
        }

        /// Checks for approximate (absolute epsilon tolerance) equality
        /// between two vectors of the same type and dimensions
        pub inline fn eql(a: *const VectorN, b: *const VectorN) bool {
            return a.eqlApprox(b, std.math.eps(ctx));
        }

        ///Returns dot product of two vectors as a scalar
        pub fn dot(a: *const VectorN, b: *const VectorN) ctx {
            return @as(ctx, @reduce(.Add, a.v * b.v));
        }

        ///Returns the square of the magnitude of the vector
        pub inline fn magnitude_squared(a: *const VectorN) ctx {
            return @as(ctx, @reduce(.Add, a.v * a.v));
        }

        ///Returns the magnitude of the vector
        /// uses magnitude_squared fn
        pub inline fn magnitude(a: *const VectorN) ctx {
            return @as(ctx, @sqrt(magnitude_squared(a)));
        }

        ///Returns a normalization of vector a
        /// i.e. vector / magnitude(vector)
        pub inline fn normalize(a: *const VectorN) VectorN {
            return a.div(&VectorN.splat(a.magnitude()));
        }

        ///Returns distance between vector a and vector b
        pub inline fn dist(a: *const VectorN, b: *const VectorN) ctx {
            return @as(ctx, @sqrt(b.sub(a).magnitude_squared()));
        }

        ///Returns the inverse of the vector
        /// i.e. 1 / vector
        pub inline fn inverse(a: *const VectorN) VectorN {
            return VectorN{ .v = VectorN.splat(1).v / a.v };
        }

        ///Returns the negation of the vector
        /// i.e. -1 * vector
        pub inline fn negate(a: *const VectorN) VectorN {
            return VectorN{ .v = a.mulScalar(-1).v };
        }

        pub fn disp(self: *const VectorN) void {
            for(0..VectorN.dim) |i| {
                if (i == VectorN.dim - 1) {
                    std.debug.print("{d}\n", .{self.v[i]});
                } else {
                    std.debug.print("{d}, ", .{self.v[i]});
                }
            }
        }

        pub inline fn update(self: *const VectorN, k: u64, c: ctx) VectorN {
            var new_vec = self.v;
            new_vec[k] = c;
            return VectorN{ .v = new_vec };
        }

        pub inline fn idx() VectorN {
            var id_vec = VectorN.splat(0).v;
            id_vec[0] = 1;
            return VectorN { .v = id_vec };
        }

        pub inline fn idy() VectorN {
            var id_vec = VectorN.splat(0).v;
            id_vec[1] = 1;
            return VectorN { .v = id_vec };
        }

        pub inline fn idz() VectorN {
            var id_vec = VectorN.splat(0).v;
            id_vec[2] = 1;
            return VectorN { .v = id_vec };
        }

        pub inline fn idw() VectorN {
            var id_vec = VectorN.splat(0).v;
            id_vec[3] = 1;
            return VectorN { .v = id_vec };
        }

        pub inline fn idn(n: u64) VectorN {
            var id_vec = VectorN.splat(0).v;
            id_vec[n] = 1;
            return VectorN { .v = id_vec };
        }
    };
}

// Easy Aliases for normal, half, double precision floats

pub const Vec2 = Vector2(f32);
pub const Vec3 = Vector3(f32);
pub const Vec4 = Vector4(f32);

pub const Vec2h = Vector2(f16);
pub const Vec3h = Vector3(f16);
pub const Vec4h = Vector4(f16);

pub const Vec2d = Vector2(f64);
pub const Vec3d = Vector3(f64);
pub const Vec4d = Vector4(f64);

pub const vec2 = Vec2.init;
pub const vec3 = Vec3.init;
pub const vec4 = Vec4.init;

pub const vec2h = Vec2h.init;
pub const vec3h = Vec3h.init;
pub const vec4h = Vec4h.init;

pub const vec2d = Vec2d.init;
pub const vec3d = Vec3d.init;
pub const vec4d = Vec4d.init;

test "basic impl" {

    const printf = std.debug.print;

    const p0 = Vec2.init(3.0, 4.0);
    const p1 = Vec2.init(2.0, 5.0);
    printf("Vector Testing:\n", .{});
    printf("{d}, {d}\n", .{p1.x(), p1.y()});

    const dist = p0.dist(&p1);
    printf("Distance from origin: {d}\n", .{dist});

    const inv = p1.inverse();
    printf("Inverse: {d}, {d}\n", .{inv.x(), inv.y()});

    const neg = p1.negate();
    printf("Negation: {d}, {d}\n", .{neg.x(), neg.y()});



    const p2 = Vec3.init(10.0, 22.0, 33.0);
    const p3 = Vec3.init(2.0, 5.0, 3.0);
    printf("{d}, {d}, {d}\n", .{p3.x(), p3.y(), p3.z()});

    const dist2 = p2.dist(&p3);
    printf("Distance from origin: {d}\n", .{dist2});

    const inv2 = p3.inverse();
    printf("Inverse: {d}, {d}, {d}\n", .{inv2.x(), inv2.y(), inv2.z()});

    const neg2 = p3.negate();
    printf("Negation: {d}, {d}, {d}\n", .{neg2.x(), neg2.y(), neg2.z()});



    const p4 = Vec4.init(10.0, 22.0, 33.0, 40.0);
    const p5 = Vec4.init(2.0, 5.0, 3.0, 10.0);
    printf("{d}, {d}, {d}, {d}\n", .{p5.x(), p5.y(), p5.z(), p5.w()});

    const dist3 = p4.dist(&p5);
    printf("Distance from origin: {d}\n", .{dist3});

    const inv3 = p5.inverse();
    printf("Inverse: {d}, {d}, {d}, {d}\n", .{inv3.x(), inv3.y(), inv3.z(), inv3.w()});

    const neg3 = p5.negate();
    printf("Negation: {d}, {d}, {d}, {d}\n", .{neg3.x(), neg3.y(), neg3.z(), neg3.w()});

    const pg = VectorGen(f32, 5).init([5]f32 {1.0, 2.0, 3.0, 4.0, 5.0});
    pg.disp();
    

    const mag4 = pg.magnitude();
    printf("Magnitude: {d}\n", .{mag4});

    const inv4 = pg.inverse();
    printf("Inverse: {d}, {d}, {d}, {d}, {d}\n", .{inv4.v[0], inv4.v[1], inv4.v[2], inv4.v[3], inv4.v[4]});

    const neg4 = pg.negate();
    printf("Negation: {d}, {d}, {d}, {d}, {d}\n", .{neg4.v[0], neg4.v[1], neg4.v[2], neg4.v[3], neg4.v[4]});

    const norm4 = pg.negate();
    printf("Normalization: {d}, {d}, {d}, {d}, {d}\n", .{norm4.v[0], norm4.v[1], norm4.v[2], norm4.v[3], norm4.v[4]});

    const pg1 = pg.update(3, 200);
    pg1.disp();
    const VG = VectorGen(f32, 5);
    VG.idx().disp();
    VG.idy().disp();
    VG.idz().disp();
    VG.idw().disp();
    VG.idn(4).disp();
}