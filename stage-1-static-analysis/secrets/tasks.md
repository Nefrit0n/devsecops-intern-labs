# Задания · Модуль 1.2 — Secrets

---

## Задание 1 · Gitleaks: pre-commit + history scan
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Скан Git history

```bash
cd targets/juice-shop/src
gitleaks detect --source . --report-format json --report-path ../../../stage-1-static-analysis/secrets/gitleaks-report.json
```

Изучите отчёт:
- Сколько секретов найдено?
- В каких файлах? В каких коммитах?
- Есть ли секреты, которые были *удалены* из текущей версии, но остались в истории?

### Шаг 2: Pre-commit hook

Настройте Gitleaks как pre-commit hook. Создайте `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks
```

Проверьте: создайте тестовый файл с фейковым ключом и попробуйте закоммитить:

```bash
echo 'AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"' > test-secret.txt
git add test-secret.txt
git commit -m "test"  # Должен быть заблокирован!
rm test-secret.txt
```

### Шаг 3: Кастомная конфигурация

Создайте `configs/.gitleaks.toml`:

```toml
[extend]
useDefault = true

[[rules]]
id = "juice-shop-admin-password"
description = "Hardcoded admin password for Juice Shop"
regex = '''(?i)(admin|root).*(?:password|passwd|pwd)\s*[=:]\s*['"][^'"]{4,}['"]'''
tags = ["password", "juice-shop"]

[allowlist]
paths = [
  '''test/.*''',
  '''.*_test\.js''',
  '''.*\.md''',
]
```

Запустите с этим конфигом:
```bash
gitleaks detect --source . --config configs/.gitleaks.toml
```

Что изменилось? Больше findings или меньше?

### Шаг 4: SARIF-экспорт

```bash
gitleaks detect --source . --report-format sarif --report-path gitleaks-report.sarif
```

> Этот файл понадобится на этапе 5, когда вы будете импортировать результаты в DefectDojo.

---

## Задание 2 · TruffleHog: глубокий скан + верификация
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Скан репозитория

```bash
trufflehog git file://./targets/juice-shop/src --json > stage-1-static-analysis/secrets/trufflehog-report.json
```

### Шаг 2: Верификация секретов

TruffleHog умеет проверять, что найденный секрет **ещё активен**:

```bash
trufflehog git file://./targets/juice-shop/src --only-verified
```

Это киллер-фича. Gitleaks скажет «вот API-ключ». TruffleHog скажет «вот API-ключ, и он **работает** прямо сейчас».

Запишите:
- Сколько секретов verified vs unverified?
- Какие типы секретов TruffleHog классифицировал? (AWS, GitHub, Slack…)

### Шаг 3: Скан Docker-образа

TruffleHog может сканировать не только Git, но и Docker images:

```bash
trufflehog docker --image bkimminich/juice-shop --json
```

Нашёл ли он секреты *внутри контейнера*, которых нет в исходном коде?

### Шаг 4: Сравнение с Gitleaks

Что TruffleHog нашёл, а Gitleaks пропустил? И наоборот? Добавьте наблюдения в `secrets-comparison.md`.

---

## Задание 3 · detect-secrets: baseline-подход
**Тег:** 🟢 практика · **Время:** ~45 мин

### Шаг 1: Создание baseline

```bash
cd targets/juice-shop/src
detect-secrets scan > ../../../stage-1-static-analysis/secrets/detect-secrets-baseline.json
```

Baseline — это «снимок» всех текущих секретов. Идея: вы *принимаете* существующие (потом разберётесь) и ловите только *новые*.

### Шаг 2: Аудит baseline

```bash
detect-secrets audit detect-secrets-baseline.json
```

Для каждого finding detect-secrets спросит: «Это настоящий секрет?» — и вы отвечаете y/n. Это **ручная разметка** — важный процесс для легаси-кодовых баз.

### Шаг 3: Проверка новых секретов

```bash
# Добавьте фейковый секрет
echo 'SLACK_TOKEN="xoxb-fake-token-12345"' >> some-file.js

# Проверьте относительно baseline — должен поймать только НОВЫЙ
detect-secrets scan --baseline detect-secrets-baseline.json
```

### Шаг 4: Сравнение трёх инструментов

Заполните `secrets-comparison.md`:

```markdown
# Сравнение инструментов поиска секретов

| Метрика | Gitleaks | TruffleHog | detect-secrets |
|---------|----------|------------|----------------|
| Findings всего | | | |
| Verified (активные) | N/A | | N/A |
| Уникальные типы секретов | | | |
| False Positives (из 10) | | | |
| Скан Git history | ✓ | ✓ | ✗ (только текущий) |
| Скан Docker images | ✗ | ✓ | ✗ |
| Pre-commit hook | ✓ (быстрый) | ✗ (медленный) | ✓ |
| Baseline-подход | ✗ | ✗ | ✓ |
| Время скана | | | |

## Вывод: когда какой использовать
- **Gitleaks** — ...
- **TruffleHog** — ...
- **detect-secrets** — ...

## Рекомендуемая комбинация
...
```

---

## Задание 4 · WrongSecrets: секреты на разных уровнях
**Тег:** 🟢 практика · **Время:** ~30 мин

Откройте WrongSecrets на http://localhost:8080. Пройдите первые 5-7 заданий:

- Challenge 1-3: секреты в исходном коде (самые простые)
- Challenge 4-5: секреты в конфигурации и переменных окружения
- Challenge 6-7: секреты в Docker-образе

Для каждого запишите: **каким инструментом** из тех, что вы изучили, можно было бы найти этот секрет автоматически? Есть ли секреты, которые *ни один* инструмент не нашёл бы?

---

## Артефакты

🟡 Итоговые файлы:
- `secrets/gitleaks-report.json` + `gitleaks-report.sarif`
- `secrets/trufflehog-report.json`
- `secrets/detect-secrets-baseline.json`
- `secrets/configs/.gitleaks.toml`
- `secrets/configs/.pre-commit-config.yaml`
- `secrets/secrets-comparison.md`

---

## Чеклист самопроверки

- [ ] Gitleaks: скан Git history выполнен, найдены секреты в старых коммитах
- [ ] Gitleaks: pre-commit hook работает — блокирует коммит с секретом
- [ ] Gitleaks: кастомный .gitleaks.toml с правилом и allowlist
- [ ] TruffleHog: скан с верификацией — отделены active vs expired
- [ ] TruffleHog: скан Docker-образа выполнен
- [ ] detect-secrets: baseline создан и прошёл ручной аудит
- [ ] detect-secrets: ловит новые секреты относительно baseline
- [ ] WrongSecrets: пройдены 5+ заданий
- [ ] Сравнительная таблица 3 инструментов заполнена
- [ ] Определена рекомендуемая комбинация инструментов

---

Далее → [`../linters/`](../linters/)
