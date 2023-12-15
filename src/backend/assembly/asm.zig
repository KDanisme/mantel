const std = @import("std");
const ast = @import("ast.zig");

// const AsmBuilder = struct { static_data:  };

fn generate_function_name(allocator: std.mem.Allocator, function_definition: ast.FunctionDefinition) ![]const u8 {
    var array = std.ArrayList(u8).init(allocator);
    try array.appendSlice("fn_");
    try array.appendSlice(function_definition.name);
    return try array.toOwnedSlice();
}
fn generate_function_definition_asm(allocator: std.mem.Allocator, function_definition: ast.FunctionDefinition) ![]const u8 {
    var array = std.ArrayList(u8).init(allocator);
    try array.appendSlice(try std.fmt.allocPrint(allocator, "{s}:\n", .{try generate_function_name(allocator, function_definition)}));
    try array.appendSlice(try generate_code_block_asm(allocator, function_definition.code_block));
    try array.appendSlice(try std.fmt.allocPrint(allocator, "ret\n", .{}));
    return try array.toOwnedSlice();
}
fn generate_function_call_asm(allocator: std.mem.Allocator, function_call: ast.FunctionCall) ![]const u8 {
    var array = std.ArrayList(u8).init(allocator);
    var stack_size: u8 = 0;
    for (function_call.arguments) |arg| {
        stack_size += 8;
        try array.appendSlice(try std.fmt.allocPrint(allocator, "push {s}\n", .{arg.string.value}));
    }
    // try array.appendSlice(try std.fmt.allocPrint(allocator, "call {s}\n", .{generate_function_name(allocator, function_call)}));
    try array.appendSlice(try std.fmt.allocPrint(allocator, "sub rsp , {d}\n", .{stack_size}));

    return try array.toOwnedSlice();
}
fn generate_code_block_asm(allocator: std.mem.Allocator, code_block: ast.CodeBlock) error{OutOfMemory}![]const u8 {
    var array = std.ArrayList(u8).init(allocator);
    for (code_block) |line| {
        try array.appendSlice(switch (line) {
            .function_definition => |function_definition| try generate_function_definition_asm(allocator, function_definition),
            .function_call => |function_call| try generate_function_call_asm(allocator, function_call),
            //todo fix this shit
            .variableDefinition => "asdf",
            .assembly => |assembly| assembly.value,
        });
    }
    return try array.toOwnedSlice();
}
pub fn generate_asm(allocator: std.mem.Allocator, code_block: ast.CodeBlock) error{OutOfMemory}![]const u8 {
    var array = std.ArrayList(u8).init(allocator);
    try array.appendSlice("global _start\n");
    for (code_block) |line| {
        try array.appendSlice(switch (line) {
            .function_definition => |function_definition| try generate_function_definition_asm(allocator, function_definition),
            //Todo fix this shit
            .variableDefinition => "asdf",
            .function_call => |function_call| try generate_function_call_asm(allocator, function_call),
            .assembly => |assembly| assembly.value,
        });
    }
    try array.appendSlice(
        \\ xor rdi, rdi
        \\ mov rax, 0x3c
        \\ syscall
        \\ section .data:
        \\   hello db "Hello World", 0xa
        \\   helloLen equ $-hello
    );
    return try array.toOwnedSlice();
}
const stdout_writer = std.io.getStdOut().writer();

fn link(allocator: std.mem.Allocator) !void {
    var result = try std.ChildProcess.exec(.{ .argv = &.{ "ld", "-o", "bla", "bla.o" }, .allocator = allocator });

    if (result.term.Exited != 0) {
        std.log.err("LD assembler failed: {s}", .{result.stderr});
        return error.FailedCompilingAssembly;
    }
}
fn assemble(allocator: std.mem.Allocator, file_name: []const u8) !void {
    _ = file_name;
    var result = try std.ChildProcess.exec(.{ .argv = &.{ "nasm", "-f", "elf64", "-o", "bla.o", "bla.asm" }, .allocator = allocator });

    if (result.term.Exited != 0) {
        std.log.err("nasm: {s}", .{result.stderr});
        return error.FailedCompilingAssembly;
    }
}
fn build(allocator: std.mem.Allocator, code_block: ast.CodeBlock) !void {
    const assembly_output = try generate_asm(allocator, code_block);
    var assembly_file_name = "bla.asm";
    var assemblyFile = try std.fs.cwd().createFile(assembly_file_name, .{});
    try assemblyFile.writeAll(assembly_output);
    assemblyFile.close();

    try assemble(allocator, "asd");
    try link(allocator);
}
