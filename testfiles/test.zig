const std = @import("std");
const posix = std.posix;

const stdin_fd = posix.STDIN_FILENO;
const stdout_fd = std.Io.File.stdout();

inline fn CTRL_KEY(k: u8) u8 {
    return k & 0x1f; // 0x1f is the address for ctrl key
}

fn enableRawMode() !void {
    var raw = try posix.tcgetattr(stdin_fd); // anything that may returns an error we must put try in front of it

    // terminal config

    raw.iflag.IXON = false;
    raw.iflag.ICRNL = false;
    raw.iflag.BRKINT = false;
    raw.iflag.INPCK = false;
    raw.iflag.ISTRIP = false;

    raw.oflag.OPOST = false;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.lflag.ISIG = false;
    raw.lflag.IEXTEN = false;

    raw.cc[@intFromEnum(std.posix.V.MIN)] = 0;
    raw.cc[@intFromEnum(std.posix.V.TIME)] = 1;

    try posix.tcsetattr(stdin_fd, .FLUSH, raw);
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

fn editorRefreshScreen(io: std.Io) !void {
    var writer_buf: [1024]u8 = undefined;
    var writer = stdout_fd.writer(io, &writer_buf);

    _ = try writer.interface.writeAll("\x1b[2J");
    _ = try writer.interface.writeAll("\x1b[H");
    try writer.flush();
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // try enableRawMode();

    while (true) {
        try editorRefreshScreen(io);
        try editorProcessKeypress();
    }
}
