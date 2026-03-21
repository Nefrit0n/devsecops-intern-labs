# 🥤 OWASP Juice Shop

> Основная мишень курса. Используется на этапах 0, 1, 2, 3, 5.

**Репозиторий:** [github.com/juice-shop/juice-shop](https://github.com/juice-shop/juice-shop)
**Документация:** [pwning.owasp-juice.shop](https://pwning.owasp-juice.shop/)

---

## Почему Juice Shop

- Покрывает весь OWASP Top 10 + OWASP API Security Top 10
- Современный стек (Node.js, Angular, SQLite) — релевантен для реальных проектов
- 100+ задокументированных уязвимостей разной сложности
- Богатые npm-зависимости с известными CVE (идеально для SCA)
- REST API — полноценная мишень для DAST и API-тестирования
- Docker-образ, запуск одной командой
- Активное сообщество и регулярные обновления

---

## Быстрый запуск

```bash
# Вариант 1: Docker (рекомендуется)
docker run --rm -p 3000:3000 bkimminich/juice-shop

# Вариант 2: Docker Compose (из этой папки)
docker compose up -d

# Приложение доступно на http://localhost:3000
```

---

## Что используем на каких этапах

| Этап | Что делаем с Juice Shop                                        |
|------|----------------------------------------------------------------|
| 0    | Строим DFD и модель угроз на основе его архитектуры            |
| 1    | SAST — сканируем исходный код (Semgrep, njsscan)               |
| 1    | Secrets — ищем захардкоженные ключи и токены                   |
| 2    | SCA — анализируем package.json на уязвимые зависимости         |
| 2    | SBOM — генерируем CycloneDX из npm-зависимостей                |
| 3    | DAST — сканируем запущенное приложение (ZAP, Nuclei)           |
| 3    | API testing — тестируем REST API                                |
| 5    | Собираем полный пайплайн, интегрирующий все сканеры            |

---

## Как получить исходный код для SAST

```bash
# Клонируем репозиторий для статического анализа
git clone https://github.com/juice-shop/juice-shop.git targets/juice-shop/src

# Или скачиваем конкретную версию
git clone --depth 1 --branch v17.1.1 https://github.com/juice-shop/juice-shop.git targets/juice-shop/src
```

> **Важно:** для SAST (этап 1) нужен исходный код. Для DAST (этап 3) достаточно Docker-образа.

---

## docker-compose.yml

```yaml
services:
  juice-shop:
    image: bkimminich/juice-shop
    ports:
      - "3000:3000"
    restart: unless-stopped
```
