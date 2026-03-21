# Сравнение SAST-инструментов на Juice Shop · Эталонное решение

## Сводка

| Метрика | Semgrep (auto) | Semgrep (owasp) | Bandit | njsscan |
|---------|---------------|-----------------|--------|---------|
| Findings всего | ~85 | ~45 | ~12 | ~35 |
| HIGH/ERROR | ~15 | ~12 | ~5 | ~10 |
| MEDIUM/WARNING | ~40 | ~25 | ~4 | ~18 |
| LOW/INFO | ~30 | ~8 | ~3 | ~7 |
| False Positives (из 10) | ~2 | ~1 | ~1 | ~3 |
| Время скана | ~30 сек | ~20 сек | ~5 сек | ~15 сек |
| Уникальные findings | ~20 | — | ~5 | ~8 |

> *Конкретные числа зависят от версии Juice Shop и ruleset. Порядок величин верный.*

## Что нашёл только один инструмент

### Только Semgrep
- Generic injection patterns через шаблоны (не привязаны к конкретной библиотеке)
- Cross-file taint в некоторых конфигурациях (Semgrep Pro)
- Широкий охват: JS + JSON config + Dockerfile

### Только Bandit
- Python-специфичные паттерны (B301 pickle.loads, B303 md5/sha1)
- AST-глубина: Bandit разбирает Python AST глубже чем Semgrep для Python
- Confidence levels (HIGH/MEDIUM/LOW) — помогает при triage

### Только njsscan
- Node.js-специфика: `child_process.exec()` с переменными
- `node-serialize` deserialization (Semgrep auto может пропустить)
- `rejectUnauthorized: false` — отключение TLS-проверки
- Express-specific: отсутствие helmet middleware

## Вывод: какой инструмент для чего

| Роль | Инструмент | Почему |
|------|-----------|--------|
| **Основной в CI** | Semgrep (auto) | Максимальный охват, быстрый, SARIF, кастомные правила |
| **Python-проекты** | Bandit | Глубже для Python, confidence levels для triage |
| **Node.js-проекты** | njsscan | Специфичные Node.js паттерны, дополняет Semgrep |
| **Pre-commit** | Semgrep (--severity ERROR) | Быстро, ловит только критичное |

**Рекомендация:** Semgrep в CI (основной) + njsscan параллельно (Node.js дополнение) + Bandit для Python-частей.
