const std = @import("std");
const data = @embedFile("data.txt");
const test_data = @embedFile("test.txt");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Race = struct {
    time: i64,
    record: i64,
};

fn parseInputP1(alloc: Allocator, ibuff: []const u8) !ArrayList(Race) {
    var races = ArrayList(Race).init(alloc);
    var lines = std.mem.tokenizeScalar(u8, ibuff, '\n');
    var l1 = lines.next().?;
    var l2 = lines.next().?;
    var l1i = std.mem.tokenizeScalar(u8, l1, ' ');
    var l2i = std.mem.tokenizeScalar(u8, l2, ' ');
    _ = l1i.next();
    _ = l2i.next();
    while (l1i.next()) |time| {
        if (l2i.next()) |record| {
            try races.append(Race{ .record = try std.fmt.parseInt(i64, record, 10), .time = try std.fmt.parseInt(i64, time, 10) });
        }
    }
    return races;
}

fn part1(races: []const Race) i64 {
    var sol: i64 = 1;
    for (races) |race| {
        var counter: i64 = 0;
        for (1..(@intCast(race.time))) |aux| {
            const vel: i64 = @intCast(aux);
            const dist = (race.time - vel) * vel;
            if (dist > race.record) {
                counter += 1;
            }
        }
        sol *= counter;
    }
    return sol;
}

test "Part 1" {
    const alloc = std.testing.allocator;
    const races = try parseInputP1(alloc, test_data);
    defer races.deinit();
    const sol = part1(races.items);
    try std.testing.expectEqual(@as(i64, 288), sol);
}

fn parseInputP2(ibuff: []const u8) !Race {
    var buff: [40]u8 = undefined;
    var lines = std.mem.tokenizeScalar(u8, ibuff, '\n');
    var l1 = lines.next().?;
    var l2 = lines.next().?;
    var l1i = std.mem.tokenizeScalar(u8, l1, ' ');
    var l2i = std.mem.tokenizeScalar(u8, l2, ' ');
    _ = l1i.next();
    _ = l2i.next();
    var c: usize = 0;
    while (l1i.next()) |num_str| {
        std.mem.copy(u8, buff[c..], num_str);
        c += num_str.len;
    }
    const time = try std.fmt.parseInt(i64, buff[0..c], 10);
    c = 0;
    while (l2i.next()) |num_str| {
        std.mem.copy(u8, buff[c..], num_str);
        c += num_str.len;
    }
    const record = try std.fmt.parseInt(i64, buff[0..c], 10);
    return Race{ .time = time, .record = record };
}

fn part2(race: Race) i64 {
    var sol: i64 = 0;
    for (1..(@intCast(race.time))) |aux| {
        const vel: i64 = @intCast(aux);
        const dist = (race.time - vel) * vel;
        if (dist > race.record) {
            sol += 1;
        }
    }
    return sol;
}

test "Part 2" {
    const race = try parseInputP2(test_data);
    const sol = part2(race);
    try std.testing.expectEqual(@as(i64, 71503), sol);
}

pub fn main() !void {
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_alloc.deinit();
    var alloc = arena_alloc.allocator();
    const races = try parseInputP1(alloc, data);
    const sol1 = part1(races.items);
    const race = try parseInputP2(data);
    const sol2 = part2(race);
    std.log.info("Solution to part 1: {}", .{sol1});
    std.log.info("Solution to part 2: {}", .{sol2});
}
