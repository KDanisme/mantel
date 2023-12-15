// const gvc = @cImport({
//     @cInclude("graphviz/gvc.h");
// });
const std = @import("std");
const cli = @import("./cli/main.zig");
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    try cli.main(allocator);
}

test {
    @import("std").testing.refAllDecls(@This());
}
