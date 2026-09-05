# UnknownFieldSet is implemented in Phase 3. v0.1 skips unknown records
# and drops them on re-encode (official proto3 deviation).
comptime UNKNOWN_PRESERVE_DEFAULT = False
