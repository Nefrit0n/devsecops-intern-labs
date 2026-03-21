# 🔑 OWASP WrongSecrets

> Специализированная мишень для этапа 1, лаба по секретам.

**Репозиторий:** [github.com/OWASP/wrongsecrets](https://github.com/OWASP/wrongsecrets)

---

## Почему WrongSecrets

- Заточен под одну задачу: неправильное хранение секретов
- Секреты спрятаны в коде, конфигах, Docker-образе, переменных окружения, K8s secrets, облаке
- Показывает прогрессию: от простого (hardcoded password) до сложного (vault, cloud KMS)
- Идеально дополняет Gitleaks/TruffleHog на этапе 1

---

## Быстрый запуск

```bash
docker run --rm -p 8080:8080 jeroenwillemsen/wrongsecrets:latest-no-vault

# Приложение на http://localhost:8080
```

---

## Что используем

| Этап | Лаба                  | Задача                                       |
|------|-----------------------|----------------------------------------------|
| 1    | secrets/              | Найти секреты с помощью Gitleaks, TruffleHog |
| 1    | secrets/              | Понять почему .env и env vars — тоже не идеал |
