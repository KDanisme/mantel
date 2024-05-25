const std = @import("std");
const gvc = @cImport({
    @cInclude("graphviz/gvc.h");
});
const graph = @import("../ast/visualization.zig");
const ast = @import("../ast/main.zig");
const lexer = @import("../lexer.zig");
// const backend = @import("../backend/main.zig");
fn run(allocator: std.mem.Allocator, file_name: []const u8) !void {
    const result = try std.ChildProcess.exec(.{ .argv = &.{file_name}, .allocator = allocator });

    if (result.term.Exited != 0) {
        std.log.err("{s}", .{result.stderr});
        return error.FailedRun;
    }
    std.log.info("{s}", .{result.stdout});
}
pub fn main(allocator: std.mem.Allocator) !void {
    const args = try std.process.argsAlloc(allocator);
    const command = args[1];
    const filePath = args[2];

    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    const lexical_tokens = try lexer.get_lexical_tokens_from_file(allocator, file);

    if (std.mem.eql(u8, command, "tokens")) {
        try lexer.print_tokens(lexical_tokens);
        return;
    }
    const code_block = try ast.get_ast(allocator, lexical_tokens);

    if (std.mem.eql(u8, command, "ast")) {
        try graph.print_ast(code_block);
    } else if (std.mem.eql(u8, command, "build")) {
        // try build(allocator, code_block);
    } else if (std.mem.eql(u8, command, "run")) {
        // try build(allocator, code_block);
        // try run(allocator, "bla");
    }
}
