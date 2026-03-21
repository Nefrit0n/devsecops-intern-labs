# Задания · Модуль 2.1 — SCA

---

## Starter kit (минимальный skeleton)

```text
stage-2-dependencies/sca/
├── README.md
├── tasks.md
├── configs/
│   └── suppression.xml            # шаблон для Dependency-Check
└── sca-comparison.md              # черновик итогового сравнения
```

Если файлов `configs/suppression.xml` и `sca-comparison.md` ещё нет — создайте их перед стартом:

```bash
mkdir -p stage-2-dependencies/sca/configs
touch stage-2-dependencies/sca/configs/suppression.xml
touch stage-2-dependencies/sca/sca-comparison.md
```

---

## Задание 1 · npm audit: стартовая точка
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
cd targets/juice-shop/src

# Базовый аудит
npm audit --json > ../../../stage-2-dependencies/sca/npm-audit-report.json

# Человекочитаемый формат
npm audit

# Что можно починить автоматически?
npm audit fix --dry-run
```

Запишите:
- Сколько уязвимостей? Разбивка по severity (critical/high/medium/low)?
- Сколько из них direct vs transitive?
- Сколько `npm audit fix` починит автоматически, а сколько требует breaking changes (`--force`)?

> **Зачем npm audit первым:** он встроен, не требует установки. В реальном проекте это первое, что делает разработчик. Но у него ограниченная база — сравним с Trivy далее.

---

## Задание 2 · Trivy: универсальный сканер
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Скан файловой системы (исходный код)

```bash
# Скан lockfile
trivy fs targets/juice-shop/src --format json --output stage-2-dependencies/sca/trivy-fs-report.json

# Только CRITICAL и HIGH
trivy fs targets/juice-shop/src --severity CRITICAL,HIGH

# С SARIF для DefectDojo
trivy fs targets/juice-shop/src --format sarif --output stage-2-dependencies/sca/trivy-report.sarif
```

### Шаг 2: Скан Docker-образа

```bash
# Образ Juice Shop — уязвимости в OS-пакетах + app-зависимостях
trivy image bkimminich/juice-shop --format json --output stage-2-dependencies/sca/trivy-image-report.json

# Только app-зависимости (без OS)
trivy image bkimminich/juice-shop --vuln-type library
```

**Ключевой момент:** при скане Docker-образа Trivy находит *два типа уязвимостей*:
- **OS packages** (apt, apk) — уязвимости в базовом образе
- **Application libraries** (npm, pip) — уязвимости в зависимостях приложения

Разделите их в отчёте. OS-пакеты — ответственность того, кто собирает образ (этап 4). App-зависимости — ответственность разработчика (этот этап).

### Шаг 3: Сравнение с npm audit

Что нашёл Trivy, но не нашёл npm audit? Типичные причины:
- Trivy использует несколько баз (NVD + GitHub Advisory + OSV), npm audit — только GitHub Advisory
- Trivy сканирует OS-пакеты в контейнере, npm audit — нет
- Trivy видит уязвимости в бинарных зависимостях

---

## Задание 3 · OWASP Dependency-Check
**Тег:** 🟢 практика · **Время:** ~1 ч

```bash
# Через Docker (рекомендуется)
docker run --rm \
  -v $(pwd)/targets/juice-shop/src:/src \
  -v $(pwd)/stage-2-dependencies/sca:/report \
  owasp/dependency-check \
  --scan /src \
  --format HTML --format JSON \
  --out /report \
  --project "Juice Shop"
```

Откройте `dependency-check-report.html` в браузере.

### Что исследовать:

1. **CPE matching** — Dependency-Check сопоставляет пакеты с записями NVD через CPE (Common Platform Enumeration). Иногда это даёт false positives: пакет с похожим именем, но другой.

2. **Suppression file** — создайте `configs/suppression.xml` для подавления FP:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
  <suppress>
    <notes>False positive: это другой пакет</notes>
    <cpe>cpe:/a:example:wrong_match</cpe>
  </suppress>
</suppressions>
```

3. **Evidence** — для каждого finding Dep-Check показывает *evidence* (почему он считает, что пакет уязвим). Изучите 3 finding'а: в каких evidence был highest confidence?

---

## Задание 4 · Grype: скан поверх SBOM
**Тег:** 🟢 практика · **Время:** ~45 мин

```bash
# Сначала генерируем SBOM (Syft) — подробнее в модуле 2.2
syft targets/juice-shop/src -o syft-json > juice-shop-sbom.syft.json

# Сканируем SBOM через Grype
grype sbom:juice-shop-sbom.syft.json --output json > stage-2-dependencies/sca/grype-report.json

# Только fixable
grype sbom:juice-shop-sbom.syft.json --only-fixed
```

### Зачем Grype, если есть Trivy?

Grype работает *поверх SBOM* — это архитектурно другой подход:
- Trivy: «дай мне код, я сам разберусь что там»
- Grype: «дай мне опись (SBOM), я скажу что уязвимо»

Подход Grype ценен тем, что SBOM можно сгенерировать *один раз*, а сканировать *повторно* — когда выходит новая CVE. Не нужен доступ к исходному коду.

### Сравнение с Trivy

Добавьте в `sca-comparison.md`:
- Сколько CVE нашёл Grype vs Trivy?
- Есть ли CVE, которые нашёл только Grype? Только Trivy?
- Разница в severity оценках?

---

## Задание 5 · Сводное сравнение и triage
**Тег:** 🟡 артефакт · **Время:** ~45 мин

Создайте `sca-comparison.md`:

```markdown
# Сравнение SCA-инструментов на Juice Shop

## Сводка

| Метрика | npm audit | Trivy (fs) | Trivy (image) | Dep-Check | Grype |
|---------|-----------|------------|---------------|-----------|-------|
| CVE всего | | | | | |
| CRITICAL | | | | | |
| HIGH | | | | | |
| MEDIUM | | | | | |
| LOW | | | | | |
| False Positives (оценка) | | | | | |
| Время скана | | | | | |
| Уникальные CVE | | | | | |

## Top-5 критичных CVE

Для 5 самых опасных CVE заполните:

| CVE ID | Пакет | Версия | CVSS | Описание | Есть fix? | Наше решение |
|--------|-------|--------|------|----------|-----------|-------------|
| | | | | | | update / accept / replace / patch |

## Связь с требованиями из этапа 0

| Требование (этап 0) | Покрыто SCA? | Каким инструментом | Finding |
|---------------------|-------------|-------------------|---------|
| T-01 (SQL injection в зависимости) | | | |

## Вывод: рекомендуемая комбинация
- В CI: ...
- Для аудита: ...
- Для мониторинга: ...
```

---

## Артефакты

🟡 Итоговые файлы:
- `sca/npm-audit-report.json`
- `sca/trivy-report.sarif` + `trivy-fs-report.json` + `trivy-image-report.json`
- `sca/dependency-check-report.html` + `.json`
- `sca/grype-report.json`
- `sca/configs/suppression.xml`
- `sca/sca-comparison.md`

---

## Чеклист самопроверки

- [ ] npm audit запущен, разбивка direct vs transitive
- [ ] Trivy: скан файловой системы И Docker-образа
- [ ] Trivy: разделены OS-пакеты и app-зависимости
- [ ] Dependency-Check: HTML-отчёт, изучены CPE evidence
- [ ] Dependency-Check: создан suppression.xml для FP
- [ ] Grype: скан поверх SBOM, сравнение с Trivy
- [ ] Сравнительная таблица 4 сканеров заполнена
- [ ] Top-5 CVE с решением (update/accept/replace/patch)
- [ ] Findings привязаны к требованиям из этапа 0

---

Далее → [`../sbom/`](../sbom/)
