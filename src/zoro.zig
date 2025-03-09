pub const CoroutineFunc = fn (arg: ?*anyopaque) callconv(.C) void;

extern fn coroutine_init() void;
extern fn coroutine_yield() void;
extern fn coroutine_go(f: *const CoroutineFunc, arg: ?*anyopaque) void;
extern fn coroutine_id() usize;
extern fn coroutine_alive() usize;
extern fn coroutine_sleep_read(fd: c_int) void;
extern fn coroutine_sleep_write(fd: c_int) void;
extern fn coroutine_wake_up(id: usize) void;

pub const init = coroutine_init;
pub const yield = coroutine_yield;
pub const go = coroutine_go;
pub const id = coroutine_id;
pub const alive = coroutine_alive;
pub const sleepRead = coroutine_sleep_read;
pub const sleepWrite = coroutine_sleep_write;
pub const wakeUp = coroutine_wake_up;
