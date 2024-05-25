const std = @import("std");
const stdout_writer = std.io.getStdOut().writer();
const UnknownPrintError = error{UnknownValue} || std.posix.WriteError;
fn print(value: anytype, node_index: *u32) !void {
    try stdout_writer.print("n{d} [label=\"{s}\"];", .{ node_index.*, value });
    node_index.* += 1;
}

fn print_connection_str(node_index: u32, parent_node_index: u32, connection_name: anytype) !void {
    try stdout_writer.print("n{d} -- n{d} [label=\"{s}\"];", .{ parent_node_index, node_index, connection_name });
}
fn print_connection_int(node_index: u32, parent_node_index: u32, connection_name: anytype) !void {
    try stdout_writer.print("n{d} -- n{d} [label=\"{d}\"];", .{ parent_node_index, node_index, connection_name });
}
fn print_generic(node: anytype, node_index: *u32) UnknownPrintError!void {
    switch (@typeInfo(@TypeOf(node))) {
        .Struct => |structValue| {
            const parent_node = node_index.*;
            try print(@typeName(@TypeOf(node)), node_index);
            inline for (structValue.fields) |structField| {
                try print_connection_str(node_index.*, parent_node, structField.name);
                try print_generic(@field(node, structField.name), node_index);
            }
        },
        .Pointer => |pointer| {
            const parent_node = node_index.*;
            switch (@typeInfo(pointer.child)) {
                .Int => {
                    try print(node, node_index);
                },
                else => {
                    try print(@typeName(@TypeOf(node)), node_index);
                    for (node, 0..) |arg, i| {
                        try print_connection_int(node_index.*, parent_node, i);
                        try print_generic(arg, node_index);
                    }
                },
            }
        },
        .Enum => {
            const parent_node = node_index.*;
            _ = parent_node;
            try print(@tagName(node), node_index);
        },
        .Union => {
            switch (node) {
                inline else => |unionValue| {
                    try print_generic(unionValue, node_index);
                },
            }
        },
        else => {
            return error.UnknownValue;
        },
    }
}
pub fn print_ast(node: anytype) !void {
    try stdout_writer.print("graph {{label =\"abstract syntax tree\";", .{});
    var int: u32 = 0;
    try print_generic(node, &int);
    try stdout_writer.print("}}", .{});
}
