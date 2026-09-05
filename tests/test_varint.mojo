from std.collections import List
from std.testing import TestSuite, assert_equal, assert_raises

from protobuf import DecodeError
from bytes_util import bytes_of, hex_of
from wire.varint import decode_varint, encode_varint, varint_len


def _expect(value: UInt64, want: List[Byte]) raises:
    var got = encode_varint(value)
    assert_equal(len(got), len(want), msg=hex_of(got))
    for i in range(len(want)):
        assert_equal(Int(got[i]), Int(want[i]), msg=hex_of(got))
    assert_equal(varint_len(value), len(want))
    var decoded = decode_varint(got)
    assert_equal(decoded, value)


def test_spec_150() raises:
    # protobuf.dev: 150 -> 96 01
    _expect(150, bytes_of(0x96, 0x01))


def test_small_varints() raises:
    _expect(0, bytes_of(0x00))
    _expect(1, bytes_of(0x01))
    _expect(127, bytes_of(0x7F))
    _expect(128, bytes_of(0x80, 0x01))
    _expect(300, bytes_of(0xAC, 0x02))


def test_int32_negative_one() raises:
    # proto3 int32 -1 sign-extends to UInt64.MAX → 10-byte varint ff..ff 01
    var got = encode_varint(UInt64.MAX)
    assert_equal(len(got), 10)
    for i in range(9):
        assert_equal(Int(got[i]), 0xFF)
    assert_equal(Int(got[9]), 0x01)
    assert_equal(decode_varint(got), UInt64.MAX)


def test_truncated() raises:
    var buf = bytes_of(0x80)
    with assert_raises(contains="kind=1"):
        _ = decode_varint(buf)


def test_overlong_rejected() raises:
    # 10th byte with continuation / high payload bits.
    var buf = List[Byte]()
    for _ in range(9):
        buf.append(Byte(0x80))
    buf.append(Byte(0x02))
    with assert_raises(contains="kind=2"):
        _ = decode_varint(buf)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
