# Задания · Модуль 2.3 — License audit

---

## Задание 1 · Trivy license: быстрый чек
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
# Скан лицензий
trivy fs targets/juice-shop/src --scanners license --format json \
  --output stage-2-dependencies/license-audit/trivy-license-report.json

# Человекочитаемый формат
trivy fs targets/juice-shop/src --scanners license

# Только проблемные (не permissive)
trivy fs targets/juice-shop/src --scanners license --severity HIGH,CRITICAL
```

Запишите:
- Сколько уникальных лицензий в проекте?
- Есть ли copyleft (GPL, AGPL, LGPL)?
- Есть ли пакеты без лицензии (UNKNOWN)?

---

## Задание 2 · ScanCode Toolkit: глубокий анализ
**Тег:** 🟢 практика · **Время:** ~1 ч

```bash
# Полный скан (может занять 10–20 минут на Juice Shop)
scancode --license --json-pp stage-2-dependencies/license-audit/scancode-report.json targets/juice-shop/src

# Быстрый скан (только top-level)
scancode --license --max-depth 2 --json-pp scancode-quick.json targets/juice-shop/src
```

### Зачем ScanCode, если есть Trivy license?

ScanCode ищет лицензии **внутри файлов**, а не только в manifest:
- Заголовки `/* Licensed under GPL-3.0 */` внутри .js файлов
- README.md файлы зависимостей с упоминанием лицензии
- Двойное лицензирование (MIT OR GPL-2.0)
- Файлы без лицензии, которые копируют код из GPL-проектов

Исследуйте отчёт:
1. Найдите пакеты, где ScanCode обнаружил лицензию **внутри файла**, а manifest говорит другое
2. Найдите файлы с двойным лицензированием
3. Есть ли файлы с embedded copyright notice, но без явной лицензии?

Запишите что нашёл ScanCode, чего нет в Trivy — добавьте в `license-report.md`.

---

## Задание 3 · license_finder: политика лицензий
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Установка и запуск

```bash
# Через Docker (проще)
docker run --rm -v $(pwd)/targets/juice-shop/src:/app licensefinder/license_finder

# Или через gem
gem install license_finder
cd targets/juice-shop/src && license_finder
```

### Шаг 2: Лицензионная политика

Создайте `configs/license-policy.yml`:

```yaml
# Whitelist — разрешённые лицензии
whitelist:
  - MIT
  - Apache-2.0
  - BSD-2-Clause
  - BSD-3-Clause
  - ISC
  - 0BSD
  - Unlicense

# Blacklist — запрещённые (блокируют CI)
blacklist:
  - GPL-2.0-only
  - GPL-2.0-or-later
  - GPL-3.0-only
  - GPL-3.0-or-later
  - AGPL-3.0-only
  - AGPL-3.0-or-later

# Всё остальное — review required
```

```bash
# Применить whitelist
license_finder whitelist add MIT Apache-2.0 BSD-2-Clause BSD-3-Clause ISC

# Проверить: какие пакеты не проходят?
license_finder action_items
```

### Шаг 3: Approval workflow

Для пакетов с лицензиями, не попавшими ни в whitelist, ни в blacklist:

```bash
# Одобрить конкретный пакет вручную (с обоснованием)
license_finder approval add express-rate-limit --why "LGPL-2.1, используем как библиотеку, не модифицируем"
```

### Шаг 4: CI-интеграция

```bash
# Exit code 1 если есть нарушения — используется как quality gate
license_finder --quiet
echo "Exit code: $?"
```

Если exit code = 1, CI должен упасть. Это quality gate для лицензий.

---

## Задание 4 · Сводный отчёт по лицензиям
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `license-report.md`:

```markdown
# Отчёт по лицензиям · Juice Shop

## Сводка лицензий

| Лицензия | Тип | Количество пакетов | Решение |
|----------|-----|--------------------|---------| 
| MIT | Permissive | ___ | Whitelist |
| Apache-2.0 | Permissive | ___ | Whitelist |
| ISC | Permissive | ___ | Whitelist |
| BSD-3-Clause | Permissive | ___ | Whitelist |
| GPL-2.0 | Strong copyleft | ___ | Blacklist / Review |
| UNKNOWN | Нет лицензии | ___ | Review required |

## Проблемные зависимости

| Пакет | Версия | Лицензия | Риск | Решение |
|-------|--------|----------|------|---------|
| | | | | approve / replace / remove |

## Что нашёл ScanCode, но пропустил Trivy
- ...

## Лицензионная политика
- Whitelist: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC
- Blacklist: GPL-2.0+, GPL-3.0+, AGPL-3.0+
- Review: всё остальное

## CI quality gate
- license_finder exit code = ___ (0 = pass, 1 = fail)
- Количество action items: ___
```

---

## Артефакты

🟡 Итоговые файлы:
- `license-audit/trivy-license-report.json`
- `license-audit/scancode-report.json`
- `license-audit/configs/license-policy.yml`
- `license-audit/license-report.md`

---

## Чеклист самопроверки

- [ ] Trivy license: скан выполнен, подсчитаны уникальные лицензии
- [ ] ScanCode: глубокий скан, найдены embedded лицензии
- [ ] ScanCode vs Trivy: определены различия
- [ ] license_finder: whitelist и blacklist настроены
- [ ] license_finder: action_items для пограничных случаев
- [ ] Approval workflow: хотя бы 1 пакет одобрен с обоснованием
- [ ] CI quality gate: проверен exit code
- [ ] `license-report.md` заполнен с решениями по каждой проблеме

---

🏁 **Этап 2 завершён!**

Создайте `stage-2-summary.md`:
- Сколько **уязвимых зависимостей** найдено? Top-5 критичных с решениями.
- **SBOM** сгенерирован, загружен в Dependency-Track, политики настроены.
- **Лицензионных нарушений**: сколько, какие решения приняты.
- Какие **требования из этапа 0** теперь закрыты композиционным анализом?
- Какие **НЕ закрыты** (нужен DAST, пентест)?

Итоговый чеклист: [`../../checklists/stage-2-checklist.md`](../../checklists/stage-2-checklist.md)

Переходите к [Этапу 3 → Атакуем приложение](../../stage-3-dynamic-analysis/)
