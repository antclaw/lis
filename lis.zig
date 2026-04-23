const std = @import("std");
const windows = std.os.windows;
const WINAPI = windows.WINAPI;

const FILE_ATTRIBUTE_DIRECTORY = 0x10;
const FILE_ATTRIBUTE_HIDDEN = 0x2;
const INVALID_HANDLE_VALUE = @as(windows.HANDLE, @ptrFromInt(@as(usize, @bitCast(@as(isize, -1)))));

extern "kernel32" fn FindFirstFileW(lpFileName: [*:0]const u16, lpFindFileData: *WIN32_FIND_DATAW) callconv(WINAPI) windows.HANDLE;
extern "kernel32" fn FindNextFileW(hFindFile: windows.HANDLE, lpFindFileData: *WIN32_FIND_DATAW) callconv(WINAPI) windows.BOOL;
extern "kernel32" fn FindClose(hFindFile: windows.HANDLE) callconv(WINAPI) windows.BOOL;
extern "kernel32" fn GetFileAttributesW(lpFileName: [*:0]const u16) callconv(WINAPI) windows.DWORD;
extern "kernel32" fn GetConsoleMode(hConsoleHandle: windows.HANDLE, lpMode: *windows.DWORD) callconv(WINAPI) windows.BOOL;
extern "kernel32" fn SetConsoleMode(hConsoleHandle: windows.HANDLE, dwMode: windows.DWORD) callconv(WINAPI) windows.BOOL;
extern "kernel32" fn GetStdHandle(nStdHandle: windows.DWORD) callconv(WINAPI) windows.HANDLE;
extern "kernel32" fn FileTimeToLocalFileTime(lpFileTime: *const windows.FILETIME, lpLocalFileTime: *windows.FILETIME) callconv(WINAPI) windows.BOOL;
extern "kernel32" fn FileTimeToSystemTime(lpFileTime: *const windows.FILETIME, lpSystemTime: *SYSTEMTIME) callconv(WINAPI) windows.BOOL;

const WIN32_FIND_DATAW = extern struct {
    dwFileAttributes: windows.DWORD,
    ftCreationTime: windows.FILETIME,
    ftLastAccessTime: windows.FILETIME,
    ftLastWriteTime: windows.FILETIME,
    nFileSizeHigh: windows.DWORD,
    nFileSizeLow: windows.DWORD,
    dwReserved0: windows.DWORD,
    dwReserved1: windows.DWORD,
    cFileName: [260]u16,
    cAlternateFileName: [14]u16,
};

const SYSTEMTIME = extern struct {
    wYear: u16,
    wMonth: u16,
    wDayOfWeek: u16,
    wDay: u16,
    wHour: u16,
    wMinute: u16,
    wSecond: u16,
    wMilliseconds: u16,
};

const ExtColor = struct {
    ext: [16]u8,
    color: u8,
};

var ext_colors: [50]ExtColor = undefined;
var ext_count: usize = 0;
var folder_color: u8 = 34;

fn parseColor(col: []const u8) u8 {
    if (std.mem.eql(u8, col, "black")) return 30;
    if (std.mem.eql(u8, col, "red")) return 31;
    if (std.mem.eql(u8, col, "green")) return 32;
    if (std.mem.eql(u8, col, "yellow")) return 33;
    if (std.mem.eql(u8, col, "blue")) return 34;
    if (std.mem.eql(u8, col, "magenta")) return 35;
    if (std.mem.eql(u8, col, "cyan")) return 36;
    if (std.mem.eql(u8, col, "white")) return 37;
    if (std.mem.eql(u8, col, "brightblack") or std.mem.eql(u8, col, "gray")) return 90;
    if (std.mem.eql(u8, col, "brightred")) return 91;
    if (std.mem.eql(u8, col, "brightgreen")) return 92;
    if (std.mem.eql(u8, col, "brightyellow")) return 93;
    if (std.mem.eql(u8, col, "brightblue")) return 94;
    if (std.mem.eql(u8, col, "brightmagenta")) return 95;
    if (std.mem.eql(u8, col, "brightcyan")) return 96;
    if (std.mem.eql(u8, col, "brightwhite")) return 97;
    return 37;
}

fn loadConfig() void {
    const file = std.fs.cwd().openFile("LIS.cfg", .{}) catch return;
    defer file.close();
    
    var buf: [1024]u8 = undefined;
    const len = file.readAll(&buf) catch return;
    var it = std.mem.split(u8, buf[0..len], "\n");
    
    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r\n");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;
        
        var parts = std.mem.split(u8, trimmed, ":");
        const ext = std.mem.trim(u8, parts.next() orelse continue, " ");
        const col = std.mem.trim(u8, parts.next() orelse continue, " ");
        
        if (std.mem.eql(u8, ext, "folder")) {
            folder_color = parseColor(col);
        } else if (ext_count < 50) {
            @memcpy(ext_colors[ext_count].ext[0..ext.len], ext);
            ext_colors[ext_count].ext[ext.len] = 0;
            ext_colors[ext_count].color = parseColor(col);
            ext_count += 1;
        }
    }
}

fn toLowerU16(c: u16) u16 {
    if (c >= 'A' and c <= 'Z') return c + 32;
    return c;
}

fn wcsicmp(a: []const u16, b: []const u16) bool {
    if (a.len != b.len) return false;
    for (a, b) |ca, cb| {
        if (toLowerU16(ca) != toLowerU16(cb)) return false;
    }
    return true;
}

fn getColor(name: []const u16, is_directory: bool) u8 {
    if (is_directory) return folder_color;
    
    if (name.len > 4 and name[name.len - 4] == '.') {
        const ext = name[name.len - 3 ..];
        var ext_buf: [16]u8 = undefined;
        for (ext, 0..) |c, i| {
            ext_buf[i] = @truncate(c);
        }
        
        for (ext_colors[0..ext_count]) |ec| {
            if (std.mem.eql(u8, ec.ext[0..3], ext_buf[0..3])) {
                return ec.color;
            }
        }
        
        if (wcsicmp(ext, &[_]u16{ 'e', 'x', 'e' }) or wcsicmp(ext, &[_]u16{ 'c', 'o', 'm' })) return 32;
        if (wcsicmp(ext, &[_]u16{ 'z', 'i', 'p' }) or wcsicmp(ext, &[_]u16{ 'r', 'a', 'r' }) or
            wcsicmp(ext, &[_]u16{ '7', 'z' }) or wcsicmp(ext, &[_]u16{ 't', 'a', 'r' }) or
            wcsicmp(ext, &[_]u16{ 'g', 'z' })) return 33;
    }
    return 37;
}

fn formatSize(size: u64, buf: []u8) []const u8 {
    if (size < 1024) {
        return std.fmt.bufPrint(buf, "{d:>10}", .{size}) catch unreachable;
    } else if (size < 1024 * 1024) {
        return std.fmt.bufPrint(buf, "{d:>9.1}K", .{@as(f64, @floatFromInt(size)) / 1024.0}) catch unreachable;
    } else if (size < 1024 * 1024 * 1024) {
        return std.fmt.bufPrint(buf, "{d:>9.1}M", .{@as(f64, @floatFromInt(size)) / (1024.0 * 1024.0)}) catch unreachable;
    } else {
        return std.fmt.bufPrint(buf, "{d:>9.1}G", .{@as(f64, @floatFromInt(size)) / (1024.0 * 1024.0 * 1024.0)}) catch unreachable;
    }
}

fn formatTime(ft: windows.FILETIME, buf: []u8) []const u8 {
    var st: SYSTEMTIME = undefined;
    var lt: windows.FILETIME = undefined;
    _ = FileTimeToLocalFileTime(&ft, &lt);
    _ = FileTimeToSystemTime(&lt, &st);
    return std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}", .{
        st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute,
    }) catch unreachable;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    
    var show_all = false;
    var show_long = false;
    
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);
    
    for (args[1..]) |arg| {
        if (arg.len > 0 and arg[0] == '-') {
            if (std.mem.indexOf(u8, arg, "a")) |_| show_all = true;
            if (std.mem.indexOf(u8, arg, "l")) |_| show_long = true;
        }
    }
    
    loadConfig();
    
    // Enable ANSI colors
    const hOut = GetStdHandle(@bitCast(@as(i32, -11)));
    var mode: windows.DWORD = 0;
    _ = GetConsoleMode(hOut, &mode);
    _ = SetConsoleMode(hOut, mode | 0x0004);
    
    var find_data: WIN32_FIND_DATAW = undefined;
    const handle = FindFirstFileW(std.unicode.utf8ToUtf16LeStringLiteral("*"), &find_data);
    if (handle == INVALID_HANDLE_VALUE) return;
    defer _ = FindClose(handle);
    
    while (true) {
        const name = std.mem.sliceTo(&find_data.cFileName, 0);
        
        if (!show_all and name[0] == '.') {
            if (FindNextFileW(handle, &find_data) == 0) break;
            continue;
        }
        
        const is_directory = (find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0;
        const color = getColor(name, is_directory);
        
        try stdout.print("\x1b[{d}m", .{color});
        
        if (show_long) {
            const size = (@as(u64, find_data.nFileSizeHigh) << 32) | find_data.nFileSizeLow;
            var size_buf: [32]u8 = undefined;
            var time_buf: [32]u8 = undefined;
            try stdout.print("{s} {s} ", .{
                formatSize(size, &size_buf),
                formatTime(find_data.ftLastWriteTime, &time_buf),
            });
        }
        
        try stdout.print("{s}", .{std.unicode.fmtUtf16Le(name)});
        if (is_directory) try stdout.print("/", .{});
        try stdout.print("\x1b[0m", .{});
        
        if (show_long) {
            try stdout.print("\n", .{});
        } else {
            try stdout.print("  ", .{});
        }
        
        if (FindNextFileW(handle, &find_data) == 0) {
            if (!show_long) try stdout.print("\n", .{});
            break;
        }
    }
}
