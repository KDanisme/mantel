const std = @import("std");
const assemblyBackend = @import("./assembly/main.zig");
// const cBackend = @import("./c/main.zig");
// const llvmBackend = @import("./llvm/main.zig");

const State = union(enum) { empty, in_word, in_double_quotes, in_single_quotes };
const Backend = union(enum) { assembly, c, llvm };

fn emit(allocator: std.mem.Allocator, backend: Backend) !void {
    _ = allocator;
    const backendImport = switch (backend) {
        // .llvm => llvmBackend
        .assembly => assemblyBackend,
    };
    backendImport
        ._ = backendImport;
}
