const std = @import("std");
const data = @embedFile("input.txt");

const Bag = struct {
    red_cubes: u32,
    green_cubes: u32,
    blue_cubes: u32,
};

pub fn main() !void {
    var solution: u32 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var minimal_bag = Bag{
            .red_cubes = 0,
            .blue_cubes = 0,
            .green_cubes = 0,
        };
        var game_id: u32 = 0;
        var record = std.mem.tokenizeScalar(u8, line, ':');
        if (record.next()) |game_string| {
            var game_string_it = std.mem.tokenizeScalar(u8, game_string, ' ');
            _ = game_string_it.next();
            var id_string = game_string_it.next().?;
            game_id = try std.fmt.parseInt(u32, id_string, 10);
        }
        var sets_it = std.mem.tokenizeScalar(u8, record.next().?, ';');
        while (sets_it.next()) |set| {
            var cubes_it = std.mem.tokenizeScalar(u8, set, ',');
            while (cubes_it.next()) |cube| {
                var cube_data_it = std.mem.tokenizeScalar(u8, cube, ' ');
                var number = try std.fmt.parseInt(u32, cube_data_it.next().?, 10);
                var cube_name = cube_data_it.next().?;
                switch (cube_name[0]) {
                    'r' => {
                        minimal_bag.red_cubes = @max(minimal_bag.red_cubes, number);
                    },
                    'g' => {
                        minimal_bag.green_cubes = @max(minimal_bag.green_cubes, number);
                    },
                    'b' => {
                        minimal_bag.blue_cubes = @max(minimal_bag.blue_cubes, number);
                    },
                    else => unreachable,
                }
            }
        }
        solution += minimal_bag.red_cubes * minimal_bag.green_cubes * minimal_bag.blue_cubes;
    }
    std.log.info("The solution is: {}", .{solution});
}
