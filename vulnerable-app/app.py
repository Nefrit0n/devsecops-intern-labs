from flask import Flask, jsonify, request
import subprocess

app = Flask(__name__)


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


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
