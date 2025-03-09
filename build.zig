const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("zoro", .{
        .root_source_file = b.path("src/zoro.zig"),
        .target = target,
        .optimize = optimize,
    });
    module.addCSourceFile(.{ .file = b.path("src/coroutine.c") });
}
