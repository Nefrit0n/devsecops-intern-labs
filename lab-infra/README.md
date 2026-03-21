# 🐳 Lab Infrastructure

Единая среда для всего курса. Один файл — все сервисы.

---

## Быстрый старт

```bash
# Минимальный набор: Juice Shop + WrongSecrets
docker compose -f lab-infra/docker-compose.lab.yml --profile targets up -d

# Полный набор: мишени + DefectDojo + Dependency-Track
docker compose -f lab-infra/docker-compose.lab.yml --profile all up -d
```

---

## Профили

Не нужно поднимать всё сразу — используйте профили по мере прохождения курса.

| Профиль | Что поднимает | Когда нужен | RAM |
|---------|---------------|-------------|-----|
| `targets` | Juice Shop + WrongSecrets | Этапы 0–2 | ~1 GB |
| `targets-extended` | + crAPI (API security) | Этап 3 | ~2 GB |
| `management` | DefectDojo + Dependency-Track | Этапы 2, 5 | ~3 GB |
| `all` | Всё вместе | Этап 5 (финальный пайплайн) | ~5 GB |
| `scanners` | ZAP (по запросу) | Этап 3 | ~1 GB |

```bash
# Этапы 0–1: достаточно мишеней
docker compose -f lab-infra/docker-compose.lab.yml --profile targets up -d

# Этап 2: добавляем Dependency-Track
docker compose -f lab-infra/docker-compose.lab.yml --profile targets --profile management up -d

# Этап 3: добавляем crAPI
docker compose -f lab-infra/docker-compose.lab.yml --profile targets --profile targets-extended up -d

# Этап 5: всё
docker compose -f lab-infra/docker-compose.lab.yml --profile all up -d
```

---

## Доступ к сервисам

| Сервис                   | URL                   | Логин                     | Этап   |
| ------------------------ | --------------------- | ------------------------- | ------ |
| **Juice Shop**           | http://localhost:3000 | — (регистрация)           | 0–3, 5 |
| **WrongSecrets**         | http://localhost:8080 | —                         | 1      |
| **crAPI**                | http://localhost:8888 | — (регистрация)           | 3      |
| **crAPI Mailhog**        | http://localhost:8025 | —                         | 3      |
| **DefectDojo**           | http://localhost:8081 | admin / DevsecopsLab2024! | 5      |
| **Dependency-Track UI**  | http://localhost:8083 | admin / admin             | 2, 5   |
| **Dependency-Track API** | http://localhost:8082 | — (token)                 | 2, 5   |

---

## Управление

```bash
# Статус всех контейнеров
docker compose -f lab-infra/docker-compose.lab.yml ps

# Логи конкретного сервиса
docker compose -f lab-infra/docker-compose.lab.yml logs juice-shop
docker compose -f lab-infra/docker-compose.lab.yml logs defectdojo

# Остановить всё
docker compose -f lab-infra/docker-compose.lab.yml --profile all down

# Остановить и удалить данные (полный сброс)
docker compose -f lab-infra/docker-compose.lab.yml --profile all down -v
```

---

## Запуск сканеров через Docker

Сканеры не запущены постоянно — вызывайте по необходимости:

### ZAP (DAST)

```bash
# Baseline scan (passive, 2 мин)
docker run --rm --network=host \
  -v $(pwd)/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:3000 -J /zap/wrk/zap-report.json

# Full scan (active, 15–30 мин)
docker run --rm --network=host \
  -v $(pwd)/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t http://localhost:3000 -J /zap/wrk/zap-full.json
```

### Trivy

```bash
# SCA: сканирование файловой системы
docker run --rm -v $(pwd):/app aquasec/trivy fs /app --severity CRITICAL,HIGH

# Container: сканирование образа Juice Shop
docker run --rm aquasec/trivy image bkimminich/juice-shop:v17.1.1
```

### OWASP Dependency-Check

```bash
docker run --rm \
  -v $(pwd):/src -v $(pwd)/reports:/report \
  owasp/dependency-check \
  --scan /src --out /report --format HTML --project "Juice Shop"
```

### Dockle

```bash
docker run --rm goodwithtech/dockle bkimminich/juice-shop:v17.1.1
```

### Checkov

```bash
docker run --rm -v $(pwd):/app bridgecrew/checkov -d /app --framework dockerfile,kubernetes
```

### KICS

```bash
docker run --rm -v $(pwd):/app checkmarx/kics scan -p /app -o /app/kics-results
```

### Nuclei

```bash
docker run --rm --network=host projectdiscovery/nuclei \
  -u http://localhost:3000 -severity critical,high
```

---

## Системные требования

| Профиль | RAM | CPU | Disk |
|---------|-----|-----|------|
| `targets` | 2 GB | 2 cores | 3 GB |
| `targets` + `management` | 5 GB | 4 cores | 8 GB |
| `all` | 6 GB | 4 cores | 10 GB |

> **Рекомендуемое:** 8 GB RAM, 4 cores. На 16 GB + SSD всё будет летать.

---

## Troubleshooting

### DefectDojo не запускается / ошибка миграции
```bash
# Полный сброс DefectDojo
docker compose -f lab-infra/docker-compose.lab.yml stop defectdojo defectdojo-db
docker volume rm lab-defectdojo-db
docker compose -f lab-infra/docker-compose.lab.yml --profile management up -d
# Подождите ~3 мин на инициализацию
```

### Dependency-Track: "Out of memory"
```bash
# Увеличьте лимиты Docker Desktop → Settings → Resources → Memory: 6 GB+
```

### Порт занят
```bash
# Проверить кто занял порт
lsof -i :3000
# Остановить или поменять порт в docker-compose.lab.yml
```

### Всё сломалось
```bash
# Ядерный вариант: удалить всё и начать заново
docker compose -f lab-infra/docker-compose.lab.yml --profile all down -v --rmi local
docker compose -f lab-infra/docker-compose.lab.yml --profile all up -d
```
