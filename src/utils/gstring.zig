const std = @import("std");

const printf = std.debug.print;
pub inline fn prints(s: []const u8) void {
    std.debug.print("{s}\n", .{s});
}

fn computeLPSArray(pattern: []const u8, lps: []usize) void {
    var len: usize = 0;
    lps[0] = 0;
    var i: usize = 1;
    while (i < pattern.len) {
        if (pattern[i] == pattern[len]) {
            len += 1;
            lps[i] = len;
            i += 1;
        } else {
            if (len != 0) {
                len = lps[len-1];
            } else {
                lps[i] = 0;
                i += 1;
            }
        }
    }
}

pub fn KMPSearch(text: []const u8, pattern: []const u8) ?usize {
    const lps = std.heap.page_allocator.alloc(usize, pattern.len) catch unreachable;
    defer std.heap.page_allocator.free(lps);

    computeLPSArray(pattern, lps);

    var i: usize = 0;
    var j: usize = 0;

    while (i < text.len) {
        if (pattern[j] == text[i]) {
            i += 1;
            j += 1;
        }
        if (j == pattern.len) {
            return i - j;
        } else if (i < text.len and pattern[j] != text[i]) {
            if (j != 0) {
                j = lps[j - 1];
            } else {
                i += 1;
            }
        }
    }
    return null;
}

test "Knuth-Morris-Pratt Algorithm" {
    const text = "ABABDABACDABABCABAB";
    const pattern = "ABABCABAB";

    if (KMPSearch(text, pattern)) |idx| {
        printf("Pattern found at index: {}.\n", .{idx});
    } else {
        printf("Pattern not found.\n", .{});
    }
}

test "Iterate over string" {
    const s = "hello";
    for (s) |char| {
        std.debug.print("{c} ", .{char}); // Output: h e l l o
    }
    printf("\n", .{});
}

test "Check existence of substring" {
    const hw = "hello world";
    const s = "hello";
    const contains: bool = std.mem.indexOf(u8, hw, s) != null;
    printf("Contains 'hello': {}\n", .{contains});
}

test "Reverse string" {
    const r = "bonjour";
    var reversed: [r.len]u8 = undefined;
    for (r, 0..) |char, i| {
        reversed[r.len - i - 1] = char;
    }
    printf("Reversed: {s}\n", .{reversed});
}

test "Concatenate strings" {
    const s1 = "hello";
    const s2 = " world";
    var result: [s1.len + s2.len]u8 = undefined;
    std.mem.copyForwards(u8, result[0..s1.len], s1);
    std.mem.copyForwards(u8, result[s1.len..], s2);
    printf("Concatenated: {s}\n", .{result}); // Output: hello world
}

test "Palindrome check" {
    //const s = "racecar";
    const s = "cactus";

    var is_palindrome = true;
    var i: usize = 0;

    while(i < s.len / 2) : (i += 1) {
        if (s[i] != s[s.len - i - 1]) {
            is_palindrome = false;
            break;
        }
    }
    printf("Is palindrome: {}\n", .{is_palindrome});
}

test "replace substrings" {
    const s = "hello world";
    const old = "world";
    const new = "zig";

    var result: [s.len + new.len - old.len]u8 = undefined;
    const index = std.mem.indexOf(u8, s, old).?;
    std.mem.copyForwards(u8, result[0..index], s[0..index]);
    std.mem.copyForwards(u8, result[index..][0..new.len], new);
    std.mem.copyForwards(u8, result[index + new.len ..], s[index + old.len ..]);

    printf("Result: {s}\n", .{result}); // Output: hello zig
}

pub const BigString = struct {
    str: std.ArrayList(u8),
    size: usize,

    ally: std.mem.Allocator,

    pub const StrConfig = struct {
        seperator: []const u8 = "",
        add_newline: bool = false,
    };

    const Self = @This();

    pub fn init(ally: std.mem.Allocator, val: []const u8) Self {
        var strlist = std.ArrayList(u8).init(ally);

        for (val) |c| {
            strlist.append(c) catch unreachable;
        }
        return Self{
            .str = strlist,
            .size = strlist.items.len,
            .ally = ally,
        };
    }

    pub fn deinit(self: *Self) void {
        self.str.deinit();
    }

    pub fn print(self: *Self) void {
        for (self.str.items) |c| {
            printf("{c}", .{c});
        }
        printf("\n", .{});
    }

    pub fn append(self: *Self, attach: []const u8, opt: StrConfig) void {
        for (opt.seperator) |c2| {
            self.str.append(c2) catch unreachable;
        }
        for (attach) |c| {
            self.str.append(c) catch unreachable;   
        }
        if (opt.add_newline) {
            self.append("\n", .{});
        }
    }

    pub fn has_substring(self: *Self, target: []const u8) ?usize {        
        return std.mem.indexOf(u8, self.str.items, target);
    }

    pub fn has_char(self: *Self, target: u8) ?usize {
        for (self.str.items, 0..) |c, idx| {
            if (c == target) {
                return idx;
            }
        }
        return null;
    }

    pub fn words(self: *Self) std.ArrayList([]const u8) {
        var wordlist = std.ArrayList([]const u8).init(self.ally);

        var wl = std.mem.splitSequence(u8, self.str.items, " ");
        while (wl.next()) |word|{
            wordlist.append(word) catch unreachable;
        }
        return wordlist;
    }

    pub fn has_word(self: *Self, target: []const u8) ?usize {
        var wl = self.words();
        defer wl.deinit();

        for (wl.items, 0..) |word, idx| {
            if (std.mem.eql(u8, word, target)) {
                return idx;
            }
        }
        return null;
    }

    pub fn word_occurance(self: *Self, target: []const u8) ?usize {
        var occ: usize = 0;
        var wl = self.words();
        defer wl.deinit();

        for (wl.items) |word| {
            if (std.mem.eql(u8, word, target)) occ += 1;
        }
        if (occ > 0) return occ;
        return null;
    }

    pub fn substring_occurance(self: *Self, target: []const u8) ?usize {
        var occ: usize = 0;
        var last_idx: usize = 0;
        const last_slice = self.str.items[0..];
        printf("{s}\n",.{self.str.items});

        var r = std.mem.indexOf(u8, last_slice, target);

        while(true){
            occ += 1;
            last_idx = r.? + target.len;
            printf("Last IDX Found: {d}\n", .{r.?});
            const next_slice = self.str.items[last_idx..];
            printf("{s}\n", .{next_slice});
            if (last_idx >= self.str.items.len) break;
            const next_r = std.mem.indexOf(u8, next_slice, target);
            if (next_r == null) break;
            r = next_r.?;
        }

        if (occ > 0) return occ;
        return null;
        
    }

    pub fn char_occurance(self: *Self, target: u8) ?usize {
        var occ: usize = 0;
        for (self.str.items) |c| {
            if (c == target) occ += 1;
        }

        if (occ > 0) return occ;
        return null;
    }
};

test "BigString" {
    printf("Big String Test: \n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer _ = gpa.deinit();

    const gstring = BigString;

    var a = gstring.init(ally, "Hello World");
    defer a.deinit();

    a.print();
    const b = "and Hello Gavin";
    a.append(b, .{.seperator = " ", .add_newline = true});
    a.append("Lorum", .{});
    a.append("Ipsum\n", .{.seperator = " "});
    a.print();

    if(a.has_substring("Lorum Ipsum") != null) {
        printf("Found substring 'Lorum Ipsum' at pos: {d}\n", .{a.has_substring("Lorum Ipsum").?});
    }
    const li: []const u8 = "Lorum Ipsum";
    for (li) |c| {
        if (a.has_char(c) != null) {
            printf("Found char {c} at pos: {d}\n", .{c, a.has_char(c).?});
        }
    }
    const word = "Hello";
    printf("Word: {s} at pos: {d}\n", .{word, a.has_word(word).?});
    printf("Word: {s} occurred {d} times\n",  .{word, a.word_occurance(word).?});
    printf("Substring {s} occurred {d} times\n", .{word, a.substring_occurance(word).?});
    printf("Char e occured {d} times\n", .{a.char_occurance(101).?});
}