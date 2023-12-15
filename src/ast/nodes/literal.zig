const std = @import("std");
const lexer = @import("../../lexer.zig");
const typeNode = @import("./type.zig");
const String = struct { value: []const u8 };

const Int = struct { value: u32 };
pub const Literal = union(enum) { string: String, int: Int };
pub fn get_literal(lexemes: []const lexer.LexicalToken, index: *usize) ?Literal {
    if (lexemes[index.*].value[0] != '"' or lexemes[index.*].value[lexemes[index.*].value.len - 1] != '"') return null;
    const value = lexemes[index.*].value;
    const literal = Literal{ .string = String{ .value = value[1 .. value.len - 1] } };
    index.* += 1;
    return literal;
}

test "function definition" {
    const literalTokenName = lexer.LexicalTokenName.literal;
    const lexemes = [_]lexer.LexicalToken{
        lexer.LexicalToken{ .name = literalTokenName, .value = "\"my-literal\"" },
    };
    var index: usize = 0;
    try std.testing.expect(get_literal(&lexemes, &index) != null);
}
