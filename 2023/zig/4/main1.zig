const std = @import("std");
const data = @embedFile("data.txt");

pub fn main() !void {
    var solution: u32 = 0;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    // We will store the winning numbers in a set
    var bag = std.AutoHashMap(u32, void).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var line_points: u32 = 0;
        defer line_points = 0;
        var record_string = blk: {
            var it = std.mem.tokenizeAny(u8, line, "|:");
            _ = it.next();
            break :blk it;
        };
        // std.debug.print("{s}\n", .{record_string.next().?});
        const winning_string = record_string.next().?;
        const playing_string = record_string.next().?;
        // We need to fill the bag
        var bag_it = std.mem.tokenizeScalar(u8, winning_string, ' ');
        while (bag_it.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try bag.put(num, {});
        }
        // After every loop we must empty the bag
        defer bag.clearAndFree();

        // {
        //     var it = bag.keyIterator();
        //     while (it.next()) |k| {
        //         std.debug.print("{}, ", .{k.*});
        //     }
        //     std.debug.print("\n", .{});
        // }
        var mynums_it = std.mem.tokenizeScalar(u8, playing_string, ' ');
        while (mynums_it.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            if (bag.contains(num)) {
                if (line_points == 0) {
                    line_points = 1;
                } else {
                    line_points <<= 1;
                }
            }
        }
        solution += line_points;
    }
    std.log.info("{}", .{solution});
}
