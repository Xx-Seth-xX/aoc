const std = @import("std");
const data = @embedFile("data.txt");

fn update_lists(max_elves: anytype, max_calories: anytype, elf: u32, calorie: u32) void {
    var current_lowest: u32 = std.math.maxInt(u32);
    var current_index: usize = 0;
    for (0..3) |i| {
        if (max_calories.*[i] <= current_lowest) {
            current_lowest = max_calories.*[i];
            current_index = i;
        }
    }
    if (current_lowest < calorie) {
        max_calories.*[current_index] = calorie;
        max_elves.*[current_index] = elf;
    }
}

pub fn main() !void {
    var max_elves = @Vector(3, u32){ 0, 0, 0 };
    var max_calories = @Vector(3, u32){ 0, 0, 0 };
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
    std.log.info("El total de calorías de estos elfos es: {}", .{@reduce(.Add, max_calories)});
}
