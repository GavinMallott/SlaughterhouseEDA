const std = @import("std");
const math = std.math;

const Polynomial = @This();


base: Atom,
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


pub const PolyConfig = struct {
    base: Atom = .{.base_var = .x},
    coef: Atom = .{.real_val = 1},
    power: Atom = .{.real_val = 1},
    constant: Atom = .{.real_val = 0},
    function: ?AppliedFunction = null,
};

pub const Atom = union(enum(u3)) {
    base_var: BaseVariable,
    real_val: f64,
    complex_val: c64,
    poly: *Polynomial,

    pub fn disp(self: @This()) void {
        switch(self){
            .base_var => {
                const bv = @tagName(self.base_var);
                printf("{s}", .{bv});
            },
            .real_val => {
                printf("{d}", .{self.real_val});
            },
            .complex_val => {},
            .poly => {
                self.poly.disp(.{.newline = false, .paren = true});
            },
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
};

pub fn init(config: PolyConfig) Polynomial {
    return Polynomial{
        .base = config.base,
        .coef = config.coef,
        .power = config.power,
        .constant = config.constant,
        .function = config.function,
    };
}

pub fn evaluate(self: Polynomial, bv: BaseVariable, val: Atom) Polynomial {
    var new_base: Atom = undefined;
    var new_coef: Atom = undefined;
    var new_power: Atom = undefined;
    var new_constant: Atom = undefined;

    switch(self.base){
        .poly => {
            new_base = .{.poly = self.base.poly.evaluate(bv, val)};
        },
        .base_var => {

            switch(self.power){
                .poly => {
                    new_power = .{.poly = self.power.poly.evaluate(bv, val)};
                },
                .base_var => {
                    if (self.power.base_var == bv) {
                        new_power = .{.real_val = 1};
                        new_base = .{.real_val = math.pow(f64, val, self.power.real_val)};
                    } else {
                        new_power = self.power;
                    }
                },
                .real_val => {
                    switch(self.coef){
                        .poly => {
                            new_coef = .{.poly = self.coef.poly.evaluate(bv, val)};
                        },
                        .base_var => {
                            if (self.coef.base_var == bv) {
                                new_coef = .{.real_val = 1};
                                new_base = self.coef.real_val * val;
                            } else {
                                new_coef = self.coef;
                            }
                        },
                        .real_val => {
                            if (self.base.base_var == bv) {
                                new_base = self.coef.real_val * val;
                            } else {
                                new_coef = self.coef;
                                new_base = self.base;
                            }

                            switch(self.constant){
                                .poly => {
                                    new_constant = .{.poly = self.constant.poly.evaluate(bv, val)};
                                },
                                .base_var => {},
                                .real_val => {
                                    new_base.real_val += self.constant.real_val;
                                },
                                else => {},
                            }
                        },
                        else => {},
                    }
                },
                else => {},
            }
        },
        .real_val => {},
        else => {},
    }

    

    switch(self.power){
        .poly => {},
        .base_var => {

        },
        else => {},
    }

    switch(self.constant){
        .poly => {},
        .base_var => {

        },
        else => {},
    }

    
    const retP = PolyConfig{
        .base = new_base,
        .coef = new_coef,
        .power = new_power,
        .constant = new_constant,
    };
    return Polynomial.init(retP);
}

pub fn disp(self: Polynomial, opt: DispOpt) void {
    if (opt.paren) prints("(");

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

    switch(self.coef) {
        .poly => {
            self.coef.disp();
            self.base.disp();

                // Power Printing
                switch (self.power) {
                    .poly => {},
                    .real_val => {
                        if (self.power.real_val == 1) {}
                        else {
                            prints("^");
                            self.power.disp();
                        }
                    },
                    else => {},
                }

                // Constant Printing
                switch(self.constant) {
                    .poly => {
                        self.constant.disp();
                    },
                    .real_val => {
                        if (self.constant.real_val == 0) {}
                        else if (self.constant.real_val < 0){
                            printf(" - {d}", .{self.constant.real_val * -1});
                        } else {
                            printf(" + {d}", .{self.constant.real_val});
                        }
                    },
                    else => {},
                }
        },
        .real_val => {
            if (self.coef.real_val == 0) {}
            else if (self.coef.real_val == 1 or self.coef.real_val == -1) {
                self.base.disp();

                // Power Printing
                switch (self.power) {
                    .poly => {
                        prints("^");
                        self.power.disp();
                    },
                    .real_val => {
                        if (self.power.real_val == 1) {}
                        else {
                            prints("^");
                            self.power.disp();
                        }
                    },
                    else => {},
                }

                // Constant Printing
                switch(self.constant) {
                    .poly => {
                        self.constant.disp();
                    },
                    .real_val => {
                        if (self.constant.real_val == 0) {}
                        else if (self.constant.real_val < 0){
                            printf(" - {d}", .{self.constant.real_val * -1});
                        } else {
                            printf(" + {d}", .{self.constant.real_val});
                        }
                    },
                    else => {},
                }
                
            } else {
                self.coef.disp();
                self.base.disp();

                // Power Printing
                switch (self.power) {
                    .poly => {
                        prints("^");
                        self.power.disp();
                    },
                    .real_val => {
                        if (self.power.real_val == 1) {}
                        else {
                            prints("^");
                            self.power.disp();
                        }
                    },
                    else => {},
                }

                // Constant Printing
                switch(self.constant) {
                    .poly => {
                        self.constant.disp();
                    },
                    .real_val => {
                        if (self.constant.real_val == 0) {}
                        else if (self.constant.real_val < 0){
                            printf(" - {d}", .{self.constant.real_val * -1});
                        } else {
                            printf(" + {d}", .{self.constant.real_val});
                        }
                    },
                    else => {},
                }
            }
        },
        else => {},
    }

    

    if (self.function != null) prints(")");
    if (opt.paren) prints(")");
    if (opt.newline) prints("\n");
}

test "atom" {
    const x = Polynomial.init(.{});
    const y = Polynomial.init(.{
        .base = .{.base_var = BaseVariable.y},
        .coef = .{.poly = @constCast(&x)},
        .power = .{.real_val = 2},
        .constant = .{.real_val = 0.5},
    });
    x.disp(.{});
    y.disp(.{});
    const z = Polynomial.init(.{
        .base = .{.base_var = .z},
        .power = .{.poly = @constCast(&y)},
        .coef = .{.real_val = 1},
        .constant = .{.real_val = 0},
        .function = .EXP,

    });
    z.disp(.{});
    const cont = Polynomial.init(.{
        .base = .{.real_val = 7}, 
        .coef = .{.real_val = 1}, 
        .constant = .{.real_val = 0}, 
        .function = null, 
        .power = .{.real_val = 1},
    });
    cont.disp(.{});
}


