from std.testing import TestSuite, assert_equal, assert_true

from descriptor import (
    LABEL_OPTIONAL,
    LABEL_REPEATED,
    TYPE_BOOL,
    TYPE_DOUBLE,
    TYPE_INT32,
    TYPE_INT64,
    TYPE_MESSAGE,
    TYPE_STRING,
    decode_file_descriptor_set,
    is_packed,
    proto3_error,
)
from descriptor_blobs import benchmark_v2_fds, import_parent_fds, legacy_proto2_fds


def test_benchmark_v2_messages() raises:
    var set = decode_file_descriptor_set(benchmark_v2_fds())
    assert_equal(len(set.files), 1)
    var file = set.files[0].copy()
    assert_equal(file.name, "benchmark_v2.proto")
    assert_equal(file.package, "benchmark.v2")
    assert_equal(file.syntax, "proto3")
    assert_equal(file.has_edition, False)
    assert_equal(proto3_error(file), "")
    assert_equal(len(file.messages), 13)

    var msg = file.message("Message").value().copy()
    assert_equal(len(msg.fields), 8)
    assert_equal(msg.fields[0].name, "f_bool")
    assert_equal(msg.fields[0].number, 1)
    assert_equal(msg.fields[0].type, TYPE_BOOL)
    assert_equal(msg.fields[0].label, LABEL_OPTIONAL)
    assert_equal(msg.fields[1].type, TYPE_INT32)
    assert_equal(msg.fields[2].type, TYPE_INT64)
    assert_equal(msg.fields[3].type, TYPE_DOUBLE)
    assert_equal(msg.fields[4].type, TYPE_STRING)

    var doc = file.message("Document").value().copy()
    var meta = doc.field("meta").value()
    assert_equal(meta.type, TYPE_MESSAGE)
    assert_equal(meta.type_name, ".benchmark.v2.DocumentMeta")
    assert_equal(meta.label, LABEL_OPTIONAL)
    var items = doc.field("items").value()
    assert_equal(items.label, LABEL_REPEATED)
    assert_equal(items.type_name, ".benchmark.v2.DocumentItem")

    var tel = file.message("Telemetry").value().copy()
    var values = tel.field("values").value()
    assert_equal(values.type, TYPE_DOUBLE)
    assert_equal(values.label, LABEL_REPEATED)
    assert_true(is_packed(values))


def test_import_public_dependency() raises:
    var set = decode_file_descriptor_set(import_parent_fds())
    assert_equal(len(set.files), 2)
    var child = set.file_named("import_child.proto").value().copy()
    assert_equal(child.package, "imp.child")
    assert_equal(child.syntax, "proto3")
    assert_equal(len(child.public_dependency), 0)
    var parent = set.file_named("import_parent.proto").value().copy()
    assert_equal(parent.package, "imp.parent")
    assert_equal(len(parent.dependency), 1)
    assert_equal(parent.dependency[0], "import_child.proto")
    assert_equal(len(parent.public_dependency), 1)
    assert_equal(parent.public_dependency[0], 0)
    var parent_msg = parent.message("Parent").value().copy()
    var field = parent_msg.field("c").value()
    assert_equal(field.type_name, ".imp.child.Child")
    assert_equal(proto3_error(parent), "")
    assert_equal(proto3_error(child), "")


def test_legacy_proto2_fails_syntax_gate() raises:
    var set = decode_file_descriptor_set(legacy_proto2_fds())
    assert_equal(len(set.files), 1)
    var err = proto3_error(set.files[0].copy())
    assert_true(err.byte_length() != 0, msg=err)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
