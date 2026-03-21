# Задания · Модуль 1.1 — SAST

---

## Задание 1 · Semgrep: от дефолтов к кастому
**Тег:** 🟢 практика · **Время:** ~1.5 ч

### Шаг 1: Первый запуск (дефолтные правила)

```bash
cd targets/juice-shop/src
semgrep --config auto --sarif -o ../../../stage-1-static-analysis/sast/semgrep-report.sarif .
```

Посмотрите результат. Запишите:
- Сколько findings всего?
- Сколько HIGH / MEDIUM / LOW?
- Какие категории уязвимостей нашёл? (injection, crypto, auth…)

### Шаг 2: Targeted scan (конкретные правила)

```bash
# Только OWASP Top 10
semgrep --config "p/owasp-top-ten" .

# Только Node.js security
semgrep --config "p/nodejs" .
```

Сравните: что нашёл `auto`, но не нашёл `owasp-top-ten`? И наоборот?

### Шаг 3: Написать свои правила

Откройте ваш файл `security-requirements.md` из этапа 0. Выберите 3 требования и напишите Semgrep-правило для каждого.

Пример: если ваше требование T-01 = «Все SQL-запросы ДОЛЖНЫ использовать параметризованные выражения»:

```yaml
rules:
  - id: juice-shop-sql-concatenation
    message: >
      SQL-запрос собран конкатенацией строк.
      Требование T-01: используйте параметризованные запросы.
    severity: ERROR
    languages: [javascript, typescript]
    patterns:
      - pattern: |
          $QUERY = "..." + $USER_INPUT + "..."
      - metavariable-regex:
          metavariable: $QUERY
          regex: ".*(SELECT|INSERT|UPDATE|DELETE).*"
```

Сохраните в `configs/semgrep-custom-rules.yml` и запустите:

```bash
semgrep --config configs/semgrep-custom-rules.yml targets/juice-shop/src
```

> **Цель:** не просто «написать правило», а связать его с конкретным требованием из этапа 0. Это трассируемость, которую требует ГОСТ.

### Шаг 4: Разбор findings (triage)

Выберите 10 findings из отчёта Semgrep. Для каждого определите:

| # | Finding | Файл:строка | True Positive? | Severity | Связь с требованием |
|---|---------|-------------|----------------|----------|---------------------|
| 1 | sql-injection | routes/user.js:42 | TP | HIGH | T-01 |
| 2 | ... | ... | FP (тест-файл) | — | — |

> **Зачем:** в реальном проекте SAST выдаёт сотни findings. Навык triage — отделить настоящие уязвимости от шума — это 50% работы AppSec-инженера.

---

## Задание 2 · Bandit: глубокий Python-анализ
**Тег:** 🟢 практика · **Время:** ~1 ч

```bash
# Если в Juice Shop есть Python-компоненты, или используйте WrongSecrets:
bandit -r targets/juice-shop/src -f json -o stage-1-static-analysis/sast/bandit-report.json

# С фильтром по severity:
bandit -r targets/juice-shop/src -ll  # только MEDIUM и выше

# С конкретными тестами:
bandit -r . -t B102,B301,B303,B608  # eval, pickle, md5, sql injection
```

### Что исследовать:

1. **Confidence levels** — Bandit показывает не только severity, но и confidence (насколько уверен). Найдите finding с HIGH severity но LOW confidence — почему так?

2. **Конфигурация** — создайте `.bandit` файл:
```ini
[bandit]
exclude = /tests,/node_modules
skips = B101
```
Что изменилось в количестве findings?

3. **Сравнение** — какие findings нашёл Bandit, но не Semgrep? Запишите в `sast-comparison.md`.

---

## Задание 3 · njsscan: Node.js под лупой
**Тег:** 🟢 практика · **Время:** ~45 мин

```bash
njsscan --sarif -o stage-1-static-analysis/sast/njsscan-report.sarif targets/juice-shop/src
```

### Что исследовать:

1. **Node.js-специфика** — njsscan ищет паттерны, которые имеют смысл только в Node.js:
   - `eval()`, `Function()`, `vm.runInNewContext()`
   - `child_process.exec()` с пользовательским вводом
   - Небезопасная десериализация (`node-serialize`)
   - Отключённая проверка TLS (`rejectUnauthorized: false`)

2. **Что нашёл njsscan, но пропустил Semgrep с дефолтами?** Добавьте в `sast-comparison.md`.

---

## Задание 4 · Сводное сравнение
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте файл `sast-comparison.md`:

```markdown
# Сравнение SAST-инструментов на Juice Shop

## Сводка

| Метрика | Semgrep | Bandit | njsscan |
|---------|---------|--------|---------|
| Findings всего | | | |
| HIGH | | | |
| MEDIUM | | | |
| LOW | | | |
| False Positives (из 10) | | | |
| Время скана | | | |
| Уникальные findings | | | |

## Что нашёл только один инструмент

### Только Semgrep
- ...

### Только Bandit
- ...

### Только njsscan
- ...

## Вывод: какой инструмент для чего
- ...
```

---

## Артефакты

🟡 Итоговые файлы:
- `sast/semgrep-report.sarif`
- `sast/configs/semgrep-custom-rules.yml` (3 правила → 3 требования)
- `sast/bandit-report.json`
- `sast/njsscan-report.sarif`
- `sast/sast-comparison.md`

---

## Чеклист самопроверки

- [ ] Semgrep запущен с auto, owasp-top-ten и кастомными правилами
- [ ] Написаны 3 кастомных Semgrep-правила, каждое привязано к требованию из этапа 0
- [ ] Проведён triage 10 findings (TP/FP определён)
- [ ] Bandit запущен, исследованы confidence levels
- [ ] njsscan запущен, найдены Node.js-специфичные уязвимости
- [ ] Сравнительная таблица заполнена
- [ ] Определены уникальные findings каждого инструмента
- [ ] Все отчёты экспортированы в JSON/SARIF

---

Далее → [`../secrets/`](../secrets/)
