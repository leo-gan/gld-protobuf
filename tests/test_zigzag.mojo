from std.collections import List
from std.testing import TestSuite, assert_equal

from wire.zigzag import (
    zigzag_decode_i32,
    zigzag_decode_i64,
    zigzag_encode_i32,
    zigzag_encode_i64,
)


def test_zigzag_i32_spec_table() raises:
    assert_equal(zigzag_encode_i32(0), 0)
    assert_equal(zigzag_encode_i32(-1), 1)
    assert_equal(zigzag_encode_i32(1), 2)
    assert_equal(zigzag_encode_i32(-2), 3)
    assert_equal(zigzag_encode_i32(2), 4)
    assert_equal(zigzag_encode_i32(Int32.MIN), UInt32.MAX)
    assert_equal(zigzag_decode_i32(0), 0)
    assert_equal(zigzag_decode_i32(1), -1)
    assert_equal(zigzag_decode_i32(2), 1)
    assert_equal(zigzag_decode_i32(UInt32.MAX), Int32.MIN)


def test_zigzag_i64_roundtrip() raises:
    var samples = [
        Int64(0),
        Int64(-1),
        Int64(1),
        Int64.MIN,
        Int64.MAX,
        Int64(-42),
    ]
    for i in range(len(samples)):
        var n = samples[i]
        assert_equal(zigzag_decode_i64(zigzag_encode_i64(n)), n)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
