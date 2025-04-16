// -----------------------------------------------------------------------------------//
//                                  Matrix Primatives                                 //
// -----------------------------------------------------------------------------------//
pub const std = @import("std");
pub const V = @import("vector.zig");

const Vector2 = V.Vector2;
const Vector3 = V.Vector3;
const Vector4 = V.Vector4;
const VectorGen = V.VectorGen;

pub const COLUMN_MAJOR: bool = true;

//pub const Matrix_2_2 = if (COLUMN_MAJOR) Matrix_2_2_Col else Matrix_2_2_Row;

//pub const Matrix_2_2 = Matrix_2_2_Col;

pub const Matrix = Matrix_N_N_Col;
pub const Matrix2x2 = Matrix(f32, 2, 2);
pub const Matrix3x3 = Matrix(f32, 3, 3);
pub const Matrix4x4 = Matrix(f32, 4, 4);

pub fn Matrix_N_N_Col(comptime ctx: type, comptime R: u64, comptime C: u64) type {
    return struct {
        m: [cols]Vector,

        pub const cols = C;
        pub const rows = R;

        pub const Vector = if (rows == 2 and cols == 2) Vector2(ctx) else if (rows == 3 and cols == 3) Vector3(ctx) else if (rows == 4 and cols == 4) Vector4(ctx) else VectorGen(ctx, rows);
        pub const Self = @This();

        pub fn init(t: [rows]Vector) Self {
            switch (cols) {
                2 => {
                    return Self{ .m = [cols]Vector{
                        Vector.init(t[0].v[0], t[1].v[0]),
                        Vector.init(t[0].v[1], t[1].v[1]),
                    } };
                },

                3 => {
                    return Self{ .m = [cols]Vector{
                        Vector.init(t[0].v[0], t[1].v[0], t[2].v[0]),
                        Vector.init(t[0].v[1], t[1].v[1], t[2].v[1]),
                        Vector.init(t[0].v[2], t[1].v[2], t[2].v[2]),
                    } };
                },

                4 => {
                    return Self{ .m = [cols]Vector{
                        Vector.init(t[0].v[0], t[1].v[0], t[2].v[0], t[3].v[0]),
                        Vector.init(t[0].v[1], t[1].v[1], t[2].v[1], t[3].v[1]),
                        Vector.init(t[0].v[2], t[1].v[2], t[2].v[2], t[3].v[2]),
                        Vector.init(t[0].v[3], t[1].v[3], t[2].v[3], t[3].v[3]),
                    } };
                },
                
                else => {
                    var tmp:[rows]Vector = undefined;

                    for (0..cols) |c| {
                        var col_vals: [cols]ctx = undefined;
                        for (0..rows) |r| {
                            col_vals[r] = t[r].v[c];
                        }
                        tmp[c] = (Vector.init(col_vals));
                    }
                    return Self{ .m = tmp };
                },
            }
        }

        pub inline fn col(self: *const Self, i: u64) Vector {
            return self.m[i];
        }

        pub inline fn row(self: *const Self, i: u64) Vector {
            var vals: [cols]ctx = undefined;
            for (0..cols) |j| {
                vals[j] = self.m[j].v[i];
            }
            switch (rows) {
                inline 2 => {
                    return Vector.init(vals[0], vals[1]);
                },
                inline 3 => {
                    return Vector.init(vals[0], vals[1], vals[2]);
                },
                inline 4 => {
                    return Vector.init(vals[0], vals[1], vals[2], vals[3]);
                },
                else => {
                    return Vector.init(vals);
                },
            }
        }

        pub fn disp(self: *const Self) void {
            std.debug.print("{d}x{d} Matrix:\n", .{rows, cols});
            for (0..cols) |c| {
                self.m[c].disp();
            }
            std.debug.print("\n", .{});
        }

        pub inline fn transpose(self: *const Self) Self {
            const m = self.m;
            return Self.init(m);
        }

        pub fn indentity(self: *const Self) Self {
            _ = self;
            return indentityMat();
        }

        pub fn indentityMat() Self {
            switch (rows) {
                2 => {
                    return Self.init([2]Vector {
                            Vector.init(1, 0),
                            Vector.init(0, 1),
                        });
                },

                3 => {
                    return Self.init([3]Vector {
                        Vector.init(1, 0, 0),
                        Vector.init(0, 1, 0),
                        Vector.init(0, 0, 1),
                    });
                },

                4 => {
                    return Self.init([4]Vector {
                        Vector.init(1, 0, 0, 0),
                        Vector.init(0, 1, 0, 0),
                        Vector.init(0, 0, 1, 0),
                        Vector.init(0, 0, 0, 1),
                    });
                },

                else => {
                    var vec_list: [rows]Vector = undefined;
                    for (0..rows) |r| {
                        var val_list: [cols]ctx = undefined;
                        for (0..cols) |c| {
                            if (r == c) {
                                val_list[c] = 1;
                            } else {
                                val_list[c] = 0;
                            }
                        }
                        vec_list[r] = Vector.init(val_list);
                    }
                    return Self.init(vec_list);
                },
            }
        }

        pub inline fn get(self: *const Self, r: u64, c: u64) ctx {
            return self.m[c-1].v[r-1];
        }

        pub fn splat(c: ctx) Self {
            switch (rows) {
                2 => {
                    return Self.init([2]Vector {
                            Vector.splat(c),
                            Vector.splat(c),
                        });
                },

                3 => {
                    return Self.init([3]Vector {
                        Vector.splat(c),
                        Vector.splat(c),
                        Vector.splat(c),
                    });
                },

                4 => {
                    return Self.init([4]Vector {
                        Vector.splat(c),
                        Vector.splat(c),
                        Vector.splat(c),
                        Vector.splat(c),
                    });
                },

                else => {
                    var vec_list: [rows]Vector = undefined;
                    for (0..rows) |r| {
                        vec_list[r] = Vector.splat(c);
                    }
                    return Self.init(vec_list);
                },
            }
        }

        fn det2(self: *const Self) ctx {
            return (self.row(0).v[0] * self.row(1).v[1]) - (self.row(0).v[1] * self.row(1).v[0]);
        }

        fn det3(self: *const Self) ctx {
            const a11 = self.get(1, 1);
            const a12 = self.get(1, 2);
            const a13 = self.get(1, 3);

            const a21 = self.get(2, 1);
            const a22 = self.get(2, 2);
            const a23 = self.get(2, 3);

            const a31 = self.get(3, 1);
            const a32 = self.get(3, 2);
            const a33 = self.get(3, 3);

            return (a11 * (a22 * a33 - a23  * a32)) - (a12 * (a21 * a33 - a23 * a31)) + (a13 * (a21 * a32 - a22 * a31));
        }

        inline fn det4(self: *const Self) ctx {
            const a11 = self.get(1, 1);
            const a12 = self.get(1, 2);
            const a13 = self.get(1, 3);
            const a14 = self.get(1, 4);
            

            const a21 = self.get(2, 1);
            const a22 = self.get(2, 2);
            const a23 = self.get(2, 3);
            const a24 = self.get(2, 4);

            const a31 = self.get(3, 1);
            const a32 = self.get(3, 2);
            const a33 = self.get(3, 3);
            const a34 = self.get(3, 4);

            const a41 = self.get(4, 1);
            const a42 = self.get(4, 2);
            const a43 = self.get(4, 3);
            const a44 = self.get(4, 4);

            return (
                (a11 * ( (a22 * (a33*a44 - a34*a43)) - (a23 * (a32*a44 - a34*a42)) + (a24 * (a32*a43 - a33*a42)) )) - 
                (a12 * ( (a21 * (a33*a44 - a34*a43)) - (a23 * (a31*a44 - a34*a41)) + (a24 * (a31*a43 - a33*a41)) )) +
                (a13 * ( (a21 * (a32*a44 - a34*a42)) - (a22 * (a31*a44 - a34*a41)) + (a24 * (a31*a42 - a32*a41)) )) -
                (a14 * ( (a21 * (a32*a43 - a33*a42)) - (a22 * (a31*a43 - a33*a41)) + (a23 * (a31*a42 - a32*a41)) ))
            );
        }

        pub fn det(self: *const Self) ctx {
            switch(rows) {
                2 => {
                    return det2(self);
                },

                3 => {
                    return det3(self);
                },

                4 => {
                    return det4(self);
                },

                else => {
                    @compileError("Determinant not implemented for this size matrix\n");
                },
            }
        }

        // pub fn LU_Decomposition(self: *const Self) [2]Self {
        //     var L = Self.indentityMat();
        //     var U = self.*;

        //     const A = self.*;

        //     for (0..rows) |k| {
        //         // Upper Triangular Matrix U
        //         for (0..rows) |j| {
        //             var sum: ctx = 0;
        //             if (j >= k){
        //                 for (0..cols) |i| {
        //                     sum += L.row(k).v[i] * U.row(i).v[j];
        //                 }
        //                 U.m[k].v[j] = A.row(k).v[j] - sum;
        //             }
        //         }

        //         // Lower Triangular Matrix L
        //         for (k..rows) |j| {
        //             var sum: ctx = 0;
        //             if (j > k) {
        //                 for (0..cols) |i| {
        //                     sum += L.row(i).v[j] * U.row(j).v[k];
        //                 }
        //                 L.m[j].v[k] = (A.row(j).v[k] - sum) / U.row(k).v[k];
        //             }
        //         }
        //     }

        //     return [_]Self {L, U};
        // }

        pub fn LU_Decomposition(self: *const Self) [2]Self {
            var L = Self.indentityMat();
            //var U = Self.splat(0);
            const A = self.*;
            var U = Self{ .m = A.m };
            const n = rows;

            for (0..n) |k| {
                for (k+1..n) |i| {
                    if (i > k) {
                        const Lik = A.m[k].v[i] / U.m[k].v[k];
                        L.m[k].v[i] = Lik;
                    }
                    for (k+1..n) |j| {
                        U.m[j].v[i] = U.m[j].v[i] - (L.m[k].v[i] * U.m[j].v[k]);
                    }
                }                
            }
            return [_]Self {L, U};
        }
    };
}

pub fn Matrix_N_N_Flat(comptime ctx: type, comptime size: u64) type {
    _ = ctx;
    _ = size;
    return struct {
        
    };
}

test "vectors and matricies" {

    const vec = @import("vector.zig");

    const Vec2 = vec.Vec2;
    const Vec3 = vec.Vec3;
    const Vec4 = vec.Vec4;



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
    //printf("{}\n", .{pg});
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

    printf("\n\nMatrix Testing:\n", .{});

    const m1 = Matrix2x2.init([2]Vec2 {p0, p1});
    //printf("{}\n", .{m1});
    m1.disp();

    const m2 = Matrix3x3.init([3]Vec3 {p2, p3, Vec3.init(9.0, 12.0, 15.0)});
    m2.col(0).disp();

    const m3 = Matrix4x4.init([4]Vec4 {p4, p5, Vec4.init(9.0, 12.0, 15.0, 18.0), Vec4.init(1.0,2.0,3.0,4.0)});
    m3.row(1).disp();

    const Vector5 = VectorGen(f32, 5);
    const v0 = Vector5.init([_]f32 {4, 3, 2, 1, 5});
    const v1 = Vector5.init([_]f32 {8, 7, 6, 5, 4});
    const v2 = Vector5.init([_]f32 {4, 8, 7, 6, 5});
    const v3 = Vector5.init([_]f32 {6, 4, 8, 7, 6});
    const v4 = Vector5.init([_]f32 {5, 6, 4, 8, 7});
    const m5 = Matrix(f32, 5, 5).init([_]Vector5 {v0, v1, v2, v3, v4});
    m5.col(2).disp();

    m1.disp();
    m1.transpose().disp();
    m1.indentity().disp();
    printf("Det: {d}\n", .{m1.det()});
    m2.disp();
    m2.transpose().disp();
    m2.indentity().disp();
    printf("Det: {d}\n", .{m2.det()});
    m3.disp();
    m3.transpose().disp();
    m3.indentity().disp();
    printf("Det: {d}\n", .{m3.det()});
    m5.disp();
    m5.transpose().disp();
    m5.indentity().disp();

    const res = m5.LU_Decomposition();
    res[0].disp();
    res[1].disp();
}