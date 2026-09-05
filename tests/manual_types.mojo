"""Hand-written test messages matching testdata/proto/benchmark_v2.proto."""

from std.collections import List, Span

from protobuf import (
    DecodeError,
    ProtoMessage,
    WireReader,
    WireType,
    WireWriter,
    decode,
    encode,
    i32_to_u64,
    i64_to_u64,
    tag_fixed64_len,
    tag_len_len,
    tag_varint_len,
    u64_to_i32,
    u64_to_i64,
)


struct Message(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var f_bool: Bool
    var f_int32: Int32
    var f_int64: Int64
    var f_float64: Float64
    var f_string: String
    var f_bool_2: Bool
    var f_int32_2: Int32
    var f_string_2: String

    def __init__(out self):
        self.f_bool = False
        self.f_int32 = 0
        self.f_int64 = 0
        self.f_float64 = 0.0
        self.f_string = String()
        self.f_bool_2 = False
        self.f_int32_2 = 0
        self.f_string_2 = String()

    def encoded_len(self) -> Int:
        var n = 0
        if self.f_bool:
            n += tag_varint_len(1, 1)
        if self.f_int32 != 0:
            n += tag_varint_len(2, i32_to_u64(self.f_int32))
        if self.f_int64 != 0:
            n += tag_varint_len(3, i64_to_u64(self.f_int64))
        if self.f_float64 != 0.0:
            n += tag_fixed64_len(4)
        if self.f_string.byte_length() != 0:
            n += tag_len_len(5, self.f_string.byte_length())
        if self.f_bool_2:
            n += tag_varint_len(6, 1)
        if self.f_int32_2 != 0:
            n += tag_varint_len(7, i32_to_u64(self.f_int32_2))
        if self.f_string_2.byte_length() != 0:
            n += tag_len_len(8, self.f_string_2.byte_length())
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.f_bool:
            enc.write_tag(1, WireType.VARINT)
            enc.write_varint(1)
        if self.f_int32 != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.f_int32))
        if self.f_int64 != 0:
            enc.write_tag(3, WireType.VARINT)
            enc.write_varint(i64_to_u64(self.f_int64))
        if self.f_float64 != 0.0:
            enc.write_tag(4, WireType.I64)
            enc.write_i64_le(UInt64(self.f_float64.to_bits()))
        if self.f_string.byte_length() != 0:
            enc.write_len_header(5, self.f_string.byte_length())
            enc.write_bytes(self.f_string.as_bytes())
        if self.f_bool_2:
            enc.write_tag(6, WireType.VARINT)
            enc.write_varint(1)
        if self.f_int32_2 != 0:
            enc.write_tag(7, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.f_int32_2))
        if self.f_string_2.byte_length() != 0:
            enc.write_len_header(8, self.f_string_2.byte_length())
            enc.write_bytes(self.f_string_2.as_bytes())

    def merge_from[
        origin: ImmOrigin
    ](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.VARINT:
                self.f_bool = dec.read_varint() != 0
            elif field == 2 and wire == WireType.VARINT:
                self.f_int32 = u64_to_i32(dec.read_varint())
            elif field == 3 and wire == WireType.VARINT:
                self.f_int64 = u64_to_i64(dec.read_varint())
            elif field == 4 and wire == WireType.I64:
                self.f_float64 = Float64(from_bits=dec.read_i64_le())
            elif field == 5 and wire == WireType.LEN:
                self.f_string = dec.read_string()
            elif field == 6 and wire == WireType.VARINT:
                self.f_bool_2 = dec.read_varint() != 0
            elif field == 7 and wire == WireType.VARINT:
                self.f_int32_2 = u64_to_i32(dec.read_varint())
            elif field == 8 and wire == WireType.LEN:
                self.f_string_2 = dec.read_string()
            else:
                dec.skip_field(wire)

    def encode(self) -> List[Byte]:
        return encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        return (
            self.f_bool == other.f_bool
            and self.f_int32 == other.f_int32
            and self.f_int64 == other.f_int64
            and self.f_float64 == other.f_float64
            and self.f_string == other.f_string
            and self.f_bool_2 == other.f_bool_2
            and self.f_int32_2 == other.f_int32_2
            and self.f_string_2 == other.f_string_2
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Message(", self.f_string, ")")


struct DocumentMeta(
    Copyable,
    Movable,
    Defaultable,
    Deinitable,
    Writable,
    Equatable,
    ProtoMessage,
):
    var region: String
    var version: Int32

    def __init__(out self):
        self.region = String()
        self.version = 0

    def encoded_len(self) -> Int:
        var n = 0
        if self.region.byte_length() != 0:
            n += tag_len_len(1, self.region.byte_length())
        if self.version != 0:
            n += tag_varint_len(2, i32_to_u64(self.version))
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.region.byte_length() != 0:
            enc.write_len_header(1, self.region.byte_length())
            enc.write_bytes(self.region.as_bytes())
        if self.version != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.version))

    def merge_from[
        origin: ImmOrigin
    ](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.region = dec.read_string()
            elif field == 2 and wire == WireType.VARINT:
                self.version = u64_to_i32(dec.read_varint())
            else:
                dec.skip_field(wire)

    def __eq__(self, other: Self) -> Bool:
        return self.region == other.region and self.version == other.version

    def write_to[W: Writer](self, mut writer: W):
        writer.write("DocumentMeta(", self.region, ")")


struct DocumentItem(
    Copyable,
    Movable,
    Defaultable,
    Deinitable,
    ImplicitlyCopyable,
    Writable,
    Equatable,
    ProtoMessage,
):
    var sku: String
    var qty: Int32
    var price_minor: Int64

    def __init__(out self):
        self.sku = String()
        self.qty = 0
        self.price_minor = 0

    def encoded_len(self) -> Int:
        var n = 0
        if self.sku.byte_length() != 0:
            n += tag_len_len(1, self.sku.byte_length())
        if self.qty != 0:
            n += tag_varint_len(2, i32_to_u64(self.qty))
        if self.price_minor != 0:
            n += tag_varint_len(3, i64_to_u64(self.price_minor))
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.sku.byte_length() != 0:
            enc.write_len_header(1, self.sku.byte_length())
            enc.write_bytes(self.sku.as_bytes())
        if self.qty != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.qty))
        if self.price_minor != 0:
            enc.write_tag(3, WireType.VARINT)
            enc.write_varint(i64_to_u64(self.price_minor))

    def merge_from[
        origin: ImmOrigin
    ](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.sku = dec.read_string()
            elif field == 2 and wire == WireType.VARINT:
                self.qty = u64_to_i32(dec.read_varint())
            elif field == 3 and wire == WireType.VARINT:
                self.price_minor = u64_to_i64(dec.read_varint())
            else:
                dec.skip_field(wire)

    def __eq__(self, other: Self) -> Bool:
        return (
            self.sku == other.sku
            and self.qty == other.qty
            and self.price_minor == other.price_minor
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write("DocumentItem(", self.sku, ")")


struct Document(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var id: String
    var status: Int32
    var meta: Optional[DocumentMeta]
    var items: List[DocumentItem]

    def __init__(out self):
        self.id = String()
        self.status = 0
        self.meta = None
        self.items = List[DocumentItem]()

    def encoded_len(self) -> Int:
        var n = 0
        if self.id.byte_length() != 0:
            n += tag_len_len(1, self.id.byte_length())
        if self.status != 0:
            n += tag_varint_len(2, i32_to_u64(self.status))
        if self.meta:
            n += tag_len_len(3, self.meta.value().encoded_len())
        for i in range(len(self.items)):
            n += tag_len_len(4, self.items[i].encoded_len())
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.id.byte_length() != 0:
            enc.write_len_header(1, self.id.byte_length())
            enc.write_bytes(self.id.as_bytes())
        if self.status != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i32_to_u64(self.status))
        if self.meta:
            ref meta = self.meta.value()
            enc.write_len_header(3, meta.encoded_len())
            meta.encode_to(enc)
        for i in range(len(self.items)):
            enc.write_len_header(4, self.items[i].encoded_len())
            self.items[i].encode_to(enc)

    def merge_from[
        origin: ImmOrigin
    ](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.id = dec.read_string()
            elif field == 2 and wire == WireType.VARINT:
                self.status = u64_to_i32(dec.read_varint())
            elif field == 3 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                if not self.meta:
                    self.meta = DocumentMeta()
                self.meta.value().merge_from(inner)
            elif field == 4 and wire == WireType.LEN:
                var inner = dec.subreader(dec.read_len_span())
                var item = DocumentItem()
                item.merge_from(inner)
                self.items.append(item^)
            else:
                dec.skip_field(wire)

    def encode(self) -> List[Byte]:
        return encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if (
            self.id != other.id
            or self.status != other.status
            or Bool(self.meta) != Bool(other.meta)
            or len(self.items) != len(other.items)
        ):
            return False
        if self.meta:
            if self.meta.value() != other.meta.value():
                return False
        for i in range(len(self.items)):
            if self.items[i] != other.items[i]:
                return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Document(", self.id, ")")


struct Telemetry(
    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage
):
    var source: String
    var ts: Int64
    var tags: List[String]
    var values: List[Float64]

    def __init__(out self):
        self.source = String()
        self.ts = 0
        self.tags = List[String]()
        self.values = List[Float64]()

    def encoded_len(self) -> Int:
        var n = 0
        if self.source.byte_length() != 0:
            n += tag_len_len(1, self.source.byte_length())
        if self.ts != 0:
            n += tag_varint_len(2, i64_to_u64(self.ts))
        for i in range(len(self.tags)):
            n += tag_len_len(3, self.tags[i].byte_length())
        if len(self.values) != 0:
            n += tag_len_len(4, len(self.values) * 8)
        return n

    def encode_to(self, mut enc: WireWriter):
        if self.source.byte_length() != 0:
            enc.write_len_header(1, self.source.byte_length())
            enc.write_bytes(self.source.as_bytes())
        if self.ts != 0:
            enc.write_tag(2, WireType.VARINT)
            enc.write_varint(i64_to_u64(self.ts))
        for i in range(len(self.tags)):
            enc.write_len_header(3, self.tags[i].byte_length())
            enc.write_bytes(self.tags[i].as_bytes())
        if len(self.values) != 0:
            enc.write_len_header(4, len(self.values) * 8)
            for i in range(len(self.values)):
                enc.write_i64_le(UInt64(self.values[i].to_bits()))

    def merge_from[
        origin: ImmOrigin
    ](mut self, mut dec: WireReader[origin]) raises DecodeError:
        while dec.remaining() > 0:
            var tag = dec.read_tag()
            var field = tag[0]
            var wire = tag[1]
            if field == 1 and wire == WireType.LEN:
                self.source = dec.read_string()
            elif field == 2 and wire == WireType.VARINT:
                self.ts = u64_to_i64(dec.read_varint())
            elif field == 3 and wire == WireType.LEN:
                self.tags.append(dec.read_string())
            elif field == 4 and wire == WireType.I64:
                self.values.append(Float64(from_bits=dec.read_i64_le()))
            elif field == 4 and wire == WireType.LEN:
                var words = List[UInt64]()
                dec.read_packed_fixed64(words)
                for i in range(len(words)):
                    self.values.append(Float64(from_bits=words[i]))
            else:
                dec.skip_field(wire)

    def encode(self) -> List[Byte]:
        return encode(self)

    @staticmethod
    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:
        return decode[Self, origin](buf)

    def __eq__(self, other: Self) -> Bool:
        if (
            self.source != other.source
            or self.ts != other.ts
            or len(self.tags) != len(other.tags)
            or len(self.values) != len(other.values)
        ):
            return False
        for i in range(len(self.tags)):
            if self.tags[i] != other.tags[i]:
                return False
        for i in range(len(self.values)):
            if self.values[i] != other.values[i]:
                return False
        return True

    def write_to[W: Writer](self, mut writer: W):
        writer.write("Telemetry(", self.source, ")")
