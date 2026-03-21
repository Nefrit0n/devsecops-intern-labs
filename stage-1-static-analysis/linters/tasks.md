# Задания · Модуль 1.3 — Linters

---

## Задание 1 · ESLint + security-плагины
**Тег:** 🟢 практика · **Время:** ~1.5 ч

### Шаг 1: Установка плагинов

```bash
cd targets/juice-shop/src
npm install --save-dev eslint eslint-plugin-security eslint-plugin-no-unsanitized
```

### Шаг 2: Конфигурация

Создайте `configs/.eslintrc.json`:

```json
{
  "plugins": ["security", "no-unsanitized"],
  "extends": [
    "plugin:security/recommended-legacy"
  ],
  "rules": {
    "security/detect-eval-with-expression": "error",
    "security/detect-non-literal-fs-filename": "warn",
    "security/detect-non-literal-regexp": "warn",
    "security/detect-non-literal-require": "warn",
    "security/detect-object-injection": "warn",
    "security/detect-possible-timing-attacks": "warn",
    "security/detect-child-process": "error",
    "no-unsanitized/method": "error",
    "no-unsanitized/property": "error"
  },
  "env": {
    "node": true,
    "es2022": true
  }
}
```

### Шаг 3: Запуск

```bash
npx eslint --config configs/.eslintrc.json --format json -o eslint-report.json "targets/juice-shop/src/**/*.js"
```

### Шаг 4: Анализ

Из отчёта определите:
- Какие security-правила сработали чаще всего?
- Что нашёл `eslint-plugin-security`, чего не нашёл Semgrep?
- Что нашёл `no-unsanitized`, чего не было в других сканерах?

### Шаг 5: Кастомное правило

Напишите одно ESLint-правило (или modifируйте severity существующего), привязав к требованию из этапа 0. Например:

```json
"security/detect-eval-with-expression": ["error", {
  "message": "Требование E-01: запрещено использование eval() с пользовательским вводом"
}]
```

---

## Задание 2 · Ruff: быстрый Python-линтер с security-правилами
**Тег:** 🟢 практика · **Время:** ~45 мин

### Шаг 1: Конфигурация

Создайте `configs/pyproject.toml`:

```toml
[tool.ruff]
target-version = "py311"
line-length = 120

[tool.ruff.lint]
select = [
    "S",     # flake8-bandit (security) — ЭТО ГЛАВНОЕ
    "B",     # flake8-bugbear
    "A",     # flake8-builtins
    "T20",   # flake8-print (no print in production)
    "SIM",   # flake8-simplify
]

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101"]  # assert допустим в тестах
```

### Шаг 2: Запуск и сравнение с Bandit

```bash
ruff check targets/juice-shop/src --config configs/pyproject.toml --output-format json > ruff-report.json
```

Ruff включает правила Bandit как S-коды (S101 = assert, S301 = pickle, S608 = SQL injection). Сравните:
- Ruff нашёл столько же, что и Bandit?
- Какая разница по скорости? (Засеките time для обоих)
- Есть ли findings, которые Ruff нашёл, а Bandit нет? (за счёт bugbear и simplify)

---

## Задание 3 · hadolint: безопасность Dockerfile
**Тег:** 🟢 практика · **Время:** ~45 мин

### Шаг 1: Сканирование

```bash
# Dockerfile Juice Shop
hadolint targets/juice-shop/src/Dockerfile --format json > hadolint-report.json

# Если Dockerfile нет в src, используйте образ:
docker run --rm -i hadolint/hadolint < targets/juice-shop/src/Dockerfile
```

### Шаг 2: Конфигурация

Создайте `configs/.hadolint.yaml`:

```yaml
ignored:
  - DL3008  # pin versions in apt-get (иногда допустимо)

trustedRegistries:
  - docker.io
  - gcr.io

override:
  error:
    - DL3002  # Last USER should not be root
    - DL3007  # Using latest is prone to errors
    - DL3015  # Avoid additional packages with apt-get
  warning:
    - DL3003  # Use WORKDIR instead of cd
    - DL3025  # Use arguments JSON notation for CMD
```

### Шаг 3: Привязка к требованиям

Из вашего `security-requirements.md` (этап 0) найдите требования, связанные с Docker. Для каждого hadolint-правила укажите связь:

| hadolint правило | Описание | Требование из этапа 0 |
|------------------|----------|-----------------------|
| DL3002 | USER не должен быть root | D-01 (или ваш ID) |
| DL3007 | Не используй latest | I-05 (или ваш ID) |

---

## Задание 4 · Сводный отчёт по линтерам
**Тег:** 🟡 артефакт · **Время:** ~20 мин

Создайте `linters-report.md`:

```markdown
# Отчёт по линтерам · Этап 1

## Coding standard

На основе анализа Juice Shop принимаем следующие правила:

### JavaScript
- ESLint config: `configs/.eslintrc.json`
- Ключевые security-правила: ...
- Заблокировано: eval(), child_process.exec() с user input

### Python
- Ruff config: `configs/pyproject.toml`
- Security-правила (S-коды): S301, S608, ...

### Dockerfile
- hadolint config: `configs/.hadolint.yaml`
- Блокеры: DL3002 (root), DL3007 (latest)

## Findings

| Линтер | Total | Errors | Warnings | Security-related |
|--------|-------|--------|----------|-----------------|
| ESLint | | | | |
| Ruff | | | | |
| hadolint | | | | |

## Что линтеры нашли, а SAST пропустил
- ...

## Что SAST нашёл, а линтеры пропустили
- ...
```

---

## Артефакты

🟡 Итоговые файлы:
- `linters/configs/.eslintrc.json`
- `linters/configs/pyproject.toml`
- `linters/configs/.hadolint.yaml`
- `linters/linters-report.md`

---

## Чеклист самопроверки

- [ ] ESLint: security + no-unsanitized плагины подключены
- [ ] ESLint: конфиг создан, findings проанализированы
- [ ] Ruff: security-правила (S-коды) включены
- [ ] Ruff: сравнение с Bandit по скорости и покрытию
- [ ] hadolint: Dockerfile Juice Shop просканирован
- [ ] hadolint: правила привязаны к требованиям из этапа 0
- [ ] Создан linters-report.md с coding standard
- [ ] Определено что нашли линтеры, а SAST пропустил, и наоборот

---

🏁 **Этап 1 завершён!**

Перед тем как двигаться дальше, создайте итоговый файл `stage-1-summary.md`:
- Сколько **уникальных уязвимостей** нашли все 9 инструментов суммарно?
- Какие **требования из этапа 0** теперь закрыты (есть инструмент + правило + отчёт)?
- Какие **требования НЕ закрыты** статическим анализом (нужен DAST/pentest)?

Итоговый чеклист: [`../../checklists/stage-1-checklist.md`](../../checklists/stage-1-checklist.md)

Переходите к [Этапу 2 → Зависимости и состав ПО](../../stage-2-dependencies/)
