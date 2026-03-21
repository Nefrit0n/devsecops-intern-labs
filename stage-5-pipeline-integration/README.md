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
│   ├── github-actions/                ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   ├── security-pr.yml              ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── security-main.yml            ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── gitlab-ci/                      ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── .gitlab-ci.yml               ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── pre-commit/                    ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── .pre-commit-config.yaml      ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── pipeline-comparison.md           ← ожидаемые артефакты студента (создаются в ходе выполнения)
├── defectdojo/
│   ├── configs/                        ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── docker-compose.yml           ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── scripts/                        ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── import-reports.sh            ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── defectdojo-setup.md              ← ожидаемые артефакты студента (создаются в ходе выполнения)
├── quality-gates/
│   ├── scripts/                        ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   ├── quality-gate.py              ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── metrics-collector.py         ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   ├── requirements-coverage.md         ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── security-metrics.md              ← ожидаемые артефакты студента (создаются в ходе выполнения)
├── supply-chain/
│   ├── configs/                        ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   │   └── cosign-verify-policy.yaml   ← ожидаемые артефакты студента (создаются в ходе выполнения)
│   └── supply-chain-setup.md            ← ожидаемые артефакты студента (создаются в ходе выполнения)
└── stage-5-summary.md                   ← ожидаемые артефакты студента (создаются в ходе выполнения)
```

После завершения → [`../checklists/stage-5-checklist.md`](../checklists/stage-5-checklist.md)
