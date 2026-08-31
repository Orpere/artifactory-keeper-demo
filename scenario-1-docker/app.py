#!/usr/bin/env python3
"""
greet-service — a tiny zero-dependency HTTP server used to demo pushing
container images to an Artifact Keeper registry.

Endpoints:
  GET /            -> JSON greeting with service name + version
  GET /healthz     -> 200 OK (container health check)
  GET /env         -> runtime environment details

Run locally:
  python3 app.py

Run in a container:
  docker build -t greet-service .
  docker run --rm -p 8080:8080 greet-service
"""

import json
import os
import socket
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SERVICE_NAME = os.environ.get("SERVICE_NAME", "greet-service")
SERVICE_VERSION = os.environ.get("SERVICE_VERSION", "1.0.0")


class Handler(BaseHTTPRequestHandler):
    """Minimal JSON API handler."""

    def _send_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (http.server API)
        if self.path == "/healthz":
            self._send_json(200, {"status": "ok"})
            return
        if self.path == "/env":
            self._send_json(
                200,
                {
                    "service": SERVICE_NAME,
                    "version": SERVICE_VERSION,
                    "hostname": socket.gethostname(),
                    "python": sys.version.split()[0],
                },
            )
            return
        self._send_json(
            200,
            {
                "message": f"Hello from {SERVICE_NAME}!",
                "service": SERVICE_NAME,
                "version": SERVICE_VERSION,
            },
        )

    def log_message(self, format: str, *args) -> None:  # noqa: N802,N803
        print(f"[{self.log_date_time_string()}] {format % args}")


def main() -> None:
    port = int(os.environ.get("PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(f"{SERVICE_NAME} v{SERVICE_VERSION} listening on :{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nshutting down")


if __name__ == "__main__":
    main()
