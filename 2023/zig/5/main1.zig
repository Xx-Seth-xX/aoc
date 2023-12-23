const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const data = @embedFile("data.txt");
const MapList = [7]ArrayList(MapUnit);
const MapUnit = struct {
    const Self = @This();
    jump_size: i64,
    source: i64,
    source_end: i64,
    pub fn init(source: i64, destination: i64, length: i64) Self {
        const jump_size = destination - source;
        return Self{
            .jump_size = jump_size,
            .source = source,
            .source_end = source + length - 1,
        };
    }
    pub fn get_dest(self: Self, seed: i64) ?i64 {
        if (seed > self.source_end or seed < self.source) {
            return null;
        }
        return seed + self.jump_size;
    }
    pub fn get_overlap(self: Self, sr: SeedRange) ?[2]i64 {
        if (self.source_end < sr.start or self.source > sr.end) {
            return null;
        }
        const ov_start = @max(self.source, sr.start);
        const ov_end = @min(self.source_end, sr.end);
        return .{ ov_start, ov_end };
    }
};
const SeedRange = struct {
    const Self = @This();
    start: i64,
    end: i64,
    level: usize,
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

    var maps: MapList = undefined;
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

fn first_part(maps: MapList, seeds: ArrayList(i64)) i64 {
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

fn second_part(alloc: Allocator, maps: MapList, fake_seeds: ArrayList(i64)) !i64 {
    const Queue = std.SinglyLinkedList(SeedRange);
    var min: i64 = std.math.maxInt(i64);
    var queue = Queue{};
    {
        var i: usize = 0;
        while (i <= fake_seeds.items.len - 2) : (i += 2) {
            const start = fake_seeds.items[i];
            const end = start + fake_seeds.items[i + 1] - 1;
            var new_node = try alloc.create(Queue.Node);
            new_node.*.data = SeedRange{ .start = start, .end = end, .level = 0 };
            queue.prepend(new_node);
        }
    }
    while (queue.popFirst()) |node| {
        var sr: SeedRange = node.*.data;
        defer {
            min = @min(min, sr.start);
            alloc.destroy(node);
        }
        while (sr.level < 7) : (sr.level += 1) {
            // std.debug.print("{}\n", .{sr});
            const map = maps[sr.level];
            for (map.items) |map_unit| {
                if (map_unit.get_overlap(sr)) |overlap| {
                    if (overlap[0] > sr.start) {
                        var new_node = try alloc.create(Queue.Node);
                        new_node.*.data = SeedRange{
                            .start = sr.start,
                            .end = overlap[0] - 1,
                            .level = sr.level,
                        };
                        queue.prepend(new_node);
                    }
                    if (overlap[1] < sr.end) {
                        var new_node = try alloc.create(Queue.Node);
                        new_node.*.data = SeedRange{
                            .end = sr.end,
                            .start = overlap[1] + 1,
                            .level = sr.level,
                        };
                        queue.prepend(new_node);
                    }
                    sr.start = overlap[0] + map_unit.jump_size;
                    sr.end = overlap[1] + map_unit.jump_size;
                    break;
                }
            }
        }
    }
    return min;
}
