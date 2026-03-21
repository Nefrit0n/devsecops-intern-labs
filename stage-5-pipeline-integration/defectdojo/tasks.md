# Задания · Модуль 5.2 — DefectDojo

---

## Задание 1 · Развёртывание
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
git clone https://github.com/DefectDojo/django-DefectDojo
cd django-DefectDojo
docker compose up -d

# Дождитесь инициализации (~3 мин)
docker compose logs initializer | grep "Admin password:"

# Откройте http://localhost:8080
# Логин: admin / <пароль из логов>
```

Или используйте `configs/docker-compose.yml` из этого модуля.

---

## Задание 2 · Структура: Product → Engagement → Test
**Тег:** 🟢 практика · **Время:** ~30 мин

DefectDojo имеет иерархию:

```
Product Type: "DevSecOps Lab"
  └── Product: "Juice Shop"
        ├── Engagement: "CI/CD Automated Scans"
        │     ├── Test: "Semgrep SAST" (import semgrep.sarif)
        │     ├── Test: "Trivy SCA" (import trivy-fs.json)
        │     ├── Test: "ZAP DAST" (import zap-report.json)
        │     └── Test: "Trivy Container" (import trivy-image.json)
        └── Engagement: "Manual Assessment Q1"
              └── Test: "Pentest" (import вручную)
```

Создайте эту структуру в UI:

1. **Product Type** → «DevSecOps Lab»
2. **Product** → «Juice Shop» (Description, tags, SLA config)
3. **Engagement** → «CI/CD Pipeline» (тип: CI/CD)
4. **Tests** → создадутся автоматически при импорте

---

## Задание 3 · Импорт всех отчётов из этапов 1–4
**Тег:** 🟢 практика · **Время:** ~1 ч

### Через UI (для понимания)

1. Перейдите в Engagement «CI/CD Pipeline»
2. Import Scan Results → выберите Scan Type → загрузите файл

Импортируйте **все** отчёты, которые вы создали на этапах 1–4:

| Этап | Инструмент | Файл | Scan Type в DefectDojo |
|------|-----------|------|------------------------|
| 1 | Semgrep | semgrep-report.sarif | Semgrep JSON Report |
| 1 | Bandit | bandit-report.json | Bandit Scan |
| 1 | njsscan | njsscan-report.sarif | njsscan Scan |
| 1 | Gitleaks | gitleaks-report.json | Gitleaks Scan |
| 1 | TruffleHog | trufflehog-report.json | Trufflehog Scan |
| 2 | Trivy (fs) | trivy-fs-report.json | Trivy Scan |
| 2 | Dependency-Check | dependency-check-report.json | Dependency Check Scan |
| 2 | Grype | grype-report.json | Anchore Grype |
| 3 | ZAP | zap-full-report.json | ZAP Scan |
| 3 | Nuclei | nuclei-report.json | Nuclei Scan |
| 4 | Trivy (image) | trivy-image-report.json | Trivy Scan |
| 4 | Checkov | checkov-report.json | Checkov Scan |

### Через API (для автоматизации)

Создайте `scripts/import-reports.sh`:

```bash
#!/bin/bash
DD_URL="${DD_URL:-http://localhost:8080}"
DD_TOKEN="${DD_TOKEN:-your-api-token}"
ENGAGEMENT_ID="${DD_ENGAGEMENT:-1}"

import_scan() {
    local scan_type="$1"
    local file="$2"
    echo "Importing $file as $scan_type..."
    curl -s -X POST "$DD_URL/api/v2/import-scan/" \
        -H "Authorization: Token $DD_TOKEN" \
        -F "scan_type=$scan_type" \
        -F "file=@$file" \
        -F "engagement=$ENGAGEMENT_ID" \
        -F "active=true" \
        -F "verified=false" \
        -F "close_old_findings=false"
    echo ""
}

# Этап 1 — SAST
import_scan "Semgrep JSON Report" "stage-1-static-analysis/sast/semgrep-report.sarif"
import_scan "Bandit Scan" "stage-1-static-analysis/sast/bandit-report.json"
import_scan "Gitleaks Scan" "stage-1-static-analysis/secrets/gitleaks-report.json"

# Этап 2 — SCA
import_scan "Trivy Scan" "stage-2-dependencies/sca/trivy-fs-report.json"
import_scan "Dependency Check Scan" "stage-2-dependencies/sca/dependency-check-report.json"

# Этап 3 — DAST
import_scan "ZAP Scan" "stage-3-dynamic-analysis/dast/zap-full-report.json"
import_scan "Nuclei Scan" "stage-3-dynamic-analysis/dast/nuclei-report.json"

# Этап 4 — Container
import_scan "Trivy Scan" "stage-4-infrastructure/container-sec/trivy-image-report.json"
import_scan "Checkov Scan" "stage-4-infrastructure/iac-sec/checkov-report.json"

echo "Done! Check DefectDojo dashboard."
```

### Анализ после импорта

После импорта всех отчётов посмотрите на дашборд:
1. **Total findings** — сколько всего?
2. **After deduplication** — сколько уникальных? (DefectDojo дедуплицирует автоматически)
3. **By severity** — CRITICAL / HIGH / MEDIUM / LOW
4. **By tool** — какой инструмент нашёл больше всего?

Запишите: до дедупликации ___ findings → после ___ findings. Процент дублей: ___%

---

## Задание 4 · SLA и workflow
**Тег:** 🟢 практика · **Время:** ~30 мин

### SLA configuration

В Product settings настройте SLA:

| Severity | Time to Remediate |
|----------|-------------------|
| Critical | 1 день |
| High | 7 дней |
| Medium | 30 дней |
| Low | 90 дней |

### Workflow

Для 5 findings разного severity пройдите полный lifecycle:
1. **Active** → Finding обнаружен
2. **Verified** → Подтверждено что это реальная уязвимость (не FP)
3. **Risk Accepted** или **Mitigated** → Решение принято
4. **Closed** → Исправлено и перепроверено

Для 2 findings отметьте как **False Positive** с обоснованием.

---

## Задание 5 · Dashboard и метрики
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `defectdojo-setup.md` со скриншотами/описанием:

```markdown
# DefectDojo · Juice Shop Dashboard

## Общая статистика
- Total findings (до дедупликации): ___
- Unique findings (после): ___
- Дублей: ___% 

## По severity
| Severity | Count | SLA | On track? |
|----------|-------|-----|-----------|
| Critical | | 1 день | |
| High | | 7 дней | |
| Medium | | 30 дней | |
| Low | | 90 дней | |

## По инструменту (Top-5)
| Tool | Findings | Unique | % от общего |
|------|----------|--------|-------------|
| 1. | | | |
| 2. | | | |

## Workflow пройден для 5 findings: ✓/✗
## False Positive отмечено для 2 findings: ✓/✗
```

---

## Чеклист самопроверки

- [ ] DefectDojo развёрнут и доступен
- [ ] Product/Engagement/Tests структура создана
- [ ] Все отчёты из этапов 1–4 импортированы (12+ файлов)
- [ ] Дедупликация: подсчитаны уникальные findings
- [ ] SLA настроен (Critical ≤ 1 день, High ≤ 7 дней)
- [ ] Workflow пройден для 5 findings (Active → Verified → Mitigated/Closed)
- [ ] 2 findings отмечены как False Positive
- [ ] API-импорт скрипт работает
- [ ] `defectdojo-setup.md` заполнен с метриками

---

Далее → [`../quality-gates/`](../quality-gates/)
