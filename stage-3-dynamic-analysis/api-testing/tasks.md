# Задания · Модуль 3.3 — API Security Testing

> **Мишень:** crAPI. Запуск: `cd targets/crapi && docker compose up -d`
> crAPI UI: http://localhost:8888 · Mailhog: http://localhost:8025

---

## Starter kit (минимальный skeleton)

```text
stage-3-dynamic-analysis/api-testing/
├── README.md
├── tasks.md
├── cats-report/
└── api-comparison.md
```

Перед выполнением создайте каталоги/черновики:

```bash
mkdir -p stage-3-dynamic-analysis/api-testing/cats-report
touch stage-3-dynamic-analysis/api-testing/api-comparison.md
```

---

## Задание 1 · Postman: OWASP API Top 10 вручную
**Тег:** 🟢 практика · **Время:** ~1.5 ч

### Шаг 1: Подготовка

1. Откройте crAPI, зарегистрируйте два аккаунта: `user1@test.com` и `user2@test.com`
2. В Postman создайте коллекцию «crAPI — OWASP API Top 10»
3. Настройте environments с переменными: `base_url`, `token_user1`, `token_user2`

### Шаг 2: Тесты на OWASP API Top 10

Создайте запросы и тесты для каждой категории:

**API1 — BOLA (Broken Object Level Authorization):**
```
# Войдите как user1, получите ID своего ресурса
GET {{base_url}}/api/v2/vehicle/123

# Попробуйте получить ресурс user2 с токеном user1
GET {{base_url}}/api/v2/vehicle/456
Authorization: Bearer {{token_user1}}

# Тест в Postman:
pm.test("BOLA: should return 403", function() {
    pm.response.to.have.status(403);
});
```

**API2 — Broken Authentication:**
```
# Перебор паролей: нет rate limiting?
POST {{base_url}}/api/auth/login
Body: {"email": "user1@test.com", "password": "wrong1"}
# Повторите 50 раз. Заблокирует ли API?
```

**API3 — Excessive Data Exposure:**
```
# Запросите профиль — возвращает ли API лишние поля?
GET {{base_url}}/api/v2/user/dashboard
# Есть ли в ответе password_hash, internal_id, admin_flag?
```

**API5 — BFLA (Broken Function Level Auth):**
```
# Попробуйте вызвать admin-эндпоинт с обычным токеном
GET {{base_url}}/api/v2/admin/users
Authorization: Bearer {{token_user1}}
```

### Шаг 3: Экспорт коллекции

```bash
# Экспортируйте коллекцию из Postman
# Сохраните как api-testing/postman-collection.json
```

### Шаг 4: Newman в CI

```bash
newman run postman-collection.json \
  --environment crapi-env.json \
  --reporters html,json \
  --reporter-html-export stage-3-dynamic-analysis/api-testing/newman-report.html \
  --reporter-json-export stage-3-dynamic-analysis/api-testing/newman-report.json
```

> **Связка с этапом 5:** Newman-команда ляжет в CI/CD пайплайн. Если BOLA-тест упадёт — пайплайн упадёт.

---

## Задание 2 · Dredd: contract testing
**Тег:** 🟢 практика · **Время:** ~45 мин

Dredd проверяет: **«API ведёт себя так, как описано в OpenAPI спецификации?»** Если в spec сказано что `/users` возвращает `200` со схемой `{id, name, email}`, а реально возвращает `{id, name, email, password_hash}` — Dredd это найдёт.

### Шаг 1: Запуск

```bash
# Получите OpenAPI spec crAPI (или Juice Shop)
dredd http://localhost:3000/api-docs http://localhost:3000 \
  --reporter json \
  --output stage-3-dynamic-analysis/api-testing/dredd-results.json
```

### Шаг 2: Анализ

- Сколько эндпоинтов прошли?
- Сколько failures? Какие типы: wrong status code, wrong schema, missing fields?
- Есть ли **undocumented endpoints** (реально существуют, но нет в spec)?
- Есть ли **extra fields** в ответе (API возвращает больше, чем в spec)?

> **Security-инсайт:** extra fields в ответе — это API3 (Excessive Data Exposure). Contract test нашёл security-баг!

---

## Задание 3 · CATS: автоматический API fuzzer
**Тег:** 🟢 практика · **Время:** ~45 мин

CATS (Contract And Testing Service) — генерирует 50+ видов тестов из OpenAPI:

```bash
docker run --rm -v $(pwd):/app endava/cats \
  --contract=/app/crapi-swagger.json \
  --server=http://host.docker.internal:8888 \
  --reportPath=/app/stage-3-dynamic-analysis/api-testing/cats-report
```

### Типы fuzzers в CATS:

- **Security fuzzers:** injection в headers, body, path params
- **Contract fuzzers:** missing required fields, wrong types, extra fields
- **Auth fuzzers:** empty auth, invalid token, expired token
- **Boundary fuzzers:** max length, min length, special chars

### Анализ

1. Откройте HTML-отчёт в `cats-report/`
2. Сколько тестов всего? Сколько failed?
3. Разбейте по категориям: security / contract / auth / boundary
4. Что CATS нашёл, а Postman нет? (CATS автоматический, Postman ручной)
5. Что Postman нашёл, а CATS нет? (бизнес-логика: BOLA, BFLA)

---

## Задание 4 · Сводный отчёт по API security
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `api-comparison.md`:

```markdown
# API Security Testing · crAPI + Juice Shop

## OWASP API Top 10 Coverage

| # | Категория | Postman | Dredd | CATS | ZAP API | Найдено? |
|---|-----------|---------|-------|------|---------|----------|
| API1 | BOLA | ✓ ручной тест | ✗ | ✗ | ✗ | ✓/✗ |
| API2 | Broken Auth | ✓ | ✗ | ✓ auth fuzzers | Частично | |
| API3 | Excessive Data | ✗ | ✓ extra fields | ✓ contract | ✗ | |
| API4 | Unrestricted Resource | ✓ ручной | ✗ | ✗ | ✗ | |
| API5 | BFLA | ✓ ручной | ✗ | ✓ auth fuzzers | ✗ | |
| API6 | Mass Assignment | ✓ ручной | ✗ | ✓ | ✗ | |
| API7 | SSRF | ✗ | ✗ | ✗ | ✓ | |
| API8 | Security Misconfig | ✗ | ✗ | ✓ | ✓ Nuclei | |
| API9 | Improper Inventory | ✗ | ✓ undocumented | ✗ | ✗ | |
| API10 | Unsafe Consumption | ✗ | ✗ | ✗ | ✗ | |

## Ключевой вывод
Ни один инструмент не покрывает весь OWASP API Top 10. Нужна комбинация:
- Postman (ручные тесты на бизнес-логику: BOLA, BFLA, mass assignment)
- CATS (автоматический fuzzing: injection, auth, contract)
- Dredd (contract: extra fields, undocumented endpoints)
- ZAP/Nuclei (традиционные уязвимости: SSRF, misconfig)
```

---

## Артефакты

🟡 Итоговые файлы:
- `api-testing/postman-collection.json`
- `api-testing/newman-report.html` + `.json`
- `api-testing/dredd-results.json`
- `api-testing/cats-report/`
- `api-testing/api-comparison.md`

---

## Чеклист самопроверки

- [ ] Postman: коллекция OWASP API Top 10 создана
- [ ] Postman: тесты BOLA, broken auth, excessive data, BFLA
- [ ] Newman: коллекция прогнана в CLI, отчёт сохранён
- [ ] Dredd: contract testing, найдены extra fields / undocumented endpoints
- [ ] CATS: все категории fuzzers запущены
- [ ] OWASP API Top 10 coverage table заполнена
- [ ] Определено что находит только ручной тест (Postman) vs автоматика

---

🏁 **Этап 3 завершён!**

Создайте `stage-3-summary.md`:
- **Корреляция DAST↔SAST:** что нашёл DAST, но пропустил SAST? И наоборот?
- **Уникальные findings** каждого слоя (DAST / Fuzzing / API testing)
- Какие **требования из этапа 0** теперь полностью закрыты?
- Какие **остались открытыми** (нужны этапы 4–5)?

Чеклист: [`../../checklists/stage-3-checklist.md`](../../checklists/stage-3-checklist.md)

Переходите к [Этапу 4 → Инфраструктура](../../stage-4-infrastructure/)
