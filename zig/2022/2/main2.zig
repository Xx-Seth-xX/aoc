const std = @import("std");
const data = @embedFile("data.txt");
const Hand = enum(u8) { rock = 1, paper = 2, scissors = 3 };
const Outcome = enum(u8) { win = 6, draw = 3, loss = 0 };

fn char_to_outcome(c: u8) Outcome {
    return switch (c) {
        'X' => .loss,
        'Y' => .draw,
        'Z' => .win,
        else => unreachable,
    };
}
fn char_to_hand(c: u8) Hand {
    return switch (c) {
        'A' => .rock,
        'B' => .paper,
        'C' => .scissors,
        else => unreachable,
    };
}
fn my_hand(theirs: Hand, outcome: Outcome) Hand {
    const offset: u32 = switch (outcome) {
        .draw => 0,
        .win => 1,
        .loss => 2,
    };
    return ([_]Hand{ .scissors, .rock, .paper })[(@enumToInt(theirs) + offset) % 3];
}
pub fn main() void {
    var lines = std.mem.split(u8, data, "\n");
    var result: u32 = 0;
    var line_n: u32 = 0;
    while (lines.next()) |line| {
        std.log.info("{}: {s}", .{ line_n, line });
        line_n += 1;
        const theirs = char_to_hand(line[0]);
        const outcome = char_to_outcome(line[2]);
        result += @enumToInt(my_hand(theirs, outcome));
        result += @enumToInt(outcome);
    }
    std.log.info("Resultado: {}", .{result});
}
