from std.testing import TestSuite, assert_equal, assert_true

from features import Holder
from protobuf import WireType, WireWriter
from bytes_util import bytes_of


def test_oneof_last_wins() raises:
    var msg = Holder()
    msg.which_payload = 1
    msg.name = "n"
    var buf = msg.encode()
    var got = Holder.decode(buf)
    assert_equal(got.which_payload, Int32(1))
    assert_equal(got.name, "n")

    var enc = WireWriter(capacity=16)
    enc.write_len_header(1, 1)
    enc.write_bytes(String("x").as_bytes())
    enc.write_tag(2, WireType.VARINT)
    enc.write_varint(4)
    var both = enc^.finish()
    var last = Holder.decode(both)
    assert_equal(last.which_payload, Int32(2))
    assert_equal(last.id, Int32(4))
    assert_equal(last.name.byte_length(), 0)


def test_oneof_empty_string_present() raises:
    var msg = Holder()
    msg.which_payload = 1
    msg.name = String()
    var buf = msg.encode()
    assert_true(len(buf) > 0)
    var got = Holder.decode(buf)
    assert_equal(got.which_payload, Int32(1))


def test_map_last_key_wins() raises:
    var msg = Holder()
    msg.attrs["a"] = 1
    msg.attrs["b"] = 2
    msg.labels[Int32(3)] = "c"
    var got = Holder.decode(msg.encode())
    assert_equal(got.attrs["a"], Int32(1))
    assert_equal(got.attrs["b"], Int32(2))
    assert_equal(got.labels[Int32(3)], "c")


def test_unknown_field_preserved() raises:
    var enc = WireWriter(capacity=16)
    enc.write_tag(2, WireType.VARINT)
    enc.write_varint(5)
    enc.write_tag(99, WireType.VARINT)
    enc.write_varint(7)
    var buf = enc^.finish()
    var got = Holder.decode(buf)
    assert_equal(got.which_payload, Int32(2))
    assert_equal(got.id, Int32(5))
    var out = got.encode()
    # field 2 varint 5, then unknown field 99 varint 7 (tag 99<<3 = 792 → 98 06)
    var want = bytes_of(0x10, 0x05, 0x98, 0x06, 0x07)
    assert_equal(len(out), len(want))
    for i in range(len(want)):
        assert_equal(Int(out[i]), Int(want[i]))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
