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

struct NullValue(
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
        writer.write("NullValue(", self.value, ")")

comptime NullValue_NULL_VALUE = Int32(0)

struct Struct(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var fields: Dict[String, Value]
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.fields = Dict[String, Value]()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        for item in self.fields.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            entry_len += tag_len_len(2, item.value.encoded_len())
            n += tag_len_len(1, entry_len)
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        for item in self.fields.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            entry_len += tag_len_len(2, item.value.encoded_len())
            enc.write_len_header(1, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            enc.write_len_header(2, item.value.encoded_len())
            item.value.encode_to(enc)
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = Value()
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
                self.fields[map_key] = map_val^
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.fields != other.fields:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Struct()")

struct Value(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var which_kind: Int32
    var null_value: NullValue
    var number_value: Float64
    var string_value: String
    var bool_value: Bool
    var struct_value: Struct
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.which_kind = 0
        self.null_value = NullValue()
        self.number_value = 0.0
        self.string_value = String()
        self.bool_value = False
        self.struct_value = Struct()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.which_kind == 1:
            n += tag_varint_len(1, i32_to_u64(self.null_value.value))
        if self.which_kind == 2:
            n += tag_fixed64_len(2)
        if self.which_kind == 3:
            n += tag_len_len(3, self.string_value.byte_length())
        if self.which_kind == 4:
            n += tag_varint_len(4, UInt64(Int(self.bool_value)))
        if self.which_kind == 5:
            n += tag_len_len(5, self.struct_value.encoded_len())
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.which_kind == 1:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.null_value.value))
        if self.which_kind == 2:
            enc.write_tag(2, WireType.I64)
            enc.write_i64_le(UInt64(self.number_value.to_bits()))
        if self.which_kind == 3:
            enc.write_len_header(3, self.string_value.byte_length())
            enc.write_bytes(self.string_value.as_bytes())
        if self.which_kind == 4:
            enc.write_tag(4, WireType.VARINT)
            enc.write_varint(UInt64(Int(self.bool_value)))
        if self.which_kind == 5:
            enc.write_len_header(5, self.struct_value.encoded_len())
            self.struct_value.encode_to(enc)
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.which_kind = 1
                self.number_value = 0.0
                self.string_value = String()
                self.bool_value = False
                self.struct_value = Struct()
                self.null_value = NullValue(u64_to_i32(dec.read_varint()))
            elif field == 2 and wire == WireType.I64:
                self.which_kind = 2
                self.null_value = NullValue()
                self.string_value = String()
                self.bool_value = False
                self.struct_value = Struct()
                self.number_value = Float64(from_bits=dec.read_i64_le())
            elif field == 3 and wire == WireType.LEN:
                self.which_kind = 3
                self.null_value = NullValue()
                self.number_value = 0.0
                self.bool_value = False
                self.struct_value = Struct()
                self.string_value = dec.read_string()
            elif field == 4 and wire == WireType.VARINT:
                self.which_kind = 4
                self.null_value = NullValue()
                self.number_value = 0.0
                self.string_value = String()
                self.struct_value = Struct()
                self.bool_value = dec.read_varint() != 0
            elif field == 5 and wire == WireType.LEN:
                self.which_kind = 5
                self.null_value = NullValue()
                self.number_value = 0.0
                self.string_value = String()
                self.bool_value = False
                var inner = dec.subreader(dec.read_len_span())
                self.struct_value = Struct()
                self.struct_value.merge_from(inner)
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.which_kind != other.which_kind:
            return False
        if self.null_value != other.null_value:
            return False
        if self.number_value != other.number_value:
            return False
        if self.string_value != other.string_value:
            return False
        if self.bool_value != other.bool_value:
            return False
        if self.struct_value != other.struct_value:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Value()")

struct ListValue(
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
        writer.write("ListValue()")

