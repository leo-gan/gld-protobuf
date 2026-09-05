from std.testing import TestSuite, assert_equal, assert_raises

from protobuf import DecodeError, WireReader, WireType, WireWriter
from bytes_util import bytes_of
from wire.size import i32_to_u64, u64_to_i32, varint_len


def test_fixed64_roundtrip() raises:
    var enc = WireWriter(capacity=16)
    enc.write_tag(4, WireType.I64)
    enc.write_i64_le(UInt64(Float64(1.5).to_bits()))
    var buf = enc^.finish()
    var dec = WireReader(buf)
    var tag = dec.read_tag()
    var field = tag[0]
    var wire = tag[1]
    assert_equal(field, 4)
    assert_equal(wire, WireType.I64)
    var bits = dec.read_i64_le()
    assert_equal(Float64(from_bits=bits), 1.5)
    assert_equal(dec.remaining(), 0)


def test_len_string() raises:
    var enc = WireWriter(capacity=16)
    enc.write_len_header(5, 2)
    enc.write_bytes(String("hi").as_bytes())
    var buf = enc^.finish()
    var dec = WireReader(buf)
    var tag = dec.read_tag()
    var field = tag[0]
    var wire = tag[1]
    assert_equal(field, 5)
    assert_equal(wire, WireType.LEN)
    assert_equal(dec.read_string(), "hi")


def test_int32_negative_sign_extend() raises:
    var n = Int32(-1)
    assert_equal(varint_len(i32_to_u64(n)), 10)
    assert_equal(u64_to_i32(i32_to_u64(n)), n)
    var enc = WireWriter(capacity=16)
    enc.write_varint(i32_to_u64(n))
    var buf = enc^.finish()
    assert_equal(len(buf), 10)
    var dec = WireReader(buf)
    assert_equal(u64_to_i32(dec.read_varint()), n)


def test_skip_unknown_varint() raises:
    var enc = WireWriter(capacity=8)
    enc.write_tag(99, WireType.VARINT)
    enc.write_varint(7)
    var buf = enc^.finish()
    var dec = WireReader(buf)
    var tag = dec.read_tag()
    var field = tag[0]
    var wire = tag[1]
    assert_equal(field, 99)
    dec.skip_field(wire)
    assert_equal(dec.remaining(), 0)


def test_oversize_len() raises:
    var buf = bytes_of(0x0A)  # claims 10 bytes, none follow
    var dec = WireReader(buf)
    with assert_raises(contains="kind=5"):
        _ = dec.read_len_span()


def test_depth_limit() raises:
    var outer = WireWriter(capacity=8)
    outer.write_varint(0)
    var buf = outer^.finish()
    var dec = WireReader(buf, depth=100, max_depth=100)
    with assert_raises(contains="kind=7"):
        _ = dec.subreader(buf)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
