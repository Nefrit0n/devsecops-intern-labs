# Сравнение SCA-инструментов на Juice Shop · Эталонное решение

## Сводка

| Метрика | npm audit | Trivy (fs) | Trivy (image) | Dep-Check | Grype |
|---------|-----------|------------|---------------|-----------|-------|
| CVE всего | ~35 | ~60 | ~180 | ~45 | ~55 |
| CRITICAL | ~3 | ~5 | ~15 | ~4 | ~5 |
| HIGH | ~12 | ~18 | ~40 | ~15 | ~16 |
| MEDIUM | ~15 | ~25 | ~80 | ~18 | ~22 |
| LOW | ~5 | ~12 | ~45 | ~8 | ~12 |
| False Positives | Низко | Низко | Низко (OS CVE реальны) | ~5 (CPE mismatch) | Низко |
| Время скана | ~3 сек | ~15 сек | ~45 сек | ~2 мин | ~10 сек |
| Уникальные CVE | ~2 | ~8 | ~120 (OS pkgs) | ~5 (CPE-based) | ~3 |

> Trivy image показывает больше CVE, потому что сканирует OS-пакеты (apt/apk) в базовом образе.

## Top-5 критичных CVE (пример)

| CVE ID | Пакет | Версия | CVSS | Описание | Есть fix? | Решение |
|--------|-------|--------|------|----------|-----------|---------|
| CVE-2024-XXXXX | jsonwebtoken | 8.x | 9.8 | JWT signature bypass | ✓ (9.0.2) | **update** — критичная auth-уязвимость |
| CVE-2023-YYYYY | express | 4.17.x | 7.5 | ReDoS в path parsing | ✓ (4.18.3) | **update** — доступен патч |
| CVE-2024-ZZZZZ | sanitize-html | 2.x | 8.2 | XSS bypass | ✓ (2.12.1) | **update** — блокер по T-02 |
| CVE-2023-AAAAA | node:18-alpine (zlib) | 1.2.x | 7.0 | Buffer overflow | ✓ (alpine 3.19) | **update base image** |
| CVE-2023-BBBBB | lodash | 4.17.20 | 7.4 | Prototype pollution | ✓ (4.17.21) | **update** — one-liner fix |

> *Конкретные CVE ID зависят от версии Juice Shop. Формат решений — универсальный.*

## Рекомендуемая комбинация

- **В CI (каждый PR):** `npm audit --audit-level=critical` (3 сек) + `trivy fs --severity CRITICAL,HIGH` (15 сек)
- **Для аудита:** OWASP Dependency-Check с HTML-отчётом (для аудитора)
- **Для мониторинга:** Grype через SBOM (Syft) → Dependency-Track (непрерывный)
- **Для Docker-образов:** `trivy image` (OS + app зависимости в одном скане)
