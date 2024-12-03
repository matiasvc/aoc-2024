const std = @import("std");
const fs = std.fs;

fn compareI32(context: i32, item: i32) std.math.Order {
    return std.math.order(context, item);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try fs.cwd().openFile("day01.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    const read_bytes = try file.readAll(buffer);
    const content = buffer[0..read_bytes];
    var lines = std.mem.splitScalar(u8, content, '\n');

    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();
    var list2 = std.ArrayList(i32).init(allocator);
    defer list2.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) { continue; }
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        const num1 = try std.fmt.parseInt(i32, tokens.next().?, 10);
        const num2 = try std.fmt.parseInt(i32, tokens.next().?, 10);

        try list1.append(num1);
        try list2.append(num2);
    }

    // Sort the lists
    std.mem.sortUnstable(i32, list1.items, {},  comptime std.sort.asc(i32));
    std.mem.sortUnstable(i32,list2.items, {},  comptime std.sort.asc(i32));

    var distance_sum: u64 = 0;

    for (0..list1.items.len) |i| {
        distance_sum += @abs(list1.items[i] - list2.items[i]);
    }

    std.debug.print("Part one answer: {d}\n", .{distance_sum});

    var simularity_sum: i32 = 0;

    for (list1.items) |value| {
        const index = std.sort.lowerBound(
            i32, list2.items, value, compareI32);

        var items_found: u16 = 0;

        while (index < list2.items.len and list2.items[index + @as(usize, items_found)] == value) {
            items_found += 1;
        }

        simularity_sum += value * items_found;
    }

    std.debug.print("Part two answer: {d}\n", .{simularity_sum});
}

