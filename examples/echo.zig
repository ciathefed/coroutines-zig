const std = @import("std");
const mem = std.mem;
const net = std.net;
const posix = std.posix;
const coroutines = @import("coroutines");

var quit: bool = false;
var server_id: usize = 0;

fn handleConn(arg: ?*anyopaque) callconv(.c) void {
    const conn: i32 = @intCast(@intFromPtr(arg));
    const allocator = std.heap.c_allocator;

    var buf = allocator.alloc(u8, 1024) catch |err| {
        std.log.err("failed to allocator buffer: {}", .{err});
        return;
    };

    std.debug.print("[{d}] client connected\n", .{coroutines.id()});
    defer {
        std.debug.print("[{d}] client disconnected\n", .{coroutines.id()});
        posix.close(conn);
        allocator.free(buf);
    }

    while (true) {
        coroutines.sleepRead(conn);
        const n = posix.read(conn, buf) catch |err| {
            std.log.err("failed to read from client: {}", .{err});
            return;
        };
        if (n == 0) return;

        var chunk = buf[0..n];
        const trimmed = mem.trim(u8, chunk, &std.ascii.whitespace);

        if (mem.eql(u8, trimmed, "quit")) {
            std.debug.print("[{d}] client requested to quit\n", .{coroutines.id()});
            return;
        } else if (mem.eql(u8, trimmed, "shutdown")) {
            std.debug.print("[{d}] client requested to shutdown server\n", .{coroutines.id()});
            quit = true;
            coroutines.wakeUp(server_id);
            return;
        }

        std.debug.print("[{d}] client sent {d} bytes\n", .{ coroutines.id(), n });

        while (chunk.len > 0) {
            coroutines.sleepWrite(conn);
            const m = posix.write(conn, chunk) catch |err| {
                std.log.err("failed to write to client: {}", .{err});
                return;
            };
            if (m == 0) return;
            chunk = chunk[m..];
        }
    }
}

pub fn main() !void {
    coroutines.init();

    server_id = coroutines.id();

    const host = "127.0.0.1";
    const port = 6969;

    const address = try net.Address.parseIp(host, port);

    const tpe: u32 = posix.SOCK.STREAM | posix.SOCK.NONBLOCK;
    const protocol = posix.IPPROTO.TCP;
    const server = try posix.socket(address.any.family, tpe, protocol);
    defer posix.close(server);

    try posix.setsockopt(server, posix.SOL.SOCKET, posix.SO.REUSEADDR, &mem.toBytes(@as(c_int, 1)));
    try posix.bind(server, &address.any, address.getOsSockLen());
    try posix.listen(server, 69);

    std.debug.print("[{d}] server listening on {s}:{d}\n", .{ coroutines.id(), host, port });

    while (true) {
        coroutines.sleepRead(server);
        if (quit) break;

        const conn = posix.accept(server, null, null, posix.SOCK.NONBLOCK) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            continue;
        };

        coroutines.go(handleConn, @ptrFromInt(@as(usize, @intCast(conn))));
    }
}
