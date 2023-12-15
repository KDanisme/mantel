const std = @import("std");
const lexer = @import("../../lexer.zig");
const literal = @import("./literal.zig");
pub const FunctionCall = struct { name: []const u8, arguments: []literal.Literal };
pub fn get_function_call(allocator: std.mem.Allocator, lexemes: []const lexer.LexicalToken, index: *usize) !?FunctionCall {
    if (!std.mem.eql(u8, lexemes[index.* + 1].value, "(")) {
        return null;
    }
    const name = lexemes[index.*].value;
    index.* += 2;
    var args = std.ArrayList(literal.Literal).init(allocator);
    while (!std.mem.eql(u8, lexemes[index.*].value, ")")) {
        if (literal.get_literal(lexemes, index)) |literalValue| {
            try args.append(literalValue);
        } else return error.OnlyLiteralsAreSupporeted;
        if (lexemes[index.*].value[0] != ',') {
            if (lexemes[index.*].value[0] == ')') {
                break;
            }
            return error.expectedComma;
        }
        index.* += 1;
    }
    index.* += 1;

    return FunctionCall{ .name = name, .arguments = try args.toOwnedSlice() };
}

test "function call" {
    const literalTokenName = lexer.LexicalTokenName.literal;
    const lexemes = [_]lexer.LexicalToken{
        lexer.LexicalToken{ .name = literalTokenName, .value = "bla" },
        lexer.LexicalToken{ .name = literalTokenName, .value = "(" },
        lexer.LexicalToken{ .name = literalTokenName, .value = ")" },
    };
    var index: usize = 0;
    try std.testing.expect(try get_function_call(std.testing.allocator, &lexemes, &index) != null);
}
