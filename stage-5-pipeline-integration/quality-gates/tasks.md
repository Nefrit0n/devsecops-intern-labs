# Задания · Модуль 5.3 — Quality Gates

---

## Задание 1 · Quality gate скрипт
**Тег:** 🟢 практика · **Время:** ~1 ч

Создайте `scripts/quality-gate.py`:

```python
#!/usr/bin/env python3
"""
Quality Gate: pass/fail на основе требований безопасности.
Парсит SARIF/JSON отчёты и применяет правила.

Exit code 0 = PASS, 1 = FAIL
"""
import json
import sys
from pathlib import Path

class QualityGate:
    def __init__(self):
        self.blockers = []
        self.warnings = []

    def check_sarif(self, path, tool_name, max_critical=0, max_high=5):
        """Проверяет SARIF-отчёт на превышение порогов."""
        if not Path(path).exists():
            self.warnings.append(f"{tool_name}: отчёт не найден ({path})")
            return

        with open(path) as f:
            data = json.load(f)

        critical = high = medium = 0
        for run in data.get("runs", []):
            for result in run.get("results", []):
                level = result.get("level", "warning")
                if level == "error":
                    critical += 1
                elif level == "warning":
                    high += 1
                else:
                    medium += 1

        if critical > max_critical:
            self.blockers.append(
                f"{tool_name}: {critical} CRITICAL (max: {max_critical})"
            )
        if high > max_high:
            self.warnings.append(
                f"{tool_name}: {high} HIGH (max: {max_high})"
            )

    def check_trivy_json(self, path, max_critical=0):
        """Проверяет Trivy JSON-отчёт."""
        if not Path(path).exists():
            self.warnings.append(f"Trivy: отчёт не найден ({path})")
            return

        with open(path) as f:
            data = json.load(f)

        critical = 0
        for result in data.get("Results", []):
            for vuln in result.get("Vulnerabilities", []):
                if vuln.get("Severity") == "CRITICAL":
                    critical += 1

        if critical > max_critical:
            self.blockers.append(f"Trivy: {critical} CRITICAL CVE (max: {max_critical})")

    def report(self):
        """Выводит результат и возвращает exit code."""
        print("=" * 60)
        print("  QUALITY GATE REPORT")
        print("=" * 60)

        if self.blockers:
            print("\n🛑 BLOCKERS (pipeline FAIL):")
            for b in self.blockers:
                print(f"  - {b}")

        if self.warnings:
            print("\n⚠️  WARNINGS:")
            for w in self.warnings:
                print(f"  - {w}")

        if not self.blockers and not self.warnings:
            print("\n✅ All checks passed!")

        if self.blockers:
            print(f"\n❌ QUALITY GATE: FAIL ({len(self.blockers)} blockers)")
            return 1
        else:
            print(f"\n✅ QUALITY GATE: PASS")
            return 0

if __name__ == "__main__":
    qg = QualityGate()

    # SAST
    qg.check_sarif("semgrep-report.sarif", "Semgrep", max_critical=0, max_high=3)
    qg.check_sarif("njsscan-report.sarif", "njsscan", max_critical=0, max_high=5)

    # SCA
    qg.check_trivy_json("trivy-fs-report.json", max_critical=0)

    # Container
    qg.check_trivy_json("trivy-image-report.json", max_critical=0)

    sys.exit(qg.report())
```

Протестируйте на отчётах из этапов 1–4. Exit code = 0 или 1?

---

## Задание 2 · Маппинг: требования → findings → status
**Тег:** 🟢 практика · **Время:** ~1 ч

Откройте ваш `security-requirements.md` из этапа 0. Для **каждого** требования определите текущий статус:

Создайте `requirements-coverage.md`:

```markdown
# Requirements Coverage Report

## Покрытие требований безопасности

| ID | Требование | Инструмент | Finding (если есть) | Status |
|----|-----------|------------|--------------------|---------| 
| S-01 | JWT проверка на каждом endpoint | ZAP auth scan | ZAP-2024-001 | ❌ FAIL |
| T-01 | Параметризованные SQL-запросы | Semgrep rule sql-injection | SEMGREP-042 | ❌ FAIL |
| T-02 | Санитизация пользовательского ввода | njsscan | NJSSCAN-015 | ❌ FAIL |
| I-01 | Нет stack trace в production | ZAP | Не найден | ✅ PASS |
| I-02 | Нет секретов в коде | Gitleaks | GL-003, GL-007 | ❌ FAIL |
| D-01 | Контейнер не от root | Dockle CIS-DI-0001 | DOCKLE-001 | ❌ FAIL → ✅ (hardened) |
| ... | ... | ... | ... | ... |

## Сводка

| Приоритет | Всего | PASS | FAIL | Coverage |
|-----------|-------|------|------|----------|
| 🔴 Блокер | ___ | ___ | ___ | ___% |
| 🟡 Важно | ___ | ___ | ___ | ___% |
| 🟢 Рекомендация | ___ | ___ | ___ | ___% |
| **Итого** | ___ | ___ | ___ | **___**% |

## Gaps — что не покрыто ни одним инструментом
- ...
```

> **Это ключевой артефакт всего курса.** Он показывает трассируемость от угрозы до проверки — именно это спрашивает аудитор по ГОСТу.

---

## Задание 3 · Метрики безопасности
**Тег:** 🟡 артефакт · **Время:** ~1 ч

Создайте `security-metrics.md`:

```markdown
# Security Metrics · Juice Shop DevSecOps Pipeline

## KPI пайплайна

| Метрика | Значение | Target | Status |
|---------|----------|--------|--------|
| MTTD (Mean Time To Detect) | ___ | < 24 ч | ✅/❌ |
| MTTR Critical | ___ | < 1 день | |
| MTTR High | ___ | < 7 дней | |
| False Positive Rate | ___% | < 20% | |
| Requirements Coverage | ___% | > 80% | |
| Quality Gate Pass Rate | ___% | > 90% | |

## По инструментам

| Инструмент | True Positives | False Positives | FP Rate | Unique Findings |
|-----------|----------------|-----------------|---------|-----------------|
| Semgrep | | | | |
| Trivy | | | | |
| ZAP | | | | |
| ... | | | | |

## Effectiveness: SAST vs DAST vs SCA

| Тип | Findings | TP | FP Rate | Unique (не нашли другие) |
|-----|----------|----|---------|-------------------------|
| SAST (этап 1) | | | | |
| SCA (этап 2) | | | | |
| DAST (этап 3) | | | | |
| Container/IaC (этап 4) | | | | |

## Trend (если запускали несколько раз)
- Скан 1 (дата): ___ findings
- Скан 2 (дата): ___ findings (после fix)
- Дельта: ___

## Рекомендации по улучшению
1. ...
2. ...
3. ...
```

---

## Чеклист самопроверки

- [ ] quality-gate.py: парсит SARIF/JSON, возвращает exit code 0/1
- [ ] Quality gate протестирован на реальных отчётах
- [ ] requirements-coverage.md: каждое требование из этапа 0 → status
- [ ] Coverage: посчитан % покрытых требований
- [ ] Gaps: определено что не покрыто ни одним инструментом
- [ ] security-metrics.md: MTTD, MTTR, FP rate, coverage
- [ ] По инструментам: определены TP, FP, unique findings

---

Далее → [`../supply-chain/`](../supply-chain/)
