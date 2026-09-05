from std.collections import Dict, List, Optional, Span
from protobuf import (
    DecodeError,
    ProtoMessage,
    UnknownFieldSet,
    WireReader,
    WireType,
    WireWriter,
    decode as pb_decode,
    encode as pb_encode,
    i32_to_u64,
    i64_to_u64,
    tag_fixed32_len,
    tag_fixed64_len,
    tag_len_len,
    tag_varint_len,
    u64_to_i32,
    u64_to_i64,
    varint_len,
    zigzag_decode_i32,
    zigzag_decode_i64,
    zigzag_encode_i32,
    zigzag_encode_i64,
)

struct WireFormat(
    Copyable, Movable, Defaultable, ImplicitlyCopyable, Equatable, Writable
):
    var value: Int32

    def __init__(out self):
        self.value = 0

    def __init__(out self, value: Int32):
        self.value = value

    def __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    def write_to[W: Writer](self, mut writer: W):
        writer.write("WireFormat(", self.value, ")")

comptime WireFormat_UNSPECIFIED = Int32(0)

comptime WireFormat_PROTOBUF = Int32(1)

comptime WireFormat_JSON = Int32(2)

comptime WireFormat_JSPB = Int32(3)

comptime WireFormat_TEXT_FORMAT = Int32(4)

struct TestCategory(
    Copyable, Movable, Defaultable, ImplicitlyCopyable, Equatable, Writable
):
    var value: Int32

    def __init__(out self):
        self.value = 0

    def __init__(out self, value: Int32):
        self.value = value

    def __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    def write_to[W: Writer](self, mut writer: W):
        writer.write("TestCategory(", self.value, ")")

comptime TestCategory_UNSPECIFIED_TEST = Int32(0)

comptime TestCategory_BINARY_TEST = Int32(1)

comptime TestCategory_JSON_TEST = Int32(2)

comptime TestCategory_JSON_IGNORE_UNKNOWN_PARSING_TEST = Int32(3)

comptime TestCategory_JSPB_TEST = Int32(4)

comptime TestCategory_TEXT_FORMAT_TEST = Int32(5)

struct TestStatus(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var name: String
    var failure_message: String
    var matched_name: String
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.name = String()
        self.failure_message = String()
        self.matched_name = String()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.name.byte_length() != 0:
            n += tag_len_len(1, self.name.byte_length())
        if self.failure_message.byte_length() != 0:
            n += tag_len_len(2, self.failure_message.byte_length())
        if self.matched_name.byte_length() != 0:
            n += tag_len_len(3, self.matched_name.byte_length())
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.name.byte_length() != 0:
            enc.write_len_header(1, self.name.byte_length())
            enc.write_bytes(self.name.as_bytes())
        if self.failure_message.byte_length() != 0:
            enc.write_len_header(2, self.failure_message.byte_length())
            enc.write_bytes(self.failure_message.as_bytes())
        if self.matched_name.byte_length() != 0:
            enc.write_len_header(3, self.matched_name.byte_length())
            enc.write_bytes(self.matched_name.as_bytes())
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.name = dec.read_string()
            elif field == 2 and wire == WireType.LEN:
                self.failure_message = dec.read_string()
            elif field == 3 and wire == WireType.LEN:
                self.matched_name = dec.read_string()
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.name != other.name:
            return False
        if self.failure_message != other.failure_message:
            return False
        if self.matched_name != other.matched_name:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("TestStatus()")

struct FailureSet(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var test: List[TestStatus]
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.test = List[TestStatus]()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        for i in range(len(self.test)):
            n += tag_len_len(2, self.test[i].encoded_len())
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        for i in range(len(self.test)):
            enc.write_len_header(2, self.test[i].encoded_len())
            self.test[i].encode_to(enc)
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 2 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = TestStatus()
                item.merge_from(inner)
                self.test.append(item^)
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if len(self.test) != len(other.test):
            return False
        for i in range(len(self.test)):
            if self.test[i] != other.test[i]:
                return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("FailureSet()")

struct ConformanceRequest(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var which_payload: Int32
    var protobuf_payload: List[Byte]
    var json_payload: String
    var jspb_payload: String
    var text_payload: String
    var requested_output_format: WireFormat
    var message_type: String
    var test_category: TestCategory
    var jspb_encoding_options: Optional[JspbEncodingConfig]
    var print_unknown_fields: Bool
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.which_payload = 0
        self.protobuf_payload = List[Byte]()
        self.json_payload = String()
        self.jspb_payload = String()
        self.text_payload = String()
        self.requested_output_format = WireFormat()
        self.message_type = String()
        self.test_category = TestCategory()
        self.jspb_encoding_options = None
        self.print_unknown_fields = False
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.which_payload == 1:
            n += tag_len_len(1, len(self.protobuf_payload))
        if self.which_payload == 2:
            n += tag_len_len(2, self.json_payload.byte_length())
        if self.which_payload == 7:
            n += tag_len_len(7, self.jspb_payload.byte_length())
        if self.which_payload == 8:
            n += tag_len_len(8, self.text_payload.byte_length())
        if self.requested_output_format.value != 0:
            n += tag_varint_len(3, i32_to_u64(self.requested_output_format.value))
        if self.message_type.byte_length() != 0:
            n += tag_len_len(4, self.message_type.byte_length())
        if self.test_category.value != 0:
            n += tag_varint_len(5, i32_to_u64(self.test_category.value))
        if self.jspb_encoding_options:
            n += tag_len_len(6, self.jspb_encoding_options.value().encoded_len())
        if self.print_unknown_fields:
            n += tag_varint_len(9, UInt64(Int(self.print_unknown_fields)))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.which_payload == 1:
            enc.write_len_header(1, len(self.protobuf_payload))
            enc.write_bytes(self.protobuf_payload)
        if self.which_payload == 2:
            enc.write_len_header(2, self.json_payload.byte_length())
            enc.write_bytes(self.json_payload.as_bytes())
        if self.which_payload == 7:
            enc.write_len_header(7, self.jspb_payload.byte_length())
            enc.write_bytes(self.jspb_payload.as_bytes())
        if self.which_payload == 8:
            enc.write_len_header(8, self.text_payload.byte_length())
            enc.write_bytes(self.text_payload.as_bytes())
        if self.requested_output_format.value != 0:
            enc.write_tag(3, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.requested_output_format.value))
        if self.message_type.byte_length() != 0:
            enc.write_len_header(4, self.message_type.byte_length())
            enc.write_bytes(self.message_type.as_bytes())
        if self.test_category.value != 0:
            enc.write_tag(5, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.test_category.value))
        if self.jspb_encoding_options:
            ref child = self.jspb_encoding_options.value()
            enc.write_len_header(6, child.encoded_len())
            child.encode_to(enc)
        if self.print_unknown_fields:
            enc.write_tag(9, WireType.VARINT)
            enc.write_varint(UInt64(Int(self.print_unknown_fields)))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.which_payload = 1
                self.json_payload = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.protobuf_payload = dec.read_bytes()
            elif field == 2 and wire == WireType.LEN:
                self.which_payload = 2
                self.protobuf_payload = List[Byte]()
                self.jspb_payload = String()
                self.text_payload = String()
                self.json_payload = dec.read_string()
            elif field == 7 and wire == WireType.LEN:
                self.which_payload = 7
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.text_payload = String()
                self.jspb_payload = dec.read_string()
            elif field == 8 and wire == WireType.LEN:
                self.which_payload = 8
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.jspb_payload = String()
                self.text_payload = dec.read_string()
            elif field == 3 and wire == WireType.VARINT:
                self.requested_output_format = WireFormat(u64_to_i32(dec.read_varint()))
            elif field == 4 and wire == WireType.LEN:
                self.message_type = dec.read_string()
            elif field == 5 and wire == WireType.VARINT:
                self.test_category = TestCategory(u64_to_i32(dec.read_varint()))
            elif field == 6 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.jspb_encoding_options:
                    self.jspb_encoding_options = JspbEncodingConfig()
                self.jspb_encoding_options.value().merge_from(inner)
            elif field == 9 and wire == WireType.VARINT:
                self.print_unknown_fields = dec.read_varint() != 0
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.which_payload != other.which_payload:
            return False
        if self.protobuf_payload != other.protobuf_payload:
            return False
        if self.json_payload != other.json_payload:
            return False
        if self.jspb_payload != other.jspb_payload:
            return False
        if self.text_payload != other.text_payload:
            return False
        if self.requested_output_format != other.requested_output_format:
            return False
        if self.message_type != other.message_type:
            return False
        if self.test_category != other.test_category:
            return False
        if Bool(self.jspb_encoding_options) != Bool(other.jspb_encoding_options):
            return False
        if self.jspb_encoding_options:
            if self.jspb_encoding_options.value() != other.jspb_encoding_options.value():
                return False
        if self.print_unknown_fields != other.print_unknown_fields:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("ConformanceRequest()")

struct ConformanceResponse(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var which_result: Int32
    var parse_error: String
    var serialize_error: String
    var timeout_error: String
    var runtime_error: String
    var protobuf_payload: List[Byte]
    var json_payload: String
    var skipped: String
    var jspb_payload: String
    var text_payload: String
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.which_result = 0
        self.parse_error = String()
        self.serialize_error = String()
        self.timeout_error = String()
        self.runtime_error = String()
        self.protobuf_payload = List[Byte]()
        self.json_payload = String()
        self.skipped = String()
        self.jspb_payload = String()
        self.text_payload = String()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.which_result == 1:
            n += tag_len_len(1, self.parse_error.byte_length())
        if self.which_result == 6:
            n += tag_len_len(6, self.serialize_error.byte_length())
        if self.which_result == 9:
            n += tag_len_len(9, self.timeout_error.byte_length())
        if self.which_result == 2:
            n += tag_len_len(2, self.runtime_error.byte_length())
        if self.which_result == 3:
            n += tag_len_len(3, len(self.protobuf_payload))
        if self.which_result == 4:
            n += tag_len_len(4, self.json_payload.byte_length())
        if self.which_result == 5:
            n += tag_len_len(5, self.skipped.byte_length())
        if self.which_result == 7:
            n += tag_len_len(7, self.jspb_payload.byte_length())
        if self.which_result == 8:
            n += tag_len_len(8, self.text_payload.byte_length())
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.which_result == 1:
            enc.write_len_header(1, self.parse_error.byte_length())
            enc.write_bytes(self.parse_error.as_bytes())
        if self.which_result == 6:
            enc.write_len_header(6, self.serialize_error.byte_length())
            enc.write_bytes(self.serialize_error.as_bytes())
        if self.which_result == 9:
            enc.write_len_header(9, self.timeout_error.byte_length())
            enc.write_bytes(self.timeout_error.as_bytes())
        if self.which_result == 2:
            enc.write_len_header(2, self.runtime_error.byte_length())
            enc.write_bytes(self.runtime_error.as_bytes())
        if self.which_result == 3:
            enc.write_len_header(3, len(self.protobuf_payload))
            enc.write_bytes(self.protobuf_payload)
        if self.which_result == 4:
            enc.write_len_header(4, self.json_payload.byte_length())
            enc.write_bytes(self.json_payload.as_bytes())
        if self.which_result == 5:
            enc.write_len_header(5, self.skipped.byte_length())
            enc.write_bytes(self.skipped.as_bytes())
        if self.which_result == 7:
            enc.write_len_header(7, self.jspb_payload.byte_length())
            enc.write_bytes(self.jspb_payload.as_bytes())
        if self.which_result == 8:
            enc.write_len_header(8, self.text_payload.byte_length())
            enc.write_bytes(self.text_payload.as_bytes())
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.which_result = 1
                self.serialize_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.parse_error = dec.read_string()
            elif field == 6 and wire == WireType.LEN:
                self.which_result = 6
                self.parse_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.serialize_error = dec.read_string()
            elif field == 9 and wire == WireType.LEN:
                self.which_result = 9
                self.parse_error = String()
                self.serialize_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.timeout_error = dec.read_string()
            elif field == 2 and wire == WireType.LEN:
                self.which_result = 2
                self.parse_error = String()
                self.serialize_error = String()
                self.timeout_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.runtime_error = dec.read_string()
            elif field == 3 and wire == WireType.LEN:
                self.which_result = 3
                self.parse_error = String()
                self.serialize_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.json_payload = String()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.protobuf_payload = dec.read_bytes()
            elif field == 4 and wire == WireType.LEN:
                self.which_result = 4
                self.parse_error = String()
                self.serialize_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.json_payload = dec.read_string()
            elif field == 5 and wire == WireType.LEN:
                self.which_result = 5
                self.parse_error = String()
                self.serialize_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.jspb_payload = String()
                self.text_payload = String()
                self.skipped = dec.read_string()
            elif field == 7 and wire == WireType.LEN:
                self.which_result = 7
                self.parse_error = String()
                self.serialize_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.skipped = String()
                self.text_payload = String()
                self.jspb_payload = dec.read_string()
            elif field == 8 and wire == WireType.LEN:
                self.which_result = 8
                self.parse_error = String()
                self.serialize_error = String()
                self.timeout_error = String()
                self.runtime_error = String()
                self.protobuf_payload = List[Byte]()
                self.json_payload = String()
                self.skipped = String()
                self.jspb_payload = String()
                self.text_payload = dec.read_string()
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.which_result != other.which_result:
            return False
        if self.parse_error != other.parse_error:
            return False
        if self.serialize_error != other.serialize_error:
            return False
        if self.timeout_error != other.timeout_error:
            return False
        if self.runtime_error != other.runtime_error:
            return False
        if self.protobuf_payload != other.protobuf_payload:
            return False
        if self.json_payload != other.json_payload:
            return False
        if self.skipped != other.skipped:
            return False
        if self.jspb_payload != other.jspb_payload:
            return False
        if self.text_payload != other.text_payload:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("ConformanceResponse()")

struct JspbEncodingConfig(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var use_jspb_array_any_format: Bool
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.use_jspb_array_any_format = False
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.use_jspb_array_any_format:
            n += tag_varint_len(1, UInt64(Int(self.use_jspb_array_any_format)))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.use_jspb_array_any_format:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(UInt64(Int(self.use_jspb_array_any_format)))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.use_jspb_array_any_format = dec.read_varint() != 0
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.use_jspb_array_any_format != other.use_jspb_array_any_format:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("JspbEncodingConfig()")

