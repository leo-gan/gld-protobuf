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

struct Any(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var type_url: String
    var value: List[Byte]
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.type_url = String()
        self.value = List[Byte]()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.type_url.byte_length() != 0:
            n += tag_len_len(1, self.type_url.byte_length())
        if len(self.value) != 0:
            n += tag_len_len(2, len(self.value))
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.type_url.byte_length() != 0:
            enc.write_len_header(1, self.type_url.byte_length())
            enc.write_bytes(self.type_url.as_bytes())
        if len(self.value) != 0:
            enc.write_len_header(2, len(self.value))
            enc.write_bytes(self.value)
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.type_url = dec.read_string()
            elif field == 2 and wire == WireType.LEN:
                self.value = dec.read_bytes()
            else:
                self.unknown.add(field, wire, dec)

    def encode(self) -> List[Byte]:
        return pb_encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return pb_decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if self.type_url != other.type_url:
            return False
        if self.value != other.value:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Any()")

