# Сравнение инструментов поиска секретов · Эталонное решение

## Сводка

| Метрика | Gitleaks | TruffleHog | detect-secrets |
|---------|----------|------------|----------------|
| Findings всего | ~18 | ~12 | ~22 |
| Verified (активные) | N/A | ~3 | N/A |
| Уникальные типы секретов | 6 | 8 (более точная классификация) | 5 |
| False Positives (из 10) | ~3 | ~1 | ~4 |
| Скан Git history | ✓ (быстрый) | ✓ (медленнее) | ✗ (только текущий) |
| Скан Docker images | ✗ | ✓ | ✗ |
| Pre-commit hook | ✓ (мс) | ✗ (слишком медленный) | ✓ (секунды) |
| Baseline-подход | ✗ | ✗ | ✓ |
| Время скана (full repo) | ~45 сек | ~3 мин | ~20 сек |
| Кастомные правила | .gitleaks.toml (regex) | Нет (детекторы зашиты) | Plugins (Python) |

## Вывод: когда какой использовать

- **Gitleaks** — pre-commit hook (мгновенный), CI pipeline (быстрый), Git history scan. Лучший баланс скорости и покрытия.
- **TruffleHog** — аудит и incident response: «этот ключ ещё работает?» Credential verification — киллер-фича. Скан Docker-образов — уникальная возможность.
- **detect-secrets** — legacy-кодовая база с тысячами исторических «секретов». Baseline зафиксировал текущее, ловим только новое. Audit mode для ручной разметки TP/FP.

## Рекомендуемая комбинация

```
Pre-commit:  Gitleaks (блокирует коммит с секретом)
CI pipeline: Gitleaks (SARIF → GitHub Security)
Weekly audit: TruffleHog --only-verified (живые ключи → немедленная ротация)
Legacy repos: detect-secrets baseline + audit
Docker:      TruffleHog docker (секреты внутри образа)
```
