# Задания · Модуль 3.1 — DAST

> **Важно:** перед началом убедитесь что Juice Shop запущен: `docker run --rm -p 3000:3000 bkimminich/juice-shop`

---

## Starter kit (минимальный skeleton)

```text
stage-3-dynamic-analysis/dast/
├── README.md
├── tasks.md
├── configs/
│   └── zap-automation.yaml        # YAML для ZAP Automation Framework
├── nuclei-custom-templates/
└── dast-comparison.md
```

Подготовьте каркас перед выполнением:

```bash
mkdir -p stage-3-dynamic-analysis/dast/configs
mkdir -p stage-3-dynamic-analysis/dast/nuclei-custom-templates
touch stage-3-dynamic-analysis/dast/configs/zap-automation.yaml
touch stage-3-dynamic-analysis/dast/dast-comparison.md
```

---

## Задание 1 · ZAP: от baseline до full scan
**Тег:** 🟢 практика · **Время:** ~2 ч

### Шаг 1: Baseline scan (passive, 2 мин)

```bash
docker run --rm -v $(pwd)/stage-3-dynamic-analysis/dast:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -r zap-baseline-report.html \
  -J zap-baseline-report.json
```

Baseline scan **не атакует** — он только просматривает страницы и анализирует ответы (passive). Это безопасно для production.

Изучите отчёт:
- Какие проблемы нашёл passive scan? (missing headers, cookie flags, info disclosure)
- Сколько MEDIUM+ findings?
- Есть ли false positives?

### Шаг 2: Full active scan (10–30 мин)

```bash
docker run --rm -v $(pwd)/stage-3-dynamic-analysis/dast:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -r zap-full-report.html \
  -J zap-full-report.json
```

Active scan **атакует** — подставляет SQL injection, XSS, path traversal и т.д. Никогда не запускайте на production.

Сравните с baseline:
- Сколько *новых* findings появилось?
- Какие категории: injection, XSS, info disclosure, auth?
- Сколько из них реально эксплуатируемы?

### Шаг 3: API scan

Juice Shop имеет REST API. Найдите его спецификацию (подсказка: попробуйте `/api-docs` или изучите сетевые запросы в DevTools).

```bash
docker run --rm -v $(pwd)/stage-3-dynamic-analysis/dast:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t http://host.docker.internal:3000/api-docs \
  -f openapi \
  -r zap-api-report.html \
  -J zap-api-report.json
```

Что нашёл API scan, чего не было в full scan?

### Шаг 4: ZAP Automation Framework (YAML для CI)

Создайте `configs/zap-automation.yaml`:

```yaml
env:
  contexts:
    - name: "Juice Shop"
      urls:
        - "http://localhost:3000"
  parameters:
    failOnError: true
    failOnWarning: false
    progressToStdout: true

jobs:
  - type: spider
    parameters:
      maxDuration: 2
  - type: spiderAjax
    parameters:
      maxDuration: 2
  - type: passiveScan-wait
  - type: activeScan
    parameters:
      maxRuleDurationInMins: 5
  - type: report
    parameters:
      template: "traditional-json"
      reportFile: "zap-automation-report.json"
```

```bash
docker run --rm -v $(pwd)/stage-3-dynamic-analysis/dast/configs:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable zap.sh -cmd \
  -autorun /zap/wrk/zap-automation.yaml
```

> **Зачем YAML:** на этапе 5 этот файл ляжет в CI/CD пайплайн. Automation Framework — это «ZAP as code».

---

## Задание 2 · Nuclei: template-based scanning
**Тег:** 🟢 практика · **Время:** ~1.5 ч

### Шаг 1: Скан с community templates

```bash
# Обновить шаблоны
nuclei -update-templates

# Полный скан
nuclei -u http://localhost:3000 -o stage-3-dynamic-analysis/dast/nuclei-report.json -jsonl

# Только OWASP-related
nuclei -u http://localhost:3000 -tags owasp

# Только critical + high
nuclei -u http://localhost:3000 -severity critical,high
```

### Шаг 2: Security headers check

```bash
nuclei -u http://localhost:3000 -tags headers
```

Какие заголовки отсутствуют? (HSTS, CSP, X-Content-Type-Options, X-Frame-Options)

### Шаг 3: Написать 2 кастомных шаблона

Пример: проверка что Juice Shop score board доступен без аутентификации:

```yaml
id: juice-shop-scoreboard-exposed

info:
  name: Juice Shop Scoreboard Exposed
  author: your-name
  severity: medium
  description: Score board доступен без аутентификации
  tags: juice-shop,access-control

http:
  - method: GET
    path:
      - "{{BaseURL}}/#/score-board"
    matchers:
      - type: status
        status:
          - 200
      - type: word
        words:
          - "Score Board"
```

Создайте ещё один шаблон, привязанный к требованию из этапа 0. Сохраните в `nuclei-custom-templates/`.

```bash
nuclei -u http://localhost:3000 -t nuclei-custom-templates/
```

### Шаг 4: Сравнение с ZAP

Что Nuclei нашёл, а ZAP пропустил? (Типично: known CVE, misconfigs, exposed panels)
Что ZAP нашёл, а Nuclei нет? (Типично: injection, XSS через fuzzing)

---

## Задание 3 · Nikto: серверные мисконфигурации
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
cd nikto/program
perl nikto.pl -h http://localhost:3000 -o ../../stage-3-dynamic-analysis/dast/nikto-report.json -Format json

# Или через Docker:
docker run --rm sullo/nikto -h http://host.docker.internal:3000
```

Что искать:
- Exposed .git directory?
- Directory listing?
- Default credentials panels?
- Information disclosure через error pages?
- Missing security headers?

Запишите: что Nikto нашёл уникального (не ZAP, не Nuclei).

---

## Задание 4 · Wapiti: crawl + inject
**Тег:** 🟢 практика · **Время:** ~45 мин

```bash
wapiti -u http://localhost:3000 \
  --format json \
  --output stage-3-dynamic-analysis/dast/wapiti-report.json \
  -m sql,xss,ssrf,crlf,exec
```

Wapiti работает иначе: агрессивно crawlит и инжектит payload в каждый найденный параметр. Сравните глубину crawl с ZAP Spider — кто нашёл больше URL?

---

## Задание 5 · Сводное сравнение DAST
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `dast-comparison.md`:

```markdown
# Сравнение DAST-инструментов на Juice Shop

| Метрика | ZAP baseline | ZAP full | Nuclei | Nikto | Wapiti |
|---------|-------------|----------|--------|-------|--------|
| Findings всего | | | | | |
| HIGH+ | | | | | |
| Уникальные (только этот) | | | | | |
| Время скана | | | | | |
| False Positives (оценка) | | | | | |

## Корреляция с SAST (этап 1)

| Finding DAST | Файл:строка (из SAST) | Нашёл SAST? | Нашёл DAST? | Комментарий |
|-------------|----------------------|-------------|-------------|-------------|
| SQL injection /api/Users | routes/user.js:42 | ✓ Semgrep | ✓ ZAP | Совпадение |
| Missing CSP header | — | ✗ | ✓ ZAP | Только runtime |
| ... | | | | |

## Рекомендуемая комбинация для CI
- PR: ZAP baseline (2 мин) + Nuclei headers (1 мин)
- Staging: ZAP full + Nuclei all + Wapiti
- Nightly: всё вместе
```

---

## Артефакты

🟡 Итоговые файлы:
- `dast/zap-baseline-report.html` + `.json`
- `dast/zap-full-report.html` + `.json`
- `dast/configs/zap-automation.yaml`
- `dast/nuclei-report.json`
- `dast/nuclei-custom-templates/` (2 шаблона)
- `dast/nikto-report.json`
- `dast/wapiti-report.json`
- `dast/dast-comparison.md`

---

## Чеклист самопроверки

- [ ] ZAP: baseline scan (passive) выполнен
- [ ] ZAP: full active scan выполнен, findings проанализированы
- [ ] ZAP: API scan через OpenAPI spec
- [ ] ZAP: Automation Framework YAML создан (готов для CI)
- [ ] Nuclei: скан с community templates
- [ ] Nuclei: написаны 2 кастомных шаблона
- [ ] Nikto: серверные мисконфигурации найдены
- [ ] Wapiti: crawl + inject выполнен
- [ ] Корреляция DAST↔SAST: таблица совпадений и расхождений
- [ ] `dast-comparison.md` заполнен с рекомендациями для CI

---

Далее → [`../fuzzing/`](../fuzzing/)
