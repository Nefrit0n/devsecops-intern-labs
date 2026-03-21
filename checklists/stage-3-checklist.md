# Чеклист · Этап 3 — Атакуем приложение

**Процессы ГОСТа:** 5.11 (динамический анализ), 5.12 (функциональное тестирование), 5.13 (нефункциональное тестирование)

---

## Модуль 3.1 — DAST

**ZAP:**
- [ ] Baseline scan (passive) выполнен
- [ ] Full active scan выполнен, findings проанализированы
- [ ] API scan через OpenAPI import
- [ ] Automation Framework YAML создан (готов для CI)

**Nuclei:**
- [ ] Скан с community templates выполнен
- [ ] Security headers check
- [ ] Написаны 2 кастомных YAML-шаблона

**Nikto:**
- [ ] Серверные мисконфигурации найдены
- [ ] Определены уникальные findings (не ZAP, не Nuclei)

**Wapiti:**
- [ ] Crawl + inject выполнен
- [ ] Сравнение глубины crawl с ZAP

**Сравнение + корреляция:**
- [ ] `dast-comparison.md` заполнен
- [ ] Таблица корреляции DAST↔SAST: совпадения и расхождения

**Пункты ГОСТа:** 5.11.2 (проведение динамического анализа), 5.11.3 (свидетельства)

---

## Модуль 3.2 — Fuzzing

**RESTler:**
- [ ] Compile → test → fuzz-lean → fuzz выполнены
- [ ] 500-е ошибки найдены и задокументированы
- [ ] Checkers: resource leaks, use-after-free

**Schemathesis:**
- [ ] Property-based тесты: schema + status code conformance
- [ ] Stateful mode с цепочками запросов
- [ ] Сравнение с RESTler

**ffuf:**
- [ ] Directory fuzzing: скрытые эндпоинты найдены
- [ ] Parameter fuzzing: спецсимволы, 500-е ошибки
- [ ] Использован кастомный wordlist из attack surface (этап 0)

**Сравнение:**
- [ ] `fuzzing-comparison.md` заполнен

**Пункты ГОСТа:** 5.13.2 (фаззинг-тестирование), 5.13.3 (свидетельства)

---

## Модуль 3.3 — API Security

**Postman:**
- [ ] Коллекция OWASP API Top 10 создана
- [ ] Тесты: BOLA, broken auth, excessive data, BFLA, mass assignment
- [ ] Newman CLI-прогон выполнен

**Dredd:**
- [ ] Contract testing выполнен
- [ ] Найдены extra fields и/или undocumented endpoints

**CATS:**
- [ ] Все категории fuzzers (security, contract, auth, boundary)
- [ ] Определено что нашёл CATS, а Postman нет (и наоборот)

**OWASP API Top 10:**
- [ ] Coverage table заполнена
- [ ] Определены gaps — что не покрыто ни одним инструментом

**Пункты ГОСТа:** 5.12.2 (функциональное тестирование), 5.12.3 (свидетельства)

---

## Итоговый артефакт

- [ ] `stage-3-summary.md` содержит:
  - Корреляция DAST↔SAST: что нашёл только DAST, только SAST
  - Уникальные findings каждого слоя
  - OWASP API Top 10 coverage
  - Какие требования из этапа 0 полностью закрыты
  - Какие требования остались открытыми

---

✅ Всё выполнено? → [Этап 4 · Инфраструктура](../stage-4-infrastructure/)
