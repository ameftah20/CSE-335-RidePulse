#!/usr/bin/env python3
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib import error, parse, request

ROOT_DIR = Path(__file__).resolve().parent
WEB_DIR = ROOT_DIR / "web"


def get_config() -> dict:
    return {
        "app_name": os.getenv("APP_NAME", "PulseMind AI"),
        "system_prompt": os.getenv(
            "APP_SYSTEM_PROMPT",
            "You are PulseMind AI, a practical and clear assistant. Give concise, helpful answers.",
        ),
        "model": os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        "base_url": os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1").rstrip("/"),
        "port": int(os.getenv("PORT", "8080")),
    }


def json_response(handler: BaseHTTPRequestHandler, status: int, payload: dict) -> None:
    body = json.dumps(payload).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def sanitize_history(history: list, system_prompt: str) -> list:
    clean = []
    for msg in history:
        if not isinstance(msg, dict):
            continue
        role = msg.get("role")
        content = msg.get("content")
        if role not in {"system", "user", "assistant"}:
            continue
        if not isinstance(content, str):
            continue
        text = content.strip()
        if not text:
            continue
        clean.append({"role": role, "content": text})

    has_system = any(m["role"] == "system" for m in clean)
    if not has_system:
        clean.insert(0, {"role": "system", "content": system_prompt})
    return clean


def call_model(history: list, config: dict) -> str:
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError("Missing OPENAI_API_KEY environment variable.")

    messages = sanitize_history(history, config["system_prompt"])
    if not messages or len(messages) == 1:
        raise RuntimeError("Send at least one user message.")

    payload = {
        "model": config["model"],
        "messages": messages,
        "temperature": 0.7,
    }
    url = f"{config['base_url']}/chat/completions"
    data = json.dumps(payload).encode("utf-8")
    req = request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with request.urlopen(req, timeout=60) as resp:
            raw = resp.read().decode("utf-8")
            parsed = json.loads(raw)
    except error.HTTPError as exc:
        details = exc.read().decode("utf-8", errors="replace")
        try:
            err_obj = json.loads(details)
            message = err_obj.get("error", {}).get("message", details)
        except json.JSONDecodeError:
            message = details
        raise RuntimeError(f"Model API error ({exc.code}): {message}") from exc
    except error.URLError as exc:
        raise RuntimeError(f"Network error contacting model API: {exc.reason}") from exc

    choices = parsed.get("choices", [])
    if not choices:
        raise RuntimeError("No choices returned from model API.")
    msg = choices[0].get("message", {})
    content = msg.get("content", "")
    if isinstance(content, str):
        answer = content.strip()
    elif isinstance(content, list):
        parts = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(str(item.get("text", "")))
        answer = "\n".join(parts).strip()
    else:
        answer = ""

    if not answer:
        raise RuntimeError("Model returned an empty response.")
    return answer


class AppHandler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        route = parse.urlparse(self.path).path
        if route == "/api/health":
            config = get_config()
            return json_response(
                self,
                200,
                {
                    "ok": True,
                    "appName": config["app_name"],
                    "model": config["model"],
                },
            )

        if route == "/":
            route = "/index.html"
        return self.serve_static(route)

    def do_POST(self) -> None:
        route = parse.urlparse(self.path).path
        if route != "/api/chat":
            return json_response(self, 404, {"error": "Not found."})

        content_length = self.headers.get("Content-Length")
        if not content_length:
            return json_response(self, 400, {"error": "Missing request body."})

        try:
            body_raw = self.rfile.read(int(content_length))
            body = json.loads(body_raw.decode("utf-8"))
        except (ValueError, json.JSONDecodeError):
            return json_response(self, 400, {"error": "Body must be valid JSON."})

        history = body.get("history", [])
        if not isinstance(history, list):
            return json_response(self, 400, {"error": "history must be an array."})

        config = get_config()
        try:
            reply = call_model(history, config)
        except RuntimeError as exc:
            return json_response(self, 500, {"error": str(exc)})

        return json_response(self, 200, {"reply": reply})

    def serve_static(self, route: str) -> None:
        rel_path = route.lstrip("/")
        file_path = (WEB_DIR / rel_path).resolve()
        if WEB_DIR not in file_path.parents and file_path != WEB_DIR:
            return json_response(self, 403, {"error": "Forbidden path."})
        if not file_path.exists() or not file_path.is_file():
            return json_response(self, 404, {"error": "Not found."})

        mime = "text/plain; charset=utf-8"
        if file_path.suffix == ".html":
            mime = "text/html; charset=utf-8"
        elif file_path.suffix == ".css":
            mime = "text/css; charset=utf-8"
        elif file_path.suffix == ".js":
            mime = "application/javascript; charset=utf-8"

        payload = file_path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", mime)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args) -> None:
        return


def main() -> None:
    config = get_config()
    server = ThreadingHTTPServer(("0.0.0.0", config["port"]), AppHandler)
    print(f"{config['app_name']} running on http://localhost:{config['port']}")
    print(f"Model target: {config['model']} @ {config['base_url']}")
    server.serve_forever()


if __name__ == "__main__":
    main()
