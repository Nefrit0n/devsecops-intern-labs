# Этап 3 · Атакуем приложение

> *«Приложение запущено — бьём снаружи»*

**Время:** ~12 часов · **Сложность:** выше средней
**Мишени:** Juice Shop (DAST, fuzzing) + crAPI (API security)
**Процессы ГОСТа:** 5.11 (динамический анализ), 5.12 (функциональное тестирование), 5.13 (нефункциональное тестирование)

---

## Зачем динамический анализ, если мы уже прогнали SAST и SCA

На этапах 1–2 вы искали уязвимости в *коде* и *зависимостях*. Но некоторые проблемы проявляются **только в работающем приложении**:

| Уязвимость | Находит SAST? | Находит DAST? | Почему |
|-----------|---------------|---------------|--------|
| SQL injection через конкатенацию строк | ✓ | ✓ | Паттерн виден в коде |
| SQL injection через ORM misuse | ✗ | ✓ | Код выглядит «правильно», но ORM генерирует уязвимый SQL |
| Missing security headers (CSP, HSTS) | ✗ | ✓ | Это конфигурация сервера, не код |
| Broken authentication flow | ✗ | ✓ | Нужно пройти login → получить токен → проверить |
| CORS misconfiguration | ✗ | ✓ | Зависит от runtime-конфигурации |
| IDOR (Insecure Direct Object Reference) | ✗ | ✓ | Нужно два аккаунта и реальные запросы |
| Race condition | ✗ | ✓ | Проявляется только при параллельных запросах |

**Аналогия:** SAST — это проверка чертежа здания на бумаге. DAST — это попытка *физически взломать* дверь, окно, вентиляцию. Чертёж может быть идеальным, но если замок установлен криво — SAST этого не увидит.

---

## Три слоя тестирования

### 🌐 Слой 1 · DAST — сканируем работающее приложение
*«Приложение запущено, мы бьём по HTTP — что ломается?»*

Инструменты: **ZAP**, **Nuclei**, **Nikto**, **Wapiti**

### 🔨 Слой 2 · Fuzzing — подаём мусор на вход
*«Что если послать 10000 случайных строк в каждое поле?»*

Инструменты: **RESTler**, **Schemathesis**, **ffuf**

### 🔌 Слой 3 · API security — тестируем бизнес-логику API
*«Можно ли получить чужие данные? Обойти авторизацию? Изменить чужой заказ?»*

Инструменты: **Postman + Newman**, **Dredd**, **CATS**

---

## Арсенал

### 🌐 DAST

| Инструмент | Зачем нужен | Суперсила |
|------------|-------------|-----------|
| **OWASP ZAP** | Основной DAST-сканер | Proxy + crawler + active scan, Docker, CI-ready |
| **Nuclei** | Template-based сканер | 11000+ YAML-шаблонов, молниеносный |
| **Nikto** | Server misconfiguration | .git, .env, дефолты, заголовки |
| **Wapiti** | Black-box injection | Crawl + inject, XSS/SQLi-специалист |

### 🔨 Fuzzing

| Инструмент | Зачем нужен | Суперсила |
|------------|-------------|-----------|
| **RESTler** | Stateful API fuzzing | Понимает зависимости между API-вызовами |
| **Schemathesis** | Property-based API fuzzing | Python, авто-тесты из OpenAPI spec |
| **ffuf** | Web fuzzer (paths, params) | Быстрый, wordlist-based, Go |

### 🔌 API security

| Инструмент | Зачем нужен | Суперсила |
|------------|-------------|-----------|
| **Postman + Newman** | Коллекции security-тестов | Визуальный, скрипты, CI через Newman |
| **Dredd** | Contract testing | API соответствует своей спецификации? |
| **CATS** | OpenAPI-driven fuzzer | 50+ fuzzers из spec, авто-генерация |

---

## Порядок прохождения

| #   | Модуль | Время | Мишень | Результат |
|-----|--------|-------|--------|-----------|
| 3.1 | DAST | ~5 ч | Juice Shop | Отчёты ZAP + Nuclei + Nikto + Wapiti, сравнение |
| 3.2 | Fuzzing | ~4 ч | Juice Shop (API) | RESTler + Schemathesis + ffuf, crash log |
| 3.3 | API security | ~3 ч | crAPI | Postman коллекция, Dredd, CATS, OWASP API Top 10 |

---

## Подготовка

```bash
# Мишени
docker run --rm -p 3000:3000 bkimminich/juice-shop        # Juice Shop
cd targets/crapi && docker compose up -d                    # crAPI (для модуля 3.3)

# Инструменты
# ZAP (через Docker — проще всего)
docker pull ghcr.io/zaproxy/zaproxy:stable

# Nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
# или: brew install nuclei

# Nikto
git clone https://github.com/sullo/nikto.git && cd nikto/program

# Wapiti
pip install wapiti3

# RESTler
pip install restler-fuzzer
# или: docker pull mcr.microsoft.com/restler

# Schemathesis
pip install schemathesis

# ffuf
go install github.com/ffuf/ffuf/v2@latest
# или: brew install ffuf

# Postman → Newman (CLI)
npm install -g newman

# Dredd
npm install -g dredd

# CATS
docker pull endava/cats
```

---

## Главный принцип этапа

На этапах 1–2 вы работали с *кодом*. Здесь вы работаете с *приложением*. Разница огромная:

- **SAST видит код** — находит паттерны (`eval(userInput)`), но не знает, достижим ли этот код
- **DAST видит приложение** — не знает про код, но находит *реально эксплуатируемые* уязвимости

Ключевой навык этого этапа: **корреляция**. Когда ZAP находит SQL injection в `/api/Users`, вы должны открыть отчёт Semgrep и найти ту же уязвимость в коде. Если DAST нашёл, а SAST нет — это gap в правилах. Если SAST нашёл, а DAST нет — возможно, код недостижим или есть WAF.

---

## Начинаем

👉 [`dast/`](dast/)

---

## Артефакты этапа

```
stage-3-dynamic-analysis/
├── dast/
│   ├── zap-baseline-report.html      ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── zap-full-report.json          ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── zap-automation.yaml           ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── nuclei-report.json            ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── nuclei-custom-templates/      ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── nikto-report.json             ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── wapiti-report.json            ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── dast-comparison.md            ← ожидаемые артефакты студента (создаются в ходе выполнения)
├── fuzzing/
│   ├── restler-results/              ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── schemathesis-report.json      ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── ffuf-results/                 ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── fuzzing-comparison.md         ← ожидаемые артефакты студента (создаются в ходе выполнения)
├── api-testing/
│   ├── postman-collection.json       ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── newman-report.html            ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── dredd-results.json            ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── cats-report/                  ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── api-comparison.md             ← ожидаемые артефакты студента (создаются в ходе выполнения)
└── stage-3-summary.md                ← ожидаемые артефакты студента (создаются в ходе выполнения)
```

После завершения → [`../checklists/stage-3-checklist.md`](../checklists/stage-3-checklist.md) → [Этап 4](../stage-4-infrastructure/)
