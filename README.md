# coroutines-zig

Zig bindings for tsoding's [coroutines](https://github.com/tsoding/coroutines) library

## Install

```shell
zig fetch --save "git+https://github.com/ciathefed/coroutines-zig#v0.1.0"
```

Add the following to `build.zig`:

```zig
const coroutines = b.dependency("coroutines", .{
    .target = target,
    .optimize = optimize,
});
exe_mod.addImport("coroutines", coroutines.module("coroutines"));
```

## Example

```zig
const std = @import("std");
const coroutines = @import("coroutines");

fn counter(arg: ?*anyopaque) callconv(.C) void {
    const n = @as(usize, @intCast(@intFromPtr(arg)));
    for (0..n) |i| {
        std.debug.print("[{}] {}\n", .{ coroutines.id(), i });
        coroutines.yield();
    }
}

pub fn main() !void {
    coroutines.init();

    coroutines.go(counter, @ptrFromInt(5));
    coroutines.go(counter, @ptrFromInt(10));

    while (coroutines.alive() > 1) {
        coroutines.yield();
    }
}
```

You can find more examples [here](https://github.com/ciathefed/coroutines/tree/main/examples)
