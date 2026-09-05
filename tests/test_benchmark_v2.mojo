from std.testing import TestSuite, assert_equal, assert_true

from benchmark.v2 import Document, DocumentMeta, Message, Telemetry
from bytes_util import bytes_of


def test_generated_message_matches_protoc() raises:
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
    assert_equal(len(buf), len(want))
    for i in range(len(want)):
        assert_equal(Int(buf[i]), Int(want[i]))
    var again = Message.decode(buf)
    assert_equal(again, msg)


def test_generated_empty_meta() raises:
    var doc = Document()
    doc.id = "x"
    doc.status = 1
    doc.meta = DocumentMeta()
    var buf = doc.encode()
    assert_equal(len(buf), 7)
    assert_equal(Int(buf[5]), 0x1A)
    assert_equal(Int(buf[6]), 0x00)
    var got = Document.decode(buf)
    assert_true(Bool(got.meta))


def test_generated_packed_telemetry() raises:
    var tel = Telemetry()
    tel.source = "s"
    tel.ts = 9
    tel.values.append(1.0)
    tel.values.append(2.0)
    var buf = tel.encode()
    var got = Telemetry.decode(buf)
    assert_equal(len(got.values), 2)
    assert_equal(got.values[0], 1.0)
    assert_equal(got.values[1], 2.0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
