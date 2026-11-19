#!/usr/bin/env python3
"""Single Boltz HTTP endpoint for the regtest stack.

Boltz serves part of its public API from the backend (port 9001) and part from
the Rust sidecar (port 9005); production puts a reverse proxy in front so
clients see one URL. This gateway does the same: it routes each connection by
the path of its first request and forces `Connection: close`, so every request
opens a new connection and is routed on its own.
"""

import asyncio
import contextlib
import re
import signal

BACKEND = ("boltz", 9001)
SIDECAR = ("boltz", 9005)
# Routes registered by the sidecar in boltzr/src/api/mod.rs (Boltz v3.13.0).
SIDECAR_ROUTES = re.compile(
    r"^/(streamswapstatus"
    r"|v2/swap/(rescue|restore(/index)?|[^/]+/stats/[^/]+/[^/]+)"
    r"|v2/asset/[^/]+/rescue/"
    r"|v2/lightning/"
    r"|v2/quote/)"
)
MAX_HEADER = 64 * 1024


async def pipe(reader, writer):
    with contextlib.suppress(ConnectionError, asyncio.CancelledError):
        while data := await reader.read(65536):
            writer.write(data)
            await writer.drain()
    with contextlib.suppress(Exception):
        writer.close()


async def serve(reader, writer):
    upstream = None
    try:
        head = await asyncio.wait_for(reader.readuntil(b"\r\n\r\n"), 10)
        if len(head) > MAX_HEADER:
            return
        lines = head.decode("latin-1").split("\r\n")
        parts = lines[0].split(" ")
        if len(parts) != 3:
            return
        path = parts[1].split("?", 1)[0]
        host, port = SIDECAR if SIDECAR_ROUTES.match(path) else BACKEND
        headers = [l for l in lines[1:] if l and not l.lower().startswith("connection:")]
        request = "\r\n".join([lines[0], *headers, "Connection: close", "", ""])
        remote_reader, upstream = await asyncio.wait_for(asyncio.open_connection(host, port), 5)
        upstream.write(request.encode("latin-1"))
        await upstream.drain()
        await asyncio.gather(pipe(reader, upstream), pipe(remote_reader, writer))
    except (asyncio.IncompleteReadError, asyncio.LimitOverrunError, asyncio.TimeoutError, OSError):
        pass
    finally:
        for stream in (upstream, writer):
            if stream is not None:
                with contextlib.suppress(Exception):
                    stream.close()


async def main():
    server = await asyncio.start_server(serve, "0.0.0.0", 9001, limit=MAX_HEADER)
    stop = asyncio.Event()
    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)
    async with server:
        await stop.wait()


if __name__ == "__main__":
    asyncio.run(main())
