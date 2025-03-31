const std = @import("std");

pub const Atom = []const u8; 




pub const PosId = struct {
    X: u64,
    Y: u64,
    ANGLE: ?u64,
};

pub const XY = struct {
    X: u64,
    Y: u64,
};

pub const Pts = struct {
    xy: []XY, 
};

pub const StrokeType = union(enum) {
    dash,
    dash_dot,
    dash_dot_dot,
    dot,
    default,
    solid,
};

pub const Color = struct {
    R: u8,
    G: u8,
    B: u8,
    A: u8,
};

pub const Stroke = struct {
    width: Atom,
    stype: StrokeType,
    color: Color,
};

pub const FSize = struct {
    height: Atom,
    width: Atom,
};

pub const Font = struct {
    face: ?Atom,
    size: FSize,
    thickness: ?Atom,
    bold: ?bool,
    italic: ?bool,
    line_spacing: ?Atom,
};

pub const RL = union(enum) {
    RIGHT,
    CENTER,
    LEFT,
};

pub const TB = union(enum) {
    TOP,
    CENTER,
    BOTTOM,
};

pub const Justify = struct {
    rl: ?RL = .CENTER,
    tb: ?TB = .CENTER,
    mirror: ?bool = false,
};

pub const Effects = struct {
    font: Font,
    justify: ?Justify = Justify{},
    hide: ?bool = false,
};
