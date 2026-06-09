const std = @import("std");
const posix = std.posix;

const stdin_fd = posix.STDIN_FILENO;

inline fn CTRL_KEY(k: u8) u8 {
    return k & 0x1f; // 0x1f is the address for ctrl key
}

fn editorReadKey() ![1]u8 {
    var buf: [1]u8 = undefined;
    const nread: usize = try posix.read(stdin_fd, &buf);

    while (nread != 1) {
        continue;
    }

    return buf;
}

fn editorProcessKeypress() !void {
    const buf = try editorReadKey();

    switch (buf[0]) {
        CTRL_KEY('q') => std.process.exit(1),
        else => {},
    }
}

pub fn main(init: std.process.Init) !void {
    _ = init;

    while (true) {
        try editorProcessKeypress();
    }
}
