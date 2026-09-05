from benchmark.v2 import Message


def main() raises:
    var msg = Message()
    msg.f_bool = True
    msg.f_int32 = 150
    msg.f_string = "hi"
    var buf = msg.encode()
    print("encoded", len(buf), "bytes")
    var again = Message.decode(buf)
    print("round-trip", again.f_int32, again.f_string)
