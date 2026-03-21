---
description: "Быстрый старт с DevSecOps Lab — от клонирования до первого сканирования за 3 минуты"
---

# Быстрый старт

Три минуты до первого скана.

---

!!! warning "Системные требования"
    | Компонент | Минимум | Рекомендуется |
    |-----------|---------|---------------|
    | **Docker + Docker Compose** | v20+ / v2+ | Последняя стабильная |
    | **RAM** | 4 ГБ (только мишени) | 8 ГБ (полный стенд) |
    | **Git** | v2.30+ | Последняя |
    | **Python** | 3.10+ | 3.12 |
    | **Node.js** | 18+ | 20 LTS |
    | **Свободное место** | 10 ГБ | 20 ГБ (все образы) |

---

## 1. Клонируйте репозиторий

=== "HTTPS"

    ```bash
    git clone https://github.com/Nefrit0n/devsecops-intern-labs.git
    cd devsecops-intern-labs
    ```

=== "SSH"

    ```bash
    git clone git@github.com:Nefrit0n/devsecops-intern-labs.git
    cd devsecops-intern-labs
    ```

## 2. Поднимите среду

=== "Минимальный набор (Juice Shop)"

    ```bash
    docker compose -f lab-infra/docker-compose.lab.yml --profile targets up -d
    ```

    Доступ: [http://localhost:3000](http://localhost:3000)

=== "Полный набор (всё)"

    ```bash
    docker compose -f lab-infra/docker-compose.lab.yml --profile all up -d
    ```

    | Сервис | URL | Логин |
    |--------|-----|-------|
    | Juice Shop | http://localhost:3000 | — |
    | WrongSecrets | http://localhost:8080 | — |
    | DefectDojo | http://localhost:8081 | admin / DevsecopsLab2024! |
    | Dependency-Track | http://localhost:8083 | admin / admin |

=== "Через Makefile"

    ```bash
    make lab-up    # мишени
    make lab-all   # всё
    make help      # все команды
    ```

## 3. Проверьте инструменты

```bash
make check-tools
```

## 4. Начинайте с Этапа 0

```bash
# Откройте в браузере или в терминале:
cat stage-0/README.md
```

Или перейдите к [Этапу 0 · Фундамент](../stage-0/README.md).

---

## Установка инструментов по ОС

=== "macOS"

    ```bash
    # Docker Desktop
    brew install --cask docker

    # Python + Node.js
    brew install python@3.12 node@20

    # Инструменты безопасности
    pip install semgrep bandit checkov
    brew install trivy gitleaks hadolint
    npm install -g eslint @cyclonedx/cdxgen
    ```

=== "Linux (Ubuntu/Debian)"

    ```bash
    # Docker
    sudo apt update && sudo apt install -y docker.io docker-compose-v2
    sudo usermod -aG docker $USER

    # Python + Node.js
    sudo apt install -y python3.12 python3-pip nodejs npm

    # Инструменты безопасности
    pip install semgrep bandit checkov
    sudo apt install -y trivy
    npm install -g eslint @cyclonedx/cdxgen
    ```

=== "Windows (WSL2)"

    ```powershell
    # 1. Установите WSL2 и Docker Desktop с поддержкой WSL2
    wsl --install -d Ubuntu

    # 2. Внутри WSL2 — те же команды что для Linux:
    sudo apt update && sudo apt install -y docker.io python3.12 python3-pip nodejs npm
    pip install semgrep bandit checkov
    npm install -g eslint @cyclonedx/cdxgen
    ```

---

## Что дальше

!!! tip "Рекомендуемый порядок"
    Этапы проходятся **строго последовательно** — каждый следующий опирается на результаты предыдущего. Не перескакивайте.

---

## Что уже реализовано

- Структура из 6 этапов обучения и документация по каждому модулю
- Учебные мишени (Juice Shop, WrongSecrets, crAPI, K8s Goat) с инструкциями по запуску
- Набор automation-целей в `Makefile`: `lab-*`, `stage1-*` … `stage5-*`, `scan-all`
- Скрипты подготовки окружения и проверки инструментов
- Шаблоны для моделей угроз, требований безопасности, SBOM, quality gates

## Что выполняет студент

- Последовательно проходит этапы и запускает соответствующие цели `Makefile`
- Анализирует отчёты сканеров, устраняет проблемы и фиксирует результаты
- Создаёт недостающие артефакты (скрипты интеграции, кастомные правила, политики)
- Настраивает quality gates и требования под контекст своей программы

---

## Решение проблем

??? question "Docker не запускается?"
    **Симптом:** `Cannot connect to the Docker daemon`

    1. Убедитесь что Docker Desktop запущен (macOS/Windows) или сервис активен:
    ```bash
    sudo systemctl start docker
    sudo systemctl enable docker
    ```
    2. Проверьте что пользователь в группе docker:
    ```bash
    sudo usermod -aG docker $USER
    # Перезайдите в терминал
    ```
    3. Проверьте версию:
    ```bash
    docker --version && docker compose version
    ```

??? question "Порт занят?"
    **Симптом:** `Bind for 0.0.0.0:3000 failed: port is already allocated`

    Найдите процесс и остановите или смените порт:
    ```bash
    # Найти кто занимает порт
    lsof -i :3000
    # Или через docker
    docker ps --format '{{.Ports}}' | grep 3000
    ```

    Чтобы сменить порт, отредактируйте `lab-infra/docker-compose.lab.yml`:
    ```yaml
    ports:
      - "3001:3000"  # доступ на localhost:3001
    ```

??? question "Не хватает RAM?"
    **Симптом:** контейнеры перезапускаются, OOM-killer

    1. Запустите минимальный набор вместо полного:
    ```bash
    docker compose -f lab-infra/docker-compose.lab.yml --profile targets up -d
    ```
    2. Увеличьте память для Docker Desktop: Settings → Resources → Memory → 8 GB
    3. Остановите неиспользуемые контейнеры:
    ```bash
    docker compose -f lab-infra/docker-compose.lab.yml down
    ```

??? question "Semgrep/Bandit не находит файлы?"
    **Симптом:** пустой вывод или `No files found`

    Убедитесь что вы в корне репозитория и мишень склонирована:
    ```bash
    pwd  # должен быть devsecops-intern-labs/
    ls targets/juice-shop/src/  # должны быть исходники
    ```
    Если `src/` пуст — загрузите мишени:
    ```bash
    make lab-up
    ```
