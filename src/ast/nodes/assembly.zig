const std = @import("std");
const lexer = @import("../../lexer.zig");

pub const Assembly = struct { value: []const u8 };

pub fn get_assembly(lexemes: []const lexer.LexicalToken, index: *usize) ?Assembly {
    if (!std.mem.eql(u8, lexemes[index.*].value, "asm")) {
        return null;
    }
    index.* += 2;
    const value = lexemes[index.* - 1].value;
    return Assembly{ .value = value[1 .. value.len - 1] };
}

test "assembly" {
    const literal = lexer.LexicalTokenName.literal;
    const lexemes = [_]lexer.LexicalToken{
        lexer.LexicalToken{ .name = literal, .value = "asm" },
        lexer.LexicalToken{ .name = literal, .value = "\"mov a b\nbla a c\"" },
    };
    var index: usize = 0;
    try std.testing.expect(get_assembly(&lexemes, &index) != null);
}
