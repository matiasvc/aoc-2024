const std = @import("std");
const fs = std.fs;

inline fn expect(str: []const u8, content: []const u8) bool {
    // Does `str` fit within the remaining data in `content`
    if (str.len > content.len) {
        return false;
    }

    for (0..str.len) |index| {
        if (str[index] != content[index]) {
            return false;
        }
    }

    return true;
}

inline fn parse_number(content: []const u8) ?usize {
    var num_digits: usize = 0;

    while (num_digits < 3 and num_digits < content.len) : (num_digits += 1) {
        if (!std.ascii.isDigit(content[num_digits])) {
            break;
        }
    }

    if (num_digits == 0) {
        return null;
    }

    return num_digits;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try fs.cwd().openFile("day03.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    const read_bytes = try file.readAll(buffer);
    const content = buffer[0..read_bytes];

    var pos: usize = 0;

    var sum: i32 = 0;
    var sum_enabled: i32 = 0;

    var mul_enabled = true;
    while (pos < content.len) {
        if (expect("do()", content[pos..])) {
            mul_enabled = true;
            pos += 4;
            continue;
        } else if (expect("don't()", content[pos..])) {
            mul_enabled = false;
            pos += 7;
            continue;
        } else if (expect("mul", content[pos..])) {
            pos += 3;
        } else {
            pos += 1;
            continue;
        }

        if (expect("(", content[pos..])) {
            pos += 1;
        } else {
            continue;
        }

        var first_number: i32 = undefined;
        if (parse_number(content[pos..])) |digits| {
            first_number = try std.fmt.parseInt(i32, content[pos .. pos + digits], 10);
            pos += digits;
        } else {
            continue;
        }

        if (expect(",", content[pos..])) {
            pos += 1;
        } else {
            continue;
        }

        var second_number: i32 = undefined;
        if (parse_number(content[pos..])) |digits| {
            second_number = try std.fmt.parseInt(i32, content[pos .. pos + digits], 10);
            pos += digits;
        } else {
            continue;
        }

        if (expect(")", content[pos..])) {
            pos += 1;
        } else {
            continue;
        }

        sum += first_number * second_number;
        if (mul_enabled) {
            sum_enabled += first_number * second_number;
        }
    }

    std.debug.print("Part one: {d}\n", .{sum});
    std.debug.print("Part two: {d}\n", .{sum_enabled});
}
