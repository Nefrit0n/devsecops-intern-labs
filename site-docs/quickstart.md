# Быстрый старт

Три минуты до первого скана.

---

## 1. Клонируйте репозиторий

```bash
git clone https://github.com/your-username/devsecops-intern-labs.git
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

## Что дальше

!!! tip "Рекомендуемый порядок"
    Этапы проходятся **строго последовательно** — каждый следующий опирается на результаты предыдущего. Не перескакивайте.

!!! info "Системные требования"
    - Docker и Docker Compose
    - 8 GB RAM (минимум 4 GB для `--profile targets`)
    - Git
    - Python 3.10+ (для Semgrep, Bandit, Checkov)
    - Node.js 18+ (для ESLint, njsscan, cdxgen)
