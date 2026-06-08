// imports

const std = @import("std");
const posix = std.posix;

// data

const stdin_fd = posix.STDIN_FILENO;

// terminal

fn enableRawMode() !void {
    //struct termios raw;
    //tcgetattr(STDIN_FILENO, &raw);
    //raw.c_lflag &= ~(ECHO);
    //tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);

    // const raw = posix.termios; --> this equal to struct termios raw, but in zig std raw can be defined as below

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

    // raw.cc[@intFromEnum(std.posix.V.MIN)] = 0;
    // raw.cc[@intFromEnum(std.posix.V.TIME)] = 1;

    try posix.tcsetattr(stdin_fd, .FLUSH, raw);
}

// init

pub fn main() !void {
    try enableRawMode();

    var buf: [1]u8 = undefined; // I figured we only takes in 1 byte of char

    while (try posix.read(stdin_fd, &buf) == 1 and buf[0] != 'q') { // anything that includes q will exit the system
        if (std.ascii.isControl(buf[0])) {
            std.debug.print("{d}\r\n", .{buf[0]});
        } else {
            std.debug.print("{d} ('{c}')\r\n", .{ buf[0], buf[0] });
        }
    }
}
