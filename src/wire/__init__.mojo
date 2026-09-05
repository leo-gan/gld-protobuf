from wire.reader import WireReader
from wire.size import (
    i32_to_u64,
    i64_to_u64,
    tag_fixed32_len,
    tag_fixed64_len,
    tag_len,
    tag_len_len,
    tag_varint_len,
    u64_to_i32,
    u64_to_i64,
    varint_len,
)
from wire.types import WireType
from wire.utf8 import string_from_utf8
from wire.varint import decode_varint, encode_varint
from wire.writer import WireWriter
from wire.zigzag import (
    zigzag_decode_i32,
    zigzag_decode_i64,
    zigzag_encode_i32,
    zigzag_encode_i64,
)
