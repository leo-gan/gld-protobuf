from std.testing import TestSuite, assert_equal, assert_true

from protobuf import WireReader, WireType, WireWriter
from bytes_util import bytes_of
from manual_types import Message


def test_message_bytes_match_protoc() raises:
    # testdata/golden/message_populated.bin from scripts/gen_golden.py
    var msg = Message()
    msg.f_bool = True
    msg.f_int32 = 150
    msg.f_int64 = 1
    msg.f_float64 = 1.5
    msg.f_string = "hi"
    var buf = msg.encode()
    var want = bytes_of(
        0x08,
        0x01,
        0x10,
        0x96,
        0x01,
        0x18,
        0x01,
        0x21,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xF8,
        0x3F,
        0x2A,
        0x02,
        0x68,
        0x69,
    )
    assert_equal(len(buf), len(want), msg="populated Message length")
    for i in range(len(want)):
        assert_equal(Int(buf[i]), Int(want[i]))


def test_message_populated_matches_oracle() raises:
    # testdata/golden/message_populated.bin from scripts/gen_golden.py
    var msg = Message()
    msg.f_bool = True
    msg.f_int32 = 150
    msg.f_int64 = 1
    msg.f_float64 = 1.5
    msg.f_string = "hi"
    var buf = msg.encode()

    var dec = WireReader(buf)
    var saw_bool = False
    var saw_i32 = False
    var saw_str = False
    while dec.remaining() > 0:
        var tag = dec.read_tag()
        var field = tag[0]
        var wire = tag[1]
        if field == 1:
            saw_bool = True
            assert_equal(wire, WireType.VARINT)
            assert_equal(dec.read_varint(), 1)
        elif field == 2:
            saw_i32 = True
            assert_equal(dec.read_varint(), 150)
        elif field == 3:
            assert_equal(dec.read_varint(), 1)
        elif field == 4:
            assert_equal(Float64(from_bits=dec.read_i64_le()), 1.5)
        elif field == 5:
            saw_str = True
            assert_equal(dec.read_string(), "hi")
        else:
            dec.skip_field(wire)
    assert_true(saw_bool)
    assert_true(saw_i32)
    assert_true(saw_str)

    var again = Message.decode(buf)
    assert_equal(again, msg)


def test_message_omits_defaults() raises:
    var msg = Message()
    var buf = msg.encode()
    assert_equal(len(buf), 0)


def test_message_skip_unknown() raises:
    var enc = WireWriter(capacity=16)
    enc.write_tag(1, WireType.VARINT)
    enc.write_varint(1)
    enc.write_tag(99, WireType.VARINT)
    enc.write_varint(7)
    var buf = enc^.finish()
    var got = Message.decode(buf)
    assert_equal(got.f_bool, True)
    # Hand-written Message still skips unknowns. Generated types preserve
    # them; see tests/test_features.mojo.
    var out = got.encode()
    var want = bytes_of(0x08, 0x01)
    assert_equal(len(out), 2)
    assert_equal(Int(out[0]), Int(want[0]))
    assert_equal(Int(out[1]), Int(want[1]))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
