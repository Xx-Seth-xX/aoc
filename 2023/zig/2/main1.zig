const std = @import("std");
const data = @embedFile("input.txt");

const Bag = struct {
    red_cubes: u32,
    green_cubes: u32,
    blue_cubes: u32,
};

const real_bag = Bag{ .red_cubes = 12, .green_cubes = 13, .blue_cubes = 14 };

pub fn main() !void {
    var solution: u32 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    main_loop: while (lines.next()) |line| {
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
                        if (number > real_bag.red_cubes)
                            continue :main_loop;
                    },
                    'g' => {
                        if (number > real_bag.green_cubes)
                            continue :main_loop;
                    },
                    'b' => {
                        if (number > real_bag.blue_cubes)
                            continue :main_loop;
                    },
                    else => unreachable,
                }
            }
        }
        // If we are here no set is invalid so this game is valid
        solution += game_id;
    }
    std.log.info("The solution is: {}", .{solution});
}
