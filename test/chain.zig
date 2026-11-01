//! Minimal hash-chain fixture used to prove that a PCSC seal protects a chain
//! head. The production chain implementation remains a concern of the caller.

const std = @import("std");

const Hash = std.crypto.hash.sha2.Sha256;

pub const digest_len = Hash.digest_length * 2;
pub const Digest = [digest_len]u8;

pub fn of(bytes: []const u8) Digest {
    var digest: [Hash.digest_length]u8 = undefined;
    Hash.hash(bytes, &digest, .{});
    return std.fmt.bytesToHex(digest, .lower);
}

pub const Verdict = enum { intact, broken };
pub const Ending = enum { complete };

pub const Report = struct {
    verdict: Verdict,
};

pub const Verifier = struct {
    expected: Digest,
    broken: bool = false,

    pub fn init(header: Digest) Verifier {
        return .{ .expected = header };
    }

    pub fn take(self: *Verifier, id: u64, line: []const u8, prev: []const u8) void {
        _ = id;
        if (!std.mem.eql(u8, prev, &self.expected)) self.broken = true;
        self.expected = of(line);
    }

    pub fn finish(self: Verifier, ending: Ending, at: u64) Report {
        _ = ending;
        _ = at;
        return .{ .verdict = if (self.broken) .broken else .intact };
    }
};
