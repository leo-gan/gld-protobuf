from std.collections import Optional
from std.testing import TestSuite, assert_equal, assert_true

from scalars import Color, Color_RED, Scalars
from protobuf import WireReader, WireType, WireWriter
from bytes_util import bytes_of


def test_scalars_roundtrip() raises:
    var msg = Scalars()
    msg.u32 = 7
    msg.u64 = 9
    msg.s32 = -2
    msg.s64 = -3
    msg.fx32 = 11
    msg.fx64 = 13
    msg.sfx32 = -4
    msg.sfx64 = -5
    msg.f32 = 1.5
    msg.data.append(0x61)
    msg.data.append(0x62)
    msg.color = Color(Color_RED)
    msg.packed_s32.append(-1)
    msg.packed_s32.append(2)
    msg.unpacked_s32.append(3)
    msg.maybe = Optional(Int32(0))
    var buf = msg.encode()
    var got = Scalars.decode(buf)
    assert_equal(got.u32, UInt32(7))
    assert_equal(got.u64, UInt64(9))
    assert_equal(got.s32, Int32(-2))
    assert_equal(got.s64, Int64(-3))
    assert_equal(got.fx32, UInt32(11))
    assert_equal(got.fx64, UInt64(13))
    assert_equal(got.sfx32, Int32(-4))
    assert_equal(got.sfx64, Int64(-5))
    assert_equal(got.f32, Float32(1.5))
    assert_equal(len(got.data), 2)
    assert_equal(got.color.value, Color_RED)
    assert_equal(len(got.packed_s32), 2)
    assert_equal(got.packed_s32[0], Int32(-1))
    assert_equal(len(got.unpacked_s32), 1)
    assert_true(Bool(got.maybe))
    assert_equal(got.maybe.value(), Int32(0))
    assert_equal(got, msg)


def test_unknown_enum_retained() raises:
    var msg = Scalars()
    msg.color = Color(Int32(99))
    var got = Scalars.decode(msg.encode())
    assert_equal(got.color.value, Int32(99))


def test_unpacked_sint32_decodes() raises:
    var enc = WireWriter(capacity=16)
    enc.write_tag(13, WireType.VARINT)
    enc.write_varint(UInt64(6))  # zigzag of 3
    var buf = enc^.finish()
    var got = Scalars.decode(buf)
    assert_equal(len(got.unpacked_s32), 1)
    assert_equal(got.unpacked_s32[0], Int32(3))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
