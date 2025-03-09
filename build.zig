const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const coroutine_lib = b.addStaticLibrary(.{
        .name = "coroutine",
        .target = target,
        .optimize = optimize,
    });
    coroutine_lib.addCSourceFile(.{ .file = b.path("src/coroutine.c") });
    coroutine_lib.linkLibC();

    const module = b.addModule("zoro", .{
        .target = target,
        .optimize = optimize,
    });

    module.linkLibrary(coroutine_lib);
}
