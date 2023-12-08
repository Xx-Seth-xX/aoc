const std = @import("std");
const data = @embedFile("input.txt");

const directions = [_][2]isize{
    [_]isize{ -1, -1 },
    [_]isize{ -1, 0 },
    [_]isize{ -1, 1 },
    [_]isize{ 0, -1 },
    [_]isize{ 0, 0 },
    [_]isize{ 0, 1 },
    [_]isize{ 1, -1 },
    [_]isize{ 1, 0 },
    [_]isize{ 1, 1 },
};

// We have to take into account that all lines end in \n
const line_length: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const number_of_rows: usize = (data.len + 1) / (line_length + 1);

fn getCharAt(x: usize, y: usize) u8 {
    return data[y * (1 + line_length) + x];
}

fn isSymbol(c: u8) bool {
    return !std.ascii.isDigit(c) and c != '.';
}

fn hasAdjadcentSymbol(x: usize, y: usize) bool {
    for (directions) |dr| {
        const new_x = @as(isize, @intCast(x)) + dr[0];
        const new_y = @as(isize, @intCast(y)) + dr[1];
        if (!(new_x < 0 or new_x >= line_length or new_y < 0 or new_y >= number_of_rows)) {
            if (isSymbol(getCharAt(@intCast(new_x), @intCast(new_y)))) {
                return true;
            }
        }
    }
    // If we are here we haven't found any symbol
    return false;
}

pub fn main() !void {
    var solution: u32 = 0;
    var num: u32 = 0;
    var is_valid: bool = false;
    for (0..number_of_rows) |i| {
        for (0..line_length) |j| {
            var c = getCharAt(j, i);
            if (std.ascii.isDigit(c)) {
                // Whatever is in number gets shifted left in base 10
                num = num * 10 + try std.fmt.charToDigit(c, 10);
                is_valid = is_valid or hasAdjadcentSymbol(j, i);
            } else {
                // If we are not in a number we reset it
                if (is_valid) {
                    solution += num;
                }
                is_valid = false;
                num = 0;
            }
        }
        if (is_valid) {
            solution += num;
        }
        is_valid = false;
        num = 0;
    }
    std.log.info("Solution is: {}", .{solution});
}
