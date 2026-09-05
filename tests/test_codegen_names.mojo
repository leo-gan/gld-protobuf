from std.testing import TestSuite, assert_equal, assert_true

from codegen.names import flatten_nested, mojo_field_name, mojo_type_name
from codegen.emit import output_path, stem_of


def test_flatten_and_reserved() raises:
    assert_equal(flatten_nested("Outer.Inner"), "OuterInner")
    assert_equal(mojo_type_name("List"), "List_")
    assert_equal(mojo_type_name("Message"), "Message")
    assert_equal(mojo_field_name("var"), "`var`")
    assert_equal(mojo_field_name("unknown"), "unknown_")
    assert_equal(mojo_field_name("f_int32"), "f_int32")


def test_output_path() raises:
    assert_equal(stem_of("testdata/proto/benchmark_v2.proto"), "benchmark_v2")
    assert_equal(
        output_path("tests/generated", "", "benchmark.v2", "benchmark_v2"),
        "tests/generated/benchmark/v2/benchmark_v2.mojo",
    )
    assert_equal(
        output_path("out", "generated", "benchmark.v2", "benchmark_v2"),
        "out/generated/benchmark/v2/benchmark_v2.mojo",
    )
    assert_equal(output_path("out", "", "", "scalars"), "out/scalars.mojo")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
