const std = @import("std");
const lexer = @import("../../lexer.zig");

pub const Type = enum { string, int, void };

pub fn get_type(lexemes: []const lexer.LexicalToken, index: *usize) !Type {
    const typeValue = lexemes[index.*].value;
    index.* += 1;
    inline for (@typeInfo(Type).Enum.fields) |typeField| {
        if (std.mem.eql(u8, typeField.name, typeValue)) {
            return @enumFromInt(typeField.value);
        }
    }
    std.log.err("{s} is not a known type\n", .{typeValue});
    return error.undefinedTypeError;
}

test "function definition" {
    const literalTokenName = lexer.LexicalTokenName.literal;
    const lexemes = [_]lexer.LexicalToken{
        lexer.LexicalToken{ .name = literalTokenName, .value = "void" },
    };
    var index: usize = 0;
    _ = try get_type(&lexemes, &index);
}
