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

struct Color(
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
        writer.write("Color(", self.value, ")")

comptime Color_COLOR_UNSPECIFIED = Int32(0)

comptime Color_RED = Int32(1)

comptime Color_BLUE = Int32(2)

struct Scalars(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var u32: UInt32
    var u64: UInt64
    var s32: Int32
    var s64: Int64
    var fx32: UInt32
    var fx64: UInt64
    var sfx32: Int32
    var sfx64: Int64
    var f32: Float32
    var data: List[Byte]
    var color: Color
    var packed_s32: List[Int32]
    var unpacked_s32: List[Int32]
    var maybe: Optional[Int32]
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.u32 = UInt32(0)
        self.u64 = UInt64(0)
        self.s32 = Int32(0)
        self.s64 = Int64(0)
        self.fx32 = UInt32(0)
        self.fx64 = UInt64(0)
        self.sfx32 = Int32(0)
        self.sfx64 = Int64(0)
        self.f32 = Float32(0.0)
        self.data = List[Byte]()
        self.color = Color()
        self.packed_s32 = List[Int32]()
        self.unpacked_s32 = List[Int32]()
        self.maybe = None
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.u32 != 0:
            n += tag_varint_len(1, UInt64(self.u32))
        if self.u64 != 0:
            n += tag_varint_len(2, self.u64)
        if self.s32 != 0:
            n += tag_varint_len(3, UInt64(zigzag_encode_i32(self.s32)))
        if self.s64 != 0:
            n += tag_varint_len(4, zigzag_encode_i64(self.s64))
        if self.fx32 != 0:
            n += tag_fixed32_len(5)
        if self.fx64 != 0:
            n += tag_fixed64_len(6)
        if self.sfx32 != 0:
            n += tag_fixed32_len(7)
        if self.sfx64 != 0:
            n += tag_fixed64_len(8)
        if self.f32 != 0.0:
            n += tag_fixed32_len(9)
        if len(self.data) != 0:
            n += tag_len_len(10, len(self.data))
        if self.color.value != 0:
            n += tag_varint_len(11, i32_to_u64(self.color.value))
        if len(self.packed_s32) != 0:
            var payload = 0
            for i in range(len(self.packed_s32)):
                payload += varint_len(UInt64(zigzag_encode_i32(self.packed_s32[i])))
            n += tag_len_len(12, payload)
        for i in range(len(self.unpacked_s32)):
            n += tag_varint_len(13, UInt64(zigzag_encode_i32(self.unpacked_s32[i])))
        if self.maybe:
            n += tag_varint_len(14, i32_to_u64(self.maybe.value()))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.u32 != 0:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(UInt64(self.u32))
        if self.u64 != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(self.u64)
        if self.s32 != 0:
            enc.write_tag(3, WireType.VARINT)
            enc.write_varint(UInt64(zigzag_encode_i32(self.s32)))
        if self.s64 != 0:
            enc.write_tag(4, WireType.VARINT)
            enc.write_varint(zigzag_encode_i64(self.s64))
        if self.fx32 != 0:
            enc.write_tag(5, WireType.I32)
            enc.write_i32_le(self.fx32)
        if self.fx64 != 0:
            enc.write_tag(6, WireType.I64)
            enc.write_i64_le(self.fx64)
        if self.sfx32 != 0:
            enc.write_tag(7, WireType.I32)
            enc.write_i32_le(UInt32(self.sfx32))
        if self.sfx64 != 0:
            enc.write_tag(8, WireType.I64)
            enc.write_i64_le(UInt64(self.sfx64))
        if self.f32 != 0.0:
            enc.write_tag(9, WireType.I32)
            enc.write_i32_le(UInt32(self.f32.to_bits()))
        if len(self.data) != 0:
            enc.write_len_header(10, len(self.data))
            enc.write_bytes(self.data)
        if self.color.value != 0:
            enc.write_tag(11, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.color.value))
        if len(self.packed_s32) != 0:
            var payload = 0
            for i in range(len(self.packed_s32)):
                payload += varint_len(UInt64(zigzag_encode_i32(self.packed_s32[i])))
            enc.write_len_header(12, payload)
            for i in range(len(self.packed_s32)):
                enc.write_varint(UInt64(zigzag_encode_i32(self.packed_s32[i])))
        for i in range(len(self.unpacked_s32)):
            enc.write_tag(13, WireType.VARINT)
            enc.write_varint(UInt64(zigzag_encode_i32(self.unpacked_s32[i])))
        if self.maybe:
            enc.write_tag(14, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.maybe.value()))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.u32 = UInt32(dec.read_varint())
            elif field == 2 and wire == WireType.VARINT:
                self.u64 = dec.read_varint()
            elif field == 3 and wire == WireType.VARINT:
                self.s32 = zigzag_decode_i32(UInt32(dec.read_varint()))
            elif field == 4 and wire == WireType.VARINT:
                self.s64 = zigzag_decode_i64(dec.read_varint())
            elif field == 5 and wire == WireType.I32:
                self.fx32 = dec.read_i32_le()
            elif field == 6 and wire == WireType.I64:
                self.fx64 = dec.read_i64_le()
            elif field == 7 and wire == WireType.I32:
                self.sfx32 = Int32(dec.read_i32_le())
            elif field == 8 and wire == WireType.I64:
                self.sfx64 = Int64(dec.read_i64_le())
            elif field == 9 and wire == WireType.I32:
                self.f32 = Float32(from_bits=dec.read_i32_le())
            elif field == 10 and wire == WireType.LEN:
                self.data = dec.read_bytes()
            elif field == 11 and wire == WireType.VARINT:
                self.color = Color(u64_to_i32(dec.read_varint()))
            elif field == 12 and wire == WireType.VARINT:
                self.packed_s32.append(zigzag_decode_i32(UInt32(dec.read_varint())))
            elif field == 12 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.packed_s32.append(zigzag_decode_i32(UInt32(words[i])))
            elif field == 13 and wire == WireType.VARINT:
                self.unpacked_s32.append(zigzag_decode_i32(UInt32(dec.read_varint())))
            elif field == 13 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_varint(words)
                for i in range(len(words)):
                    self.unpacked_s32.append(zigzag_decode_i32(UInt32(words[i])))
            elif field == 14 and wire == WireType.VARINT:
                self.maybe = Optional(u64_to_i32(dec.read_varint()))
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.u32 != other.u32:
            return False
        if self.u64 != other.u64:
            return False
        if self.s32 != other.s32:
            return False
        if self.s64 != other.s64:
            return False
        if self.fx32 != other.fx32:
            return False
        if self.fx64 != other.fx64:
            return False
        if self.sfx32 != other.sfx32:
            return False
        if self.sfx64 != other.sfx64:
            return False
        if self.f32 != other.f32:
            return False
        if self.data != other.data:
            return False
        if self.color != other.color:
            return False
        if len(self.packed_s32) != len(other.packed_s32):
            return False
        for i in range(len(self.packed_s32)):
            if self.packed_s32[i] != other.packed_s32[i]:
                return False
        if len(self.unpacked_s32) != len(other.unpacked_s32):
            return False
        for i in range(len(self.unpacked_s32)):
            if self.unpacked_s32[i] != other.unpacked_s32[i]:
                return False
        if Bool(self.maybe) != Bool(other.maybe):
            return False
        if self.maybe:
            if self.maybe.value() != other.maybe.value():
                return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Scalars()")

