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

from google.protobuf import NullValue
from google.protobuf import BoolValue
from google.protobuf import Int32Value
from google.protobuf import Int64Value
from google.protobuf import UInt32Value
from google.protobuf import UInt64Value
from google.protobuf import FloatValue
from google.protobuf import DoubleValue
from google.protobuf import StringValue
from google.protobuf import BytesValue
from google.protobuf import Duration
from google.protobuf import Timestamp
from google.protobuf import FieldMask
from google.protobuf import Struct
from google.protobuf import Any
from google.protobuf import Value
from google.protobuf import ListValue

struct ForeignEnum(
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
        writer.write("ForeignEnum(", self.value, ")")

comptime ForeignEnum_FOREIGN_FOO = Int32(0)

comptime ForeignEnum_FOREIGN_BAR = Int32(1)

comptime ForeignEnum_FOREIGN_BAZ = Int32(2)

struct TestAllTypesProto3NestedMessage(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var a: Int32
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.a = Int32(0)
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.a != 0:
            n += tag_varint_len(1, i32_to_u64(self.a))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.a != 0:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.a))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.a = u64_to_i32(dec.read_varint())
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.a != other.a:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("TestAllTypesProto3NestedMessage()")

struct TestAllTypesProto3NestedEnum(
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
        writer.write("TestAllTypesProto3NestedEnum(", self.value, ")")

comptime TestAllTypesProto3NestedEnum_FOO = Int32(0)

comptime TestAllTypesProto3NestedEnum_BAR = Int32(1)

comptime TestAllTypesProto3NestedEnum_BAZ = Int32(2)

comptime TestAllTypesProto3NestedEnum_NEG = Int32(-1)

struct TestAllTypesProto3AliasedEnum(
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
        writer.write("TestAllTypesProto3AliasedEnum(", self.value, ")")

comptime TestAllTypesProto3AliasedEnum_ALIAS_FOO = Int32(0)

comptime TestAllTypesProto3AliasedEnum_ALIAS_BAR = Int32(1)

comptime TestAllTypesProto3AliasedEnum_ALIAS_BAZ = Int32(2)

comptime TestAllTypesProto3AliasedEnum_MOO = Int32(2)

comptime TestAllTypesProto3AliasedEnum_moo = Int32(2)

comptime TestAllTypesProto3AliasedEnum_bAz = Int32(2)

struct TestAllTypesProto3(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var which_oneof_field: Int32
    var optional_int32: Int32
    var optional_int64: Int64
    var optional_uint32: UInt32
    var optional_uint64: UInt64
    var optional_sint32: Int32
    var optional_sint64: Int64
    var optional_fixed32: UInt32
    var optional_fixed64: UInt64
    var optional_sfixed32: Int32
    var optional_sfixed64: Int64
    var optional_float: Float32
    var optional_double: Float64
    var optional_bool: Bool
    var optional_string: String
    var optional_bytes: List[Byte]
    var optional_foreign_message: Optional[ForeignMessage]
    var optional_nested_enum: TestAllTypesProto3NestedEnum
    var optional_foreign_enum: ForeignEnum
    var optional_aliased_enum: TestAllTypesProto3AliasedEnum
    var optional_string_piece: String
    var optional_cord: String
    var repeated_int32: List[Int32]
    var repeated_int64: List[Int64]
    var repeated_uint32: List[UInt32]
    var repeated_uint64: List[UInt64]
    var repeated_sint32: List[Int32]
    var repeated_sint64: List[Int64]
    var repeated_fixed32: List[UInt32]
    var repeated_fixed64: List[UInt64]
    var repeated_sfixed32: List[Int32]
    var repeated_sfixed64: List[Int64]
    var repeated_float: List[Float32]
    var repeated_double: List[Float64]
    var repeated_bool: List[Bool]
    var repeated_string: List[String]
    var repeated_bytes: List[List[Byte]]
    var repeated_foreign_message: List[ForeignMessage]
    var repeated_nested_enum: List[TestAllTypesProto3NestedEnum]
    var repeated_foreign_enum: List[ForeignEnum]
    var repeated_string_piece: List[String]
    var repeated_cord: List[String]
    var packed_int32: List[Int32]
    var packed_int64: List[Int64]
    var packed_uint32: List[UInt32]
    var packed_uint64: List[UInt64]
    var packed_sint32: List[Int32]
    var packed_sint64: List[Int64]
    var packed_fixed32: List[UInt32]
    var packed_fixed64: List[UInt64]
    var packed_sfixed32: List[Int32]
    var packed_sfixed64: List[Int64]
    var packed_float: List[Float32]
    var packed_double: List[Float64]
    var packed_bool: List[Bool]
    var packed_nested_enum: List[TestAllTypesProto3NestedEnum]
    var unpacked_int32: List[Int32]
    var unpacked_int64: List[Int64]
    var unpacked_uint32: List[UInt32]
    var unpacked_uint64: List[UInt64]
    var unpacked_sint32: List[Int32]
    var unpacked_sint64: List[Int64]
    var unpacked_fixed32: List[UInt32]
    var unpacked_fixed64: List[UInt64]
    var unpacked_sfixed32: List[Int32]
    var unpacked_sfixed64: List[Int64]
    var unpacked_float: List[Float32]
    var unpacked_double: List[Float64]
    var unpacked_bool: List[Bool]
    var unpacked_nested_enum: List[TestAllTypesProto3NestedEnum]
    var map_int32_int32: Dict[Int32, Int32]
    var map_int64_int64: Dict[Int64, Int64]
    var map_uint32_uint32: Dict[UInt32, UInt32]
    var map_uint64_uint64: Dict[UInt64, UInt64]
    var map_sint32_sint32: Dict[Int32, Int32]
    var map_sint64_sint64: Dict[Int64, Int64]
    var map_fixed32_fixed32: Dict[UInt32, UInt32]
    var map_fixed64_fixed64: Dict[UInt64, UInt64]
    var map_sfixed32_sfixed32: Dict[Int32, Int32]
    var map_sfixed64_sfixed64: Dict[Int64, Int64]
    var map_int32_float: Dict[Int32, Float32]
    var map_int32_double: Dict[Int32, Float64]
    var map_bool_bool: Dict[Bool, Bool]
    var map_string_string: Dict[String, String]
    var map_string_bytes: Dict[String, List[Byte]]
    var map_string_nested_message: Dict[String, TestAllTypesProto3NestedMessage]
    var map_string_foreign_message: Dict[String, ForeignMessage]
    var map_string_nested_enum: Dict[String, TestAllTypesProto3NestedEnum]
    var map_string_foreign_enum: Dict[String, ForeignEnum]
    var oneof_uint32: UInt32
    var oneof_string: String
    var oneof_bytes: List[Byte]
    var oneof_bool: Bool
    var oneof_uint64: UInt64
    var oneof_float: Float32
    var oneof_double: Float64
    var oneof_enum: TestAllTypesProto3NestedEnum
    var oneof_null_value: NullValue
    var optional_bool_wrapper: Optional[BoolValue]
    var optional_int32_wrapper: Optional[Int32Value]
    var optional_int64_wrapper: Optional[Int64Value]
    var optional_uint32_wrapper: Optional[UInt32Value]
    var optional_uint64_wrapper: Optional[UInt64Value]
    var optional_float_wrapper: Optional[FloatValue]
    var optional_double_wrapper: Optional[DoubleValue]
    var optional_string_wrapper: Optional[StringValue]
    var optional_bytes_wrapper: Optional[BytesValue]
    var repeated_bool_wrapper: List[BoolValue]
    var repeated_int32_wrapper: List[Int32Value]
    var repeated_int64_wrapper: List[Int64Value]
    var repeated_uint32_wrapper: List[UInt32Value]
    var repeated_uint64_wrapper: List[UInt64Value]
    var repeated_float_wrapper: List[FloatValue]
    var repeated_double_wrapper: List[DoubleValue]
    var repeated_string_wrapper: List[StringValue]
    var repeated_bytes_wrapper: List[BytesValue]
    var optional_duration: Optional[Duration]
    var optional_timestamp: Optional[Timestamp]
    var optional_field_mask: Optional[FieldMask]
    var optional_struct: Optional[Struct]
    var optional_any: Optional[Any]
    var optional_value: Optional[Value]
    var optional_null_value: NullValue
    var repeated_duration: List[Duration]
    var repeated_timestamp: List[Timestamp]
    var repeated_fieldmask: List[FieldMask]
    var repeated_struct: List[Struct]
    var repeated_any: List[Any]
    var repeated_value: List[Value]
    var repeated_list_value: List[ListValue]
    var fieldname1: Int32
    var field_name2: Int32
    var _field_name3: Int32
    var field__name4_: Int32
    var field0name5: Int32
    var field_0_name6: Int32
    var fieldName7: Int32
    var FieldName8: Int32
    var field_Name9: Int32
    var Field_Name10: Int32
    var FIELD_NAME11: Int32
    var FIELD_name12: Int32
    var __field_name13: Int32
    var __Field_name14: Int32
    var field__name15: Int32
    var field__Name16: Int32
    var field_name17__: Int32
    var Field_name18__: Int32
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.which_oneof_field = 0
        self.optional_int32 = Int32(0)
        self.optional_int64 = Int64(0)
        self.optional_uint32 = UInt32(0)
        self.optional_uint64 = UInt64(0)
        self.optional_sint32 = Int32(0)
        self.optional_sint64 = Int64(0)
        self.optional_fixed32 = UInt32(0)
        self.optional_fixed64 = UInt64(0)
        self.optional_sfixed32 = Int32(0)
        self.optional_sfixed64 = Int64(0)
        self.optional_float = Float32(0.0)
        self.optional_double = 0.0
        self.optional_bool = False
        self.optional_string = String()
        self.optional_bytes = List[Byte]()
        self.optional_foreign_message = None
        self.optional_nested_enum = TestAllTypesProto3NestedEnum()
        self.optional_foreign_enum = ForeignEnum()
        self.optional_aliased_enum = TestAllTypesProto3AliasedEnum()
        self.optional_string_piece = String()
        self.optional_cord = String()
        self.repeated_int32 = List[Int32]()
        self.repeated_int64 = List[Int64]()
        self.repeated_uint32 = List[UInt32]()
        self.repeated_uint64 = List[UInt64]()
        self.repeated_sint32 = List[Int32]()
        self.repeated_sint64 = List[Int64]()
        self.repeated_fixed32 = List[UInt32]()
        self.repeated_fixed64 = List[UInt64]()
        self.repeated_sfixed32 = List[Int32]()
        self.repeated_sfixed64 = List[Int64]()
        self.repeated_float = List[Float32]()
        self.repeated_double = List[Float64]()
        self.repeated_bool = List[Bool]()
        self.repeated_string = List[String]()
        self.repeated_bytes = List[List[Byte]]()
        self.repeated_foreign_message = List[ForeignMessage]()
        self.repeated_nested_enum = List[TestAllTypesProto3NestedEnum]()
        self.repeated_foreign_enum = List[ForeignEnum]()
        self.repeated_string_piece = List[String]()
        self.repeated_cord = List[String]()
        self.packed_int32 = List[Int32]()
        self.packed_int64 = List[Int64]()
        self.packed_uint32 = List[UInt32]()
        self.packed_uint64 = List[UInt64]()
        self.packed_sint32 = List[Int32]()
        self.packed_sint64 = List[Int64]()
        self.packed_fixed32 = List[UInt32]()
        self.packed_fixed64 = List[UInt64]()
        self.packed_sfixed32 = List[Int32]()
        self.packed_sfixed64 = List[Int64]()
        self.packed_float = List[Float32]()
        self.packed_double = List[Float64]()
        self.packed_bool = List[Bool]()
        self.packed_nested_enum = List[TestAllTypesProto3NestedEnum]()
        self.unpacked_int32 = List[Int32]()
        self.unpacked_int64 = List[Int64]()
        self.unpacked_uint32 = List[UInt32]()
        self.unpacked_uint64 = List[UInt64]()
        self.unpacked_sint32 = List[Int32]()
        self.unpacked_sint64 = List[Int64]()
        self.unpacked_fixed32 = List[UInt32]()
        self.unpacked_fixed64 = List[UInt64]()
        self.unpacked_sfixed32 = List[Int32]()
        self.unpacked_sfixed64 = List[Int64]()
        self.unpacked_float = List[Float32]()
        self.unpacked_double = List[Float64]()
        self.unpacked_bool = List[Bool]()
        self.unpacked_nested_enum = List[TestAllTypesProto3NestedEnum]()
        self.map_int32_int32 = Dict[Int32, Int32]()
        self.map_int64_int64 = Dict[Int64, Int64]()
        self.map_uint32_uint32 = Dict[UInt32, UInt32]()
        self.map_uint64_uint64 = Dict[UInt64, UInt64]()
        self.map_sint32_sint32 = Dict[Int32, Int32]()
        self.map_sint64_sint64 = Dict[Int64, Int64]()
        self.map_fixed32_fixed32 = Dict[UInt32, UInt32]()
        self.map_fixed64_fixed64 = Dict[UInt64, UInt64]()
        self.map_sfixed32_sfixed32 = Dict[Int32, Int32]()
        self.map_sfixed64_sfixed64 = Dict[Int64, Int64]()
        self.map_int32_float = Dict[Int32, Float32]()
        self.map_int32_double = Dict[Int32, Float64]()
        self.map_bool_bool = Dict[Bool, Bool]()
        self.map_string_string = Dict[String, String]()
        self.map_string_bytes = Dict[String, List[Byte]]()
        self.map_string_nested_message = Dict[String, TestAllTypesProto3NestedMessage]()
        self.map_string_foreign_message = Dict[String, ForeignMessage]()
        self.map_string_nested_enum = Dict[String, TestAllTypesProto3NestedEnum]()
        self.map_string_foreign_enum = Dict[String, ForeignEnum]()
        self.oneof_uint32 = UInt32(0)
        self.oneof_string = String()
        self.oneof_bytes = List[Byte]()
        self.oneof_bool = False
        self.oneof_uint64 = UInt64(0)
        self.oneof_float = Float32(0.0)
        self.oneof_double = 0.0
        self.oneof_enum = TestAllTypesProto3NestedEnum()
        self.oneof_null_value = NullValue()
        self.optional_bool_wrapper = None
        self.optional_int32_wrapper = None
        self.optional_int64_wrapper = None
        self.optional_uint32_wrapper = None
        self.optional_uint64_wrapper = None
        self.optional_float_wrapper = None
        self.optional_double_wrapper = None
        self.optional_string_wrapper = None
        self.optional_bytes_wrapper = None
        self.repeated_bool_wrapper = List[BoolValue]()
        self.repeated_int32_wrapper = List[Int32Value]()
        self.repeated_int64_wrapper = List[Int64Value]()
        self.repeated_uint32_wrapper = List[UInt32Value]()
        self.repeated_uint64_wrapper = List[UInt64Value]()
        self.repeated_float_wrapper = List[FloatValue]()
        self.repeated_double_wrapper = List[DoubleValue]()
        self.repeated_string_wrapper = List[StringValue]()
        self.repeated_bytes_wrapper = List[BytesValue]()
        self.optional_duration = None
        self.optional_timestamp = None
        self.optional_field_mask = None
        self.optional_struct = None
        self.optional_any = None
        self.optional_value = None
        self.optional_null_value = NullValue()
        self.repeated_duration = List[Duration]()
        self.repeated_timestamp = List[Timestamp]()
        self.repeated_fieldmask = List[FieldMask]()
        self.repeated_struct = List[Struct]()
        self.repeated_any = List[Any]()
        self.repeated_value = List[Value]()
        self.repeated_list_value = List[ListValue]()
        self.fieldname1 = Int32(0)
        self.field_name2 = Int32(0)
        self._field_name3 = Int32(0)
        self.field__name4_ = Int32(0)
        self.field0name5 = Int32(0)
        self.field_0_name6 = Int32(0)
        self.fieldName7 = Int32(0)
        self.FieldName8 = Int32(0)
        self.field_Name9 = Int32(0)
        self.Field_Name10 = Int32(0)
        self.FIELD_NAME11 = Int32(0)
        self.FIELD_name12 = Int32(0)
        self.__field_name13 = Int32(0)
        self.__Field_name14 = Int32(0)
        self.field__name15 = Int32(0)
        self.field__Name16 = Int32(0)
        self.field_name17__ = Int32(0)
        self.Field_name18__ = Int32(0)
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.optional_int32 != 0:
            n += tag_varint_len(1, i32_to_u64(self.optional_int32))
        if self.optional_int64 != 0:
            n += tag_varint_len(2, i64_to_u64(self.optional_int64))
        if self.optional_uint32 != 0:
            n += tag_varint_len(3, UInt64(self.optional_uint32))
        if self.optional_uint64 != 0:
            n += tag_varint_len(4, self.optional_uint64)
        if self.optional_sint32 != 0:
            n += tag_varint_len(5, UInt64(zigzag_encode_i32(self.optional_sint32)))
        if self.optional_sint64 != 0:
            n += tag_varint_len(6, zigzag_encode_i64(self.optional_sint64))
        if self.optional_fixed32 != 0:
            n += tag_fixed32_len(7)
        if self.optional_fixed64 != 0:
            n += tag_fixed64_len(8)
        if self.optional_sfixed32 != 0:
            n += tag_fixed32_len(9)
        if self.optional_sfixed64 != 0:
            n += tag_fixed64_len(10)
        if self.optional_float != 0.0:
            n += tag_fixed32_len(11)
        if self.optional_double != 0.0:
            n += tag_fixed64_len(12)
        if self.optional_bool:
            n += tag_varint_len(13, UInt64(Int(self.optional_bool)))
        if self.optional_string.byte_length() != 0:
            n += tag_len_len(14, self.optional_string.byte_length())
        if len(self.optional_bytes) != 0:
            n += tag_len_len(15, len(self.optional_bytes))
        if self.optional_foreign_message:
            n += tag_len_len(19, self.optional_foreign_message.value().encoded_len())
        if self.optional_nested_enum.value != 0:
            n += tag_varint_len(21, i32_to_u64(self.optional_nested_enum.value))
        if self.optional_foreign_enum.value != 0:
            n += tag_varint_len(22, i32_to_u64(self.optional_foreign_enum.value))
        if self.optional_aliased_enum.value != 0:
            n += tag_varint_len(23, i32_to_u64(self.optional_aliased_enum.value))
        if self.optional_string_piece.byte_length() != 0:
            n += tag_len_len(24, self.optional_string_piece.byte_length())
        if self.optional_cord.byte_length() != 0:
            n += tag_len_len(25, self.optional_cord.byte_length())
        if len(self.repeated_int32) != 0:
            var payload = 0
            for i in range(len(self.repeated_int32)):
                payload += varint_len(i32_to_u64(self.repeated_int32[i]))
            n += tag_len_len(31, payload)
        if len(self.repeated_int64) != 0:
            var payload = 0
            for i in range(len(self.repeated_int64)):
                payload += varint_len(i64_to_u64(self.repeated_int64[i]))
            n += tag_len_len(32, payload)
        if len(self.repeated_uint32) != 0:
            var payload = 0
            for i in range(len(self.repeated_uint32)):
                payload += varint_len(UInt64(self.repeated_uint32[i]))
            n += tag_len_len(33, payload)
        if len(self.repeated_uint64) != 0:
            var payload = 0
            for i in range(len(self.repeated_uint64)):
                payload += varint_len(self.repeated_uint64[i])
            n += tag_len_len(34, payload)
        if len(self.repeated_sint32) != 0:
            var payload = 0
            for i in range(len(self.repeated_sint32)):
                payload += varint_len(UInt64(zigzag_encode_i32(self.repeated_sint32[i])))
            n += tag_len_len(35, payload)
        if len(self.repeated_sint64) != 0:
            var payload = 0
            for i in range(len(self.repeated_sint64)):
                payload += varint_len(zigzag_encode_i64(self.repeated_sint64[i]))
            n += tag_len_len(36, payload)
        if len(self.repeated_fixed32) != 0:
            n += tag_len_len(37, len(self.repeated_fixed32) * 4)
        if len(self.repeated_fixed64) != 0:
            n += tag_len_len(38, len(self.repeated_fixed64) * 8)
        if len(self.repeated_sfixed32) != 0:
            n += tag_len_len(39, len(self.repeated_sfixed32) * 4)
        if len(self.repeated_sfixed64) != 0:
            n += tag_len_len(40, len(self.repeated_sfixed64) * 8)
        if len(self.repeated_float) != 0:
            n += tag_len_len(41, len(self.repeated_float) * 4)
        if len(self.repeated_double) != 0:
            n += tag_len_len(42, len(self.repeated_double) * 8)
        if len(self.repeated_bool) != 0:
            var payload = 0
            for i in range(len(self.repeated_bool)):
                payload += varint_len(UInt64(Int(self.repeated_bool[i])))
            n += tag_len_len(43, payload)
        for i in range(len(self.repeated_string)):
            n += tag_len_len(44, self.repeated_string[i].byte_length())
        for i in range(len(self.repeated_bytes)):
            n += tag_len_len(45, len(self.repeated_bytes[i]))
        for i in range(len(self.repeated_foreign_message)):
            n += tag_len_len(49, self.repeated_foreign_message[i].encoded_len())
        if len(self.repeated_nested_enum) != 0:
            var payload = 0
            for i in range(len(self.repeated_nested_enum)):
                payload += varint_len(i32_to_u64(self.repeated_nested_enum[i].value))
            n += tag_len_len(51, payload)
        if len(self.repeated_foreign_enum) != 0:
            var payload = 0
            for i in range(len(self.repeated_foreign_enum)):
                payload += varint_len(i32_to_u64(self.repeated_foreign_enum[i].value))
            n += tag_len_len(52, payload)
        for i in range(len(self.repeated_string_piece)):
            n += tag_len_len(54, self.repeated_string_piece[i].byte_length())
        for i in range(len(self.repeated_cord)):
            n += tag_len_len(55, self.repeated_cord[i].byte_length())
        if len(self.packed_int32) != 0:
            var payload = 0
            for i in range(len(self.packed_int32)):
                payload += varint_len(i32_to_u64(self.packed_int32[i]))
            n += tag_len_len(75, payload)
        if len(self.packed_int64) != 0:
            var payload = 0
            for i in range(len(self.packed_int64)):
                payload += varint_len(i64_to_u64(self.packed_int64[i]))
            n += tag_len_len(76, payload)
        if len(self.packed_uint32) != 0:
            var payload = 0
            for i in range(len(self.packed_uint32)):
                payload += varint_len(UInt64(self.packed_uint32[i]))
            n += tag_len_len(77, payload)
        if len(self.packed_uint64) != 0:
            var payload = 0
            for i in range(len(self.packed_uint64)):
                payload += varint_len(self.packed_uint64[i])
            n += tag_len_len(78, payload)
        if len(self.packed_sint32) != 0:
            var payload = 0
            for i in range(len(self.packed_sint32)):
                payload += varint_len(UInt64(zigzag_encode_i32(self.packed_sint32[i])))
            n += tag_len_len(79, payload)
        if len(self.packed_sint64) != 0:
            var payload = 0
            for i in range(len(self.packed_sint64)):
                payload += varint_len(zigzag_encode_i64(self.packed_sint64[i]))
            n += tag_len_len(80, payload)
        if len(self.packed_fixed32) != 0:
            n += tag_len_len(81, len(self.packed_fixed32) * 4)
        if len(self.packed_fixed64) != 0:
            n += tag_len_len(82, len(self.packed_fixed64) * 8)
        if len(self.packed_sfixed32) != 0:
            n += tag_len_len(83, len(self.packed_sfixed32) * 4)
        if len(self.packed_sfixed64) != 0:
            n += tag_len_len(84, len(self.packed_sfixed64) * 8)
        if len(self.packed_float) != 0:
            n += tag_len_len(85, len(self.packed_float) * 4)
        if len(self.packed_double) != 0:
            n += tag_len_len(86, len(self.packed_double) * 8)
        if len(self.packed_bool) != 0:
            var payload = 0
            for i in range(len(self.packed_bool)):
                payload += varint_len(UInt64(Int(self.packed_bool[i])))
            n += tag_len_len(87, payload)
        if len(self.packed_nested_enum) != 0:
            var payload = 0
            for i in range(len(self.packed_nested_enum)):
                payload += varint_len(i32_to_u64(self.packed_nested_enum[i].value))
            n += tag_len_len(88, payload)
        for i in range(len(self.unpacked_int32)):
            n += tag_varint_len(89, i32_to_u64(self.unpacked_int32[i]))
        for i in range(len(self.unpacked_int64)):
            n += tag_varint_len(90, i64_to_u64(self.unpacked_int64[i]))
        for i in range(len(self.unpacked_uint32)):
            n += tag_varint_len(91, UInt64(self.unpacked_uint32[i]))
        for i in range(len(self.unpacked_uint64)):
            n += tag_varint_len(92, self.unpacked_uint64[i])
        for i in range(len(self.unpacked_sint32)):
            n += tag_varint_len(93, UInt64(zigzag_encode_i32(self.unpacked_sint32[i])))
        for i in range(len(self.unpacked_sint64)):
            n += tag_varint_len(94, zigzag_encode_i64(self.unpacked_sint64[i]))
        for i in range(len(self.unpacked_fixed32)):
            n += tag_fixed32_len(95)
        for i in range(len(self.unpacked_fixed64)):
            n += tag_fixed64_len(96)
        for i in range(len(self.unpacked_sfixed32)):
            n += tag_fixed32_len(97)
        for i in range(len(self.unpacked_sfixed64)):
            n += tag_fixed64_len(98)
        for i in range(len(self.unpacked_float)):
            n += tag_fixed32_len(99)
        for i in range(len(self.unpacked_double)):
            n += tag_fixed64_len(100)
        for i in range(len(self.unpacked_bool)):
            n += tag_varint_len(101, UInt64(Int(self.unpacked_bool[i])))
        for i in range(len(self.unpacked_nested_enum)):
            n += tag_varint_len(102, i32_to_u64(self.unpacked_nested_enum[i].value))
        for item in self.map_int32_int32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value))
            n += tag_len_len(56, entry_len)
        for item in self.map_int64_int64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i64_to_u64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, i64_to_u64(item.value))
            n += tag_len_len(57, entry_len)
        for item in self.map_uint32_uint32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, UInt64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, UInt64(item.value))
            n += tag_len_len(58, entry_len)
        for item in self.map_uint64_uint64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, item.key)
            if item.value != 0:
                entry_len += tag_varint_len(2, item.value)
            n += tag_len_len(59, entry_len)
        for item in self.map_sint32_sint32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, UInt64(zigzag_encode_i32(item.key)))
            if item.value != 0:
                entry_len += tag_varint_len(2, UInt64(zigzag_encode_i32(item.value)))
            n += tag_len_len(60, entry_len)
        for item in self.map_sint64_sint64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, zigzag_encode_i64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, zigzag_encode_i64(item.value))
            n += tag_len_len(61, entry_len)
        for item in self.map_fixed32_fixed32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed32_len(1)
            if item.value != 0:
                entry_len += tag_fixed32_len(2)
            n += tag_len_len(62, entry_len)
        for item in self.map_fixed64_fixed64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed64_len(1)
            if item.value != 0:
                entry_len += tag_fixed64_len(2)
            n += tag_len_len(63, entry_len)
        for item in self.map_sfixed32_sfixed32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed32_len(1)
            if item.value != 0:
                entry_len += tag_fixed32_len(2)
            n += tag_len_len(64, entry_len)
        for item in self.map_sfixed64_sfixed64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed64_len(1)
            if item.value != 0:
                entry_len += tag_fixed64_len(2)
            n += tag_len_len(65, entry_len)
        for item in self.map_int32_float.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value != 0.0:
                entry_len += tag_fixed32_len(2)
            n += tag_len_len(66, entry_len)
        for item in self.map_int32_double.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value != 0.0:
                entry_len += tag_fixed64_len(2)
            n += tag_len_len(67, entry_len)
        for item in self.map_bool_bool.items():
            var entry_len = 0
            if item.key:
                entry_len += tag_varint_len(1, UInt64(Int(item.key)))
            if item.value:
                entry_len += tag_varint_len(2, UInt64(Int(item.value)))
            n += tag_len_len(68, entry_len)
        for item in self.map_string_string.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value.byte_length() != 0:
                entry_len += tag_len_len(2, item.value.byte_length())
            n += tag_len_len(69, entry_len)
        for item in self.map_string_bytes.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if len(item.value) != 0:
                entry_len += tag_len_len(2, len(item.value))
            n += tag_len_len(70, entry_len)
        for item in self.map_string_nested_message.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            entry_len += tag_len_len(2, item.value.encoded_len())
            n += tag_len_len(71, entry_len)
        for item in self.map_string_foreign_message.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            entry_len += tag_len_len(2, item.value.encoded_len())
            n += tag_len_len(72, entry_len)
        for item in self.map_string_nested_enum.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value.value))
            n += tag_len_len(73, entry_len)
        for item in self.map_string_foreign_enum.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value.value))
            n += tag_len_len(74, entry_len)
        if self.which_oneof_field == 111:
            n += tag_varint_len(111, UInt64(self.oneof_uint32))
        if self.which_oneof_field == 113:
            n += tag_len_len(113, self.oneof_string.byte_length())
        if self.which_oneof_field == 114:
            n += tag_len_len(114, len(self.oneof_bytes))
        if self.which_oneof_field == 115:
            n += tag_varint_len(115, UInt64(Int(self.oneof_bool)))
        if self.which_oneof_field == 116:
            n += tag_varint_len(116, self.oneof_uint64)
        if self.which_oneof_field == 117:
            n += tag_fixed32_len(117)
        if self.which_oneof_field == 118:
            n += tag_fixed64_len(118)
        if self.which_oneof_field == 119:
            n += tag_varint_len(119, i32_to_u64(self.oneof_enum.value))
        if self.which_oneof_field == 120:
            n += tag_varint_len(120, i32_to_u64(self.oneof_null_value.value))
        if self.optional_bool_wrapper:
            n += tag_len_len(201, self.optional_bool_wrapper.value().encoded_len())
        if self.optional_int32_wrapper:
            n += tag_len_len(202, self.optional_int32_wrapper.value().encoded_len())
        if self.optional_int64_wrapper:
            n += tag_len_len(203, self.optional_int64_wrapper.value().encoded_len())
        if self.optional_uint32_wrapper:
            n += tag_len_len(204, self.optional_uint32_wrapper.value().encoded_len())
        if self.optional_uint64_wrapper:
            n += tag_len_len(205, self.optional_uint64_wrapper.value().encoded_len())
        if self.optional_float_wrapper:
            n += tag_len_len(206, self.optional_float_wrapper.value().encoded_len())
        if self.optional_double_wrapper:
            n += tag_len_len(207, self.optional_double_wrapper.value().encoded_len())
        if self.optional_string_wrapper:
            n += tag_len_len(208, self.optional_string_wrapper.value().encoded_len())
        if self.optional_bytes_wrapper:
            n += tag_len_len(209, self.optional_bytes_wrapper.value().encoded_len())
        for i in range(len(self.repeated_bool_wrapper)):
            n += tag_len_len(211, self.repeated_bool_wrapper[i].encoded_len())
        for i in range(len(self.repeated_int32_wrapper)):
            n += tag_len_len(212, self.repeated_int32_wrapper[i].encoded_len())
        for i in range(len(self.repeated_int64_wrapper)):
            n += tag_len_len(213, self.repeated_int64_wrapper[i].encoded_len())
        for i in range(len(self.repeated_uint32_wrapper)):
            n += tag_len_len(214, self.repeated_uint32_wrapper[i].encoded_len())
        for i in range(len(self.repeated_uint64_wrapper)):
            n += tag_len_len(215, self.repeated_uint64_wrapper[i].encoded_len())
        for i in range(len(self.repeated_float_wrapper)):
            n += tag_len_len(216, self.repeated_float_wrapper[i].encoded_len())
        for i in range(len(self.repeated_double_wrapper)):
            n += tag_len_len(217, self.repeated_double_wrapper[i].encoded_len())
        for i in range(len(self.repeated_string_wrapper)):
            n += tag_len_len(218, self.repeated_string_wrapper[i].encoded_len())
        for i in range(len(self.repeated_bytes_wrapper)):
            n += tag_len_len(219, self.repeated_bytes_wrapper[i].encoded_len())
        if self.optional_duration:
            n += tag_len_len(301, self.optional_duration.value().encoded_len())
        if self.optional_timestamp:
            n += tag_len_len(302, self.optional_timestamp.value().encoded_len())
        if self.optional_field_mask:
            n += tag_len_len(303, self.optional_field_mask.value().encoded_len())
        if self.optional_struct:
            n += tag_len_len(304, self.optional_struct.value().encoded_len())
        if self.optional_any:
            n += tag_len_len(305, self.optional_any.value().encoded_len())
        if self.optional_value:
            n += tag_len_len(306, self.optional_value.value().encoded_len())
        if self.optional_null_value.value != 0:
            n += tag_varint_len(307, i32_to_u64(self.optional_null_value.value))
        for i in range(len(self.repeated_duration)):
            n += tag_len_len(311, self.repeated_duration[i].encoded_len())
        for i in range(len(self.repeated_timestamp)):
            n += tag_len_len(312, self.repeated_timestamp[i].encoded_len())
        for i in range(len(self.repeated_fieldmask)):
            n += tag_len_len(313, self.repeated_fieldmask[i].encoded_len())
        for i in range(len(self.repeated_struct)):
            n += tag_len_len(324, self.repeated_struct[i].encoded_len())
        for i in range(len(self.repeated_any)):
            n += tag_len_len(315, self.repeated_any[i].encoded_len())
        for i in range(len(self.repeated_value)):
            n += tag_len_len(316, self.repeated_value[i].encoded_len())
        for i in range(len(self.repeated_list_value)):
            n += tag_len_len(317, self.repeated_list_value[i].encoded_len())
        if self.fieldname1 != 0:
            n += tag_varint_len(401, i32_to_u64(self.fieldname1))
        if self.field_name2 != 0:
            n += tag_varint_len(402, i32_to_u64(self.field_name2))
        if self._field_name3 != 0:
            n += tag_varint_len(403, i32_to_u64(self._field_name3))
        if self.field__name4_ != 0:
            n += tag_varint_len(404, i32_to_u64(self.field__name4_))
        if self.field0name5 != 0:
            n += tag_varint_len(405, i32_to_u64(self.field0name5))
        if self.field_0_name6 != 0:
            n += tag_varint_len(406, i32_to_u64(self.field_0_name6))
        if self.fieldName7 != 0:
            n += tag_varint_len(407, i32_to_u64(self.fieldName7))
        if self.FieldName8 != 0:
            n += tag_varint_len(408, i32_to_u64(self.FieldName8))
        if self.field_Name9 != 0:
            n += tag_varint_len(409, i32_to_u64(self.field_Name9))
        if self.Field_Name10 != 0:
            n += tag_varint_len(410, i32_to_u64(self.Field_Name10))
        if self.FIELD_NAME11 != 0:
            n += tag_varint_len(411, i32_to_u64(self.FIELD_NAME11))
        if self.FIELD_name12 != 0:
            n += tag_varint_len(412, i32_to_u64(self.FIELD_name12))
        if self.__field_name13 != 0:
            n += tag_varint_len(413, i32_to_u64(self.__field_name13))
        if self.__Field_name14 != 0:
            n += tag_varint_len(414, i32_to_u64(self.__Field_name14))
        if self.field__name15 != 0:
            n += tag_varint_len(415, i32_to_u64(self.field__name15))
        if self.field__Name16 != 0:
            n += tag_varint_len(416, i32_to_u64(self.field__Name16))
        if self.field_name17__ != 0:
            n += tag_varint_len(417, i32_to_u64(self.field_name17__))
        if self.Field_name18__ != 0:
            n += tag_varint_len(418, i32_to_u64(self.Field_name18__))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.optional_int32 != 0:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.optional_int32))
        if self.optional_int64 != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i64_to_u64(self.optional_int64))
        if self.optional_uint32 != 0:
            enc.write_tag(3, WireType.VARINT)
            enc.write_varint(UInt64(self.optional_uint32))
        if self.optional_uint64 != 0:
            enc.write_tag(4, WireType.VARINT)
            enc.write_varint(self.optional_uint64)
        if self.optional_sint32 != 0:
            enc.write_tag(5, WireType.VARINT)
            enc.write_varint(UInt64(zigzag_encode_i32(self.optional_sint32)))
        if self.optional_sint64 != 0:
            enc.write_tag(6, WireType.VARINT)
            enc.write_varint(zigzag_encode_i64(self.optional_sint64))
        if self.optional_fixed32 != 0:
            enc.write_tag(7, WireType.I32)
            enc.write_i32_le(self.optional_fixed32)
        if self.optional_fixed64 != 0:
            enc.write_tag(8, WireType.I64)
            enc.write_i64_le(self.optional_fixed64)
        if self.optional_sfixed32 != 0:
            enc.write_tag(9, WireType.I32)
            enc.write_i32_le(UInt32(self.optional_sfixed32))
        if self.optional_sfixed64 != 0:
            enc.write_tag(10, WireType.I64)
            enc.write_i64_le(UInt64(self.optional_sfixed64))
        if self.optional_float != 0.0:
            enc.write_tag(11, WireType.I32)
            enc.write_i32_le(UInt32(self.optional_float.to_bits()))
        if self.optional_double != 0.0:
            enc.write_tag(12, WireType.I64)
            enc.write_i64_le(UInt64(self.optional_double.to_bits()))
        if self.optional_bool:
            enc.write_tag(13, WireType.VARINT)
            enc.write_varint(UInt64(Int(self.optional_bool)))
        if self.optional_string.byte_length() != 0:
            enc.write_len_header(14, self.optional_string.byte_length())
            enc.write_bytes(self.optional_string.as_bytes())
        if len(self.optional_bytes) != 0:
            enc.write_len_header(15, len(self.optional_bytes))
            enc.write_bytes(self.optional_bytes)
        if self.optional_foreign_message:
            ref child = self.optional_foreign_message.value()
            enc.write_len_header(19, child.encoded_len())
            child.encode_to(enc)
        if self.optional_nested_enum.value != 0:
            enc.write_tag(21, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.optional_nested_enum.value))
        if self.optional_foreign_enum.value != 0:
            enc.write_tag(22, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.optional_foreign_enum.value))
        if self.optional_aliased_enum.value != 0:
            enc.write_tag(23, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.optional_aliased_enum.value))
        if self.optional_string_piece.byte_length() != 0:
            enc.write_len_header(24, self.optional_string_piece.byte_length())
            enc.write_bytes(self.optional_string_piece.as_bytes())
        if self.optional_cord.byte_length() != 0:
            enc.write_len_header(25, self.optional_cord.byte_length())
            enc.write_bytes(self.optional_cord.as_bytes())
        if len(self.repeated_int32) != 0:
            var payload = 0
            for i in range(len(self.repeated_int32)):
                payload += varint_len(i32_to_u64(self.repeated_int32[i]))
            enc.write_len_header(31, payload)
            for i in range(len(self.repeated_int32)):
                enc.write_varint(i32_to_u64(self.repeated_int32[i]))
        if len(self.repeated_int64) != 0:
            var payload = 0
            for i in range(len(self.repeated_int64)):
                payload += varint_len(i64_to_u64(self.repeated_int64[i]))
            enc.write_len_header(32, payload)
            for i in range(len(self.repeated_int64)):
                enc.write_varint(i64_to_u64(self.repeated_int64[i]))
        if len(self.repeated_uint32) != 0:
            var payload = 0
            for i in range(len(self.repeated_uint32)):
                payload += varint_len(UInt64(self.repeated_uint32[i]))
            enc.write_len_header(33, payload)
            for i in range(len(self.repeated_uint32)):
                enc.write_varint(UInt64(self.repeated_uint32[i]))
        if len(self.repeated_uint64) != 0:
            var payload = 0
            for i in range(len(self.repeated_uint64)):
                payload += varint_len(self.repeated_uint64[i])
            enc.write_len_header(34, payload)
            for i in range(len(self.repeated_uint64)):
                enc.write_varint(self.repeated_uint64[i])
        if len(self.repeated_sint32) != 0:
            var payload = 0
            for i in range(len(self.repeated_sint32)):
                payload += varint_len(UInt64(zigzag_encode_i32(self.repeated_sint32[i])))
            enc.write_len_header(35, payload)
            for i in range(len(self.repeated_sint32)):
                enc.write_varint(UInt64(zigzag_encode_i32(self.repeated_sint32[i])))
        if len(self.repeated_sint64) != 0:
            var payload = 0
            for i in range(len(self.repeated_sint64)):
                payload += varint_len(zigzag_encode_i64(self.repeated_sint64[i]))
            enc.write_len_header(36, payload)
            for i in range(len(self.repeated_sint64)):
                enc.write_varint(zigzag_encode_i64(self.repeated_sint64[i]))
        if len(self.repeated_fixed32) != 0:
            enc.write_len_header(37, len(self.repeated_fixed32) * 4)
            for i in range(len(self.repeated_fixed32)):
                enc.write_i32_le(self.repeated_fixed32[i])
        if len(self.repeated_fixed64) != 0:
            enc.write_len_header(38, len(self.repeated_fixed64) * 8)
            for i in range(len(self.repeated_fixed64)):
                enc.write_i64_le(self.repeated_fixed64[i])
        if len(self.repeated_sfixed32) != 0:
            enc.write_len_header(39, len(self.repeated_sfixed32) * 4)
            for i in range(len(self.repeated_sfixed32)):
                enc.write_i32_le(UInt32(self.repeated_sfixed32[i]))
        if len(self.repeated_sfixed64) != 0:
            enc.write_len_header(40, len(self.repeated_sfixed64) * 8)
            for i in range(len(self.repeated_sfixed64)):
                enc.write_i64_le(UInt64(self.repeated_sfixed64[i]))
        if len(self.repeated_float) != 0:
            enc.write_len_header(41, len(self.repeated_float) * 4)
            for i in range(len(self.repeated_float)):
                enc.write_i32_le(UInt32(self.repeated_float[i].to_bits()))
        if len(self.repeated_double) != 0:
            enc.write_len_header(42, len(self.repeated_double) * 8)
            for i in range(len(self.repeated_double)):
                enc.write_i64_le(UInt64(self.repeated_double[i].to_bits()))
        if len(self.repeated_bool) != 0:
            var payload = 0
            for i in range(len(self.repeated_bool)):
                payload += varint_len(UInt64(Int(self.repeated_bool[i])))
            enc.write_len_header(43, payload)
            for i in range(len(self.repeated_bool)):
                enc.write_varint(UInt64(Int(self.repeated_bool[i])))
        for i in range(len(self.repeated_string)):
            enc.write_len_header(44, self.repeated_string[i].byte_length())
            enc.write_bytes(self.repeated_string[i].as_bytes())
        for i in range(len(self.repeated_bytes)):
            enc.write_len_header(45, len(self.repeated_bytes[i]))
            enc.write_bytes(self.repeated_bytes[i])
        for i in range(len(self.repeated_foreign_message)):
            enc.write_len_header(49, self.repeated_foreign_message[i].encoded_len())
            self.repeated_foreign_message[i].encode_to(enc)
        if len(self.repeated_nested_enum) != 0:
            var payload = 0
            for i in range(len(self.repeated_nested_enum)):
                payload += varint_len(i32_to_u64(self.repeated_nested_enum[i].value))
            enc.write_len_header(51, payload)
            for i in range(len(self.repeated_nested_enum)):
                enc.write_varint(i32_to_u64(self.repeated_nested_enum[i].value))
        if len(self.repeated_foreign_enum) != 0:
            var payload = 0
            for i in range(len(self.repeated_foreign_enum)):
                payload += varint_len(i32_to_u64(self.repeated_foreign_enum[i].value))
            enc.write_len_header(52, payload)
            for i in range(len(self.repeated_foreign_enum)):
                enc.write_varint(i32_to_u64(self.repeated_foreign_enum[i].value))
        for i in range(len(self.repeated_string_piece)):
            enc.write_len_header(54, self.repeated_string_piece[i].byte_length())
            enc.write_bytes(self.repeated_string_piece[i].as_bytes())
        for i in range(len(self.repeated_cord)):
            enc.write_len_header(55, self.repeated_cord[i].byte_length())
            enc.write_bytes(self.repeated_cord[i].as_bytes())
        if len(self.packed_int32) != 0:
            var payload = 0
            for i in range(len(self.packed_int32)):
                payload += varint_len(i32_to_u64(self.packed_int32[i]))
            enc.write_len_header(75, payload)
            for i in range(len(self.packed_int32)):
                enc.write_varint(i32_to_u64(self.packed_int32[i]))
        if len(self.packed_int64) != 0:
            var payload = 0
            for i in range(len(self.packed_int64)):
                payload += varint_len(i64_to_u64(self.packed_int64[i]))
            enc.write_len_header(76, payload)
            for i in range(len(self.packed_int64)):
                enc.write_varint(i64_to_u64(self.packed_int64[i]))
        if len(self.packed_uint32) != 0:
            var payload = 0
            for i in range(len(self.packed_uint32)):
                payload += varint_len(UInt64(self.packed_uint32[i]))
            enc.write_len_header(77, payload)
            for i in range(len(self.packed_uint32)):
                enc.write_varint(UInt64(self.packed_uint32[i]))
        if len(self.packed_uint64) != 0:
            var payload = 0
            for i in range(len(self.packed_uint64)):
                payload += varint_len(self.packed_uint64[i])
            enc.write_len_header(78, payload)
            for i in range(len(self.packed_uint64)):
                enc.write_varint(self.packed_uint64[i])
        if len(self.packed_sint32) != 0:
            var payload = 0
            for i in range(len(self.packed_sint32)):
                payload += varint_len(UInt64(zigzag_encode_i32(self.packed_sint32[i])))
            enc.write_len_header(79, payload)
            for i in range(len(self.packed_sint32)):
                enc.write_varint(UInt64(zigzag_encode_i32(self.packed_sint32[i])))
        if len(self.packed_sint64) != 0:
            var payload = 0
            for i in range(len(self.packed_sint64)):
                payload += varint_len(zigzag_encode_i64(self.packed_sint64[i]))
            enc.write_len_header(80, payload)
            for i in range(len(self.packed_sint64)):
                enc.write_varint(zigzag_encode_i64(self.packed_sint64[i]))
        if len(self.packed_fixed32) != 0:
            enc.write_len_header(81, len(self.packed_fixed32) * 4)
            for i in range(len(self.packed_fixed32)):
                enc.write_i32_le(self.packed_fixed32[i])
        if len(self.packed_fixed64) != 0:
            enc.write_len_header(82, len(self.packed_fixed64) * 8)
            for i in range(len(self.packed_fixed64)):
                enc.write_i64_le(self.packed_fixed64[i])
        if len(self.packed_sfixed32) != 0:
            enc.write_len_header(83, len(self.packed_sfixed32) * 4)
            for i in range(len(self.packed_sfixed32)):
                enc.write_i32_le(UInt32(self.packed_sfixed32[i]))
        if len(self.packed_sfixed64) != 0:
            enc.write_len_header(84, len(self.packed_sfixed64) * 8)
            for i in range(len(self.packed_sfixed64)):
                enc.write_i64_le(UInt64(self.packed_sfixed64[i]))
        if len(self.packed_float) != 0:
            enc.write_len_header(85, len(self.packed_float) * 4)
            for i in range(len(self.packed_float)):
                enc.write_i32_le(UInt32(self.packed_float[i].to_bits()))
        if len(self.packed_double) != 0:
            enc.write_len_header(86, len(self.packed_double) * 8)
            for i in range(len(self.packed_double)):
                enc.write_i64_le(UInt64(self.packed_double[i].to_bits()))
        if len(self.packed_bool) != 0:
            var payload = 0
            for i in range(len(self.packed_bool)):
                payload += varint_len(UInt64(Int(self.packed_bool[i])))
            enc.write_len_header(87, payload)
            for i in range(len(self.packed_bool)):
                enc.write_varint(UInt64(Int(self.packed_bool[i])))
        if len(self.packed_nested_enum) != 0:
            var payload = 0
            for i in range(len(self.packed_nested_enum)):
                payload += varint_len(i32_to_u64(self.packed_nested_enum[i].value))
            enc.write_len_header(88, payload)
            for i in range(len(self.packed_nested_enum)):
                enc.write_varint(i32_to_u64(self.packed_nested_enum[i].value))
        for i in range(len(self.unpacked_int32)):
            enc.write_tag(89, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.unpacked_int32[i]))
        for i in range(len(self.unpacked_int64)):
            enc.write_tag(90, WireType.VARINT)
            enc.write_varint(i64_to_u64(self.unpacked_int64[i]))
        for i in range(len(self.unpacked_uint32)):
            enc.write_tag(91, WireType.VARINT)
            enc.write_varint(UInt64(self.unpacked_uint32[i]))
        for i in range(len(self.unpacked_uint64)):
            enc.write_tag(92, WireType.VARINT)
            enc.write_varint(self.unpacked_uint64[i])
        for i in range(len(self.unpacked_sint32)):
            enc.write_tag(93, WireType.VARINT)
            enc.write_varint(UInt64(zigzag_encode_i32(self.unpacked_sint32[i])))
        for i in range(len(self.unpacked_sint64)):
            enc.write_tag(94, WireType.VARINT)
            enc.write_varint(zigzag_encode_i64(self.unpacked_sint64[i]))
        for i in range(len(self.unpacked_fixed32)):
            enc.write_tag(95, WireType.I32)
            enc.write_i32_le(self.unpacked_fixed32[i])
        for i in range(len(self.unpacked_fixed64)):
            enc.write_tag(96, WireType.I64)
            enc.write_i64_le(self.unpacked_fixed64[i])
        for i in range(len(self.unpacked_sfixed32)):
            enc.write_tag(97, WireType.I32)
            enc.write_i32_le(UInt32(self.unpacked_sfixed32[i]))
        for i in range(len(self.unpacked_sfixed64)):
            enc.write_tag(98, WireType.I64)
            enc.write_i64_le(UInt64(self.unpacked_sfixed64[i]))
        for i in range(len(self.unpacked_float)):
            enc.write_tag(99, WireType.I32)
            enc.write_i32_le(UInt32(self.unpacked_float[i].to_bits()))
        for i in range(len(self.unpacked_double)):
            enc.write_tag(100, WireType.I64)
            enc.write_i64_le(UInt64(self.unpacked_double[i].to_bits()))
        for i in range(len(self.unpacked_bool)):
            enc.write_tag(101, WireType.VARINT)
            enc.write_varint(UInt64(Int(self.unpacked_bool[i])))
        for i in range(len(self.unpacked_nested_enum)):
            enc.write_tag(102, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.unpacked_nested_enum[i].value))
        for item in self.map_int32_int32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value))
            enc.write_len_header(56, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.key))
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.value))
        for item in self.map_int64_int64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i64_to_u64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, i64_to_u64(item.value))
            enc.write_len_header(57, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(i64_to_u64(item.key))
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(i64_to_u64(item.value))
        for item in self.map_uint32_uint32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, UInt64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, UInt64(item.value))
            enc.write_len_header(58, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(UInt64(item.key))
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(UInt64(item.value))
        for item in self.map_uint64_uint64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, item.key)
            if item.value != 0:
                entry_len += tag_varint_len(2, item.value)
            enc.write_len_header(59, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(item.key)
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(item.value)
        for item in self.map_sint32_sint32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, UInt64(zigzag_encode_i32(item.key)))
            if item.value != 0:
                entry_len += tag_varint_len(2, UInt64(zigzag_encode_i32(item.value)))
            enc.write_len_header(60, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(UInt64(zigzag_encode_i32(item.key)))
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(UInt64(zigzag_encode_i32(item.value)))
        for item in self.map_sint64_sint64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, zigzag_encode_i64(item.key))
            if item.value != 0:
                entry_len += tag_varint_len(2, zigzag_encode_i64(item.value))
            enc.write_len_header(61, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(zigzag_encode_i64(item.key))
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(zigzag_encode_i64(item.value))
        for item in self.map_fixed32_fixed32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed32_len(1)
            if item.value != 0:
                entry_len += tag_fixed32_len(2)
            enc.write_len_header(62, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.I32)
                enc.write_i32_le(item.key)
            if item.value != 0:
                enc.write_tag(2, WireType.I32)
                enc.write_i32_le(item.value)
        for item in self.map_fixed64_fixed64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed64_len(1)
            if item.value != 0:
                entry_len += tag_fixed64_len(2)
            enc.write_len_header(63, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.I64)
                enc.write_i64_le(item.key)
            if item.value != 0:
                enc.write_tag(2, WireType.I64)
                enc.write_i64_le(item.value)
        for item in self.map_sfixed32_sfixed32.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed32_len(1)
            if item.value != 0:
                entry_len += tag_fixed32_len(2)
            enc.write_len_header(64, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.I32)
                enc.write_i32_le(UInt32(item.key))
            if item.value != 0:
                enc.write_tag(2, WireType.I32)
                enc.write_i32_le(UInt32(item.value))
        for item in self.map_sfixed64_sfixed64.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_fixed64_len(1)
            if item.value != 0:
                entry_len += tag_fixed64_len(2)
            enc.write_len_header(65, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.I64)
                enc.write_i64_le(UInt64(item.key))
            if item.value != 0:
                enc.write_tag(2, WireType.I64)
                enc.write_i64_le(UInt64(item.value))
        for item in self.map_int32_float.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value != 0.0:
                entry_len += tag_fixed32_len(2)
            enc.write_len_header(66, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.key))
            if item.value != 0.0:
                enc.write_tag(2, WireType.I32)
                enc.write_i32_le(UInt32(item.value.to_bits()))
        for item in self.map_int32_double.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value != 0.0:
                entry_len += tag_fixed64_len(2)
            enc.write_len_header(67, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.key))
            if item.value != 0.0:
                enc.write_tag(2, WireType.I64)
                enc.write_i64_le(UInt64(item.value.to_bits()))
        for item in self.map_bool_bool.items():
            var entry_len = 0
            if item.key:
                entry_len += tag_varint_len(1, UInt64(Int(item.key)))
            if item.value:
                entry_len += tag_varint_len(2, UInt64(Int(item.value)))
            enc.write_len_header(68, entry_len)
            if item.key:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(UInt64(Int(item.key)))
            if item.value:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(UInt64(Int(item.value)))
        for item in self.map_string_string.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value.byte_length() != 0:
                entry_len += tag_len_len(2, item.value.byte_length())
            enc.write_len_header(69, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            if item.value.byte_length() != 0:
                enc.write_len_header(2, item.value.byte_length())
                enc.write_bytes(item.value.as_bytes())
        for item in self.map_string_bytes.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if len(item.value) != 0:
                entry_len += tag_len_len(2, len(item.value))
            enc.write_len_header(70, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            if len(item.value) != 0:
                enc.write_len_header(2, len(item.value))
                enc.write_bytes(item.value)
        for item in self.map_string_nested_message.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            entry_len += tag_len_len(2, item.value.encoded_len())
            enc.write_len_header(71, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            enc.write_len_header(2, item.value.encoded_len())
            item.value.encode_to(enc)
        for item in self.map_string_foreign_message.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            entry_len += tag_len_len(2, item.value.encoded_len())
            enc.write_len_header(72, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            enc.write_len_header(2, item.value.encoded_len())
            item.value.encode_to(enc)
        for item in self.map_string_nested_enum.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value.value))
            enc.write_len_header(73, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            if item.value.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.value.value))
        for item in self.map_string_foreign_enum.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value.value))
            enc.write_len_header(74, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            if item.value.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.value.value))
        if self.which_oneof_field == 111:
            enc.write_tag(111, WireType.VARINT)
            enc.write_varint(UInt64(self.oneof_uint32))
        if self.which_oneof_field == 113:
            enc.write_len_header(113, self.oneof_string.byte_length())
            enc.write_bytes(self.oneof_string.as_bytes())
        if self.which_oneof_field == 114:
            enc.write_len_header(114, len(self.oneof_bytes))
            enc.write_bytes(self.oneof_bytes)
        if self.which_oneof_field == 115:
            enc.write_tag(115, WireType.VARINT)
            enc.write_varint(UInt64(Int(self.oneof_bool)))
        if self.which_oneof_field == 116:
            enc.write_tag(116, WireType.VARINT)
            enc.write_varint(self.oneof_uint64)
        if self.which_oneof_field == 117:
            enc.write_tag(117, WireType.I32)
            enc.write_i32_le(UInt32(self.oneof_float.to_bits()))
        if self.which_oneof_field == 118:
            enc.write_tag(118, WireType.I64)
            enc.write_i64_le(UInt64(self.oneof_double.to_bits()))
        if self.which_oneof_field == 119:
            enc.write_tag(119, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.oneof_enum.value))
        if self.which_oneof_field == 120:
            enc.write_tag(120, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.oneof_null_value.value))
        if self.optional_bool_wrapper:
            ref child = self.optional_bool_wrapper.value()
            enc.write_len_header(201, child.encoded_len())
            child.encode_to(enc)
        if self.optional_int32_wrapper:
            ref child = self.optional_int32_wrapper.value()
            enc.write_len_header(202, child.encoded_len())
            child.encode_to(enc)
        if self.optional_int64_wrapper:
            ref child = self.optional_int64_wrapper.value()
            enc.write_len_header(203, child.encoded_len())
            child.encode_to(enc)
        if self.optional_uint32_wrapper:
            ref child = self.optional_uint32_wrapper.value()
            enc.write_len_header(204, child.encoded_len())
            child.encode_to(enc)
        if self.optional_uint64_wrapper:
            ref child = self.optional_uint64_wrapper.value()
            enc.write_len_header(205, child.encoded_len())
            child.encode_to(enc)
        if self.optional_float_wrapper:
            ref child = self.optional_float_wrapper.value()
            enc.write_len_header(206, child.encoded_len())
            child.encode_to(enc)
        if self.optional_double_wrapper:
            ref child = self.optional_double_wrapper.value()
            enc.write_len_header(207, child.encoded_len())
            child.encode_to(enc)
        if self.optional_string_wrapper:
            ref child = self.optional_string_wrapper.value()
            enc.write_len_header(208, child.encoded_len())
            child.encode_to(enc)
        if self.optional_bytes_wrapper:
            ref child = self.optional_bytes_wrapper.value()
            enc.write_len_header(209, child.encoded_len())
            child.encode_to(enc)
        for i in range(len(self.repeated_bool_wrapper)):
            enc.write_len_header(211, self.repeated_bool_wrapper[i].encoded_len())
            self.repeated_bool_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_int32_wrapper)):
            enc.write_len_header(212, self.repeated_int32_wrapper[i].encoded_len())
            self.repeated_int32_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_int64_wrapper)):
            enc.write_len_header(213, self.repeated_int64_wrapper[i].encoded_len())
            self.repeated_int64_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_uint32_wrapper)):
            enc.write_len_header(214, self.repeated_uint32_wrapper[i].encoded_len())
            self.repeated_uint32_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_uint64_wrapper)):
            enc.write_len_header(215, self.repeated_uint64_wrapper[i].encoded_len())
            self.repeated_uint64_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_float_wrapper)):
            enc.write_len_header(216, self.repeated_float_wrapper[i].encoded_len())
            self.repeated_float_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_double_wrapper)):
            enc.write_len_header(217, self.repeated_double_wrapper[i].encoded_len())
            self.repeated_double_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_string_wrapper)):
            enc.write_len_header(218, self.repeated_string_wrapper[i].encoded_len())
            self.repeated_string_wrapper[i].encode_to(enc)
        for i in range(len(self.repeated_bytes_wrapper)):
            enc.write_len_header(219, self.repeated_bytes_wrapper[i].encoded_len())
            self.repeated_bytes_wrapper[i].encode_to(enc)
        if self.optional_duration:
            ref child = self.optional_duration.value()
            enc.write_len_header(301, child.encoded_len())
            child.encode_to(enc)
        if self.optional_timestamp:
            ref child = self.optional_timestamp.value()
            enc.write_len_header(302, child.encoded_len())
            child.encode_to(enc)
        if self.optional_field_mask:
            ref child = self.optional_field_mask.value()
            enc.write_len_header(303, child.encoded_len())
            child.encode_to(enc)
        if self.optional_struct:
            ref child = self.optional_struct.value()
            enc.write_len_header(304, child.encoded_len())
            child.encode_to(enc)
        if self.optional_any:
            ref child = self.optional_any.value()
            enc.write_len_header(305, child.encoded_len())
            child.encode_to(enc)
        if self.optional_value:
            ref child = self.optional_value.value()
            enc.write_len_header(306, child.encoded_len())
            child.encode_to(enc)
        if self.optional_null_value.value != 0:
            enc.write_tag(307, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.optional_null_value.value))
        for i in range(len(self.repeated_duration)):
            enc.write_len_header(311, self.repeated_duration[i].encoded_len())
            self.repeated_duration[i].encode_to(enc)
        for i in range(len(self.repeated_timestamp)):
            enc.write_len_header(312, self.repeated_timestamp[i].encoded_len())
            self.repeated_timestamp[i].encode_to(enc)
        for i in range(len(self.repeated_fieldmask)):
            enc.write_len_header(313, self.repeated_fieldmask[i].encoded_len())
            self.repeated_fieldmask[i].encode_to(enc)
        for i in range(len(self.repeated_struct)):
            enc.write_len_header(324, self.repeated_struct[i].encoded_len())
            self.repeated_struct[i].encode_to(enc)
        for i in range(len(self.repeated_any)):
            enc.write_len_header(315, self.repeated_any[i].encoded_len())
            self.repeated_any[i].encode_to(enc)
        for i in range(len(self.repeated_value)):
            enc.write_len_header(316, self.repeated_value[i].encoded_len())
            self.repeated_value[i].encode_to(enc)
        for i in range(len(self.repeated_list_value)):
            enc.write_len_header(317, self.repeated_list_value[i].encoded_len())
            self.repeated_list_value[i].encode_to(enc)
        if self.fieldname1 != 0:
            enc.write_tag(401, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.fieldname1))
        if self.field_name2 != 0:
            enc.write_tag(402, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field_name2))
        if self._field_name3 != 0:
            enc.write_tag(403, WireType.VARINT)
            enc.write_varint(i32_to_u64(self._field_name3))
        if self.field__name4_ != 0:
            enc.write_tag(404, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field__name4_))
        if self.field0name5 != 0:
            enc.write_tag(405, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field0name5))
        if self.field_0_name6 != 0:
            enc.write_tag(406, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field_0_name6))
        if self.fieldName7 != 0:
            enc.write_tag(407, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.fieldName7))
        if self.FieldName8 != 0:
            enc.write_tag(408, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.FieldName8))
        if self.field_Name9 != 0:
            enc.write_tag(409, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field_Name9))
        if self.Field_Name10 != 0:
            enc.write_tag(410, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.Field_Name10))
        if self.FIELD_NAME11 != 0:
            enc.write_tag(411, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.FIELD_NAME11))
        if self.FIELD_name12 != 0:
            enc.write_tag(412, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.FIELD_name12))
        if self.__field_name13 != 0:
            enc.write_tag(413, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.__field_name13))
        if self.__Field_name14 != 0:
            enc.write_tag(414, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.__Field_name14))
        if self.field__name15 != 0:
            enc.write_tag(415, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field__name15))
        if self.field__Name16 != 0:
            enc.write_tag(416, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field__Name16))
        if self.field_name17__ != 0:
            enc.write_tag(417, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.field_name17__))
        if self.Field_name18__ != 0:
            enc.write_tag(418, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.Field_name18__))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.optional_int32 = u64_to_i32(dec.read_varint())
            elif field == 2 and wire == WireType.VARINT:
                self.optional_int64 = u64_to_i64(dec.read_varint())
            elif field == 3 and wire == WireType.VARINT:
                self.optional_uint32 = UInt32(dec.read_varint())
            elif field == 4 and wire == WireType.VARINT:
                self.optional_uint64 = dec.read_varint()
            elif field == 5 and wire == WireType.VARINT:
                self.optional_sint32 = zigzag_decode_i32(UInt32(dec.read_varint()))
            elif field == 6 and wire == WireType.VARINT:
                self.optional_sint64 = zigzag_decode_i64(dec.read_varint())
            elif field == 7 and wire == WireType.I32:
                self.optional_fixed32 = dec.read_i32_le()
            elif field == 8 and wire == WireType.I64:
                self.optional_fixed64 = dec.read_i64_le()
            elif field == 9 and wire == WireType.I32:
                self.optional_sfixed32 = Int32(dec.read_i32_le())
            elif field == 10 and wire == WireType.I64:
                self.optional_sfixed64 = Int64(dec.read_i64_le())
            elif field == 11 and wire == WireType.I32:
                self.optional_float = Float32(from_bits=dec.read_i32_le())
            elif field == 12 and wire == WireType.I64:
                self.optional_double = Float64(from_bits=dec.read_i64_le())
            elif field == 13 and wire == WireType.VARINT:
                self.optional_bool = dec.read_varint() != 0
            elif field == 14 and wire == WireType.LEN:
                self.optional_string = dec.read_string()
            elif field == 15 and wire == WireType.LEN:
                self.optional_bytes = dec.read_bytes()
            elif field == 19 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_foreign_message:
                    self.optional_foreign_message = ForeignMessage()
                self.optional_foreign_message.value().merge_from(inner)
            elif field == 21 and wire == WireType.VARINT:
                self.optional_nested_enum = TestAllTypesProto3NestedEnum(u64_to_i32(dec.read_varint()))
            elif field == 22 and wire == WireType.VARINT:
                self.optional_foreign_enum = ForeignEnum(u64_to_i32(dec.read_varint()))
            elif field == 23 and wire == WireType.VARINT:
                self.optional_aliased_enum = TestAllTypesProto3AliasedEnum(u64_to_i32(dec.read_varint()))
            elif field == 24 and wire == WireType.LEN:
                self.optional_string_piece = dec.read_string()
            elif field == 25 and wire == WireType.LEN:
                self.optional_cord = dec.read_string()
            elif field == 31 and wire == WireType.VARINT:
                self.repeated_int32.append(u64_to_i32(dec.read_varint()))
            elif field == 31 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_int32.append(u64_to_i32(words[i]))
            elif field == 32 and wire == WireType.VARINT:
                self.repeated_int64.append(u64_to_i64(dec.read_varint()))
            elif field == 32 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_int64.append(u64_to_i64(words[i]))
            elif field == 33 and wire == WireType.VARINT:
                self.repeated_uint32.append(UInt32(dec.read_varint()))
            elif field == 33 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_uint32.append(UInt32(words[i]))
            elif field == 34 and wire == WireType.VARINT:
                self.repeated_uint64.append(dec.read_varint())
            elif field == 34 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_uint64.append(words[i])
            elif field == 35 and wire == WireType.VARINT:
                self.repeated_sint32.append(zigzag_decode_i32(UInt32(dec.read_varint())))
            elif field == 35 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_sint32.append(zigzag_decode_i32(UInt32(words[i])))
            elif field == 36 and wire == WireType.VARINT:
                self.repeated_sint64.append(zigzag_decode_i64(dec.read_varint()))
            elif field == 36 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_sint64.append(zigzag_decode_i64(words[i]))
            elif field == 37 and wire == WireType.I32:
                self.repeated_fixed32.append(dec.read_i32_le())
            elif field == 37 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.repeated_fixed32.append(words[i])
            elif field == 38 and wire == WireType.I64:
                self.repeated_fixed64.append(dec.read_i64_le())
            elif field == 38 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.repeated_fixed64.append(words[i])
            elif field == 39 and wire == WireType.I32:
                self.repeated_sfixed32.append(Int32(dec.read_i32_le()))
            elif field == 39 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.repeated_sfixed32.append(Int32(words[i]))
            elif field == 40 and wire == WireType.I64:
                self.repeated_sfixed64.append(Int64(dec.read_i64_le()))
            elif field == 40 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.repeated_sfixed64.append(Int64(words[i]))
            elif field == 41 and wire == WireType.I32:
                self.repeated_float.append(Float32(from_bits=dec.read_i32_le()))
            elif field == 41 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.repeated_float.append(Float32(from_bits=words[i]))
            elif field == 42 and wire == WireType.I64:
                self.repeated_double.append(Float64(from_bits=dec.read_i64_le()))
            elif field == 42 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.repeated_double.append(Float64(from_bits=words[i]))
            elif field == 43 and wire == WireType.VARINT:
                self.repeated_bool.append(dec.read_varint() != 0)
            elif field == 43 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_bool.append(words[i] != 0)
            elif field == 44 and wire == WireType.LEN:
                self.repeated_string.append(dec.read_string())
            elif field == 45 and wire == WireType.LEN:
                self.repeated_bytes.append(dec.read_bytes())
            elif field == 49 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = ForeignMessage()
                item.merge_from(inner)
                self.repeated_foreign_message.append(item^)
            elif field == 51 and wire == WireType.VARINT:
                self.repeated_nested_enum.append(TestAllTypesProto3NestedEnum(u64_to_i32(dec.read_varint())))
            elif field == 51 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_nested_enum.append(TestAllTypesProto3NestedEnum(u64_to_i32(words[i])))
            elif field == 52 and wire == WireType.VARINT:
                self.repeated_foreign_enum.append(ForeignEnum(u64_to_i32(dec.read_varint())))
            elif field == 52 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.repeated_foreign_enum.append(ForeignEnum(u64_to_i32(words[i])))
            elif field == 54 and wire == WireType.LEN:
                self.repeated_string_piece.append(dec.read_string())
            elif field == 55 and wire == WireType.LEN:
                self.repeated_cord.append(dec.read_string())
            elif field == 75 and wire == WireType.VARINT:
                self.packed_int32.append(u64_to_i32(dec.read_varint()))
            elif field == 75 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_int32.append(u64_to_i32(words[i]))
            elif field == 76 and wire == WireType.VARINT:
                self.packed_int64.append(u64_to_i64(dec.read_varint()))
            elif field == 76 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_int64.append(u64_to_i64(words[i]))
            elif field == 77 and wire == WireType.VARINT:
                self.packed_uint32.append(UInt32(dec.read_varint()))
            elif field == 77 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_uint32.append(UInt32(words[i]))
            elif field == 78 and wire == WireType.VARINT:
                self.packed_uint64.append(dec.read_varint())
            elif field == 78 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_uint64.append(words[i])
            elif field == 79 and wire == WireType.VARINT:
                self.packed_sint32.append(zigzag_decode_i32(UInt32(dec.read_varint())))
            elif field == 79 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_sint32.append(zigzag_decode_i32(UInt32(words[i])))
            elif field == 80 and wire == WireType.VARINT:
                self.packed_sint64.append(zigzag_decode_i64(dec.read_varint()))
            elif field == 80 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_sint64.append(zigzag_decode_i64(words[i]))
            elif field == 81 and wire == WireType.I32:
                self.packed_fixed32.append(dec.read_i32_le())
            elif field == 81 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.packed_fixed32.append(words[i])
            elif field == 82 and wire == WireType.I64:
                self.packed_fixed64.append(dec.read_i64_le())
            elif field == 82 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.packed_fixed64.append(words[i])
            elif field == 83 and wire == WireType.I32:
                self.packed_sfixed32.append(Int32(dec.read_i32_le()))
            elif field == 83 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.packed_sfixed32.append(Int32(words[i]))
            elif field == 84 and wire == WireType.I64:
                self.packed_sfixed64.append(Int64(dec.read_i64_le()))
            elif field == 84 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.packed_sfixed64.append(Int64(words[i]))
            elif field == 85 and wire == WireType.I32:
                self.packed_float.append(Float32(from_bits=dec.read_i32_le()))
            elif field == 85 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.packed_float.append(Float32(from_bits=words[i]))
            elif field == 86 and wire == WireType.I64:
                self.packed_double.append(Float64(from_bits=dec.read_i64_le()))
            elif field == 86 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.packed_double.append(Float64(from_bits=words[i]))
            elif field == 87 and wire == WireType.VARINT:
                self.packed_bool.append(dec.read_varint() != 0)
            elif field == 87 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_bool.append(words[i] != 0)
            elif field == 88 and wire == WireType.VARINT:
                self.packed_nested_enum.append(TestAllTypesProto3NestedEnum(u64_to_i32(dec.read_varint())))
            elif field == 88 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_nested_enum.append(TestAllTypesProto3NestedEnum(u64_to_i32(words[i])))
            elif field == 89 and wire == WireType.VARINT:
                self.unpacked_int32.append(u64_to_i32(dec.read_varint()))
            elif field == 89 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_int32.append(u64_to_i32(words[i]))
            elif field == 90 and wire == WireType.VARINT:
                self.unpacked_int64.append(u64_to_i64(dec.read_varint()))
            elif field == 90 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_int64.append(u64_to_i64(words[i]))
            elif field == 91 and wire == WireType.VARINT:
                self.unpacked_uint32.append(UInt32(dec.read_varint()))
            elif field == 91 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_uint32.append(UInt32(words[i]))
            elif field == 92 and wire == WireType.VARINT:
                self.unpacked_uint64.append(dec.read_varint())
            elif field == 92 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_uint64.append(words[i])
            elif field == 93 and wire == WireType.VARINT:
                self.unpacked_sint32.append(zigzag_decode_i32(UInt32(dec.read_varint())))
            elif field == 93 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_sint32.append(zigzag_decode_i32(UInt32(words[i])))
            elif field == 94 and wire == WireType.VARINT:
                self.unpacked_sint64.append(zigzag_decode_i64(dec.read_varint()))
            elif field == 94 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_sint64.append(zigzag_decode_i64(words[i]))
            elif field == 95 and wire == WireType.I32:
                self.unpacked_fixed32.append(dec.read_i32_le())
            elif field == 95 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.unpacked_fixed32.append(words[i])
            elif field == 96 and wire == WireType.I64:
                self.unpacked_fixed64.append(dec.read_i64_le())
            elif field == 96 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.unpacked_fixed64.append(words[i])
            elif field == 97 and wire == WireType.I32:
                self.unpacked_sfixed32.append(Int32(dec.read_i32_le()))
            elif field == 97 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.unpacked_sfixed32.append(Int32(words[i]))
            elif field == 98 and wire == WireType.I64:
                self.unpacked_sfixed64.append(Int64(dec.read_i64_le()))
            elif field == 98 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.unpacked_sfixed64.append(Int64(words[i]))
            elif field == 99 and wire == WireType.I32:
                self.unpacked_float.append(Float32(from_bits=dec.read_i32_le()))
            elif field == 99 and wire == WireType.LEN:
                var words = List[UInt32]()
                dec.read_packed_fixed32(words)
                for i in range(len(words)):
                    self.unpacked_float.append(Float32(from_bits=words[i]))
            elif field == 100 and wire == WireType.I64:
                self.unpacked_double.append(Float64(from_bits=dec.read_i64_le()))
            elif field == 100 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.unpacked_double.append(Float64(from_bits=words[i]))
            elif field == 101 and wire == WireType.VARINT:
                self.unpacked_bool.append(dec.read_varint() != 0)
            elif field == 101 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_bool.append(words[i] != 0)
            elif field == 102 and wire == WireType.VARINT:
                self.unpacked_nested_enum.append(TestAllTypesProto3NestedEnum(u64_to_i32(dec.read_varint())))
            elif field == 102 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_nested_enum.append(TestAllTypesProto3NestedEnum(u64_to_i32(words[i])))
            elif field == 56 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int32(0)
                var map_val = Int32(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = u64_to_i32(inner.read_varint())
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = u64_to_i32(inner.read_varint())
                    else:
                        inner.skip_field(ew)
                self.map_int32_int32[map_key] = map_val^
            elif field == 57 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int64(0)
                var map_val = Int64(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = u64_to_i64(inner.read_varint())
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = u64_to_i64(inner.read_varint())
                    else:
                        inner.skip_field(ew)
                self.map_int64_int64[map_key] = map_val^
            elif field == 58 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = UInt32(0)
                var map_val = UInt32(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = UInt32(inner.read_varint())
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = UInt32(inner.read_varint())
                    else:
                        inner.skip_field(ew)
                self.map_uint32_uint32[map_key] = map_val^
            elif field == 59 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = UInt64(0)
                var map_val = UInt64(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = inner.read_varint()
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = inner.read_varint()
                    else:
                        inner.skip_field(ew)
                self.map_uint64_uint64[map_key] = map_val^
            elif field == 60 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int32(0)
                var map_val = Int32(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = zigzag_decode_i32(UInt32(inner.read_varint()))
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = zigzag_decode_i32(UInt32(inner.read_varint()))
                    else:
                        inner.skip_field(ew)
                self.map_sint32_sint32[map_key] = map_val^
            elif field == 61 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int64(0)
                var map_val = Int64(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = zigzag_decode_i64(inner.read_varint())
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = zigzag_decode_i64(inner.read_varint())
                    else:
                        inner.skip_field(ew)
                self.map_sint64_sint64[map_key] = map_val^
            elif field == 62 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = UInt32(0)
                var map_val = UInt32(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.I32:
                        map_key = inner.read_i32_le()
                    elif ef == 2 and ew == WireType.I32:
                        map_val = inner.read_i32_le()
                    else:
                        inner.skip_field(ew)
                self.map_fixed32_fixed32[map_key] = map_val^
            elif field == 63 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = UInt64(0)
                var map_val = UInt64(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.I64:
                        map_key = inner.read_i64_le()
                    elif ef == 2 and ew == WireType.I64:
                        map_val = inner.read_i64_le()
                    else:
                        inner.skip_field(ew)
                self.map_fixed64_fixed64[map_key] = map_val^
            elif field == 64 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int32(0)
                var map_val = Int32(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.I32:
                        map_key = Int32(inner.read_i32_le())
                    elif ef == 2 and ew == WireType.I32:
                        map_val = Int32(inner.read_i32_le())
                    else:
                        inner.skip_field(ew)
                self.map_sfixed32_sfixed32[map_key] = map_val^
            elif field == 65 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int64(0)
                var map_val = Int64(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.I64:
                        map_key = Int64(inner.read_i64_le())
                    elif ef == 2 and ew == WireType.I64:
                        map_val = Int64(inner.read_i64_le())
                    else:
                        inner.skip_field(ew)
                self.map_sfixed64_sfixed64[map_key] = map_val^
            elif field == 66 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int32(0)
                var map_val = Float32(0.0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = u64_to_i32(inner.read_varint())
                    elif ef == 2 and ew == WireType.I32:
                        map_val = Float32(from_bits=inner.read_i32_le())
                    else:
                        inner.skip_field(ew)
                self.map_int32_float[map_key] = map_val^
            elif field == 67 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int32(0)
                var map_val = 0.0
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = u64_to_i32(inner.read_varint())
                    elif ef == 2 and ew == WireType.I64:
                        map_val = Float64(from_bits=inner.read_i64_le())
                    else:
                        inner.skip_field(ew)
                self.map_int32_double[map_key] = map_val^
            elif field == 68 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = False
                var map_val = False
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = inner.read_varint() != 0
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = inner.read_varint() != 0
                    else:
                        inner.skip_field(ew)
                self.map_bool_bool[map_key] = map_val^
            elif field == 69 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = String()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.LEN:
                        map_val = inner.read_string()
                    else:
                        inner.skip_field(ew)
                self.map_string_string[map_key] = map_val^
            elif field == 70 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = List[Byte]()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.LEN:
                        map_val = inner.read_bytes()
                    else:
                        inner.skip_field(ew)
                self.map_string_bytes[map_key] = map_val^
            elif field == 71 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = TestAllTypesProto3NestedMessage()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.LEN:
                        var vin = inner.subreader(inner.read_len_span())
                        map_val.merge_from(vin)
                    else:
                        inner.skip_field(ew)
                self.map_string_nested_message[map_key] = map_val^
            elif field == 72 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = ForeignMessage()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.LEN:
                        var vin = inner.subreader(inner.read_len_span())
                        map_val.merge_from(vin)
                    else:
                        inner.skip_field(ew)
                self.map_string_foreign_message[map_key] = map_val^
            elif field == 73 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = TestAllTypesProto3NestedEnum()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = TestAllTypesProto3NestedEnum(u64_to_i32(inner.read_varint()))
                    else:
                        inner.skip_field(ew)
                self.map_string_nested_enum[map_key] = map_val^
            elif field == 74 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = ForeignEnum()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = ForeignEnum(u64_to_i32(inner.read_varint()))
                    else:
                        inner.skip_field(ew)
                self.map_string_foreign_enum[map_key] = map_val^
            elif field == 111 and wire == WireType.VARINT:
                self.which_oneof_field = 111
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_uint32 = UInt32(dec.read_varint())
            elif field == 113 and wire == WireType.LEN:
                self.which_oneof_field = 113
                self.oneof_uint32 = UInt32(0)
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_string = dec.read_string()
            elif field == 114 and wire == WireType.LEN:
                self.which_oneof_field = 114
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_bytes = dec.read_bytes()
            elif field == 115 and wire == WireType.VARINT:
                self.which_oneof_field = 115
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_bool = dec.read_varint() != 0
            elif field == 116 and wire == WireType.VARINT:
                self.which_oneof_field = 116
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_uint64 = dec.read_varint()
            elif field == 117 and wire == WireType.I32:
                self.which_oneof_field = 117
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_float = Float32(from_bits=dec.read_i32_le())
            elif field == 118 and wire == WireType.I64:
                self.which_oneof_field = 118
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue()
                self.oneof_double = Float64(from_bits=dec.read_i64_le())
            elif field == 119 and wire == WireType.VARINT:
                self.which_oneof_field = 119
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_null_value = NullValue()
                self.oneof_enum = TestAllTypesProto3NestedEnum(u64_to_i32(dec.read_varint()))
            elif field == 120 and wire == WireType.VARINT:
                self.which_oneof_field = 120
                self.oneof_uint32 = UInt32(0)
                self.oneof_string = String()
                self.oneof_bytes = List[Byte]()
                self.oneof_bool = False
                self.oneof_uint64 = UInt64(0)
                self.oneof_float = Float32(0.0)
                self.oneof_double = 0.0
                self.oneof_enum = TestAllTypesProto3NestedEnum()
                self.oneof_null_value = NullValue(u64_to_i32(dec.read_varint()))
            elif field == 201 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_bool_wrapper:
                    self.optional_bool_wrapper = BoolValue()
                self.optional_bool_wrapper.value().merge_from(inner)
            elif field == 202 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_int32_wrapper:
                    self.optional_int32_wrapper = Int32Value()
                self.optional_int32_wrapper.value().merge_from(inner)
            elif field == 203 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_int64_wrapper:
                    self.optional_int64_wrapper = Int64Value()
                self.optional_int64_wrapper.value().merge_from(inner)
            elif field == 204 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_uint32_wrapper:
                    self.optional_uint32_wrapper = UInt32Value()
                self.optional_uint32_wrapper.value().merge_from(inner)
            elif field == 205 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_uint64_wrapper:
                    self.optional_uint64_wrapper = UInt64Value()
                self.optional_uint64_wrapper.value().merge_from(inner)
            elif field == 206 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_float_wrapper:
                    self.optional_float_wrapper = FloatValue()
                self.optional_float_wrapper.value().merge_from(inner)
            elif field == 207 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_double_wrapper:
                    self.optional_double_wrapper = DoubleValue()
                self.optional_double_wrapper.value().merge_from(inner)
            elif field == 208 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_string_wrapper:
                    self.optional_string_wrapper = StringValue()
                self.optional_string_wrapper.value().merge_from(inner)
            elif field == 209 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_bytes_wrapper:
                    self.optional_bytes_wrapper = BytesValue()
                self.optional_bytes_wrapper.value().merge_from(inner)
            elif field == 211 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = BoolValue()
                item.merge_from(inner)
                self.repeated_bool_wrapper.append(item^)
            elif field == 212 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Int32Value()
                item.merge_from(inner)
                self.repeated_int32_wrapper.append(item^)
            elif field == 213 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Int64Value()
                item.merge_from(inner)
                self.repeated_int64_wrapper.append(item^)
            elif field == 214 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = UInt32Value()
                item.merge_from(inner)
                self.repeated_uint32_wrapper.append(item^)
            elif field == 215 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = UInt64Value()
                item.merge_from(inner)
                self.repeated_uint64_wrapper.append(item^)
            elif field == 216 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = FloatValue()
                item.merge_from(inner)
                self.repeated_float_wrapper.append(item^)
            elif field == 217 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = DoubleValue()
                item.merge_from(inner)
                self.repeated_double_wrapper.append(item^)
            elif field == 218 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = StringValue()
                item.merge_from(inner)
                self.repeated_string_wrapper.append(item^)
            elif field == 219 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = BytesValue()
                item.merge_from(inner)
                self.repeated_bytes_wrapper.append(item^)
            elif field == 301 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_duration:
                    self.optional_duration = Duration()
                self.optional_duration.value().merge_from(inner)
            elif field == 302 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_timestamp:
                    self.optional_timestamp = Timestamp()
                self.optional_timestamp.value().merge_from(inner)
            elif field == 303 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_field_mask:
                    self.optional_field_mask = FieldMask()
                self.optional_field_mask.value().merge_from(inner)
            elif field == 304 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_struct:
                    self.optional_struct = Struct()
                self.optional_struct.value().merge_from(inner)
            elif field == 305 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_any:
                    self.optional_any = Any()
                self.optional_any.value().merge_from(inner)
            elif field == 306 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.optional_value:
                    self.optional_value = Value()
                self.optional_value.value().merge_from(inner)
            elif field == 307 and wire == WireType.VARINT:
                self.optional_null_value = NullValue(u64_to_i32(dec.read_varint()))
            elif field == 311 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Duration()
                item.merge_from(inner)
                self.repeated_duration.append(item^)
            elif field == 312 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Timestamp()
                item.merge_from(inner)
                self.repeated_timestamp.append(item^)
            elif field == 313 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = FieldMask()
                item.merge_from(inner)
                self.repeated_fieldmask.append(item^)
            elif field == 324 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Struct()
                item.merge_from(inner)
                self.repeated_struct.append(item^)
            elif field == 315 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Any()
                item.merge_from(inner)
                self.repeated_any.append(item^)
            elif field == 316 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = Value()
                item.merge_from(inner)
                self.repeated_value.append(item^)
            elif field == 317 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = ListValue()
                item.merge_from(inner)
                self.repeated_list_value.append(item^)
            elif field == 401 and wire == WireType.VARINT:
                self.fieldname1 = u64_to_i32(dec.read_varint())
            elif field == 402 and wire == WireType.VARINT:
                self.field_name2 = u64_to_i32(dec.read_varint())
            elif field == 403 and wire == WireType.VARINT:
                self._field_name3 = u64_to_i32(dec.read_varint())
            elif field == 404 and wire == WireType.VARINT:
                self.field__name4_ = u64_to_i32(dec.read_varint())
            elif field == 405 and wire == WireType.VARINT:
                self.field0name5 = u64_to_i32(dec.read_varint())
            elif field == 406 and wire == WireType.VARINT:
                self.field_0_name6 = u64_to_i32(dec.read_varint())
            elif field == 407 and wire == WireType.VARINT:
                self.fieldName7 = u64_to_i32(dec.read_varint())
            elif field == 408 and wire == WireType.VARINT:
                self.FieldName8 = u64_to_i32(dec.read_varint())
            elif field == 409 and wire == WireType.VARINT:
                self.field_Name9 = u64_to_i32(dec.read_varint())
            elif field == 410 and wire == WireType.VARINT:
                self.Field_Name10 = u64_to_i32(dec.read_varint())
            elif field == 411 and wire == WireType.VARINT:
                self.FIELD_NAME11 = u64_to_i32(dec.read_varint())
            elif field == 412 and wire == WireType.VARINT:
                self.FIELD_name12 = u64_to_i32(dec.read_varint())
            elif field == 413 and wire == WireType.VARINT:
                self.__field_name13 = u64_to_i32(dec.read_varint())
            elif field == 414 and wire == WireType.VARINT:
                self.__Field_name14 = u64_to_i32(dec.read_varint())
            elif field == 415 and wire == WireType.VARINT:
                self.field__name15 = u64_to_i32(dec.read_varint())
            elif field == 416 and wire == WireType.VARINT:
                self.field__Name16 = u64_to_i32(dec.read_varint())
            elif field == 417 and wire == WireType.VARINT:
                self.field_name17__ = u64_to_i32(dec.read_varint())
            elif field == 418 and wire == WireType.VARINT:
                self.Field_name18__ = u64_to_i32(dec.read_varint())
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.which_oneof_field != other.which_oneof_field:
            return False
        if self.optional_int32 != other.optional_int32:
            return False
        if self.optional_int64 != other.optional_int64:
            return False
        if self.optional_uint32 != other.optional_uint32:
            return False
        if self.optional_uint64 != other.optional_uint64:
            return False
        if self.optional_sint32 != other.optional_sint32:
            return False
        if self.optional_sint64 != other.optional_sint64:
            return False
        if self.optional_fixed32 != other.optional_fixed32:
            return False
        if self.optional_fixed64 != other.optional_fixed64:
            return False
        if self.optional_sfixed32 != other.optional_sfixed32:
            return False
        if self.optional_sfixed64 != other.optional_sfixed64:
            return False
        if self.optional_float != other.optional_float:
            return False
        if self.optional_double != other.optional_double:
            return False
        if self.optional_bool != other.optional_bool:
            return False
        if self.optional_string != other.optional_string:
            return False
        if self.optional_bytes != other.optional_bytes:
            return False
        if Bool(self.optional_foreign_message) != Bool(other.optional_foreign_message):
            return False
        if self.optional_foreign_message:
            if self.optional_foreign_message.value() != other.optional_foreign_message.value():
                return False
        if self.optional_nested_enum != other.optional_nested_enum:
            return False
        if self.optional_foreign_enum != other.optional_foreign_enum:
            return False
        if self.optional_aliased_enum != other.optional_aliased_enum:
            return False
        if self.optional_string_piece != other.optional_string_piece:
            return False
        if self.optional_cord != other.optional_cord:
            return False
        if len(self.repeated_int32) != len(other.repeated_int32):
            return False
        for i in range(len(self.repeated_int32)):
            if self.repeated_int32[i] != other.repeated_int32[i]:
                return False
        if len(self.repeated_int64) != len(other.repeated_int64):
            return False
        for i in range(len(self.repeated_int64)):
            if self.repeated_int64[i] != other.repeated_int64[i]:
                return False
        if len(self.repeated_uint32) != len(other.repeated_uint32):
            return False
        for i in range(len(self.repeated_uint32)):
            if self.repeated_uint32[i] != other.repeated_uint32[i]:
                return False
        if len(self.repeated_uint64) != len(other.repeated_uint64):
            return False
        for i in range(len(self.repeated_uint64)):
            if self.repeated_uint64[i] != other.repeated_uint64[i]:
                return False
        if len(self.repeated_sint32) != len(other.repeated_sint32):
            return False
        for i in range(len(self.repeated_sint32)):
            if self.repeated_sint32[i] != other.repeated_sint32[i]:
                return False
        if len(self.repeated_sint64) != len(other.repeated_sint64):
            return False
        for i in range(len(self.repeated_sint64)):
            if self.repeated_sint64[i] != other.repeated_sint64[i]:
                return False
        if len(self.repeated_fixed32) != len(other.repeated_fixed32):
            return False
        for i in range(len(self.repeated_fixed32)):
            if self.repeated_fixed32[i] != other.repeated_fixed32[i]:
                return False
        if len(self.repeated_fixed64) != len(other.repeated_fixed64):
            return False
        for i in range(len(self.repeated_fixed64)):
            if self.repeated_fixed64[i] != other.repeated_fixed64[i]:
                return False
        if len(self.repeated_sfixed32) != len(other.repeated_sfixed32):
            return False
        for i in range(len(self.repeated_sfixed32)):
            if self.repeated_sfixed32[i] != other.repeated_sfixed32[i]:
                return False
        if len(self.repeated_sfixed64) != len(other.repeated_sfixed64):
            return False
        for i in range(len(self.repeated_sfixed64)):
            if self.repeated_sfixed64[i] != other.repeated_sfixed64[i]:
                return False
        if len(self.repeated_float) != len(other.repeated_float):
            return False
        for i in range(len(self.repeated_float)):
            if self.repeated_float[i] != other.repeated_float[i]:
                return False
        if len(self.repeated_double) != len(other.repeated_double):
            return False
        for i in range(len(self.repeated_double)):
            if self.repeated_double[i] != other.repeated_double[i]:
                return False
        if len(self.repeated_bool) != len(other.repeated_bool):
            return False
        for i in range(len(self.repeated_bool)):
            if self.repeated_bool[i] != other.repeated_bool[i]:
                return False
        if len(self.repeated_string) != len(other.repeated_string):
            return False
        for i in range(len(self.repeated_string)):
            if self.repeated_string[i] != other.repeated_string[i]:
                return False
        if len(self.repeated_bytes) != len(other.repeated_bytes):
            return False
        for i in range(len(self.repeated_bytes)):
            if self.repeated_bytes[i] != other.repeated_bytes[i]:
                return False
        if len(self.repeated_foreign_message) != len(other.repeated_foreign_message):
            return False
        for i in range(len(self.repeated_foreign_message)):
            if self.repeated_foreign_message[i] != other.repeated_foreign_message[i]:
                return False
        if len(self.repeated_nested_enum) != len(other.repeated_nested_enum):
            return False
        for i in range(len(self.repeated_nested_enum)):
            if self.repeated_nested_enum[i] != other.repeated_nested_enum[i]:
                return False
        if len(self.repeated_foreign_enum) != len(other.repeated_foreign_enum):
            return False
        for i in range(len(self.repeated_foreign_enum)):
            if self.repeated_foreign_enum[i] != other.repeated_foreign_enum[i]:
                return False
        if len(self.repeated_string_piece) != len(other.repeated_string_piece):
            return False
        for i in range(len(self.repeated_string_piece)):
            if self.repeated_string_piece[i] != other.repeated_string_piece[i]:
                return False
        if len(self.repeated_cord) != len(other.repeated_cord):
            return False
        for i in range(len(self.repeated_cord)):
            if self.repeated_cord[i] != other.repeated_cord[i]:
                return False
        if len(self.packed_int32) != len(other.packed_int32):
            return False
        for i in range(len(self.packed_int32)):
            if self.packed_int32[i] != other.packed_int32[i]:
                return False
        if len(self.packed_int64) != len(other.packed_int64):
            return False
        for i in range(len(self.packed_int64)):
            if self.packed_int64[i] != other.packed_int64[i]:
                return False
        if len(self.packed_uint32) != len(other.packed_uint32):
            return False
        for i in range(len(self.packed_uint32)):
            if self.packed_uint32[i] != other.packed_uint32[i]:
                return False
        if len(self.packed_uint64) != len(other.packed_uint64):
            return False
        for i in range(len(self.packed_uint64)):
            if self.packed_uint64[i] != other.packed_uint64[i]:
                return False
        if len(self.packed_sint32) != len(other.packed_sint32):
            return False
        for i in range(len(self.packed_sint32)):
            if self.packed_sint32[i] != other.packed_sint32[i]:
                return False
        if len(self.packed_sint64) != len(other.packed_sint64):
            return False
        for i in range(len(self.packed_sint64)):
            if self.packed_sint64[i] != other.packed_sint64[i]:
                return False
        if len(self.packed_fixed32) != len(other.packed_fixed32):
            return False
        for i in range(len(self.packed_fixed32)):
            if self.packed_fixed32[i] != other.packed_fixed32[i]:
                return False
        if len(self.packed_fixed64) != len(other.packed_fixed64):
            return False
        for i in range(len(self.packed_fixed64)):
            if self.packed_fixed64[i] != other.packed_fixed64[i]:
                return False
        if len(self.packed_sfixed32) != len(other.packed_sfixed32):
            return False
        for i in range(len(self.packed_sfixed32)):
            if self.packed_sfixed32[i] != other.packed_sfixed32[i]:
                return False
        if len(self.packed_sfixed64) != len(other.packed_sfixed64):
            return False
        for i in range(len(self.packed_sfixed64)):
            if self.packed_sfixed64[i] != other.packed_sfixed64[i]:
                return False
        if len(self.packed_float) != len(other.packed_float):
            return False
        for i in range(len(self.packed_float)):
            if self.packed_float[i] != other.packed_float[i]:
                return False
        if len(self.packed_double) != len(other.packed_double):
            return False
        for i in range(len(self.packed_double)):
            if self.packed_double[i] != other.packed_double[i]:
                return False
        if len(self.packed_bool) != len(other.packed_bool):
            return False
        for i in range(len(self.packed_bool)):
            if self.packed_bool[i] != other.packed_bool[i]:
                return False
        if len(self.packed_nested_enum) != len(other.packed_nested_enum):
            return False
        for i in range(len(self.packed_nested_enum)):
            if self.packed_nested_enum[i] != other.packed_nested_enum[i]:
                return False
        if len(self.unpacked_int32) != len(other.unpacked_int32):
            return False
        for i in range(len(self.unpacked_int32)):
            if self.unpacked_int32[i] != other.unpacked_int32[i]:
                return False
        if len(self.unpacked_int64) != len(other.unpacked_int64):
            return False
        for i in range(len(self.unpacked_int64)):
            if self.unpacked_int64[i] != other.unpacked_int64[i]:
                return False
        if len(self.unpacked_uint32) != len(other.unpacked_uint32):
            return False
        for i in range(len(self.unpacked_uint32)):
            if self.unpacked_uint32[i] != other.unpacked_uint32[i]:
                return False
        if len(self.unpacked_uint64) != len(other.unpacked_uint64):
            return False
        for i in range(len(self.unpacked_uint64)):
            if self.unpacked_uint64[i] != other.unpacked_uint64[i]:
                return False
        if len(self.unpacked_sint32) != len(other.unpacked_sint32):
            return False
        for i in range(len(self.unpacked_sint32)):
            if self.unpacked_sint32[i] != other.unpacked_sint32[i]:
                return False
        if len(self.unpacked_sint64) != len(other.unpacked_sint64):
            return False
        for i in range(len(self.unpacked_sint64)):
            if self.unpacked_sint64[i] != other.unpacked_sint64[i]:
                return False
        if len(self.unpacked_fixed32) != len(other.unpacked_fixed32):
            return False
        for i in range(len(self.unpacked_fixed32)):
            if self.unpacked_fixed32[i] != other.unpacked_fixed32[i]:
                return False
        if len(self.unpacked_fixed64) != len(other.unpacked_fixed64):
            return False
        for i in range(len(self.unpacked_fixed64)):
            if self.unpacked_fixed64[i] != other.unpacked_fixed64[i]:
                return False
        if len(self.unpacked_sfixed32) != len(other.unpacked_sfixed32):
            return False
        for i in range(len(self.unpacked_sfixed32)):
            if self.unpacked_sfixed32[i] != other.unpacked_sfixed32[i]:
                return False
        if len(self.unpacked_sfixed64) != len(other.unpacked_sfixed64):
            return False
        for i in range(len(self.unpacked_sfixed64)):
            if self.unpacked_sfixed64[i] != other.unpacked_sfixed64[i]:
                return False
        if len(self.unpacked_float) != len(other.unpacked_float):
            return False
        for i in range(len(self.unpacked_float)):
            if self.unpacked_float[i] != other.unpacked_float[i]:
                return False
        if len(self.unpacked_double) != len(other.unpacked_double):
            return False
        for i in range(len(self.unpacked_double)):
            if self.unpacked_double[i] != other.unpacked_double[i]:
                return False
        if len(self.unpacked_bool) != len(other.unpacked_bool):
            return False
        for i in range(len(self.unpacked_bool)):
            if self.unpacked_bool[i] != other.unpacked_bool[i]:
                return False
        if len(self.unpacked_nested_enum) != len(other.unpacked_nested_enum):
            return False
        for i in range(len(self.unpacked_nested_enum)):
            if self.unpacked_nested_enum[i] != other.unpacked_nested_enum[i]:
                return False
        if self.map_int32_int32 != other.map_int32_int32:
            return False
        if self.map_int64_int64 != other.map_int64_int64:
            return False
        if self.map_uint32_uint32 != other.map_uint32_uint32:
            return False
        if self.map_uint64_uint64 != other.map_uint64_uint64:
            return False
        if self.map_sint32_sint32 != other.map_sint32_sint32:
            return False
        if self.map_sint64_sint64 != other.map_sint64_sint64:
            return False
        if self.map_fixed32_fixed32 != other.map_fixed32_fixed32:
            return False
        if self.map_fixed64_fixed64 != other.map_fixed64_fixed64:
            return False
        if self.map_sfixed32_sfixed32 != other.map_sfixed32_sfixed32:
            return False
        if self.map_sfixed64_sfixed64 != other.map_sfixed64_sfixed64:
            return False
        if self.map_int32_float != other.map_int32_float:
            return False
        if self.map_int32_double != other.map_int32_double:
            return False
        if self.map_bool_bool != other.map_bool_bool:
            return False
        if self.map_string_string != other.map_string_string:
            return False
        if self.map_string_bytes != other.map_string_bytes:
            return False
        if self.map_string_nested_message != other.map_string_nested_message:
            return False
        if self.map_string_foreign_message != other.map_string_foreign_message:
            return False
        if self.map_string_nested_enum != other.map_string_nested_enum:
            return False
        if self.map_string_foreign_enum != other.map_string_foreign_enum:
            return False
        if self.oneof_uint32 != other.oneof_uint32:
            return False
        if self.oneof_string != other.oneof_string:
            return False
        if self.oneof_bytes != other.oneof_bytes:
            return False
        if self.oneof_bool != other.oneof_bool:
            return False
        if self.oneof_uint64 != other.oneof_uint64:
            return False
        if self.oneof_float != other.oneof_float:
            return False
        if self.oneof_double != other.oneof_double:
            return False
        if self.oneof_enum != other.oneof_enum:
            return False
        if self.oneof_null_value != other.oneof_null_value:
            return False
        if Bool(self.optional_bool_wrapper) != Bool(other.optional_bool_wrapper):
            return False
        if self.optional_bool_wrapper:
            if self.optional_bool_wrapper.value() != other.optional_bool_wrapper.value():
                return False
        if Bool(self.optional_int32_wrapper) != Bool(other.optional_int32_wrapper):
            return False
        if self.optional_int32_wrapper:
            if self.optional_int32_wrapper.value() != other.optional_int32_wrapper.value():
                return False
        if Bool(self.optional_int64_wrapper) != Bool(other.optional_int64_wrapper):
            return False
        if self.optional_int64_wrapper:
            if self.optional_int64_wrapper.value() != other.optional_int64_wrapper.value():
                return False
        if Bool(self.optional_uint32_wrapper) != Bool(other.optional_uint32_wrapper):
            return False
        if self.optional_uint32_wrapper:
            if self.optional_uint32_wrapper.value() != other.optional_uint32_wrapper.value():
                return False
        if Bool(self.optional_uint64_wrapper) != Bool(other.optional_uint64_wrapper):
            return False
        if self.optional_uint64_wrapper:
            if self.optional_uint64_wrapper.value() != other.optional_uint64_wrapper.value():
                return False
        if Bool(self.optional_float_wrapper) != Bool(other.optional_float_wrapper):
            return False
        if self.optional_float_wrapper:
            if self.optional_float_wrapper.value() != other.optional_float_wrapper.value():
                return False
        if Bool(self.optional_double_wrapper) != Bool(other.optional_double_wrapper):
            return False
        if self.optional_double_wrapper:
            if self.optional_double_wrapper.value() != other.optional_double_wrapper.value():
                return False
        if Bool(self.optional_string_wrapper) != Bool(other.optional_string_wrapper):
            return False
        if self.optional_string_wrapper:
            if self.optional_string_wrapper.value() != other.optional_string_wrapper.value():
                return False
        if Bool(self.optional_bytes_wrapper) != Bool(other.optional_bytes_wrapper):
            return False
        if self.optional_bytes_wrapper:
            if self.optional_bytes_wrapper.value() != other.optional_bytes_wrapper.value():
                return False
        if len(self.repeated_bool_wrapper) != len(other.repeated_bool_wrapper):
            return False
        for i in range(len(self.repeated_bool_wrapper)):
            if self.repeated_bool_wrapper[i] != other.repeated_bool_wrapper[i]:
                return False
        if len(self.repeated_int32_wrapper) != len(other.repeated_int32_wrapper):
            return False
        for i in range(len(self.repeated_int32_wrapper)):
            if self.repeated_int32_wrapper[i] != other.repeated_int32_wrapper[i]:
                return False
        if len(self.repeated_int64_wrapper) != len(other.repeated_int64_wrapper):
            return False
        for i in range(len(self.repeated_int64_wrapper)):
            if self.repeated_int64_wrapper[i] != other.repeated_int64_wrapper[i]:
                return False
        if len(self.repeated_uint32_wrapper) != len(other.repeated_uint32_wrapper):
            return False
        for i in range(len(self.repeated_uint32_wrapper)):
            if self.repeated_uint32_wrapper[i] != other.repeated_uint32_wrapper[i]:
                return False
        if len(self.repeated_uint64_wrapper) != len(other.repeated_uint64_wrapper):
            return False
        for i in range(len(self.repeated_uint64_wrapper)):
            if self.repeated_uint64_wrapper[i] != other.repeated_uint64_wrapper[i]:
                return False
        if len(self.repeated_float_wrapper) != len(other.repeated_float_wrapper):
            return False
        for i in range(len(self.repeated_float_wrapper)):
            if self.repeated_float_wrapper[i] != other.repeated_float_wrapper[i]:
                return False
        if len(self.repeated_double_wrapper) != len(other.repeated_double_wrapper):
            return False
        for i in range(len(self.repeated_double_wrapper)):
            if self.repeated_double_wrapper[i] != other.repeated_double_wrapper[i]:
                return False
        if len(self.repeated_string_wrapper) != len(other.repeated_string_wrapper):
            return False
        for i in range(len(self.repeated_string_wrapper)):
            if self.repeated_string_wrapper[i] != other.repeated_string_wrapper[i]:
                return False
        if len(self.repeated_bytes_wrapper) != len(other.repeated_bytes_wrapper):
            return False
        for i in range(len(self.repeated_bytes_wrapper)):
            if self.repeated_bytes_wrapper[i] != other.repeated_bytes_wrapper[i]:
                return False
        if Bool(self.optional_duration) != Bool(other.optional_duration):
            return False
        if self.optional_duration:
            if self.optional_duration.value() != other.optional_duration.value():
                return False
        if Bool(self.optional_timestamp) != Bool(other.optional_timestamp):
            return False
        if self.optional_timestamp:
            if self.optional_timestamp.value() != other.optional_timestamp.value():
                return False
        if Bool(self.optional_field_mask) != Bool(other.optional_field_mask):
            return False
        if self.optional_field_mask:
            if self.optional_field_mask.value() != other.optional_field_mask.value():
                return False
        if Bool(self.optional_struct) != Bool(other.optional_struct):
            return False
        if self.optional_struct:
            if self.optional_struct.value() != other.optional_struct.value():
                return False
        if Bool(self.optional_any) != Bool(other.optional_any):
            return False
        if self.optional_any:
            if self.optional_any.value() != other.optional_any.value():
                return False
        if Bool(self.optional_value) != Bool(other.optional_value):
            return False
        if self.optional_value:
            if self.optional_value.value() != other.optional_value.value():
                return False
        if self.optional_null_value != other.optional_null_value:
            return False
        if len(self.repeated_duration) != len(other.repeated_duration):
            return False
        for i in range(len(self.repeated_duration)):
            if self.repeated_duration[i] != other.repeated_duration[i]:
                return False
        if len(self.repeated_timestamp) != len(other.repeated_timestamp):
            return False
        for i in range(len(self.repeated_timestamp)):
            if self.repeated_timestamp[i] != other.repeated_timestamp[i]:
                return False
        if len(self.repeated_fieldmask) != len(other.repeated_fieldmask):
            return False
        for i in range(len(self.repeated_fieldmask)):
            if self.repeated_fieldmask[i] != other.repeated_fieldmask[i]:
                return False
        if len(self.repeated_struct) != len(other.repeated_struct):
            return False
        for i in range(len(self.repeated_struct)):
            if self.repeated_struct[i] != other.repeated_struct[i]:
                return False
        if len(self.repeated_any) != len(other.repeated_any):
            return False
        for i in range(len(self.repeated_any)):
            if self.repeated_any[i] != other.repeated_any[i]:
                return False
        if len(self.repeated_value) != len(other.repeated_value):
            return False
        for i in range(len(self.repeated_value)):
            if self.repeated_value[i] != other.repeated_value[i]:
                return False
        if len(self.repeated_list_value) != len(other.repeated_list_value):
            return False
        for i in range(len(self.repeated_list_value)):
            if self.repeated_list_value[i] != other.repeated_list_value[i]:
                return False
        if self.fieldname1 != other.fieldname1:
            return False
        if self.field_name2 != other.field_name2:
            return False
        if self._field_name3 != other._field_name3:
            return False
        if self.field__name4_ != other.field__name4_:
            return False
        if self.field0name5 != other.field0name5:
            return False
        if self.field_0_name6 != other.field_0_name6:
            return False
        if self.fieldName7 != other.fieldName7:
            return False
        if self.FieldName8 != other.FieldName8:
            return False
        if self.field_Name9 != other.field_Name9:
            return False
        if self.Field_Name10 != other.Field_Name10:
            return False
        if self.FIELD_NAME11 != other.FIELD_NAME11:
            return False
        if self.FIELD_name12 != other.FIELD_name12:
            return False
        if self.__field_name13 != other.__field_name13:
            return False
        if self.__Field_name14 != other.__Field_name14:
            return False
        if self.field__name15 != other.field__name15:
            return False
        if self.field__Name16 != other.field__Name16:
            return False
        if self.field_name17__ != other.field_name17__:
            return False
        if self.Field_name18__ != other.Field_name18__:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("TestAllTypesProto3()")

struct ForeignMessage(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var c: Int32
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.c = Int32(0)
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.c != 0:
            n += tag_varint_len(1, i32_to_u64(self.c))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.c != 0:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.c))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.c = u64_to_i32(dec.read_varint())
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.c != other.c:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("ForeignMessage()")

struct NullHypothesisProto3(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("NullHypothesisProto3()")

struct EnumOnlyProto3Bool(
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
        writer.write("EnumOnlyProto3Bool(", self.value, ")")

comptime EnumOnlyProto3Bool_kFalse = Int32(0)

comptime EnumOnlyProto3Bool_kTrue = Int32(1)

struct EnumOnlyProto3(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("EnumOnlyProto3()")

