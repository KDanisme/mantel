const typeNode = @import("./type.zig");
const std = @import("std");
const lexer = @import("../../lexer.zig");
pub const VariableDefinition = struct { name: []const u8, type: typeNode.Type };

pub fn get_variable_definition(lexemes: []const lexer.LexicalToken, index: *usize) !?VariableDefinition {
    if (std.mem.eql(u8, lexemes[index.*].value, "const")) {
        const name = lexemes[index.* + 1].value;
        index.* += 3;
        const _type = try typeNode.get_type(lexemes, index);
        const variableDefinition = VariableDefinition{ .name = name, .type = _type };
        return variableDefinition;
    }
    return null;
}

test "function definition" {
    var index: usize = 0;
    var bufferStream = std.io.fixedBufferStream("const asdf: void ");

    const lexemes = try lexer.get_lexical_tokens(std.testing.allocator, bufferStream.reader());
    try lexer.print_tokens(lexemes);
    try std.testing.expect(try get_variable_definition(lexemes, &index) != null);
}
