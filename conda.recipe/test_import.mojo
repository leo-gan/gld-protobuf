from protobuf import DecodeError, ProtoMessage, WireWriter, encode

def main():
    print("mojo-protobuf import ok")
    _ = DecodeError(DecodeError.KIND_TRUNCATED, 0)
    var enc = WireWriter(capacity=8)
    _ = enc
    print("ok")
