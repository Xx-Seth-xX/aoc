const std = @import("std");
const data = @embedFile("data.txt");
const Hand = enum(u8) { rock = 1, paper = 2, scissors = 3 };
const Outcome = enum(u8) { win = 6, draw = 3, loss = 0 };

fn calculate_outcome(mine: Hand, theirs: Hand) Outcome {
    const r: u8 = (3 + @enumToInt(mine) - @enumToInt(theirs)) % 3;
    return switch (r) {
        0 => .draw,
        2 => .loss,
        1 => .win,
        else => unreachable,
    };
}

fn char_to_hand(c: u8) Hand {
    return switch (c) {
        'X', 'A' => .rock,
        'Y', 'B' => .paper,
        'Z', 'C' => .scissors,
        else => unreachable,
    };
}
pub fn main() void {
    var lines = std.mem.split(u8, data, "\n");
    var result: u32 = 0;
    var line_n: u32 = 0;
    while (lines.next()) |line| {
        std.log.info("{}: {s}", .{ line_n, line });
        line_n += 1;
        const mine = char_to_hand(line[2]);
        const theirs = char_to_hand(line[0]);
        result += @enumToInt(mine);
        result += @enumToInt(calculate_outcome(mine, theirs));
    }
    std.log.info("Resultado: {}", .{result});
}
