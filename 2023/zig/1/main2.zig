const std = @import("std");
const data = @embedFile("data2.txt");

const digits = [_][]const u8{
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

pub fn main() !void {
    // We need to iter through all lines in file
    var lines = std.mem.split(u8, data, "\n");
    var total_calibration_value: u64 = 0;
    while (lines.next()) |line| {
        // First we look for the first digit of the line
        var c1: u64 = 0;
        var c2: u64 = 0;

        var i: usize = 0;
        search_loop: while (i < line.len) : (i += 1) {
            if (std.ascii.isDigit(line[i])) {
                c1 = line[i] - '0';
                break;
            } else {
                for (digits, 0..) |digit, j| {
                    if (std.mem.startsWith(u8, line[i..], digit)) {
                        c1 = j;
                        break :search_loop;
                    }
                }
            }
        }
        i = line.len;
        search_loop: while (i > 0) {
            i -= 1;
            if (std.ascii.isDigit(line[i])) {
                c2 = line[i] - '0';
                break;
            } else {
                for (digits, 0..) |digit, j| {
                    if (std.mem.endsWith(u8, line[0..(i + 1)], digit)) {
                        c2 = j;
                        break :search_loop;
                    }
                }
            }
        }
        std.log.info("Found number {} at {}", .{ c2, i });

        total_calibration_value += c1 * 10 + c2;
    }
    std.log.info("Calibration vaule: {any}", .{total_calibration_value});
}
