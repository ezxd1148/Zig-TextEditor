I decided to follow the docs as usual

But i ran into a problem where after I fought with a bunch of error and successfully compiled the script. It does not work as what I was expecting it to

``` zig
switch (buf[0]) {
        CTRL_KEY('q') => std.process.exit(1),
        else => {},
}
```

At first, I thought it was because I used std.process.cleanExit(io) but after i changed it to std.process.exit(1) the problem persists.

I decided to isolate the code above to a test file to confirm my problem.

Weird..... i isolated related codes together and it works perfectly well in another script. I am now guessing it has something to do with the termios flags I set up.


At the end of the day I only got test.zig to work properly when main.zig was supposed to be the main script
