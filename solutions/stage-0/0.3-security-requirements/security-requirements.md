# Требования безопасности · Juice Shop · Эталонное решение

## S — Spoofing

| ID | Требование | Угроза | Инструмент | Правило | Этап | Pass/Fail | Приоритет |
|----|-----------|--------|------------|---------|------|-----------|-----------|
| S-01 | Backend ДОЛЖЕН проверять JWT-подпись и срок действия на каждом защищённом эндпоинте | STRIDE #1 | Semgrep + ZAP auth scan | semgrep: jwt-no-verify | CI (SAST) + DAST | 0 findings ERROR | 🔴 Блокер |
| S-02 | Форма логина ДОЛЖНА иметь rate limiting (≤5 попыток / мин / IP) | STRIDE #4 | ZAP + Postman | ZAP: bruteforce test | DAST | Rate limit активен | 🔴 Блокер |
| S-03 | /redirect ДОЛЖЕН принимать только домены из whitelist | STRIDE #8 | Nuclei + Semgrep | nuclei: open-redirect | DAST | 0 open redirects | 🟡 Важно |

## T — Tampering

| ID | Требование | Угроза | Инструмент | Правило | Этап | Pass/Fail | Приоритет |
|----|-----------|--------|------------|---------|------|-----------|-----------|
| T-01 | Все SQL-запросы ДОЛЖНЫ использовать параметризованные выражения (Sequelize ORM) | STRIDE #2 | Semgrep | javascript.sequelize.security | CI (SAST) | 0 findings sql-injection | 🔴 Блокер |
| T-02 | Frontend НЕ ДОЛЖЕН вставлять user input в DOM без DOMPurify санитизации | STRIDE #3 | njsscan + ZAP | njsscan: xss rules, ZAP: XSS active | SAST + DAST | 0 XSS findings | 🔴 Блокер |
| T-03 | Backend ДОЛЖЕН валидировать Content-Type и размер загружаемых файлов | STRIDE #7 | ZAP + Postman | Manual test: upload .php | DAST | Reject non-image files | 🟡 Важно |
| T-04 | Все state-changing операции ДОЛЖНЫ иметь CSRF protection | STRIDE #5 | ZAP | ZAP: absence of anti-CSRF | DAST | 0 CSRF findings | 🟡 Важно |

## R — Repudiation

| ID | Требование | Угроза | Инструмент | Правило | Этап | Pass/Fail | Приоритет |
|----|-----------|--------|------------|---------|------|-----------|-----------|
| R-01 | Backend ДОЛЖЕН логировать все auth-события (login, logout, failed attempts) с user_id и IP | STRIDE #9 | Ручной review | Code review checklist | Review | Логи содержат user_id+IP | 🟡 Важно |
| R-02 | Логи НЕ ДОЛЖНЫ содержать sensitive data (пароли, токены, PII) | STRIDE #9 | Semgrep | semgrep: logging-sensitive-data | SAST | 0 findings | 🟡 Важно |

## I — Information Disclosure

| ID | Требование | Угроза | Инструмент | Правило | Этап | Pass/Fail | Приоритет |
|----|-----------|--------|------------|---------|------|-----------|-----------|
| I-01 | Backend НЕ ДОЛЖЕН возвращать stack trace в HTTP-ответах 4xx/5xx | STRIDE #6 | ZAP + Nuclei | ZAP: info disclosure, Nuclei: stacktrace | DAST | 0 stack trace findings | 🔴 Блокер |
| I-02 | Исходный код НЕ ДОЛЖЕН содержать hardcoded пароли, API-ключи, токены | STRIDE #12 | Gitleaks + TruffleHog | Gitleaks default + custom rules | CI (secrets) | 0 findings | 🔴 Блокер |
| I-03 | HTTP-ответы ДОЛЖНЫ содержать security headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options | STRIDE #1 | Nuclei + ZAP | nuclei: -tags headers | DAST | Все headers present | 🟡 Важно |
| I-04 | /ftp, /encryptionkeys, /metrics НЕ ДОЛЖНЫ быть доступны без аутентификации | STRIDE #11 | ffuf + Nikto | ffuf: directory discovery | DAST | 403 на скрытых путях | 🟡 Важно |

## D — Denial of Service

| ID | Требование | Угроза | Инструмент | Правило | Этап | Pass/Fail | Приоритет |
|----|-----------|--------|------------|---------|------|-----------|-----------|
| D-01 | Docker-контейнер НЕ ДОЛЖЕН запускаться от root | STRIDE #10 | Dockle + Checkov | Dockle CIS-DI-0001, Checkov CKV_K8S_6 | Container + IaC | USER ≠ root | 🔴 Блокер |
| D-02 | K8s deployment ДОЛЖЕН иметь resource limits (CPU + memory) | — | KubeLinter + Checkov | CKV_K8S_11, CKV_K8S_13 | IaC | Limits set | 🟡 Важно |

## E — Elevation of Privilege

| ID | Требование | Угроза | Инструмент | Правило | Этап | Pass/Fail | Приоритет |
|----|-----------|--------|------------|---------|------|-----------|-----------|
| E-01 | /api/Users/{id} ДОЛЖЕН проверять что запрашиваемый ресурс принадлежит текущему пользователю | STRIDE #5 | Postman (BOLA test) | Manual test: access other user's data | DAST (API) | 403 для чужого ресурса | 🔴 Блокер |
| E-02 | Admin-эндпоинты ДОЛЖНЫ проверять роль server-side (не только client-side) | STRIDE #11 | Postman + ZAP | Manual: call admin endpoint with user token | DAST (API) | 403 для non-admin | 🟡 Важно |
| E-03 | K8s pod НЕ ДОЛЖЕН запускаться с privileged: true | — | Checkov + Kyverno | CKV_K8S_1, Kyverno deny-privileged | IaC + Admission | Pod rejected | 🔴 Блокер |

## Итог

- Всего требований: 18
- Покрытие: S(3) T(4) R(2) I(4) D(2) E(3)
- 🔴 Блокеров: 8 · 🟡 Важных: 10 · 🟢 Рекомендаций: 0
