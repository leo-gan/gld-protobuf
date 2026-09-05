from std.testing import TestSuite, assert_equal, assert_raises

from protobuf import DecodeError, WireReader, WireType, WireWriter
from bytes_util import bytes_of


def test_tag_field1_varint() raises:
    # field 1, VARINT -> 0x08
    var enc = WireWriter(capacity=4)
    enc.write_tag(1, WireType.VARINT)
    var buf = enc^.finish()
    assert_equal(len(buf), 1)
    assert_equal(Int(buf[0]), 0x08)
    var dec = WireReader(buf)
    var tag = dec.read_tag()
    var field = tag[0]
    var wire = tag[1]
    assert_equal(field, 1)
    assert_equal(wire, WireType.VARINT)


def test_tag_field1_int32_150() raises:
    # official combined example: 08 96 01
    var enc = WireWriter(capacity=8)
    enc.write_tag(1, WireType.VARINT)
    enc.write_varint(150)
    var buf = enc^.finish()
    var want = bytes_of(0x08, 0x96, 0x01)
    assert_equal(len(buf), 3)
    for i in range(3):
        assert_equal(Int(buf[i]), Int(want[i]))


def test_field_zero_rejected() raises:
    var buf = bytes_of(0x00)
    var dec = WireReader(buf)
    with assert_raises(contains="kind=6"):
        _ = dec.read_tag()


def test_groups_rejected() raises:
    # field 1, SGROUP = (1 << 3) | 3 = 11
    var buf = bytes_of(0x0B)
    var dec = WireReader(buf)
    with assert_raises(contains="kind=3"):
        _ = dec.read_tag()


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
