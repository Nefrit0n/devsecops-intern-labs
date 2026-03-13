# vulnerable-app

Это **учебное намеренно уязвимое** Flask-приложение для практики AppSec и DevSecOps.

## Важно
- Приложение специально упрощено.
- В коде есть демонстрационные анти-паттерны.
- Пример предназначен только для обучения и локальной практики.

## Цель
- Развернуть учебное приложение локально и изучить различие между безопасной и небезопасной реализацией endpoint'ов.
- Сравнить поведение endpoint'ов `unsafe` и `safe` с точки зрения обработки пользовательского ввода и рисков command injection.

## Шаги выполнения
1. Запустить приложение локально в виртуальном окружении:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

2. Либо запустить через Docker:
```bash
docker build -t vulnerable-app:lab .
docker run --rm -p 5000:5000 vulnerable-app:lab
```

3. Проверить доступные endpoint'ы:
   - `GET /health` — безопасный healthcheck.
   - `GET /hello?name=...` — пример простой валидации ввода.
   - `GET /calc?value=...` — пример обсуждения проблем валидации/ограничений.
   - `GET /diagnostic/ping?host=...` — намеренно небезопасная логика для анализа (anti-pattern).
   - `GET /diagnostic/ping-safe?host=...` — безопасная альтернатива с проверкой host и безопасным вызовом subprocess.

4. Выполнить базовые проверки через `curl`:
```bash
curl "http://127.0.0.1:5000/health"
curl "http://127.0.0.1:5000/hello?name=Intern"
curl "http://127.0.0.1:5000/calc?value=12"
curl "http://127.0.0.1:5000/diagnostic/ping?host=127.0.0.1"
curl "http://127.0.0.1:5000/diagnostic/ping-safe?host=127.0.0.1"
```

## Ожидаемый результат
- Приложение успешно запускается локально (или в Docker), endpoint `/health` отвечает корректно.
- Студент видит разницу между реализациями:
  - **Unsafe (`/diagnostic/ping`)**: строка команды собирается напрямую из ввода пользователя и выполняется через shell.
  - **Safe (`/diagnostic/ping-safe`)**: ввод проходит allow-list/валидацию, команда запускается через `subprocess.run(..., shell=False, timeout=...)`.
- В safe-варианте присутствуют контролируемая обработка ошибок и предсказуемый формат ответа.

## Вопросы на понимание
- Где и почему endpoint считается безопасным?
- Какие риски возникают в endpoint с shell-командой?
- Как валидация + `shell=False` + `timeout` снижают риск command injection?

## Критерии проверки
- Endpoint `/health` доступен и возвращает корректный ответ.
- Endpoint'ы `/diagnostic/ping` и `/diagnostic/ping-safe` демонстрируют различие в поведении при обработке ввода.
- По результатам проверки понятно, что unsafe-реализация несет больший риск, а safe-реализация снижает риск за счет валидации и безопасного запуска subprocess.
