from std.testing import TestSuite, assert_equal, assert_true

from conformance import ConformanceRequest, ConformanceResponse, WireFormat, WireFormat_PROTOBUF
from conformance_runner.framing import u32_from_le, u32_to_le
from conformance_runner.handle import handle_request
from protobuf import WireType, WireWriter
from protobuf_test_messages.proto3 import TestAllTypesProto3


def test_u32_le_roundtrip() raises:
    var buf = u32_to_le(UInt32(258))
    assert_equal(len(buf), 4)
    assert_equal(Int(buf[0]), 2)
    assert_equal(Int(buf[1]), 1)
    assert_equal(Int(buf[2]), 0)
    assert_equal(Int(buf[3]), 0)
    assert_equal(u32_from_le(buf), UInt32(258))


def test_skip_json() raises:
    var req = ConformanceRequest()
    req.message_type = "protobuf_test_messages.proto3.TestAllTypesProto3"
    req.requested_output_format = WireFormat(WireFormat_PROTOBUF)
    req.which_payload = 2
    req.json_payload = "{}"
    var resp = handle_request(req)
    assert_equal(resp.which_result, Int32(5))
    assert_true(resp.skipped.byte_length() > 0)


def test_skip_other_message() raises:
    var req = ConformanceRequest()
    req.message_type = "protobuf_test_messages.proto2.TestAllTypesProto2"
    req.requested_output_format = WireFormat(WireFormat_PROTOBUF)
    req.which_payload = 1
    var resp = handle_request(req)
    assert_equal(resp.which_result, Int32(5))


def test_failure_set() raises:
    var req = ConformanceRequest()
    req.message_type = "conformance.FailureSet"
    var resp = handle_request(req)
    assert_equal(resp.which_result, Int32(3))
    assert_true(len(resp.protobuf_payload) >= 0)


def test_binary_roundtrip() raises:
    var msg = TestAllTypesProto3()
    msg.optional_int32 = 150
    msg.optional_string = "hi"
    var req = ConformanceRequest()
    req.message_type = "protobuf_test_messages.proto3.TestAllTypesProto3"
    req.requested_output_format = WireFormat(WireFormat_PROTOBUF)
    req.which_payload = 1
    req.protobuf_payload = msg.encode()
    var resp = handle_request(req)
    assert_equal(resp.which_result, Int32(3))
    var got = TestAllTypesProto3.decode(resp.protobuf_payload)
    assert_equal(got.optional_int32, Int32(150))
    assert_equal(got.optional_string, "hi")


def test_parse_error_invalid_utf8() raises:
    var enc = WireWriter(capacity=8)
    enc.write_tag(14, WireType.LEN)
    enc.write_varint(1)
    enc.write_byte(Byte(0xFF))
    var req = ConformanceRequest()
    req.message_type = "protobuf_test_messages.proto3.TestAllTypesProto3"
    req.requested_output_format = WireFormat(WireFormat_PROTOBUF)
    req.which_payload = 1
    req.protobuf_payload = enc^.finish()
    var resp = handle_request(req)
    assert_equal(resp.which_result, Int32(1))
    assert_true(resp.parse_error.byte_length() > 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
