"""Route each Boltz path to the service that registers it, with fake upstreams."""

import asyncio
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import threading
import unittest
import urllib.request

import boltz_gateway


def fake_upstream(name):
    class Handler(BaseHTTPRequestHandler):
        def answer(self):
            body = self.rfile.read(int(self.headers.get("content-length") or 0))
            out = json.dumps({"by": name, "connection": self.headers.get("connection"),
                              "body": body.decode()}).encode()
            self.send_response(200)
            self.send_header("content-length", str(len(out)))
            self.end_headers()
            self.wfile.write(out)

        do_GET = do_POST = answer

        def log_message(self, *args):
            pass

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


class BoltzGatewayTest(unittest.TestCase):
    def test_routes_sidecar_paths_to_the_sidecar_and_the_rest_to_the_backend(self):
        backend, sidecar = fake_upstream("backend"), fake_upstream("sidecar")
        self.addCleanup(backend.shutdown)
        self.addCleanup(sidecar.shutdown)
        boltz_gateway.BACKEND = backend.server_address
        boltz_gateway.SIDECAR = sidecar.server_address
        cases = {
            "/v2/swap/reverse": "backend",
            "/v2/swap/chain/abc": "backend",
            "/version": "backend",
            "/v2/swap/restore/index": "sidecar",
            "/v2/swap/restore": "sidecar",
            "/v2/swap/rescue": "sidecar",
            "/v2/quote/BTC/in?amount=1": "sidecar",
            "/v2/swap/submarine/stats/BTC/BTC": "sidecar",
        }

        async def run():
            server = await asyncio.start_server(boltz_gateway.serve, "127.0.0.1", 0)
            port = server.sockets[0].getsockname()[1]

            def call(path):
                request = urllib.request.Request(f"http://127.0.0.1:{port}{path}", data=b'{"xpub":"x"}')
                return json.loads(urllib.request.urlopen(request, timeout=5).read())

            async with server:
                for path, expected in cases.items():
                    answer = await asyncio.to_thread(call, path)
                    with self.subTest(path=path):
                        self.assertEqual(answer["by"], expected)
                        self.assertEqual(answer["connection"], "close")
                        self.assertEqual(answer["body"], '{"xpub":"x"}')

        asyncio.run(run())


if __name__ == "__main__":
    unittest.main()
