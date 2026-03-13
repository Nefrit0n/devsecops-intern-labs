from flask import Flask, jsonify, request
import ipaddress
import re
import subprocess

app = Flask(__name__)

SAFE_DIAGNOSTIC_ALLOWLIST = {"127.0.0.1", "localhost", "::1"}
SAFE_HOST_PATTERN = re.compile(r"^[a-zA-Z0-9.-]{1,253}$")


@app.get("/health")
def health():
    """Безопасный endpoint: простой healthcheck без пользовательского ввода."""
    return jsonify({"status": "ok", "service": "vulnerable-app"})


@app.get("/hello")
def hello():
    """Endpoint с базовой валидацией ввода для демонстрации best practice."""
    name = request.args.get("name", "student").strip()
    if not name.isascii() or len(name) > 32:
        return jsonify({"error": "invalid input"}), 400
    return jsonify({"message": f"Привет, {name}!"})


@app.get("/calc")
def calc():
    """
    Endpoint с проблемой валидации ввода.
    AppSec-задача: объяснить, почему здесь нужна строгая проверка типа/диапазона.
    """
    value = request.args.get("value", "")

    # Учебный анти-паттерн: слабая обработка ошибок и отсутствие ограничений диапазона.
    try:
        number = int(value)
    except ValueError:
        return jsonify({"error": "value must be integer"}), 400

    # Потенциально проблемно с точки зрения стабильности при очень больших значениях.
    result = number * number
    return jsonify({"input": number, "square": result})


@app.get("/diagnostic/ping")
def diagnostic_ping():
    """
    Намеренно небезопасный endpoint (ТОЛЬКО ДЛЯ ОБУЧЕНИЯ).
    AppSec-задача: найти command injection анти-паттерн.

    ВАЖНО: пример не содержит вредоносной нагрузки и не предназначен для эксплуатации.
    """
    host = request.args.get("host", "127.0.0.1")

    # Учебный анти-паттерн: shell=True + прямое использование пользовательского ввода.
    command = f"ping -c 1 {host}"
    output = subprocess.getoutput(command)

    return jsonify({"host": host, "output": output})


@app.get("/diagnostic/ping-safe")
def diagnostic_ping_safe():
    """Безопасная альтернатива: allow-list + shell=False + timeout."""
    host = request.args.get("host", "127.0.0.1").strip().lower()

    is_allowed = host in SAFE_DIAGNOSTIC_ALLOWLIST
    if not is_allowed and SAFE_HOST_PATTERN.match(host):
        try:
            parsed_ip = ipaddress.ip_address(host)
            is_allowed = parsed_ip.is_loopback
        except ValueError:
            is_allowed = host.endswith(".local")

    if not is_allowed:
        return jsonify({"error": "host is not allowed for safe diagnostic mode"}), 400

    try:
        result = subprocess.run(
            ["ping", "-c", "1", host],
            capture_output=True,
            text=True,
            check=False,
            timeout=3,
            shell=False,
        )
    except subprocess.TimeoutExpired:
        return jsonify({"host": host, "error": "ping timeout"}), 504
    except OSError:
        return jsonify({"host": host, "error": "diagnostic tool unavailable"}), 500

    status_code = 200 if result.returncode == 0 else 502
    return (
        jsonify(
            {
                "host": host,
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
            }
        ),
        status_code,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
