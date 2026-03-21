# Этап 5 · Собираем пайплайн

> *«Всё вместе — от коммита до деплоя»*

**Время:** ~12 часов · **Сложность:** высокая
**Мишень:** Juice Shop (полный цикл — все инструменты в одном пайплайне)
**Процессы ГОСТа:** 5.2 (инструментальная среда), 5.14 (управление недостатками), 5.16 (безопасность при выпуске), 5.17 (эксплуатация)

---

## Зачем собирать пайплайн

На этапах 1–4 вы запускали инструменты *руками*: открыли терминал, ввели команду, посмотрели отчёт. В реальном проекте так не работает — есть 50 разработчиков, 100 коммитов в день, 20 микросервисов. Ручной запуск не масштабируется.

Этап 5 — **кульминация всего курса**. Вы берёте все инструменты из этапов 1–4 и встраиваете их в автоматический пайплайн, который:

1. **Предотвращает** — pre-commit хуки блокируют секреты и базовые баги *до коммита*
2. **Обнаруживает** — CI/CD запускает SAST, SCA, container scan, DAST на *каждый PR*
3. **Блокирует** — quality gates не дают зарелизить код с CRITICAL уязвимостями
4. **Агрегирует** — DefectDojo собирает все findings в одном месте, дедуплицирует, трекает SLA
5. **Подтверждает** — cosign подписывает образ, SLSA фиксирует provenance

Это то, что требует ГОСТ: не разовые проверки, а **процесс** — повторяемый, документируемый, автоматический.

---

## Четыре модуля

### 🔄 Модуль 5.1 · CI/CD pipeline
*«Автоматизация всех сканеров из этапов 1–4»*

GitHub Actions (основной) + GitLab CI (альтернативный) + pre-commit (локально)

### 📊 Модуль 5.2 · DefectDojo — управление уязвимостями
*«Одно место для всех findings, дедупликация, SLA, дашборд»*

DefectDojo + Dependency-Track интеграция

### 🚦 Модуль 5.3 · Quality gates — критерии прохождения
*«Пропускаем или блокируем релиз на основе требований из этапа 0»*

Кастомные скрипты + метрики безопасности

### 🔏 Модуль 5.4 · Supply chain security
*«Подписание артефактов и подтверждение происхождения»*

cosign (подпись образов) + SLSA (provenance attestation)

---

## Финальный пайплайн: что должно получиться

```
PR opened:
  ├── [pre-commit] Gitleaks + hadolint + Semgrep
  ├── [SAST]       Semgrep + njsscan              → SARIF → GitHub Security
  ├── [SCA]        Trivy fs + npm audit            → SARIF → GitHub Security
  ├── [IaC]        Checkov + KubeLinter
  └── [Gate]       0 CRITICAL findings? ─── yes → ✅ PR approved
                                          └── no  → ❌ PR blocked

Merge to main:
  ├── [Build]      Docker build
  ├── [Sign]       cosign sign
  ├── [Container]  Trivy image + Dockle + Grype
  ├── [SBOM]       Syft → Dependency-Track
  ├── [DAST]       ZAP baseline + Nuclei
  ├── [Import]     Все отчёты → DefectDojo API
  ├── [Provenance] SLSA attestation
  └── [Gate]       DefectDojo SLA OK? ─── yes → 🚀 Deploy
                                       └── no  → 🛑 Block
```

---

## Порядок прохождения

| #   | Модуль | Время | Результат |
|-----|--------|-------|-----------|
| 5.1 | CI/CD pipeline | ~4 ч | Работающие GH Actions + GitLab CI + pre-commit |
| 5.2 | DefectDojo | ~3 ч | Все findings из этапов 1–4 в одном дашборде |
| 5.3 | Quality gates | ~3 ч | Скрипты pass/fail, метрики, coverage report |
| 5.4 | Supply chain | ~2 ч | Подписанный образ, provenance attestation |

---

## Подготовка

```bash
# DefectDojo
git clone https://github.com/DefectDojo/django-DefectDojo
cd django-DefectDojo && docker compose up -d
# Логин: admin / (пароль в docker compose logs initializer)

# cosign
go install github.com/sigstore/cosign/v2/cmd/cosign@latest
# или: brew install cosign

# SLSA — через GitHub Actions (не нужна отдельная установка)

# pre-commit
pip install pre-commit
```

---

## Начинаем

👉 [`ci-cd/`](ci-cd/)

---

## Артефакты этапа

```
stage-5-pipeline-integration/
├── ci-cd/
│   ├── github-actions/
│   │   ├── security-pr.yml              ← workflow для PR (SAST+SCA+IaC)
│   │   └── security-main.yml            ← workflow для main (build+container+DAST)
│   ├── gitlab-ci/
│   │   └── .gitlab-ci.yml               ← аналогичный пайплайн для GitLab
│   ├── pre-commit/
│   │   └── .pre-commit-config.yaml      ← Gitleaks + hadolint + Semgrep
│   └── pipeline-comparison.md           ← GH Actions vs GitLab CI
├── defectdojo/
│   ├── configs/
│   │   └── docker-compose.yml           ← DefectDojo deployment
│   ├── scripts/
│   │   └── import-reports.sh            ← скрипт импорта всех отчётов через API
│   └── defectdojo-setup.md              ← Product, Engagement, SLA, dashboard
├── quality-gates/
│   ├── scripts/
│   │   ├── quality-gate.py              ← pass/fail скрипт
│   │   └── metrics-collector.py         ← сбор метрик
│   ├── requirements-coverage.md         ← маппинг: требования этапа 0 → findings → status
│   └── security-metrics.md              ← MTTD, MTTR, trend, coverage
├── supply-chain/
│   ├── configs/cosign-verify-policy.yaml
│   └── supply-chain-setup.md            ← cosign + SLSA инструкция
└── stage-5-summary.md                   ← ИТОГ ВСЕГО КУРСА
```

После завершения → [`../checklists/stage-5-checklist.md`](../checklists/stage-5-checklist.md)
