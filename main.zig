const std = @import("std");
const httpz = @import("httpz");
const zmpl = @import("zmpl");
const css = @embedFile("templates/output.css");

// global general purpose allocator used
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// sample data struct for CRUD
const Company = struct {
    id: []const u8,
    company: []const u8,
    contact: []const u8,
    country: []const u8,
};
var data = std.ArrayList(Company).init(allocator);

pub fn main() !void {
    // load initial data
    try data.append(.{ .id = "1", .company = "Amazon", .contact = "Jeff Bezos", .country = "United States" });
    try data.append(.{ .id = "2", .company = "Apple", .contact = "Tim Cook", .country = "United States" });
    try data.append(.{ .id = "3", .company = "Microsoft", .contact = "Satya Nadella", .country = "United States" });
    defer data.deinit();
    // parse env
    const addr = std.process.getEnvVarOwned(allocator, "ADDR") catch "127.0.0.1";
    const port = try std.fmt.parseUnsigned(u16, std.process.getEnvVarOwned(allocator, "PORT") catch "3000", 10);
    // server config
    var server = try httpz.Server().init(allocator, .{ .address = addr, .port = port, .request = .{
        .max_form_count = 4,
    } });
    // routes
    var router = server.router();
    router.get("/", index);
    router.get("/css/output.css", cssGet);
    router.get("/company/add", companyAdd);
    router.get("/company/edit/:id", companyEdit);
    router.get("/company", companyGet);
    router.get("/company/:id", companyGet);
    router.put("/company/:id", companyPut);
    router.post("/company", companyPost);
    router.delete("/company/:id", companyDelete);
    router.get("/metrics", metrics);
    // init server
    std.log.info("listening at http://{s}:{d}/", .{ addr, port });
    try server.listen();
}

fn index(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
    defer d.deinit();
    var root = try d.root(.object);
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.renderWithOptions(
            &d,
            .{ .layout = zmpl.find("index") },
        );
        res.body = output;
        res.content_type = .HTML;
    }
}

fn cssGet(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    res.content_type = .CSS;
    res.body = css;
}

fn companyAdd(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
    defer d.deinit();
    var root = try d.root(.object);
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.renderWithOptions(
            &d,
            .{ .layout = zmpl.find("company_add") },
        );
        res.body = output;
        res.content_type = .HTML;
    }
}

fn companyEdit(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
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
        const output = try template.render(&d);
        res.body = output;
        res.content_type = .HTML;
    }
}

fn companyGet(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
    defer d.deinit();
    var root = try d.root(.object);
    //const id = req.param("id").? ;
    res.content_type = .HTML;
    if (req.param("id")) |id| {
        for (data.items) |company| {
            if (std.mem.eql(u8, company.id, id)) {
                try root.put("id", company.id);
                try root.put("company", company.company);
                try root.put("contact", company.contact);
                try root.put("country", company.country);
                if (zmpl.find("row_get")) |template| {
                    const output = try template.render(&d);
                    res.body = output;
                    return;
                }
            }
        }
    }
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.renderWithOptions(
            &d,
            .{ .layout = zmpl.find("companies") },
        );
        res.body = output;
    }
}

fn companyPut(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
    defer d.deinit();
    var root = try d.root(.object);
    const fd = try req.formData();
    if (req.param("id")) |id| {
        for (data.items, 0..) |c, i| {
            if (std.mem.eql(u8, c.id, id)) {
                data.items[i].company = try allocator.dupe(u8, fd.get("company") orelse "");
                data.items[i].contact = try allocator.dupe(u8, fd.get("contact") orelse "");
                data.items[i].country = try allocator.dupe(u8, fd.get("country") orelse "");
                try root.put("id", id);
                try root.put("company", fd.get("company"));
                try root.put("contact", fd.get("contact"));
                try root.put("country", fd.get("country"));
                if (zmpl.find("row_get")) |template| {
                    const output = try template.render(&d);
                    res.body = output;
                    res.content_type = .HTML;
                    return;
                }
            }
        }
    }
}

fn companyPost(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
    defer d.deinit();
    const fd = try req.formData();
    var max: u32 = 0;
    for (data.items) |c| {
        const n = try std.fmt.parseUnsigned(u32, c.id, 10);
        if (n > max) max = n;
    }
    const id = try std.fmt.allocPrint(res.arena, "{d}", .{max + 1});
    try data.append(.{ .id = try allocator.dupe(u8, id), .company = try allocator.dupe(u8, fd.get("company") orelse ""), .contact = try allocator.dupe(u8, fd.get("contact") orelse ""), .country = try allocator.dupe(u8, fd.get("country") orelse "") });
    var root = try d.root(.object);
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.renderWithOptions(
            &d,
            .{ .layout = zmpl.find("companies") },
        );
        res.content_type = .HTML;
        res.body = output;
    }
}

fn companyDelete(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    var d = zmpl.Data.init(res.arena);
    defer d.deinit();
    var root = try d.root(.object);
    if (req.param("id")) |id| {
        for (data.items, 0..) |c, i| _ = if (std.mem.eql(u8, c.id, id)) data.swapRemove(i);
    }
    try root.put("companies", data.items);
    if (zmpl.find("row")) |template| {
        const output = try template.renderWithOptions(
            &d,
            .{ .layout = zmpl.find("companies") },
        );
        res.content_type = .HTML;
        res.body = output;
    }
}

fn metrics(req: *httpz.Request, res: *httpz.Response) !void {
    var timer = try std.time.Timer.start();
    defer {
        const elapsed = timer.lap() / 1000;
        std.log.info("{any} {s} from {any} {d}ms", .{ req.method, req.url.raw, req.address, elapsed });
    }
    res.content_type = .TEXT;
    return httpz.writeMetrics(res.writer());
}
