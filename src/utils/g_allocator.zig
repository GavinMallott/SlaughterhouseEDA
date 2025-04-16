const std = @import("std");
const os = std.os;

pub const GavinsPhuckingAllocator = struct {
    slab_allocator: SlabAllocator,
    free_list_allocator: FreeListAllocator,
    page_allocator: PageAllocator,

    pub fn init(ally: std.mem.Allocator) !GavinsPhuckingAllocator {
        return GavinsPhuckingAllocator{
            .slab_allocator = try SlabAllocator.init(ally),
            .free_list_allocator = try FreeListAllocator.init(),
            .page_allocator = try PageAllocator.init(),
        };
    }

    pub fn allocator(self: *GavinsPhuckingAllocator) std.mem.Allocator {
        _ = self;
        const vtable: std.mem.Allocator.VTable = .{
            .alloc = allocFn,
            .resize = resizeFn,
            .free = freeFn,
        };
        return std.mem.Allocator{
            .vtable = vtable,
        };
    }

    fn allocFn(ctx: *anyopaque, len: usize, log2_align: u8, ret_addr: usize) ?[*]u8 {
        _ = ret_addr;
        const self: *GavinsPhuckingAllocator = @ptrCast(@alignCast(ctx));

        if (len <= 256) {
            return self.slab_allocator.alloc(len, log2_align);
        } else if (len <= 64 * 1024) {
            return self.free_list_allocator.alloc(len, log2_align);
        } else {
            return self.page_allocator.alloc(len, log2_align);
        }
    }

    fn resizeFn(ctx: *anyopaque, old_mem: [*]u8, old_len: usize, new_len: usize, log2_align: u8, ret_addr: usize) ?[*]u8 {
        _ = ret_addr;
        const self: *GavinsPhuckingAllocator = @ptrCast(@alignCast(ctx));

        if (new_len <= 256) {
            return self.slab_allocator.resize(old_mem, old_len, new_len, log2_align);
        } else if (new_len <= 64 * 1024) {
            return self.free_list_allocator.resize(old_mem, old_len, new_len, log2_align);
        } else {
            return self.page_allocator.resize(old_mem, old_len, new_len, log2_align);
        }
    }

    fn freeFn(ctx: *anyopaque, ptr: [*]u8, len: usize, log2_align: u8, ret_addr: usize) void {
        _ = ret_addr;
        const self: *GavinsPhuckingAllocator = @ptrCast(@alignCast(ctx));

        if (len <= 256) {
            self.slab_allocator.free(ptr, len, log2_align);
        } else if (len <= 64 * 1024) {
            self.free_list_allocator.free(ptr, len, log2_align);
        } else {
            self.page_allocator.free(ptr, len, log2_align);
        }
    }
};

pub const SlabAllocator = struct {
    buffer: []u8,
    free_list: ?[*]u8,

    pub fn init(allocator: std.mem.Allocator) !SlabAllocator {
        const buffer = try allocator.alloc(u8, 256 * 1024);
        return SlabAllocator{.buffer = buffer, .free_list = null};
    }

    pub fn alloc(self: *SlabAllocator, len: usize, log2_align: u8) ?[*]u8 {
        _ = log2_align;
        if (self.free_list) |node| {
            self.free_list = @ptrCast(@alignCast(node));
            return node;
        }

        return self.buffer.ptr[0..len];
    }

    pub fn free(self: *SlabAllocator, ptr: [*]u8, len: usize, log2_align: u8) void {
        _ = len;
        _ = log2_align;
        self.free_list = ptr;
    }
};

pub const FreeListAllocator = struct {
    free_list: ?*Node,

    const Node = struct {
        next: ?*Node,
        size: usize,
    };

    pub fn init() !FreeListAllocator {
        return FreeListAllocator{ .free_list = null };
    }

    pub fn alloc(self: *FreeListAllocator, len: usize, log2_align: u8) ?[*]u8 {
        _ = log2_align;

        var prev: ?*Node = null;
        var node = self.free_list;

        while (node) |n| {
            if (n.size >= len) {
                if (prev) |p| {
                    p.next = n.next;
                } else {
                    self.free_list = n.next;
                }
                return @ptrCast(n);
            }
            prev = n;
            node = n.next;
        }

        return null;
    }

    pub fn free(self: *FreeListAllocator, ptr: [*]u8, len: usize, log_align: u8) void {
        _ = log_align;
        var node: *Node = @ptrCast(@alignCast(ptr));
        node.size = len;
        node.next = self.free_list;
        self.free_list = node;
    }
};

pub const PageAllocator = struct {
    pub fn init() !PageAllocator {
        return PageAllocator{};
    }

    pub fn alloc(self: *PageAllocator, len: usize, log2_align: u8) ?[*]u8 {
        _ = self;
        _ = log2_align;

        if (os.tag == .windows) {
            return @ptrCast(try os.windows.VirtualAlloc(
                null, len, os.windows.MEM.COMMIT | os.windows.MEM.RESERVE, os.windows.PAGE.READWRITE
            ));
        } else {
            return @ptrCast(try os.linux.mmap(
                null, len, os.linux.PROT.READ | os.linux.PROT.WRITE, os.linux.MAP.PRIVATE | os.linux.MAP.ANONYMOUS, -1, 0
            ));
        } 
    }

    pub fn free(self: *PageAllocator, ptr: [*]u8, len: usize, log2_align: u8) void {
        _ = self;
        _ = log2_align;
        if (os.tag == .windows) {
            _ = os.windows.VirtualFree(ptr, 0, os.windows.MEM.RELEASE);
        } else {
            _ = os.linux.munmap(ptr[0..len], len) catch {};
        }
    }
};

test "basic" {
    var gpa = try GavinsPhuckingAllocator.init(std.heap.page_allocator);
    var allocator = gpa.allocator();

    const ptr = try allocator.alloc(u8, 128);
    std.debug.print("Allocated 128 bytes at {}\n", .{ptr});

    allocator.free(ptr, 128);
    std.debug.print("Freed memory\n", .{});
}