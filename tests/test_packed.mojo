from std.testing import TestSuite, assert_equal, assert_raises, assert_true

from protobuf import DecodeError, WireReader, WireType, WireWriter
from manual_types import Document, DocumentMeta, Telemetry


def test_empty_present_meta_is_len_zero() raises:
    var doc = Document()
    doc.id = "x"
    doc.status = 1
    doc.meta = DocumentMeta()
    var buf = doc.encode()
    # id="x" → 0a 01 78 ; status=1 → 10 01 ; meta empty → 1a 00
    assert_equal(len(buf), 7)
    assert_equal(Int(buf[0]), 0x0A)
    assert_equal(Int(buf[1]), 0x01)
    assert_equal(Int(buf[2]), 0x78)
    assert_equal(Int(buf[3]), 0x10)
    assert_equal(Int(buf[4]), 0x01)
    assert_equal(Int(buf[5]), 0x1A)
    assert_equal(Int(buf[6]), 0x00)
    var got = Document.decode(buf)
    assert_true(Bool(got.meta))
    assert_equal(got.id, "x")
    assert_equal(got.status, 1)


def test_merge_into_existing_meta() raises:
    var enc = WireWriter(capacity=32)
    # first: meta.region = "a"
    enc.write_len_header(3, 3)
    enc.write_len_header(1, 1)
    enc.write_bytes(String("a").as_bytes())
    # second: meta.version = 2  (must merge, not replace)
    enc.write_len_header(3, 2)
    enc.write_tag(2, WireType.VARINT)
    enc.write_varint(2)
    var buf = enc^.finish()
    var doc = Document.decode(buf)
    assert_true(Bool(doc.meta))
    assert_equal(doc.meta.value().region, "a")
    assert_equal(doc.meta.value().version, 2)


def test_packed_doubles_encode_and_decode() raises:
    var tel = Telemetry()
    tel.source = "s"
    tel.ts = 9
    tel.values.append(1.0)
    tel.values.append(2.0)
    var buf = tel.encode()
    var got = Telemetry.decode(buf)
    assert_equal(got.source, "s")
    assert_equal(got.ts, 9)
    assert_equal(len(got.values), 2)
    assert_equal(got.values[0], 1.0)
    assert_equal(got.values[1], 2.0)

    # packed field 4 is a single LEN record
    var dec = WireReader(buf)
    var saw_packed = False
    while dec.remaining() > 0:
        var tag = dec.read_tag()
        var field = tag[0]
        var wire = tag[1]
        if field == 4:
            assert_equal(wire, WireType.LEN)
            saw_packed = True
            dec.skip_field(wire)
        else:
            dec.skip_field(wire)
    assert_true(saw_packed)


def test_unpacked_doubles_decode() raises:
    var enc = WireWriter(capacity=32)
    enc.write_len_header(1, 1)
    enc.write_bytes(String("s").as_bytes())
    enc.write_tag(2, WireType.VARINT)
    enc.write_varint(9)
    enc.write_tag(4, WireType.I64)
    enc.write_i64_le(UInt64(Float64(1.0).to_bits()))
    enc.write_tag(4, WireType.I64)
    enc.write_i64_le(UInt64(Float64(2.0).to_bits()))
    var buf = enc^.finish()
    var got = Telemetry.decode(buf)
    assert_equal(len(got.values), 2)
    assert_equal(got.values[0], 1.0)
    assert_equal(got.values[1], 2.0)


def test_bad_packed_length() raises:
    var enc = WireWriter(capacity=16)
    enc.write_len_header(4, 3)  # not a multiple of 8
    enc.write_byte(1)
    enc.write_byte(2)
    enc.write_byte(3)
    var buf = enc^.finish()
    with assert_raises(contains="kind=8"):
        _ = Telemetry.decode(buf)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
