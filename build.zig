const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const pcsc = b.addModule("pcsc", .{
        .root_source_file = b.path("lib/pcsc.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{ .root_module = pcsc });
    const run_tests = b.addRunArtifact(tests);
    run_tests.skip_foreign_checks = true;

    const test_step = b.step("test", "Run the test suite");
    test_step.dependOn(&run_tests.step);

    const verify_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/verify.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "pcsc", .module = pcsc }},
        }),
    });
    const run_verify_tests = b.addRunArtifact(verify_tests);
    run_verify_tests.skip_foreign_checks = true;
    test_step.dependOn(&run_verify_tests.step);

    const daemon_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/pcscd.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "pcsc", .module = pcsc }},
        }),
    });
    const run_daemon_tests = b.addRunArtifact(daemon_tests);
    run_daemon_tests.skip_foreign_checks = true;
    test_step.dependOn(&run_daemon_tests.step);
}
