const std = @import("std");
const lib = @import("mise_lib_template");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello from mise-lib-template!\n", .{});

    // Example library usage
    const result = lib.startsWith("hello", "he");
    try stdout.print("startsWith(\"hello\", \"he\"): {}\n", .{result});
}
