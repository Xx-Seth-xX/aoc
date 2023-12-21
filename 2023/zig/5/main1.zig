const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const data = @embedFile("data.txt");
const MapUnit = struct {
    const Self = @This();
    length: i64,
    jump_size: i64,
    source: i64,
    pub fn init(source: i64, destination: i64, length: i64) Self {
        return Self{
            .length = length,
            .jump_size = destination - source,
            .source = source,
        };
    }
    pub fn get_dest(self: Self, seed: i64) ?i64 {
        if (seed > self.length + self.source or seed < self.source) {
            return null;
        }
        return seed + self.jump_size;
    }
};

fn gen_seeds(alloc: Allocator, buff: []const u8) !ArrayList(i64) {
    var seed_str = std.mem.tokenizeScalar(u8, buff, ':');
    _ = seed_str.next();
    var seeds = std.mem.tokenizeScalar(u8, seed_str.next().?, ' ');

    var arr = ArrayList(i64).init(alloc);
    while (seeds.next()) |str| {
        try arr.append(try std.fmt.parseInt(i64, str, 10));
    }
    return arr;
}

// Will keep iterating until it finds an invalid line
fn gen_map(alloc: Allocator, lines: *std.mem.TokenIterator(u8, .scalar)) !ArrayList(MapUnit) {
    var map = ArrayList(MapUnit).init(alloc);
    while (lines.*.next()) |line| {
        if (std.ascii.isAlphabetic(line[0])) {
            break;
        }
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        const dest = try std.fmt.parseInt(i64, numbers.next().?, 10);
        const src = try std.fmt.parseInt(i64, numbers.next().?, 10);
        const length = try std.fmt.parseInt(i64, numbers.next().?, 10);
        // std.debug.print("{},{},{}\n", .{ src, dest, length });
        try map.append(MapUnit.init(src, dest, length));
    }
    return map;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var alloc = arena.allocator();
    defer arena.deinit();

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    const first_line = lines.next().?;

    var seeds = try gen_seeds(alloc, first_line);
    defer seeds.deinit();

    var maps: [7]ArrayList(MapUnit) = undefined;
    // defer for (maps) |map| {
    //     map.deinit();
    // };

    // Skip first text line
    _ = lines.next();
    for (0..maps.len) |i| {
        maps[i] = try gen_map(alloc, &lines);
        // std.debug.print("{}", .{maps[i]});
    }
    var min: i64 = std.math.maxInt(i64);
    for (seeds.items) |seed| {
        var new_pos = seed;
        for (maps) |map| {
            for (map.items) |map_unit| {
                if (map_unit.get_dest(new_pos)) |val| {
                    //If we return a valid value then we go to the next map
                    new_pos = val;
                    break;
                }
            }
            // std.debug.print("Seed: {}, Pos: {}\n", .{ seed, new_pos });
        }
        // std.debug.print("Seed: {}, Pos: {}\n", .{ seed, new_pos });
        min = @min(min, new_pos);
    }
    std.log.info("Solution to first part is: {}", .{first_part(maps, seeds)});
    std.log.info("Solution to second part is: {}", .{try second_part(alloc, maps, seeds)});
}

fn first_part(maps: anytype, seeds: ArrayList(i64)) i64 {
    var min: i64 = std.math.maxInt(i64);
    for (seeds.items) |seed| {
        var new_pos = seed;
        for (maps) |map| {
            for (map.items) |map_unit| {
                if (map_unit.get_dest(new_pos)) |val| {
                    //If we return a valid value then we go to the next map
                    new_pos = val;
                    break;
                }
            }
            // std.debug.print("Seed: {}, Pos: {}\n", .{ seed, new_pos });
        }
        // std.debug.print("Seed: {}, Pos: {}\n", .{ seed, new_pos });
        min = @min(min, new_pos);
    }
    return min;
}

fn second_part(alloc: Allocator, maps: anytype, fake_seeds: ArrayList(i64)) !i64 {
    var seeds = ArrayList(i64).init(alloc);
    defer seeds.deinit();
    var min: i64 = std.math.maxInt(i64);
    var i: usize = 0;
    while (i <= fake_seeds.items.len - 2) : (i += 2) {
        const base = fake_seeds.items[i];
        const length = fake_seeds.items[i + 1];
        var j: i64 = 0;
        while (j < length) : (j += 1) {
            try seeds.append(base + j);
        }
    }
    for (seeds.items) |seed| {
        var new_pos = seed;
        for (maps) |map| {
            for (map.items) |map_unit| {
                if (map_unit.get_dest(new_pos)) |val| {
                    //If we return a valid value then we go to the next map
                    new_pos = val;
                    break;
                }
            }
            // std.debug.print("Seed: {}, Pos: {}\n", .{ seed, new_pos });
        }
        // std.debug.print("Seed: {}, Pos: {}\n", .{ seed, new_pos });
        min = @min(min, new_pos);
    }
    return min;
}
