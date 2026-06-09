// imports

const std = @import("std");
const posix = std.posix;

// data

inline fn CTRL_KEY(k: u8) u8 {
    return k & 0x1f; // 0x1f is the address for ctrl key
}

const stdin_fd = posix.STDIN_FILENO;
const stdout_fd = std.Io.File.stdout();

// terminal

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
    } else {
        std.debug.print("An Error Has Occured\n", .{});
    }

    return buf;
}

fn editorProcessKeypress(io: std.Io) !void {
    const buf = try editorReadKey();

    var writer_buf: [1024]u8 = undefined;
    var writer = stdout_fd.writer(io, &writer_buf);

    switch (buf[0]) {
        CTRL_KEY('q') => {
            _ = try writer.interface.write("\x1b[2J");
            _ = try writer.interface.write("\x1b[H");
            std.process.exit(1);
        },
        else => {},
    }
}

// output

fn editorRefreshScreen(io: std.Io) !void {
    var writer_buf: [1024]u8 = undefined;
    var writer = stdout_fd.writer(io, &writer_buf);

    _ = try writer.interface.write("\x1b[2J");
    _ = try writer.interface.write("\x1b[H");
}

// init

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    try enableRawMode();

    while (true) {
        try editorRefreshScreen(io);
        try editorProcessKeypress(io);
    }
}
