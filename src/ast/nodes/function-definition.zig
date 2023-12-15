const std = @import("std");
const lexer = @import("../../lexer.zig");
const typeNode = @import("./type.zig");
const codeBlock = @import("./code-block.zig");
pub const FunctionDefinition = struct { name: []const u8, arguments: []const FunctionArgument, return_type: typeNode.Type, code_block: codeBlock.CodeBlock };
pub const FunctionArgument = struct {
    name: []const u8,
    type: typeNode.Type,
};
pub fn get_function_definition(allocator: std.mem.Allocator, lexemes: []const lexer.LexicalToken, index: *usize) !?FunctionDefinition {
    if (!std.mem.eql(u8, lexemes[index.*].value, "fn")) {
        return null;
    }
    const name = lexemes[index.* + 1].value;
    index.* += 3;
    var args = std.ArrayList(FunctionArgument).init(allocator);
    while (!std.mem.eql(u8, lexemes[index.*].value, ")")) {
        const arg_name = lexemes[index.*].value;
        if (lexemes[index.* + 1].value[0] != ':') {
            return error.expectedColon;
        }
        index.* += 2;
        const arg_type = try typeNode.get_type(lexemes, index);
        try args.append(FunctionArgument{ .name = arg_name, .type = arg_type });
        if (lexemes[index.*].value[0] != ',') {
            if (lexemes[index.*].value[0] == ')') {
                break;
            }
            return error.expectedComma;
        }
        index.* += 1;
    }
    index.* += 2;
    const return_type = try typeNode.get_type(lexemes, index);

    const code_block = try codeBlock.get_code_block(allocator, lexemes, index);

    return FunctionDefinition{ .return_type = return_type, .arguments = try args.toOwnedSlice(), .code_block = code_block.?, .name = name };
}

test "function definition" {
    const literalTokenName = lexer.LexicalTokenName.literal;
    const lexemes = [_]lexer.LexicalToken{
        lexer.LexicalToken{ .name = literalTokenName, .value = "fn" },
        lexer.LexicalToken{ .name = literalTokenName, .value = "test" },
        lexer.LexicalToken{ .name = literalTokenName, .value = "(" },
        // lexer.LexicalToken{ .name = literalTokenName, .value = "test" },
        // lexer.LexicalToken{ .name = literalTokenName, .value = ":" },
        // lexer.LexicalToken{ .name = literalTokenName, .value = "string" },
        lexer.LexicalToken{ .name = literalTokenName, .value = ")" },
        lexer.LexicalToken{ .name = literalTokenName, .value = ":" },
        lexer.LexicalToken{ .name = literalTokenName, .value = "string" },
        lexer.LexicalToken{ .name = literalTokenName, .value = "{" },
        lexer.LexicalToken{ .name = literalTokenName, .value = "}" },
    };
    var index: usize = 0;
    try std.testing.expect(try get_function_definition(std.testing.allocator, &lexemes, &index) != null);
}
