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
- `GET /diagnostic/ping?host=...` — намеренно небезопасная логика для анализа.

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
```

## Что анализировать студенту
- Где и почему endpoint считается безопасным.
- Какие риски в endpoint с shell-командой.
- Почему недостаточная валидация может стать AppSec/availability проблемой.
