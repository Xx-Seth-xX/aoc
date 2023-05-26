const std = @import("std");
const data = @embedFile("data.txt");

fn update_lists(max_elves: *[3]u32, max_calories: *[3]u32, elf: u32, calorie: u32) void {
    for (0..3) |i| {
        if (calorie > max_calories[i]) {
            max_elves[i] = elf;
            max_calories[i] = calorie;
            return;
        }
    }
}

pub fn main() !void {
    var max_elves = [_]u32{ 0, 0, 0 };
    var max_calories = [_]u32{ 0, 0, 0 };

    var current_elf: u32 = 1;
    var current_calories: u32 = 0;
    var lines = std.mem.split(u8, data, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            update_lists(&max_elves, &max_calories, current_elf, current_calories);
            current_elf += 1;
            current_calories = 0;
        } else {
            current_calories += try std.fmt.parseInt(u32, line, 10);
        }
    }
    update_lists(&max_elves, &max_calories, current_elf, current_calories);
    std.log.info("El elfo con más calorías es: {any}, con {any} calorías", .{ max_elves, max_calories });
}
