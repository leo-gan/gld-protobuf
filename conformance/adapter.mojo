from std.io import FileDescriptor

from conformance_runner.framing import read_frame, write_frame
from conformance_runner.handle import handle_request
from conformance import ConformanceRequest


def main() raises:
    var stdin = FileDescriptor(0)
    var stdout = FileDescriptor(1)
    while True:
        var frame = read_frame(stdin)
        if not frame:
            return
        var req = ConformanceRequest.decode(frame.value())
        var resp = handle_request(req)
        write_frame(stdout, resp.encode())
