const std = @import("std");
const data = @embedFile("input.txt");

const Coordinate = struct { usize, usize };

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

fn getAdjadcentSymbol(x: usize, y: usize) ?Coordinate {
    for (directions) |dr| {
        const new_x = @as(isize, @intCast(x)) + dr[0];
        const new_y = @as(isize, @intCast(y)) + dr[1];
        if (!(new_x < 0 or new_x >= line_length or new_y < 0 or new_y >= number_of_rows)) {
            var unx = @as(usize, @intCast(new_x));
            var uny = @as(usize, @intCast(new_y));
            if (isSymbol(getCharAt(@intCast(new_x), @intCast(new_y)))) {
                return .{ unx, uny };
            }
        }
    }
    // If we are here we haven't found any symbol
    return null;
}

pub fn main() !void {
    // We need a hashmap to store the gears
    // for that we'll use an arena allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Because we use an arena alloc we won't need to free the keys
    var gears = std.AutoHashMap(Coordinate, struct { u32, u32 }).init(arena.allocator());
    defer gears.deinit();

    var solution: u32 = 0;
    var num: u32 = 0;
    var gear_coord: ?Coordinate = null;
    for (0..number_of_rows) |i| {
        for (0..line_length) |j| {
            var c = getCharAt(j, i);
            if (std.ascii.isDigit(c)) {
                // Whatever is in number gets shifted left in base 10
                num = num * 10 + try std.fmt.charToDigit(c, 10);
                if (gear_coord == null) {
                    if (getAdjadcentSymbol(j, i)) |adj_gear_coord| {
                        gear_coord = adj_gear_coord;
                    }
                }
            } else {
                if (gear_coord) |gear_coord_key| {
                    // We need to check if the gear is already in the hashmap
                    // It can fail if we run out of space
                    var aux = try gears.getOrPut(gear_coord_key);
                    if (aux.found_existing) {
                        // If there was a gear we increment its counter and multiply its ratio
                        aux.value_ptr.*[0] += 1;
                        aux.value_ptr.*[1] *= num;
                    } else {
                        // Otherwise we initialize it
                        aux.value_ptr.*[0] = 1;
                        aux.value_ptr.*[1] = num;
                    }
                }
                gear_coord = null;
                num = 0;
            }
        }
        if (gear_coord) |gear_coord_key| {
            // We need to check if the gear is already in the hashmap
            // It can fail if we run out of space
            var aux = try gears.getOrPut(gear_coord_key);
            if (aux.found_existing) {
                // If there was a gear we increment its counter and multiply its ratio
                aux.value_ptr.*[0] += 1;
                aux.value_ptr.*[1] *= num;
            } else {
                // Otherwise we initialize it
                aux.value_ptr.*[0] = 1;
                aux.value_ptr.*[1] = num;
            }
        }
        gear_coord = null;
        num = 0;
    }
    var gears_it = gears.iterator();
    while (gears_it.next()) |aux| {
        if (aux.value_ptr.*[0] == 2) {
            solution += aux.value_ptr.*[1];
            std.log.info("Gear at coord {} with ratio {}", .{ aux.key_ptr.*, aux.value_ptr.*[1] });
        }
    }
    std.log.info("Solution is: {}", .{solution});
}
