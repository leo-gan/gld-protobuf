from protobuf import DecodeError, WireType
from std.testing import TestSuite, assert_equal


def test_public_import() raises:
    var err = DecodeError(DecodeError.KIND_TRUNCATED, 0)
    assert_equal(err.kind, DecodeError.KIND_TRUNCATED)
    assert_equal(WireType.VARINT.value, 0)
    assert_equal(WireType.I64.value, 1)
    assert_equal(WireType.LEN.value, 2)
    assert_equal(WireType.I32.value, 5)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
