# Задания · Модуль 2.2 — SBOM

---

## Задание 1 · Syft: генерация SBOM
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: SBOM из исходного кода

```bash
# CycloneDX формат
syft dir:targets/juice-shop/src -o cyclonedx-json > stage-2-dependencies/sbom/juice-shop-sbom.cdx.json

# SPDX формат (из того же кода)
syft dir:targets/juice-shop/src -o spdx-json > stage-2-dependencies/sbom/juice-shop-sbom.spdx.json

# Табличный вид (для быстрого просмотра)
syft dir:targets/juice-shop/src -o table
```

Запишите:
- Сколько пакетов в SBOM?
- Какие экосистемы обнаружены? (npm, pip, go…)
- Есть ли пакеты без версии?

### Шаг 2: SBOM из Docker-образа

```bash
syft image:bkimminich/juice-shop -o cyclonedx-json > stage-2-dependencies/sbom/juice-shop-image-sbom.cdx.json
```

Сравните два SBOM (из кода vs из образа):
- В образе больше пакетов? (OS-пакеты: apt, apk)
- Есть ли расхождения в версиях npm-пакетов?

### Шаг 3: Передача SBOM в Grype

```bash
# Vulnerability scan по SBOM — это уже модуль 2.1, но важно увидеть связку
grype sbom:stage-2-dependencies/sbom/juice-shop-sbom.cdx.json
```

Вот **архитектурная связка**, которую нужно понять:
```
Syft (SBOM) → Grype (vuln scan) → DefectDojo (management)
```
SBOM генерируется один раз, а сканируется многократно — при каждой новой CVE.

### Шаг 4: Сравнение CycloneDX vs SPDX

Откройте оба файла. Обратите внимание:
- CycloneDX: секция `vulnerabilities` (может быть пустой, зависит от настройки)
- SPDX: секция `packages[].licenseConcluded`
- Размер файлов: какой больше?
- Структура: какой легче парсить скриптом?

Запишите наблюдения в `sbom-comparison.md`.

---

## Задание 2 · cdxgen: глубокий CycloneDX
**Тег:** 🟢 практика · **Время:** ~45 мин

```bash
cd targets/juice-shop/src

# Генерация CycloneDX SBOM
cdxgen -o ../../../stage-2-dependencies/sbom/juice-shop-sbom-cdxgen.json

# С типом проекта (более точный анализ)
cdxgen -t javascript -o ../../../stage-2-dependencies/sbom/juice-shop-sbom-cdxgen-typed.json
```

### Сравнение с Syft

| Метрика | Syft | cdxgen |
|---------|------|--------|
| Пакетов всего | | |
| Direct dependencies | | |
| Transitive dependencies | | |
| Пакеты без версии | | |
| Время генерации | | |

cdxgen — официальный инструмент OWASP CycloneDX. Он часто находит больше transitive зависимостей, чем Syft, особенно для Node.js-проектов.

---

## Задание 3 · Dependency-Track: платформа управления SBOM
**Тег:** 🟢 практика · **Время:** ~1.5 ч

### Шаг 1: Запуск

Создайте `configs/dependency-track-compose.yml`:

```yaml
services:
  dtrack-apiserver:
    image: dependencytrack/apiserver
    ports:
      - "8081:8080"
    volumes:
      - dtrack-data:/data
    environment:
      ALPINE_DATABASE_MODE: external
      ALPINE_DATABASE_URL: jdbc:h2:/data/dtrack

  dtrack-frontend:
    image: dependencytrack/frontend
    ports:
      - "8082:8080"
    environment:
      API_BASE_URL: http://localhost:8081

volumes:
  dtrack-data:
```

```bash
docker compose -f configs/dependency-track-compose.yml up -d
# Подождите ~2 минуты на инициализацию
# Откройте http://localhost:8082
# Login: admin / admin (сменить при первом входе)
```

### Шаг 2: Импорт SBOM

1. Создайте проект «Juice Shop» в интерфейсе
2. Загрузите SBOM из Syft (CycloneDX JSON)
3. Загрузите SBOM из cdxgen
4. Посмотрите дашборд:
   - Risk Score проекта
   - Количество уязвимых компонентов
   - Разбивка по severity

### Шаг 3: Политики

Настройте политику:
- **BLOCK** на CRITICAL CVE с CVSS ≥ 9.0
- **WARN** на HIGH CVE
- **INFO** на MEDIUM

### Шаг 4: Мониторинг

Dependency-Track автоматически проверяет новые CVE по загруженным SBOM. Это значит: вы загрузили SBOM сегодня, а через неделю вышла новая CVE в одном из ваших пакетов — Dependency-Track уведомит.

Запишите: чем Dependency-Track отличается от простого запуска Trivy? (Ответ: Trivy — разовый скан, DTrack — непрерывный мониторинг.)

---

## Артефакты

🟡 Итоговые файлы:
- `sbom/juice-shop-sbom.cdx.json` (Syft, CycloneDX)
- `sbom/juice-shop-sbom.spdx.json` (Syft, SPDX)
- `sbom/juice-shop-sbom-cdxgen.json` (cdxgen)
- `sbom/sbom-comparison.md`
- `sbom/configs/dependency-track-compose.yml`

---

## Чеклист самопроверки

- [ ] Syft: SBOM из кода И из Docker-образа
- [ ] Syft: экспорт в CycloneDX И SPDX
- [ ] SBOM передан в Grype — связка «генератор + сканер» работает
- [ ] cdxgen: SBOM сгенерирован, сравнён с Syft
- [ ] Dependency-Track: поднят, SBOM импортирован
- [ ] Dependency-Track: политики настроены (BLOCK/WARN/INFO)
- [ ] Понимаю разницу: разовый скан vs непрерывный мониторинг
- [ ] `sbom-comparison.md` заполнен

---

Далее → [`../license-audit/`](../license-audit/)
