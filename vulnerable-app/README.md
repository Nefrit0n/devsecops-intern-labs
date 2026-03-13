# vulnerable-app

Это **учебное намеренно уязвимое** Flask-приложение для практики AppSec и DevSecOps.

## Важно
- Приложение специально упрощено.
- В коде есть демонстрационные анти-паттерны.
- Пример предназначен только для обучения и локальной практики.

## Endpoint'ы
- `GET /health` — безопасный healthcheck.
- `GET /hello?name=...` — пример простой валидации ввода.
- `GET /calc?value=...` — пример обсуждения проблем валидации/ограничений.
- `GET /diagnostic/ping?host=...` — намеренно небезопасная логика для анализа (anti-pattern).
- `GET /diagnostic/ping-safe?host=...` — безопасная альтернатива с проверкой host и безопасным вызовом subprocess.

## Unsafe vs Safe: что сравнить студенту
- **Unsafe (`/diagnostic/ping`)**: строка команды собирается напрямую из ввода пользователя и выполняется через shell.
- **Safe (`/diagnostic/ping-safe`)**: ввод проходит allow-list/валидацию, команда запускается через `subprocess.run(..., shell=False, timeout=...)`.
- В safe-варианте добавлена контролируемая обработка ошибок и предсказуемый формат ответа.

## Запуск локально
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

## Запуск через Docker
```bash
docker build -t vulnerable-app:lab .
docker run --rm -p 5000:5000 vulnerable-app:lab
```

## Примеры проверок
```bash
curl "http://127.0.0.1:5000/health"
curl "http://127.0.0.1:5000/hello?name=Intern"
curl "http://127.0.0.1:5000/calc?value=12"
curl "http://127.0.0.1:5000/diagnostic/ping?host=127.0.0.1"
curl "http://127.0.0.1:5000/diagnostic/ping-safe?host=127.0.0.1"
```

## Что анализировать студенту
- Где и почему endpoint считается безопасным.
- Какие риски в endpoint с shell-командой.
- Как валидация + `shell=False` + `timeout` снижают риск command injection.
