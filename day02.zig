const std = @import("std");
const assert = std.debug.assert;
const fs = std.fs;

fn is_safe(nums: []const i32) bool {
    const diff_sign: i32 = std.math.sign(nums[1] - nums[0]);

    for (0..nums.len - 1) |i| {
        const diff = nums[i + 1] - nums[i];

        if ((diff_sign != std.math.sign(diff)) or (@abs(diff) < 1) or (@abs(diff) > 3)) {
            return false;
        }
    }

    return true;
}

pub fn main() !void {
    const file = try fs.cwd().openFile("day02.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try std.heap.page_allocator.alloc(u8, file_size);
    defer std.heap.page_allocator.free(buffer);

    const read_bytes = try file.readAll(buffer);
    const content = buffer[0..read_bytes];
    var lines = std.mem.splitScalar(u8, content, '\n');

    var num_safe: i32 = 0;
    var num_skip_safe: i32 = 0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        var num_list = std.ArrayList(i32).init(allocator);
        defer num_list.deinit();

        while (tokens.next()) |token| {
            const num = try std.fmt.parseInt(i32, token, 10);
            try num_list.append(num);
        }

        const safe: bool = is_safe(num_list.items);

        if (safe) {
            num_safe += 1;
            num_skip_safe += 1;
            continue;
        }

        var skip_safe = false;

        for (0..num_list.items.len) |skip_index| {
            var num_list_skip = std.ArrayList(i32).init(allocator);
            defer num_list_skip.deinit();

            for (0..num_list.items.len) |index| {
                if (index == skip_index) {
                    continue;
                }
                try num_list_skip.append(num_list.items[index]);
            }
            skip_safe = is_safe(num_list_skip.items);

            if (skip_safe) {
                break;
            }
        }

        if (skip_safe) {
            num_skip_safe += 1;
            continue;
        }

        _ = arena.reset(.retain_capacity);
    }

    std.debug.print("Part one answer: {d}\n", .{num_safe});
    std.debug.print("Part two answer: {d}\n", .{num_skip_safe});
}
