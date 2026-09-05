Committed `protoc --descriptor_set_out --include_imports` blobs for Layer 2 tests.

Regenerate with `scripts/gen_descriptors.sh`. The same bytes are embedded in
`tests/descriptor_blobs.mojo` so unit tests do not depend on filesystem paths.
