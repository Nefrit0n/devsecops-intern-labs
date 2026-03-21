# Чеклист · Этап 4 — Инфраструктура

**Процессы ГОСТа:** 5.3 (управление ИТ-инфраструктурой), 5.4 (управление конфигурацией)

---

## Модуль 4.1 — Container Security

**Trivy image:**
- [ ] Полный скан образа Juice Shop
- [ ] Разделены OS-пакеты vs app-зависимости
- [ ] Base image comparison (alpine vs slim vs full)
- [ ] .trivyignore создан с обоснованием

**Grype:**
- [ ] Прямой скан + через SBOM
- [ ] Сравнение с Trivy: уникальные findings

**Dockle:**
- [ ] CIS Docker Benchmark checks выполнены
- [ ] Связь с hadolint (этап 1): Dockerfile vs built image

**Docker Scout:**
- [ ] Рекомендации по base image получены

**Hardened image:**
- [ ] Hardened Dockerfile создан (non-root, minimal base, healthcheck)
- [ ] Все инструменты перепроверены на hardened image
- [ ] `container-comparison.md` с original vs hardened

**Пункты ГОСТа:** 5.3.2 (безопасность инфраструктуры), 5.4.2 (контроль конфигурации)

---

## Модуль 4.2 — IaC Security

**Checkov:**
- [ ] Скан Dockerfile + K8s манифестов
- [ ] Кастомная Python-политика создана
- [ ] Suppression с обоснованием

**KICS:**
- [ ] Скан тех же файлов, сравнение с Checkov

**Trivy config:**
- [ ] Скан, сравнение с Checkov и KICS

**KubeLinter:**
- [ ] Быстрый lint K8s манифестов

**Hardened manifests:**
- [ ] Исправленные K8s манифесты: 0 FAILED
- [ ] `iac-comparison.md` заполнен

**Пункты ГОСТа:** 5.3.2 (безопасность инфраструктуры)

---

## Модуль 4.3 — Kubernetes Security

**Kubescape:**
- [ ] Три фреймворка: CIS, NSA-CISA, MITRE ATT&CK
- [ ] Risk scores зафиксированы

**kube-bench:**
- [ ] CIS Kubernetes Benchmark: PASS/FAIL для всех компонентов
- [ ] Сравнение с Kubescape

**Falco:**
- [ ] Установлен в кластер
- [ ] 3+ alerts triggered через K8s Goat
- [ ] Кастомное правило создано

**Kyverno:**
- [ ] 3 политики: deny-privileged, require-limits, deny-latest
- [ ] Enforce mode: небезопасный деплой → rejected

**Сравнение:**
- [ ] `k8s-comparison.md` заполнен

**Пункты ГОСТа:** 5.3.2 (безопасность ИТ-инфраструктуры)

---

## Итоговый артефакт

- [ ] `stage-4-summary.md` содержит:
  - Defense in depth: все слои (Dockerfile → Image → IaC → Cluster → Runtime)
  - Hardened Dockerfile: % уменьшения CVE
  - Hardened K8s manifests: 0 FAILED
  - K8s Goat: сколько сценариев задетектили
  - Маппинг к требованиям из этапа 0

---

✅ Всё выполнено? → [Этап 5 · Собираем пайплайн](../stage-5-pipeline-integration/)
