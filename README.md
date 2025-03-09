# Zoro

A port of tsoding's [coroutines](https://github.com/tsoding/coroutines) in Zig

## Example

```zig
const std = @import("std");
const zoro = @import("zoro");

fn counter(arg: ?*anyopaque) callconv(.C) void {
    const n = @as(usize, @intCast(@intFromPtr(arg)));
    for (0..n) |i| {
        std.debug.print("[{}] {}\n", .{ zoro.id(), i });
        zoro.yield();
    }
}

pub fn main() !void {
    zoro.init();

    zoro.go(counter, @ptrFromInt(5));
    zoro.go(counter, @ptrFromInt(10));

    while (zoro.alive() > 1) {
        zoro.yield();
    }
}
```
