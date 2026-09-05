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

struct Holder(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var which_payload: Int32
    var name: String
    var id: Int32
    var attrs: Dict[String, Int32]
    var labels: Dict[Int32, String]
    var unknown: UnknownFieldSet

    def __init__(out self):
        self.which_payload = 0
        self.name = String()
        self.id = Int32(0)
        self.attrs = Dict[String, Int32]()
        self.labels = Dict[Int32, String]()
        self.unknown = UnknownFieldSet()

    def encoded_len(self) -> Int:
        var n = 0
        if self.which_payload == 1:
            n += tag_len_len(1, self.name.byte_length())
        if self.which_payload == 2:
            n += tag_varint_len(2, i32_to_u64(self.id))
        for item in self.attrs.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value))
            n += tag_len_len(3, entry_len)
        for item in self.labels.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value.byte_length() != 0:
                entry_len += tag_len_len(2, item.value.byte_length())
            n += tag_len_len(4, entry_len)
        n += self.unknown.encoded_len()
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.which_payload == 1:
            enc.write_len_header(1, self.name.byte_length())
            enc.write_bytes(self.name.as_bytes())
        if self.which_payload == 2:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.id))
        for item in self.attrs.items():
            var entry_len = 0
            if item.key.byte_length() != 0:
                entry_len += tag_len_len(1, item.key.byte_length())
            if item.value != 0:
                entry_len += tag_varint_len(2, i32_to_u64(item.value))
            enc.write_len_header(3, entry_len)
            if item.key.byte_length() != 0:
                enc.write_len_header(1, item.key.byte_length())
                enc.write_bytes(item.key.as_bytes())
            if item.value != 0:
                enc.write_tag(2, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.value))
        for item in self.labels.items():
            var entry_len = 0
            if item.key != 0:
                entry_len += tag_varint_len(1, i32_to_u64(item.key))
            if item.value.byte_length() != 0:
                entry_len += tag_len_len(2, item.value.byte_length())
            enc.write_len_header(4, entry_len)
            if item.key != 0:
                enc.write_tag(1, WireType.VARINT)
                enc.write_varint(i32_to_u64(item.key))
            if item.value.byte_length() != 0:
                enc.write_len_header(2, item.value.byte_length())
                enc.write_bytes(item.value.as_bytes())
        self.unknown.encode_to(enc)

    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.which_payload = 1
                self.id = Int32(0)
                self.name = dec.read_string()
            elif field == 2 and wire == WireType.VARINT:
                self.which_payload = 2
                self.name = String()
                self.id = u64_to_i32(dec.read_varint())
            elif field == 3 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = String()
                var map_val = Int32(0)
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.LEN:
                        map_key = inner.read_string()
                    elif ef == 2 and ew == WireType.VARINT:
                        map_val = u64_to_i32(inner.read_varint())
                    else:
                        inner.skip_field(ew)
                self.attrs[map_key] = map_val^
            elif field == 4 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var map_key = Int32(0)
                var map_val = String()
                while inner.remaining() > 0:
                    var et = inner.read_tag()
                    var ef = et[0]
                    var ew = et[1]
                    if ef == 1 and ew == WireType.VARINT:
                        map_key = u64_to_i32(inner.read_varint())
                    elif ef == 2 and ew == WireType.LEN:
                        map_val = inner.read_string()
                    else:
                        inner.skip_field(ew)
                self.labels[map_key] = map_val^
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
        if self.name != other.name:
            return False
        if self.id != other.id:
            return False
        if self.attrs != other.attrs:
            return False
        if self.labels != other.labels:
            return False
        if self.unknown != other.unknown:
            return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Holder()")

