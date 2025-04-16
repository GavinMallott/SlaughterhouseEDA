const std = @import("std");
const math = std.math;


pub const MObject = @This();

ctx: type,
vtable: VTable,
data: Data,

pub const MathType = enum(u8) {
    Scalar,
    Vector,
    Matrix,
    Polynomial,
    Expression,
    Symbol,
};

pub const Data = union(MathType) {
};

pub fn Scalar(comptime T: type) type {
    return struct {
        value: T,
    };
}

pub fn Polynomial(comptime T: type) type {
    return struct {
        coeffs: []T,
    };
}

pub const Symbol = struct {
    char: []const u8,
};

pub fn Expr(comptime T: type) type {
    return struct {
        lhs: *MObject,
        rhs: *MObject,
        op: Op,
    };
}

pub const Op = enum(u8) {
    Add,
    Subtract,
    Multiply,
    Divide,
    Modulus,
    Power,
    Derivative,
};

pub const VTable = struct {
    kind: MathType,
    evaluate: *const fn (*const anyopaque) ?anyopaque,
    toString: *const fn (*const anyopaque, *std.mem.Allocator) []const u8,
    deinit: *const fn (*anyopaque, *std.mem.Allocator) void,
};

