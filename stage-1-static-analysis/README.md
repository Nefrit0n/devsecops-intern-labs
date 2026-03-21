# Этап 1 · Код под микроскопом

> *«Ищем баги, не запуская приложение»*

**Время:** ~10 часов · **Сложность:** средняя
**Мишени:** Juice Shop (SAST, linters) + WrongSecrets (секреты)
**Процессы ГОСТа:** 5.8 (правила кодирования), 5.9 (статический анализ), 5.15 (безопасность секретов)

---

## Зачем статический анализ

Статический анализ — это рентген для кода. Вы не запускаете приложение, не отправляете HTTP-запросы. Вы смотрите *внутрь* и видите:

- SQL-запрос, собранный конкатенацией строк → SQL injection
- `eval(userInput)` → Remote Code Execution
- `password = "admin123"` → утечка секрета
- `FROM ubuntu:latest` в Dockerfile → непредсказуемая сборка

Это самый быстрый и дешёвый способ найти уязвимости. Один запуск Semgrep на Juice Shop — 30 секунд, десятки findings. DAST-сканирование того же приложения — 30 минут.

**ГОСТ Р 56939-2024** выделяет на это три отдельных процесса:
- **5.9** — статический анализ кода (SAST)
- **5.15** — безопасность секретов (secret scanning)
- **5.8** — правила кодирования (linters)

Мы пройдём все три. По 3 инструмента на каждый — чтобы вы увидели, что *разные сканеры находят разное*, и один инструмент не заменяет всех.

---

## Арсенал

### 🔬 SAST — статический анализ

| Инструмент | Зачем нужен | Суперсила |
|------------|-------------|-----------|
| **Semgrep** | Основной SAST-сканер | Кастомные YAML-правила, 30+ языков |
| **Bandit** | Python-специфичный SAST | Глубокий AST-анализ Python |
| **njsscan** | Node.js-специфичный SAST | Ловит `eval`, `child_process`, десериализацию |

### 🔑 Secrets — поиск секретов

| Инструмент | Зачем нужен | Суперсила |
|------------|-------------|-----------|
| **Gitleaks** | Pre-commit + Git history | Быстрый, regex + entropy, SARIF-выход |
| **TruffleHog** | Глубокий скан + верификация | 800+ детекторов, проверяет что ключ ещё живой |
| **detect-secrets** | Baseline-подход | Фиксирует текущее, ловит только новые утечки |

### 📏 Linters — правила кодирования

| Инструмент | Зачем нужен | Суперсила |
|------------|-------------|-----------|
| **ESLint + security** | JS/TS security linting | eslint-plugin-security + no-unsanitized |
| **Ruff** | Python linting | В 100× быстрее flake8, встроены Bandit-правила |
| **hadolint** | Dockerfile linting | Ловит `USER root`, `latest`, лишние пакеты |

---

## Порядок прохождения

| #   | Модуль | Время | Мишень | Результат |
|-----|--------|-------|--------|-----------|
| 1.1 | SAST | ~4 ч | Juice Shop (исходный код) | Отчёты Semgrep + Bandit + njsscan, кастомные правила |
| 1.2 | Secrets | ~3 ч | Juice Shop + WrongSecrets | Pre-commit hook, Git history scan, сравнение 3 инструментов |
| 1.3 | Linters | ~3 ч | Juice Shop + его Dockerfile | Coding standard, конфиги линтеров |

---

## Подготовка

```bash
# 1. Клонируем исходный код Juice Shop
git clone --depth 1 https://github.com/juice-shop/juice-shop.git targets/juice-shop/src

# 2. Поднимаем WrongSecrets для лабы по секретам
docker run --rm -p 8080:8080 jeroenwillemsen/wrongsecrets:latest-no-vault

# 3. Устанавливаем инструменты
pip install semgrep bandit detect-secrets ruff
npm install -g eslint njsscan

# Gitleaks (бинарник)
# Linux:
curl -sSL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_8.21.2_linux_x64.tar.gz | tar xz
# macOS:
brew install gitleaks

# TruffleHog
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh

# hadolint
# Linux:
wget -O hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 && chmod +x hadolint
# macOS:
brew install hadolint
```

---

## Главный принцип этапа

**Не просто «запустил — посмотрел».** Для каждого инструмента вы:

1. **Запустите** с дефолтными настройками → поймёте базовый результат
2. **Настроите** конфигурацию под требования из этапа 0 → поймёте как управлять шумом
3. **Напишете своё правило** → поймёте как инструмент думает
4. **Сравните** с другими инструментами → поймёте что каждый ловит уникальное
5. **Экспортируете** результат в SARIF/JSON → подготовка к этапу 5 (DefectDojo)

---

## Начинаем

👉 [`sast/`](sast/)

---

## Артефакты этапа

```
stage-1-static-analysis/
├── sast/
│   ├── semgrep-report.json           ← отчёт Semgrep
│   ├── semgrep-custom-rules.yml      ← ваши 3 кастомных правила
│   ├── bandit-report.json            ← отчёт Bandit
│   ├── njsscan-report.sarif          ← отчёт njsscan
│   └── sast-comparison.md            ← сравнение: кто что нашёл
├── secrets/
│   ├── gitleaks-report.json          ← отчёт Gitleaks
│   ├── trufflehog-report.json        ← отчёт TruffleHog
│   ├── detect-secrets-baseline.json  ← baseline detect-secrets
│   ├── .gitleaks.toml                ← конфигурация Gitleaks
│   ├── .pre-commit-config.yaml       ← pre-commit hook
│   └── secrets-comparison.md         ← сравнение 3 инструментов
├── linters/
│   ├── .eslintrc.json                ← ESLint security config
│   ├── pyproject.toml                ← Ruff config
│   ├── .hadolint.yaml                ← hadolint config
│   └── linters-report.md             ← сводный отчёт линтеров
└── stage-1-summary.md                ← итоговый отчёт: findings → требования из этапа 0
```

После завершения → [`../checklists/stage-1-checklist.md`](../checklists/stage-1-checklist.md) → [Этап 2](../stage-2-dependencies/)
