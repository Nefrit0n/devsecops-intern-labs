# Задания · Модуль 3.2 — Fuzzing

> **Важно:** Juice Shop должен быть запущен на http://localhost:3000

---

## Starter kit (минимальный skeleton)

```text
stage-3-dynamic-analysis/fuzzing/
├── README.md
├── tasks.md
├── restler-results/
├── ffuf-results/
└── fuzzing-comparison.md
```

Создайте минимальный каркас для отчётов:

```bash
mkdir -p stage-3-dynamic-analysis/fuzzing/restler-results
mkdir -p stage-3-dynamic-analysis/fuzzing/ffuf-results
touch stage-3-dynamic-analysis/fuzzing/fuzzing-comparison.md
```

---

## Задание 1 · RESTler: stateful API fuzzing
**Тег:** 🟢 практика · **Время:** ~1.5 ч

RESTler от Microsoft Research — единственный из нашего арсенала, кто понимает *зависимости* между API-вызовами. Он знает, что нельзя удалить корзину, не создав её сначала.

### Шаг 1: Компиляция грамматики

```bash
# Получите OpenAPI spec Juice Shop
curl http://localhost:3000/api-docs -o juice-shop-swagger.json

# Компиляция
restler compile --api_spec juice-shop-swagger.json
```

RESTler создаст `Compile/` директорию с грамматикой фаззинга.

### Шаг 2: Smoke test (быстрый)

```bash
restler test --grammar_file Compile/grammar.py --dictionary_file Compile/dict.json \
  --settings Compile/engine_settings.json \
  --host localhost --target_port 3000
```

Smoke test отправляет по одному запросу на каждый эндпоинт. Проверяет, что всё работает.

### Шаг 3: Fuzz-lean (поиск быстрых багов)

```bash
restler fuzz-lean --grammar_file Compile/grammar.py --dictionary_file Compile/dict.json \
  --settings Compile/engine_settings.json \
  --host localhost --target_port 3000
```

### Шаг 4: Full fuzz (глубокий поиск)

```bash
restler fuzz --grammar_file Compile/grammar.py --dictionary_file Compile/dict.json \
  --settings Compile/engine_settings.json \
  --host localhost --target_port 3000 \
  --time_budget 0.5  # 30 минут
```

Изучите результаты в `Fuzz/RestlerResults/`:
- Сколько 500-х ошибок?
- Какие эндпоинты крэшнулись?
- Есть ли resource leaks (создали, но не удалили)?
- Какие checkers сработали?

Скопируйте результаты в `fuzzing/restler-results/`.

---

## Задание 2 · Schemathesis: property-based API testing
**Тег:** 🟢 практика · **Время:** ~1 ч

Schemathesis генерирует тесты автоматически из OpenAPI спецификации и проверяет *свойства* (properties): «ответ должен соответствовать схеме», «status code должен быть документированным».

### Шаг 1: Базовый запуск

```bash
schemathesis run http://localhost:3000/api-docs \
  --hypothesis-max-examples=50 \
  --report stage-3-dynamic-analysis/fuzzing/schemathesis-report.json
```

### Шаг 2: Stateful testing (цепочки)

```bash
schemathesis run http://localhost:3000/api-docs \
  --stateful=links \
  --hypothesis-max-examples=30
```

Stateful mode строит цепочки запросов: создать пользователя → войти → добавить товар → оформить заказ. Находит баги, которые проявляются только в последовательности.

### Шаг 3: Конкретные проверки

```bash
# Только status code validation
schemathesis run http://localhost:3000/api-docs --checks=status_code_conformance

# Только schema validation
schemathesis run http://localhost:3000/api-docs --checks=response_schema_conformance

# Всё вместе
schemathesis run http://localhost:3000/api-docs --checks=all
```

### Шаг 4: Сравнение с RESTler

| Метрика | RESTler | Schemathesis |
|---------|---------|-------------|
| 500-е ошибки | | |
| Schema violations | N/A | |
| Уникальные баги | | |
| Время | | |
| Понимание зависимостей | ✓ (из spec) | ✓ (stateful links) |

---

## Задание 3 · ffuf: directory + parameter fuzzing
**Тег:** 🟢 практика · **Время:** ~1 ч

ffuf — это не про API-контракты. Это про *перебор*: скрытые пути, параметры, backup-файлы.

### Шаг 1: Directory fuzzing

```bash
# Скачайте wordlist
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt

ffuf -u http://localhost:3000/FUZZ -w common.txt \
  -o stage-3-dynamic-analysis/fuzzing/ffuf-dirs.json -of json \
  -fc 404  # фильтр: убрать 404
```

Нашёл ли ffuf эндпоинты, которых нет в OpenAPI spec? (Подсказка: `/ftp`, `/encryptionkeys`, `/metrics`)

### Шаг 2: Parameter fuzzing

```bash
# Фаззинг query-параметров
ffuf -u "http://localhost:3000/rest/products/search?q=FUZZ" \
  -w /usr/share/seclists/Fuzzing/special-chars.txt \
  -o stage-3-dynamic-analysis/fuzzing/ffuf-params.json -of json \
  -mc 200,500  # интересуют 200 и 500
```

Какие спецсимволы вызвали 500-ю ошибку? Это потенциальные injection-точки.

### Шаг 3: Кастомный wordlist из attack surface

Возьмите ваш `attack-surface.md` из этапа 0. Создайте wordlist из эндпоинтов и параметров:

```bash
# Из attack surface создайте custom-wordlist.txt с путями
# /api/Users, /api/Products, /rest/basket, ...

ffuf -u http://localhost:3000/FUZZ -w custom-wordlist.txt \
  -mc all -fc 404
```

> **Связка с этапом 0:** вы определили поверхность атаки → теперь фаззите именно её.

---

## Задание 4 · Сводное сравнение фаззеров
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `fuzzing-comparison.md`:

```markdown
# Сравнение фаззеров на Juice Shop API

| Метрика | RESTler | Schemathesis | ffuf |
|---------|---------|-------------|------|
| Подход | Stateful grammar | Property-based | Wordlist brute |
| 500-е ошибки | | | |
| Уникальные findings | | | |
| Скрытые эндпоинты | N/A | N/A | |
| Schema violations | N/A | | N/A |
| Время | | | |

## Что нашёл каждый фаззер уникального
- RESTler: ...
- Schemathesis: ...
- ffuf: ...

## Рекомендуемая комбинация
...
```

---

## Артефакты

🟡 Итоговые файлы:
- `fuzzing/restler-results/` (баги, coverage)
- `fuzzing/schemathesis-report.json`
- `fuzzing/ffuf-dirs.json` + `ffuf-params.json`
- `fuzzing/fuzzing-comparison.md`

---

## Чеклист самопроверки

- [ ] RESTler: compile → test → fuzz-lean → fuzz выполнены
- [ ] RESTler: найдены 500-е ошибки, изучены checkers
- [ ] Schemathesis: stateful mode, schema + status code checks
- [ ] ffuf: directory fuzzing, найдены скрытые эндпоинты
- [ ] ffuf: parameter fuzzing с спецсимволами
- [ ] ffuf: использован кастомный wordlist из attack surface (этап 0)
- [ ] Сравнительная таблица заполнена

---

Далее → [`../api-testing/`](../api-testing/)
