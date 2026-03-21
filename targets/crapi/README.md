# 🔌 OWASP crAPI (Completely Ridiculous API)

> Специализированная мишень для этапа 3, лаба по API security.

**Репозиторий:** [github.com/OWASP/crAPI](https://github.com/OWASP/crAPI)

---

## Почему crAPI

- Мультисервисная архитектура (Go + Python + Java) — реалистичный микросервисный стек
- Покрывает OWASP API Security Top 10
- Docker Compose с несколькими контейнерами — бонус для этапа 4 (container security)
- BOLA, BFLA, Mass Assignment, SSRF и другие API-специфичные уязвимости

---

## Быстрый запуск

```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/OWASP/crAPI/develop/deploy/docker/docker-compose.yml
docker compose up -d

# Приложение на http://localhost:8888
# Почтовый сервер на http://localhost:8025
```

---

## Что используем

| Этап | Лаба           | Задача                                          |
|------|----------------|-------------------------------------------------|
| 3    | api-testing/   | Тестирование OWASP API Top 10                   |
| 3    | dast/          | DAST-сканирование мультисервисного API           |
| 4    | container-sec/ | Сканирование нескольких Docker-образов            |
