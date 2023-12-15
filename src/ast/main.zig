// fn get_next_closing_char(lexemes: []const std.LexicalToken, opening_char: u8, closing_char: u8) !usize {
//     var count: usize = 1;
//     for (lexemes, 0..) |lexeme, index| {
//         if (lexeme.value[0] == closing_char) {
//             count -= 1;
//         } else if (lexeme.value[0] == opening_char) {
//             count += 1;
//         }
//         if (count == 0) {
//             return index + 1;
//         }
//     }
//     return error.no_closing_char;
// }
const std = @import("std");
const codeBlock = @import("./nodes/code-block.zig");
const lexer = @import("../lexer.zig");
pub fn get_ast(allocator: std.mem.Allocator, lexemes: []const lexer.LexicalToken) !codeBlock.CodeBlock {
    return codeBlock.get_top_level_code_block(allocator, lexemes);
}
