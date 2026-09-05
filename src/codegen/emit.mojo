from std.collections import List

from codegen.names import (
    ResolvedType,
    mojo_field_name,
    mojo_type_name,
    resolve_type_name,
)
from descriptor.model import (
    FieldDesc,
    FileDesc,
    FileDescSet,
    LABEL_REPEATED,
    LABEL_REQUIRED,
    MessageDesc,
    TYPE_BOOL,
    TYPE_DOUBLE,
    TYPE_GROUP,
    TYPE_INT32,
    TYPE_INT64,
    TYPE_MESSAGE,
    TYPE_STRING,
    is_packed,
    proto3_error,
)


struct EmitError(Copyable, Movable, Defaultable, Writable):
    var message: String

    def __init__(out self):
        self.message = String()

    def __init__(out self, message: String):
        self.message = message

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.message)


def _check_field(set: FileDescSet, file: FileDesc, field: FieldDesc) raises EmitError:
    if field.label == LABEL_REQUIRED:
        raise EmitError("required fields are proto2: " + field.name)
    if field.type == TYPE_GROUP:
        raise EmitError("groups are not supported: " + field.name)
    if field.is_map:
        raise EmitError("maps are not supported yet: " + field.name)
    if field.oneof_index:
        raise EmitError("oneof is not supported yet: " + field.name)
    if (
        field.type != TYPE_BOOL
        and field.type != TYPE_INT32
        and field.type != TYPE_INT64
        and field.type != TYPE_DOUBLE
        and field.type != TYPE_STRING
        and field.type != TYPE_MESSAGE
    ):
        raise EmitError("unsupported field type in v0.1 codegen: " + field.name)


def _resolve(set: FileDescSet, file: FileDesc, type_name: String) raises EmitError -> ResolvedType:
    try:
        return resolve_type_name(set, file.name, type_name)
    except _:
        raise EmitError("type_name resolve failed: " + type_name)


def _elem_type(set: FileDescSet, file: FileDesc, field: FieldDesc) raises EmitError -> String:
    if field.type == TYPE_BOOL:
        return "Bool"
    if field.type == TYPE_INT32:
        return "Int32"
    if field.type == TYPE_INT64:
        return "Int64"
    if field.type == TYPE_DOUBLE:
        return "Float64"
    if field.type == TYPE_STRING:
        return "String"
    if field.type == TYPE_MESSAGE:
        var resolved = _resolve(set, file, field.type_name)
        if not resolved.ok:
            raise EmitError(resolved.error)
        return resolved.mojo_name
    raise EmitError("unsupported field type: " + field.name)


def _field_type(set: FileDescSet, file: FileDesc, field: FieldDesc) raises EmitError -> String:
    var elem = _elem_type(set, file, field)
    if field.label == LABEL_REPEATED:
        return "List[" + elem + "]"
    if field.type == TYPE_MESSAGE:
        return "Optional[" + elem + "]"
    return elem


def _default_expr(field: FieldDesc, field_type: String) -> String:
    if field.label == LABEL_REPEATED:
        return field_type + "()"
    if field.type == TYPE_MESSAGE:
        return "None"
    if field.type == TYPE_BOOL:
        return "False"
    if field.type == TYPE_INT32 or field.type == TYPE_INT64:
        return "0"
    if field.type == TYPE_DOUBLE:
        return "0.0"
    return "String()"


def _emit_encoded_len(field: FieldDesc, fname: String, n: String) -> String:
    var num = String(field.number)
    if field.label == LABEL_REPEATED and field.type == TYPE_DOUBLE and is_packed(field):
        return (
            "        if len(self."
            + fname
            + ") != 0:\n            "
            + n
            + " += tag_len_len("
            + num
            + ", len(self."
            + fname
            + ") * 8)\n"
        )
    if field.label == LABEL_REPEATED and field.type == TYPE_STRING:
        return (
            "        for i in range(len(self."
            + fname
            + ")):\n            "
            + n
            + " += tag_len_len("
            + num
            + ", self."
            + fname
            + "[i].byte_length())\n"
        )
    if field.label == LABEL_REPEATED and field.type == TYPE_MESSAGE:
        return (
            "        for i in range(len(self."
            + fname
            + ")):\n            "
            + n
            + " += tag_len_len("
            + num
            + ", self."
            + fname
            + "[i].encoded_len())\n"
        )
    if field.type == TYPE_BOOL:
        return (
            "        if self."
            + fname
            + ":\n            "
            + n
            + " += tag_varint_len("
            + num
            + ", 1)\n"
        )
    if field.type == TYPE_INT32:
        return (
            "        if self."
            + fname
            + " != 0:\n            "
            + n
            + " += tag_varint_len("
            + num
            + ", i32_to_u64(self."
            + fname
            + "))\n"
        )
    if field.type == TYPE_INT64:
        return (
            "        if self."
            + fname
            + " != 0:\n            "
            + n
            + " += tag_varint_len("
            + num
            + ", i64_to_u64(self."
            + fname
            + "))\n"
        )
    if field.type == TYPE_DOUBLE:
        return (
            "        if self."
            + fname
            + " != 0.0:\n            "
            + n
            + " += tag_fixed64_len("
            + num
            + ")\n"
        )
    if field.type == TYPE_STRING:
        return (
            "        if self."
            + fname
            + ".byte_length() != 0:\n            "
            + n
            + " += tag_len_len("
            + num
            + ", self."
            + fname
            + ".byte_length())\n"
        )
    if field.type == TYPE_MESSAGE:
        return (
            "        if self."
            + fname
            + ":\n            "
            + n
            + " += tag_len_len("
            + num
            + ", self."
            + fname
            + ".value().encoded_len())\n"
        )
    return ""


def _emit_encode(field: FieldDesc, fname: String) -> String:
    var num = String(field.number)
    if field.label == LABEL_REPEATED and field.type == TYPE_DOUBLE and is_packed(field):
        return (
            "        if len(self."
            + fname
            + ") != 0:\n            enc.write_len_header("
            + num
            + ", len(self."
            + fname
            + ") * 8)\n            for i in range(len(self."
            + fname
            + ")):\n                enc.write_i64_le(UInt64(self."
            + fname
            + "[i].to_bits()))\n"
        )
    if field.label == LABEL_REPEATED and field.type == TYPE_STRING:
        return (
            "        for i in range(len(self."
            + fname
            + ")):\n            enc.write_len_header("
            + num
            + ", self."
            + fname
            + "[i].byte_length())\n            enc.write_bytes(self."
            + fname
            + "[i].as_bytes())\n"
        )
    if field.label == LABEL_REPEATED and field.type == TYPE_MESSAGE:
        return (
            "        for i in range(len(self."
            + fname
            + ")):\n            enc.write_len_header("
            + num
            + ", self."
            + fname
            + "[i].encoded_len())\n            self."
            + fname
            + "[i].encode_to(enc)\n"
        )
    if field.type == TYPE_BOOL:
        return (
            "        if self."
            + fname
            + ":\n            enc.write_tag("
            + num
            + ", WireType.VARINT)\n            enc.write_varint(1)\n"
        )
    if field.type == TYPE_INT32:
        return (
            "        if self."
            + fname
            + " != 0:\n            enc.write_tag("
            + num
            + ", WireType.VARINT)\n            enc.write_varint(i32_to_u64(self."
            + fname
            + "))\n"
        )
    if field.type == TYPE_INT64:
        return (
            "        if self."
            + fname
            + " != 0:\n            enc.write_tag("
            + num
            + ", WireType.VARINT)\n            enc.write_varint(i64_to_u64(self."
            + fname
            + "))\n"
        )
    if field.type == TYPE_DOUBLE:
        return (
            "        if self."
            + fname
            + " != 0.0:\n            enc.write_tag("
            + num
            + ", WireType.I64)\n            enc.write_i64_le(UInt64(self."
            + fname
            + ".to_bits()))\n"
        )
    if field.type == TYPE_STRING:
        return (
            "        if self."
            + fname
            + ".byte_length() != 0:\n            enc.write_len_header("
            + num
            + ", self."
            + fname
            + ".byte_length())\n            enc.write_bytes(self."
            + fname
            + ".as_bytes())\n"
        )
    if field.type == TYPE_MESSAGE:
        return (
            "        if self."
            + fname
            + ":\n            ref child = self."
            + fname
            + ".value()\n            enc.write_len_header("
            + num
            + ", child.encoded_len())\n            child.encode_to(enc)\n"
        )
    return ""


def _kw(first: Bool) -> String:
    if first:
        return "if"
    return "elif"


def _emit_decode(field: FieldDesc, fname: String, elem: String, first: Bool) -> String:
    var num = String(field.number)
    var kw = _kw(first)
    if field.label == LABEL_REPEATED and field.type == TYPE_DOUBLE:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.I64:\n                self."
            + fname
            + ".append(Float64(from_bits=dec.read_i64_le()))\n            elif field == "
            + num
            + " and wire == WireType.LEN:\n                var words = List[UInt64]()\n                dec.read_packed_fixed64(words)\n                for i in range(len(words)):\n                    self."
            + fname
            + ".append(Float64(from_bits=words[i]))\n"
        )
    if field.label == LABEL_REPEATED and field.type == TYPE_STRING:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.LEN:\n                self."
            + fname
            + ".append(dec.read_string())\n"
        )
    if field.label == LABEL_REPEATED and field.type == TYPE_MESSAGE:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.LEN:\n                var inner = dec.subreader(dec.read_len_span())\n                var item = "
            + elem
            + "()\n                item.merge_from(inner)\n                self."
            + fname
            + ".append(item^)\n"
        )
    if field.type == TYPE_BOOL:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.VARINT:\n                self."
            + fname
            + " = dec.read_varint() != 0\n"
        )
    if field.type == TYPE_INT32:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.VARINT:\n                self."
            + fname
            + " = u64_to_i32(dec.read_varint())\n"
        )
    if field.type == TYPE_INT64:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.VARINT:\n                self."
            + fname
            + " = u64_to_i64(dec.read_varint())\n"
        )
    if field.type == TYPE_DOUBLE:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.I64:\n                self."
            + fname
            + " = Float64(from_bits=dec.read_i64_le())\n"
        )
    if field.type == TYPE_STRING:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.LEN:\n                self."
            + fname
            + " = dec.read_string()\n"
        )
    if field.type == TYPE_MESSAGE:
        return (
            "            "
            + kw
            + " field == "
            + num
            + " and wire == WireType.LEN:\n                var inner = dec.subreader(dec.read_len_span())\n                if not self."
            + fname
            + ":\n                    self."
            + fname
            + " = "
            + elem
            + "()\n                self."
            + fname
            + ".value().merge_from(inner)\n"
        )
    return String()


def _emit_eq(field: FieldDesc, fname: String) -> String:
    if field.label == LABEL_REPEATED:
        return (
            "        if len(self."
            + fname
            + ") != len(other."
            + fname
            + "):\n            return False\n        for i in range(len(self."
            + fname
            + ")):\n            if self."
            + fname
            + "[i] != other."
            + fname
            + "[i]:\n                return False\n"
        )
    if field.type == TYPE_MESSAGE:
        return (
            "        if Bool(self."
            + fname
            + ") != Bool(other."
            + fname
            + "):\n            return False\n        if self."
            + fname
            + ":\n            if self."
            + fname
            + ".value() != other."
            + fname
            + ".value():\n                return False\n"
        )
    return (
        "        if self."
        + fname
        + " != other."
        + fname
        + ":\n            return False\n"
    )


def emit_message(
    set: FileDescSet, file: FileDesc, msg: MessageDesc
) raises EmitError -> String:
    var tname: String
    try:
        tname = mojo_type_name(msg.dotted_name())
    except _:
        raise EmitError("type name mapping failed")
    var out = String()
    out += "struct "
    out += tname
    out += "(\n    Copyable, Movable, Defaultable, Deinitable, Writable, Equatable, ProtoMessage\n):\n"
    for i in range(len(msg.fields)):
        _check_field(set, file, msg.fields[i])
        var ft = _field_type(set, file, msg.fields[i])
        var field_ident = mojo_field_name(msg.fields[i].name)
        out += "    var "
        out += field_ident
        out += ": "
        out += ft
        out += "\n"
    out += "\n    def __init__(out self):\n"
    if len(msg.fields) == 0:
        out += "        pass\n"
    for i in range(len(msg.fields)):
        var field_ident = mojo_field_name(msg.fields[i].name)
        var ft = _field_type(set, file, msg.fields[i])
        out += "        self."
        out += field_ident
        out += " = "
        out += _default_expr(msg.fields[i], ft)
        out += "\n"
    out += "\n    def encoded_len(self) -> Int:\n        var n = 0\n"
    for i in range(len(msg.fields)):
        out += _emit_encoded_len(msg.fields[i], mojo_field_name(msg.fields[i].name), "n")
    out += "        return n\n"
    out += "\n    def encode_to(self, mut enc: WireWriter):\n"
    if len(msg.fields) == 0:
        out += "        pass\n"
    for i in range(len(msg.fields)):
        out += _emit_encode(msg.fields[i], mojo_field_name(msg.fields[i].name))
    out += "\n    def merge_from[origin: ImmOrigin](mut self, mut dec: WireReader[origin]) raises DecodeError:\n        while dec.remaining() > 0:\n            var tag = dec.read_tag()\n            var field = tag[0]\n            var wire = tag[1]\n"
    if len(msg.fields) == 0:
        out += "            dec.skip_field(wire)\n"
    for i in range(len(msg.fields)):
        var elem = _elem_type(set, file, msg.fields[i])
        out += _emit_decode(
            msg.fields[i], mojo_field_name(msg.fields[i].name), elem, i == 0
        )
    out += "            else:\n                dec.skip_field(wire)\n"
    out += "\n    def encode(self) -> List[Byte]:\n        return pb_encode(self)\n\n    @staticmethod\n    def decode[origin: ImmOrigin](buf: Span[Byte, origin]) raises DecodeError -> Self:\n        return pb_decode[Self, origin](buf)\n"
    out += "\n    def __eq__(self, other: Self) -> Bool:\n"
    if len(msg.fields) == 0:
        out += "        return True\n"
    for i in range(len(msg.fields)):
        out += _emit_eq(msg.fields[i], mojo_field_name(msg.fields[i].name))
    if len(msg.fields) != 0:
        out += "        return True\n"
    out += "\n    def write_to[W: Writer](self, mut writer: W):\n        writer.write(\""
    out += tname
    out += "()\")\n"
    return out


def flatten_local(msg: MessageDesc) -> String:
    return msg.dotted_name()


def emit_file(set: FileDescSet, file: FileDesc) raises EmitError -> String:
    var gate = proto3_error(file)
    if gate.byte_length() != 0:
        raise EmitError(gate)
    if len(file.enums) != 0:
        raise EmitError("enums are not supported in v0.1 codegen: " + file.name)
    var out = String()
    out += "from std.collections import List, Optional, Span\n"
    out += "from protobuf import (\n"
    out += "    DecodeError,\n    ProtoMessage,\n    WireReader,\n    WireType,\n    WireWriter,\n"
    out += "    decode as pb_decode,\n    encode as pb_encode,\n"
    out += "    i32_to_u64,\n    i64_to_u64,\n    tag_fixed64_len,\n    tag_len_len,\n    tag_varint_len,\n"
    out += "    u64_to_i32,\n    u64_to_i64,\n)\n\n"
    var imports = List[String]()
    for i in range(len(file.messages)):
        for j in range(len(file.messages[i].fields)):
            if file.messages[i].fields[j].type == TYPE_MESSAGE:
                var resolved = _resolve(
                    set, file, file.messages[i].fields[j].type_name
                )
                if resolved.ok and resolved.import_pkg.byte_length() != 0:
                    var line = (
                        "from "
                        + resolved.import_pkg
                        + " import "
                        + resolved.mojo_name
                        + "\n"
                    )
                    var seen = False
                    for k in range(len(imports)):
                        if imports[k] == line:
                            seen = True
                    if not seen:
                        imports.append(line)
    for i in range(len(imports)):
        out += imports[i]
    if len(imports) != 0:
        out += "\n"
    for i in range(len(file.messages)):
        out += emit_message(set, file, file.messages[i])
        out += "\n"
    return out


def output_path(out_dir: String, module_prefix: String, package: String, stem: String) raises -> String:
    var path = out_dir
    if module_prefix.byte_length() != 0:
        path += "/" + module_prefix
    if package.byte_length() != 0:
        var buf = List[Byte]()
        for i in range(package.byte_length()):
            var b = package.as_bytes()[i]
            if b == Byte(ord(".")):
                buf.append(Byte(ord("/")))
            else:
                buf.append(b)
        path += "/" + String(from_utf8=buf)
    path += "/" + stem + ".mojo"
    return path


def stem_of(path: String) raises -> String:
    var start = 0
    var end = path.byte_length()
    for i in range(path.byte_length()):
        if path.as_bytes()[i] == Byte(ord("/")):
            start = i + 1
    # strip .proto
    if end >= 6:
        var looks = True
        var suf = String(".proto")
        for i in range(6):
            if path.as_bytes()[end - 6 + i] != suf.as_bytes()[i]:
                looks = False
        if looks:
            end = end - 6
    var buf = List[Byte]()
    var i = start
    while i < end:
        buf.append(path.as_bytes()[i])
        i += 1
    return String(from_utf8=buf)
