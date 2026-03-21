---
description: "Отслеживание прогресса прохождения курса DevSecOps Lab по ГОСТ Р 56939-2024"
---

# Прогресс обучения

Используйте эту страницу для отслеживания прохождения курса. Отмечайте выполненные модули в чеклистах каждого этапа.

---

## Обзор этапов

<div class="stat-cards">
  <div class="stat-card">
    <div class="stat-number">0/6</div>
    <div class="stat-label">этапов пройдено</div>
  </div>
  <div class="stat-card">
    <div class="stat-number">0/20</div>
    <div class="stat-label">модулей завершено</div>
  </div>
  <div class="stat-card">
    <div class="stat-number">0</div>
    <div class="stat-label">часов затрачено</div>
  </div>
  <div class="stat-card">
    <div class="stat-number">0%</div>
    <div class="stat-label">общий прогресс</div>
  </div>
</div>

---

## Чеклисты по этапам

### :material-foundation: Этап 0 · Фундамент

<div class="stage-progress"><div class="stage-progress-bar" style="width: 0%; background: var(--stage-0-color);"></div></div>

- [ ] 0.1 — Теория ГОСТа: маппинг 25 процессов
- [ ] 0.2 — Моделирование угроз: DFD + STRIDE
- [ ] 0.3 — Требования безопасности: Definition of Done

[:material-clipboard-check: Полный чеклист](checklists/stage-0-checklist.md)

---

### :material-magnify: Этап 1 · Статика

<div class="stage-progress"><div class="stage-progress-bar" style="width: 0%; background: var(--stage-1-color);"></div></div>

- [ ] 1.1 — SAST: Semgrep, Bandit, кастомные правила
- [ ] 1.2 — Secrets: Gitleaks, TruffleHog, pre-commit
- [ ] 1.3 — Linters: ESLint, Ruff, hadolint

[:material-clipboard-check: Полный чеклист](checklists/stage-1-checklist.md)

---

### :material-package-variant: Этап 2 · Зависимости

<div class="stage-progress"><div class="stage-progress-bar" style="width: 0%; background: var(--stage-2-color);"></div></div>

- [ ] 2.1 — SCA: Trivy, Dep-Check, CVE triage
- [ ] 2.2 — SBOM: Syft, cdxgen, Dependency-Track
- [ ] 2.3 — Лицензии: policy-as-code

[:material-clipboard-check: Полный чеклист](checklists/stage-2-checklist.md)

---

### :material-web: Этап 3 · Динамика

<div class="stage-progress"><div class="stage-progress-bar" style="width: 0%; background: var(--stage-3-color);"></div></div>

- [ ] 3.1 — DAST: ZAP, Nuclei, кастомные шаблоны
- [ ] 3.2 — Fuzzing: RESTler, Schemathesis, ffuf
- [ ] 3.3 — API Testing: Postman, OWASP API Top 10

[:material-clipboard-check: Полный чеклист](checklists/stage-3-checklist.md)

---

### :material-server-security: Этап 4 · Инфраструктура

<div class="stage-progress"><div class="stage-progress-bar" style="width: 0%; background: var(--stage-4-color);"></div></div>

- [ ] 4.1 — Контейнеры: Trivy, Dockle, hardened Dockerfile
- [ ] 4.2 — IaC: Checkov, KICS, кастомные политики
- [ ] 4.3 — Kubernetes: Kubescape, Falco, Kyverno

[:material-clipboard-check: Полный чеклист](checklists/stage-4-checklist.md)

---

### :material-rocket-launch: Этап 5 · Пайплайн

<div class="stage-progress"><div class="stage-progress-bar" style="width: 0%; background: var(--stage-5-color);"></div></div>

- [ ] 5.1 — CI/CD: GitHub Actions, полный workflow
- [ ] 5.2 — DefectDojo: дедупликация, SLA, дашборд
- [ ] 5.3 — Quality Gates: requirements coverage
- [ ] 5.4 — Supply Chain: cosign, SLSA, provenance

[:material-clipboard-check: Полный чеклист](checklists/stage-5-checklist.md)

---

!!! tip "Как отслеживать прогресс"
    1. Форкните репозиторий и работайте в своём форке
    2. Отмечайте `[x]` в чеклистах по мере прохождения
    3. Сохраняйте артефакты в директории `solutions/stage-N/`
    4. Коммитьте результаты — ваша история Git станет портфолио
