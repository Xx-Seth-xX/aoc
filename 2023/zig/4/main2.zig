const std = @import("std");
const data = @embedFile("data.txt");
const no_of_cards: usize = blk: {
    @setEvalBranchQuota(100000);
    break :blk std.mem.count(u8, data, "\n");
};
var card_counter: @Vector(no_of_cards, u64) = @splat(1);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    // We will store the winning numbers in a set
    var bag = std.AutoHashMap(u32, void).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var card_n: u64 = 1;
    while (lines.next()) |line| {
        var line_points: u64 = 0;

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
                line_points += 1;
            }
        }
        std.debug.print("{}, {}\n", .{ card_n, line_points });
        for ((card_n)..(card_n + line_points)) |i| {
            card_counter[i] += card_counter[card_n - 1];
        }
        std.debug.print("- {}\n", .{card_counter});
        card_n += 1;
    }

    std.log.info("{}", .{@reduce(std.builtin.ReduceOp.Add, card_counter)});
}
