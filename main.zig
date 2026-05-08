const std = @import("std");
const httpz = @import("httpz");
const zmpl = @import("zmpl");
const css = @embedFile("templates/output.css");

const Company = struct {
    id: []const u8,
    company: []const u8,
    contact: []const u8,
    country: []const u8,
};

var data: std.ArrayList(Company) = .empty;
var global_io: std.Io = undefined;
var global_gpa: std.mem.Allocator = undefined;

pub fn main(init: std.process.Init) !void {
    global_gpa = init.gpa;
    global_io = init.io;

    try data.append(std.heap.page_allocator, .{ .id = "1", .company = "Amazon", .contact = "Jeff Bezos", .country = "United States" });
    try data.append(std.heap.page_allocator, .{ .id = "2", .company = "Apple", .contact = "Tim Cook", .country = "United States" });
    try data.append(std.heap.page_allocator, .{ .id = "3", .company = "Microsoft", .contact = "Satya Nadella", .country = "United States" });
    defer data.deinit(std.heap.page_allocator);

    const addr_str = init.environ_map.get("ADDR") orelse "127.0.0.1";
    const port_str = init.environ_map.get("PORT") orelse "3000";
    const port = try std.fmt.parseUnsigned(u16, port_str, 10);
    const addr: httpz.Config.Address = .{ .ip = try std.Io.net.IpAddress.resolve(init.io, addr_str, port) };

    var server = try httpz.Server(void).init(init.io, global_gpa, .{
        .address = addr,
        .request = .{
            .max_form_count = 4,
        },
    }, {});
    defer server.deinit();
    defer server.stop();

    var router = try server.router(.{});
    router.get("/", index, .{});
    router.get("/css/output.css", cssGet, .{});
    router.get("/company/add", companyAdd, .{});
    router.get("/company/edit/:id", companyEdit, .{});
    router.get("/company", companyGet, .{});
    router.get("/company/:id", companyGet, .{});
    router.put("/company/:id", companyPut, .{});
    router.post("/company", companyPost, .{});
    router.delete("/company/:id", companyDelete, .{});
    router.get("/metrics", metrics, .{});

    std.log.info("listening at http://{s}:{d}/", .{ addr_str, port });
    try server.listen();
}

fn logStart() std.Io.Timestamp {
    return std.Io.Clock.awake.now(global_io);
}

fn logEnd(req: *httpz.Request, start: std.Io.Timestamp) void {
    const end = std.Io.Clock.awake.now(global_io);
    const elapsed = start.durationTo(end);
    var buf: [64]u8 = undefined;
    var w = std.Io.Writer.fixed(&buf);
    req.address.format(&w) catch {};
    const addr_str = std.Io.Writer.buffered(&w);
    std.log.info("{any} {s} from {s} {d}ms", .{ req.method, req.url.raw, addr_str, elapsed.toMilliseconds() });
}

fn index(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    var root = try d.root(.object);
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{ .layout = zmpl.find("index") });
        res.body = try res.arena.dupe(u8, output);
        res.content_type = .HTML;
    }
}

fn cssGet(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    res.content_type = .CSS;
    res.body = try res.arena.dupe(u8, css);
}

fn companyAdd(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    var root = try d.root(.object);
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{ .layout = zmpl.find("company_add") });
        res.body = try res.arena.dupe(u8, output);
        res.content_type = .HTML;
    }
}

fn companyEdit(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    var root = try d.root(.object);
    const id = req.param("id").?;
    var company: Company = undefined;
    for (data.items) |c| {
        if (std.mem.eql(u8, c.id, id)) {
            company = c;
        }
    }
    try root.put("id", company.id);
    try root.put("company", company.company);
    try root.put("contact", company.contact);
    try root.put("country", company.country);
    if (zmpl.find("row_edit")) |template| {
        const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{});
        res.body = try res.arena.dupe(u8, output);
        res.content_type = .HTML;
    }
}

fn companyGet(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    var root = try d.root(.object);
    res.content_type = .HTML;
    if (req.param("id")) |id| {
        for (data.items) |company| {
            if (std.mem.eql(u8, company.id, id)) {
                try root.put("id", company.id);
                try root.put("company", company.company);
                try root.put("contact", company.contact);
                try root.put("country", company.country);
                if (zmpl.find("row_get")) |template| {
                    const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{});
                    res.body = try res.arena.dupe(u8, output);
                    return;
                }
            }
        }
    }
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{ .layout = zmpl.find("companies") });
        res.body = try res.arena.dupe(u8, output);
    }
}

fn companyPut(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    var root = try d.root(.object);
    const fd = try req.formData();
    if (req.param("id")) |id| {
        for (data.items, 0..) |c, i| {
            if (std.mem.eql(u8, c.id, id)) {
                data.items[i].company = try res.arena.dupe(u8, fd.get("company") orelse "");
                data.items[i].contact = try res.arena.dupe(u8, fd.get("contact") orelse "");
                data.items[i].country = try res.arena.dupe(u8, fd.get("country") orelse "");
                try root.put("id", id);
                try root.put("company", fd.get("company"));
                try root.put("contact", fd.get("contact"));
                try root.put("country", fd.get("country"));
                if (zmpl.find("row_get")) |template| {
                    const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{});
                    res.body = try res.arena.dupe(u8, output);
                    res.content_type = .HTML;
                    return;
                }
            }
        }
    }
}

fn companyPost(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    const fd = try req.formData();
    var max: u32 = 0;
    for (data.items) |c| {
        const n = try std.fmt.parseUnsigned(u32, c.id, 10);
        if (n > max) max = n;
    }
    const id = try std.fmt.allocPrint(res.arena, "{d}", .{max + 1});
    try data.append(std.heap.page_allocator, .{ .id = try res.arena.dupe(u8, id), .company = try res.arena.dupe(u8, fd.get("company") orelse ""), .contact = try res.arena.dupe(u8, fd.get("contact") orelse ""), .country = try res.arena.dupe(u8, fd.get("country") orelse "") });
    var root = try d.root(.object);
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{ .layout = zmpl.find("companies") });
        res.content_type = .HTML;
        res.body = try res.arena.dupe(u8, output);
    }
}

fn companyDelete(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    var d = zmpl.Data.init(global_io, global_gpa);
    defer d.deinit();
    var root = try d.root(.object);
    if (req.param("id")) |id| {
        for (data.items, 0..) |c, i| _ = if (std.mem.eql(u8, c.id, id)) data.swapRemove(i);
    }
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.render(global_io, &d, null, null, &[_]zmpl.Template.Block{}, .{ .layout = zmpl.find("companies") });
        res.content_type = .HTML;
        res.body = try res.arena.dupe(u8, output);
    }
}

fn metrics(req: *httpz.Request, res: *httpz.Response) !void {
    const start = logStart();
    defer logEnd(req, start);
    res.content_type = .TEXT;
    return httpz.writeMetrics(res.writer());
}
