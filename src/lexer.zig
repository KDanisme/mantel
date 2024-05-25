const std = @import("std");
const LexemeType = enum { Word, Number };
const Lexeme = struct { type: LexemeType, value: []const u8 };
pub const LexicalTokenName = enum { identifier, keyword, seperator, operator, literal };
pub const LexicalToken = struct { name: LexicalTokenName, value: []const u8 };
const State = enum { empty, in_word, in_double_quotes, in_single_quotes };
const TokenList = std.ArrayList(LexicalToken);

pub fn get_lexical_tokens_from_file(allocator: std.mem.Allocator, file: std.fs.File) ![]LexicalToken {
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();
    return try get_lexical_tokens(allocator, reader);
}
pub fn get_lexical_tokens(allocator: std.mem.Allocator, reader: anytype) ![]LexicalToken {
    var token_list = TokenList.init(allocator);
    var state = State.empty;
    var remainder: ?u8 = null;
    while (true) {
        var lexeme = get_next_lexeme(allocator, &reader, &state, remainder) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        remainder = lexeme.?[1];
        const token = try evaluate_token(&lexeme.?[0]);
        try token_list.append(token);
    }
    return token_list.toOwnedSlice();
}
fn evaluate_token(lexem: *const Lexeme) !LexicalToken {
    return LexicalToken{ .value = lexem.value, .name = LexicalTokenName.literal };
    // return switch (lexem.type) {
    //     LexemeType.Word => {
    //         const Case = enum { true, false, @"fn", @"(" };
    //         _ = Case;
    //         // const case = std.meta.stringToEnum(Case, lexem.value.?).?;
    //         // return switch (case) {
    //         //     else => LexicalToken{ .value = lexem.value, .name = LexicalTokenName.literal },
    //         //     //                else => error.Broken,
    //         // };
    //         return LexicalToken{ .value = lexem.value, .name = LexicalTokenName.literal };
    //     },
    //     LexemeType.Number => {
    //         return LexicalToken{ .value = lexem.value, .name = LexicalTokenName.literal };
    //     },
    // };
}
fn get_next_lexeme(allocator: std.mem.Allocator, reader: anytype, state: *State, remainder: ?u8) !?struct { Lexeme, ?u8 } {
    var letters: ?std.ArrayList(u8) = null;
    while (true) {
        const b = if (remainder != null) remainder.? else try reader.readByte();
        switch (state.*) {
            .empty => switch (b) {
                ' ', '\t' => continue,
                '\n' => {
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                    return .{ Lexeme{ .type = LexemeType.Word, .value = try letters.?.toOwnedSlice() }, null };
                },
                ',', ':', '(', ')', '{', '}' => {
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                    return .{ Lexeme{ .type = LexemeType.Word, .value = try letters.?.toOwnedSlice() }, null };
                },
                '=', '+', '-', '/', '*' => {
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                    return .{ Lexeme{ .type = LexemeType.Word, .value = try letters.?.toOwnedSlice() }, null };
                },
                '_', 'a'...'z', 'A'...'Z' => {
                    state.* = State.in_word;
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                },
                '0'...'9' => {
                    state.* = State.in_word;
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                },
                '\"' => {
                    state.* = State.in_double_quotes;
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                },
                '\'' => {
                    state.* = State.in_single_quotes;
                    letters = std.ArrayList(u8).init(allocator);
                    try letters.?.append(b);
                },
                else => {
                    std.debug.print("{c}", .{b});
                    return error.unknownLexerChar;
                },
            },
            .in_word => switch (b) {
                ' ',
                '\t',
                => {
                    state.* = State.empty;
                    return .{ Lexeme{ .type = LexemeType.Number, .value = try letters.?.toOwnedSlice() }, null };
                },
                '\n',
                ',',
                '"',
                '\'',
                ':',
                '{',
                '}',
                '(',
                ')',
                => |char| {
                    state.* = State.empty;
                    return .{ Lexeme{ .type = LexemeType.Number, .value = try letters.?.toOwnedSlice() }, char };
                },
                else => {
                    try letters.?.append(b);
                },
            },
            .in_double_quotes => switch (b) {
                '\"' => {
                    state.* = State.empty;
                    try letters.?.append(b);
                    return .{ Lexeme{ .type = LexemeType.Word, .value = try letters.?.toOwnedSlice() }, null };
                },
                else => {
                    try letters.?.append(b);
                },
            },
            .in_single_quotes => switch (b) {
                '\'' => {
                    state.* = State.empty;

                    try letters.?.append(b);
                    return .{ Lexeme{ .type = LexemeType.Word, .value = try letters.?.toOwnedSlice() }, null };
                },
                else => {
                    try letters.?.append(b);
                },
            },
        }
    }
    return error.Adas;
}

pub fn print_tokens(lexical_tokens: []LexicalToken) !void {
    for (lexical_tokens) |token| {
        std.debug.print("{?s},'{?s}'\n", .{ @tagName(token.name), token.value });
    }
}
