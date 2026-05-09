const std = @import("std");
const zmpl_build = @import("zmpl");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const templates_paths = try zmpl_build.templatesPaths(
        b.graph.io,
        b.allocator,
        &.{
            .{ .prefix = "", .path = &.{
                "templates",
            } },
        },
    );
    const zmpl_dep = b.dependency("zmpl", .{
        .target = target,
        .optimize = optimize,
        .zmpl_templates_paths = templates_paths,
    }).module("zmpl");
    const httpz_dep = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    }).module("httpz");
    const exe = b.addExecutable(.{
        .name = "zig-htmx-tailwind-example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zmpl", .module = zmpl_dep },
                .{ .name = "httpz", .module = httpz_dep },
            },
        }),
    });
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
