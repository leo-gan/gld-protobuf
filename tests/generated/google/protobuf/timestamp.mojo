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

struct Timestamp(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var seconds: Int64
    var nanos: Int32
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.seconds = Int64(0)
        self.nanos = Int32(0)
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.seconds != 0:
            n += tag_varint_len(1, i64_to_u64(self.seconds))
        if self.nanos != 0:
            n += tag_varint_len(2, i32_to_u64(self.nanos))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.seconds != 0:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(i64_to_u64(self.seconds))
        if self.nanos != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.nanos))
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.seconds = u64_to_i64(dec.read_varint())
            elif field == 2 and wire == WireType.VARINT:
                self.nanos = u64_to_i32(dec.read_varint())
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.seconds != other.seconds:
            return False
        if self.nanos != other.nanos:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Timestamp()")

