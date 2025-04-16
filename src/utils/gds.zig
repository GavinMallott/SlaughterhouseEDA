const std = @import("std");

pub const printf = std.debug.print;

pub fn prints(s: []const u8) void {
    printf("{s}\n", .{s});
}

test "prints" {
    printf("Hello World\n", .{});
    prints("Hello World");
}