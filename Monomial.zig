const std = @import("std");
const math = std.math;

const Monomial = @This();

base: Base,
coef: Atom,
power: Atom,
constant: Atom,
function: ?AppliedFunction,

const printf = std.debug.print;

fn prints(s: []const u8) void {
    printf("{s}", .{s});
}

fn println(s: []const u8) void {
    printf("{s}\n", .{s});
} 

pub const DispOpt = struct {
    newline: bool = true,
    paren: bool = false,
};

pub const c64 = math.Complex(f64);

pub const Base = union(enum(u1)) {
    base_var: BaseVariable,
    poly: *const Monomial,

    pub fn disp(self: @This()) void {
        switch(self){
            .base_var => |bv| {
                if (bv != .NO_VAR) {
                    const sv = @tagName(bv);
                    printf("{s}", .{sv});
                }
            },
            .poly => |sub_mono| {
                sub_mono._disp(.{.newline = false, .paren = true});
            },
        }
    }

    pub fn has_bv(self: @This()) bool {
        switch (self) {
            .base_var => return true,
            else => return false,
        }
    }

    pub fn has_poly(self: @This()) bool {
        switch (self) {
            .poly => return true,
            else => return false,
        }
    }
};

pub const Atom = union(enum(u2)) {
    real_val: f64,
    complex_val: c64,
    poly: *const Monomial,

    pub fn disp(self: @This()) void {
        switch(self){
            .real_val => {
                printf("{d}", .{self.real_val});
            },
            .complex_val => {},
            .poly => |sub_mono| {
                sub_mono._disp(.{.newline = false, .paren = true});
            },
        }
    }

    pub fn has_real_val(self: @This()) bool {
        switch (self) {
            .real_val => return true,
            else => return false,
        }
    }

    pub fn has_complex_val(self: @This()) bool {
        switch (self) {
            .complex_val => return true,
            else => return false,
        }
    }

    pub fn has_poly(self: @This()) bool {
        switch (self) {
            .poly => return true,
            else => return false,
        }
    }
};

pub const AppliedFunction = union(enum(u8)) {
    EXP,

    SIN,
    COS,
    TAN,
    SEC,
    CSC,
    COT,

    ARCSIN,
    ARCCOS,
    ARCTAN,
    ARCSEC,
    ARCCSC,
    ARCCOT,

    LOG,
    LN,

    DRV,
    INT,

    SUM,
    PRD,

    LMT,

};

pub const BaseVariable = enum(usize) {
    X,
    Y,
    Z,
    a,
    b,
    c,
    x,
    y,
    z,
    n,

    NO_VAR,
};

pub const PolyConfig = struct {
    base: Base = .{.base_var = .NO_VAR},
    coef: Atom = .{.real_val = 1},
    power: Atom = .{.real_val = 1},
    constant: Atom = .{.real_val = 0},
    function: ?AppliedFunction = null,
};

pub fn init(config: PolyConfig) Monomial {
    return Monomial{
        .base = config.base,
        .coef = config.coef,
        .power = config.power,
        .constant = config.constant,
        .function = config.function,
    };
}

pub fn _disp_power(self: *const Monomial) void {
    switch (self.power) {
        .poly => {
            prints("^");
            self.power.disp();
        },
        .real_val => {
            if (self.power.real_val != 1) {
                prints("^");
                self.power.disp();
            }
        },
        else => {},
    }
}

pub fn _disp_constant(self: *const Monomial) void {
    switch(self.constant) {
        .poly => {
            prints(" + ");
            self.constant.disp();
        },
        .real_val => |rv| {
            var nobase: bool = false;
            if (self.base.has_bv()) {
                if (self.base.base_var == .NO_VAR) nobase = true;
            }

            if (nobase) {
                printf("{d}", .{rv});
            } else {
                if (rv < 0){
                    printf(" - {d}", .{rv * -1});
                } else if (rv > 0) {
                    printf(" + {d}", .{rv});
                }
            }

        },
        else => {},
    }
}

pub fn _disp_func(self: *const Monomial) void {
    if (self.function != null) {
        switch(self.function.?){
            .EXP => {
                prints("e^(");
            },
            .SIN => {
                prints("Sin(");
            },
            .COS => {
                prints("Cos(");
            },
            .TAN => {
                prints("Tan(");
            },
            .SEC => {
                prints("Sec(");
            },
            .CSC => {
                prints("Csc(");
            },
            .COT => {
                prints("Cot(");
            },
            .ARCSIN => {
                prints("ArcSin(");
            },
            .ARCCOS => {
                prints("ArcCos(");
            },
            .ARCTAN => {
                prints("ArcTan(");
            },
            .ARCSEC => {
                prints("ArcSec(");
            },
            .ARCCSC => {
                prints("ArcCsc(");
            },
            .ARCCOT => {
                prints("ArcCot(");
            },
            .LOG => {
                printf("Log{d}(", .{10});
            },
            .LN => {
                printf("Ln(", .{});
            },
            .DRV => {
                prints("Derivative(");
            },
            .INT => {
                prints("Integral(");
            },
            else => {},
        }
    }
}


pub fn _disp(self: *const Monomial, opt: DispOpt) void {
    if (opt.paren) prints("(");

    self._disp_func();

    switch(self.coef) {
        .poly => {
            self.coef.disp();
            self.base.disp();
            self._disp_power();
            self._disp_constant();
        },
        .real_val => |rv| {
            if (rv != 0) {
                if (rv == 1) {
                self.base.disp();
                } else if (rv == -1) {
                    prints("-");
                    self.base.disp();
                }
                self._disp_power();
            }

            self._disp_constant();
        },
        else => {},
    }

    if (self.function != null) prints(")");
    if (opt.paren) prints(")");
    if (opt.newline) prints("\n");
}

pub fn add(self: *const Monomial, op: *const Monomial) Monomial {
    return Monomial.init(.{
        .base = .{ .poly = self },
        .constant = .{ .poly = op },
    });

}

pub fn mul(self: *const Monomial, op: *const Monomial) Monomial {
    return Monomial.init(.{
        .base = .{ .poly = self },
        .coef = .{ .poly = op },
    });
}

pub fn disp(self: *const Monomial) void {
    self._disp(.{});
}

pub fn simplify(self: *const Monomial) Monomial {
    switch(self.base) {
        .base_var => |bv| {
            switch (self.power) {
                .real_val => |power_rv| {
                    switch (self.coef) {
                        .real_val => |coef_rv| {
                            switch (self.constant) {
                                .real_val => |const_rv| {
                                    return self.*;
                                },
                                .poly => |sub_const| {
                                    const simp_const = sub_const.simplify();
                                },
                                else => {},
                            }
                        },
                        .poly => |sub_coef| {
                            const simp_coef = sub_coef.simplify();
                        },
                        else => {},
                    }
                },
                .poly => |sub_pow| {
                    const simp_pow = sub_pow.simplify();
                },
                else => {},
            }
        },
        .poly => |sub_base| {
            const simp_base = sub_base.simplify();
        },
    }
}

test "atom" {
    const x = Monomial.init(.{
        .base = .{ .base_var = .x },
    });
    const y = Monomial.init(.{
        .base = .{.base_var = BaseVariable.y},
        .coef = .{.poly = &x},
        .power = .{.real_val = 2},
        .constant = .{.real_val = 0.5},
    });
    prints("Just X: ");
    x.disp();

    prints("X in Y: ");
    y.disp();

    const z = Monomial.init(.{
        .base = .{.base_var = .z},
        .power = .{.poly = &y},
        .coef = .{.real_val = 1},
        .constant = .{.real_val = 0},
        .function = .EXP,

    });
    prints("Exponential with sub mono: ");
    z.disp();

    const cont = Monomial.init(.{
        .coef = .{.real_val = 1}, 
        .constant = .{.real_val = 7}, 
        .function = null, 
        .power = .{.real_val = 1},
    });
    prints("Constant only: ");
    cont.disp();

    prints("No value (default): ");
    const nully = Monomial.init(.{});
    nully.disp();

    prints("Negative base var no coef: ");
    const p = Monomial.init(.{
        .base = .{.base_var = .X},
        .coef = .{ .real_val = -1 },
        .constant = .{ .poly = &x},
    });
    p.disp();

    prints("\nTry adding: ");
    const new_y = y.add(&cont);
    new_y.disp();

    prints("\nTry mulling: ");
    const new_y2 = y.mul(&cont);
    new_y2.disp();
}


