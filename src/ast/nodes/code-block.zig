const std = @import("std");
const lexer = @import("../../lexer.zig");
const functionCall = @import("./function-call.zig");
const assemblyNode = @import("./assembly.zig");
const variableDefinitionNode = @import("./variable-definition.zig");
const functionDefinition = @import("./function-definition.zig");

pub const Line = union(enum) { function_call: functionCall.FunctionCall, function_definition: functionDefinition.FunctionDefinition, assembly: assemblyNode.Assembly, variableDefinition: variableDefinitionNode.VariableDefinition };
pub const CodeBlock = []Line;
const CommonError = std.posix.WriteError || std.mem.Allocator.Error || error{ BadLineDontKnow, undefinedTypeError, expectedColon, expectedComma, OnlyLiteralsAreSupporeted };

pub fn get_top_level_code_block(allocator: std.mem.Allocator, lexemes: []const lexer.LexicalToken) !CodeBlock {
    var array = std.ArrayList(Line).init(allocator);
    var index: usize = 0;
    while (index < lexemes.len) {
        const line = if (std.mem.eql(u8, lexemes[index].value, "\n")) {
            index += 1;
            continue;
        } else if (try functionDefinition.get_function_definition(allocator, lexemes, &index)) |function_definition|
            Line{ .function_definition = function_definition }
        else if (try functionCall.get_function_call(allocator, lexemes, &index)) |function_call|
            Line{ .function_call = function_call }
        else {
            std.log.err("Bad token at line 'idk': '{s}'", .{lexemes[index].value});
            return error.BadLineDontKnow;
        };
        try array.append(line);
    }
    return array.toOwnedSlice();
}
pub fn get_code_block(allocator: std.mem.Allocator, lexemes: []const lexer.LexicalToken, index: *usize) CommonError!?CodeBlock {
    if (std.mem.eql(u8, lexemes[index.*].value, "{")) {
        index.* += 1;
        var array = std.ArrayList(Line).init(allocator);
        while (!std.mem.eql(u8, lexemes[index.*].value, "}")) {
            const optional_line =
                if (std.mem.eql(u8, lexemes[index.*].value, "\n"))
            {
                index.* += 1;
                continue;
            } else if (try functionDefinition.get_function_definition(allocator, lexemes, index)) |function_definition|
                Line{ .function_definition = function_definition }
            else if (try functionCall.get_function_call(allocator, lexemes, index)) |function_call|
                Line{ .function_call = function_call }
            else if (assemblyNode.get_assembly(lexemes, index)) |assembly|
                Line{ .assembly = assembly }
            else if (try variableDefinitionNode.get_variable_definition(lexemes, index)) |variableDefinition|
                Line{ .variableDefinition = variableDefinition }
            else {
                std.log.err("Bad token at line 'idk': '{s}'", .{lexemes[index.*].value});
                return error.BadLineDontKnow;
            };
            try array.append(optional_line);
        }
        index.* += 1;
        return try array.toOwnedSlice();
    }
    return null;
}

test "code block" {
    const literal = lexer.LexicalTokenName.literal;
    const lexemes = [_]lexer.LexicalToken{
        lexer.LexicalToken{ .name = literal, .value = "{" },
        lexer.LexicalToken{ .name = literal, .value = "\n" },
        lexer.LexicalToken{ .name = literal, .value = "}" },
    };
    var index: usize = 0;
    try std.testing.expect(try get_code_block(std.testing.allocator, &lexemes, &index) != null);
}
