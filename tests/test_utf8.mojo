from std.testing import TestSuite, assert_equal, assert_raises

from protobuf import DecodeError, WireReader, WireWriter
from wire.utf8 import string_from_utf8


def test_valid_utf8() raises:
    var s = string_from_utf8(String("café").as_bytes(), 0)
    assert_equal(s, "café")


def test_invalid_utf8_remaps() raises:
    var enc = WireWriter(capacity=8)
    enc.write_len_header(1, 1)
    enc.write_byte(Byte(0xFF))
    var buf = enc^.finish()
    var dec = WireReader(buf)
    _ = dec.read_tag()
    with assert_raises(contains="kind=4"):
        _ = dec.read_string()


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
