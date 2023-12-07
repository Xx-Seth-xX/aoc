const std = @import("std");
const data = @embedFile("data1.txt");

pub fn main() !void {
    // We need to iter through all lines in file
    var lines = std.mem.split(u8, data, "\n");
    var total_calibration_value: u32 = 0;
    while (lines.next()) |line| {
        // First we look for the first digit of the line
        var i: usize = 0;
        var c1: u8 = 0;
        var c2: u8 = 0;
        while (i <= line.len) : (i += 1) {
            c1 = line[i];
            if (c1 <= 57 and c1 >= 48) {
                // If we are hare c is a number
                c1 -= 48;
                // and by substracting 48 we have the actual number
                break;
            }
        }
        i = line.len;
        while (i > 0) {
            i -= 1;
            c2 = line[i];
            if (c2 <= 57 and c2 >= 48) {
                // If we are hare c is a number
                c2 -= 48;
                // and by substracting 48 we have the actual number
                break;
            }
        }
        total_calibration_value += c1 * 10 + c2;
    }
    std.log.info("Calibration vaule: {any}", .{total_calibration_value});
}
