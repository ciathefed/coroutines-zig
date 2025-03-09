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

    const lib = b.addStaticLibrary(.{
        .name = "zoro",
        .root_source_file = b.path("src/zoro.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibrary(coroutine_lib);
    lib.linkLibC();

    b.installArtifact(lib);
}
