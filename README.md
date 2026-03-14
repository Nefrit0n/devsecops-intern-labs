# devsecops-intern-labs

Учебный репозиторий для практики DevSecOps на уровне Intern.

## Для чего этот репозиторий
После прохождения практики студент должен уметь:
- запускать базовые security-проверки локально;
- читать результаты сканеров;
- понимать, как собрать простой локальный security pipeline.

## Что нужно установить
Минимальный набор инструментов:
- `git`
- `docker`
- `python3`
- `bash`
- `trivy`
- `gitleaks`
- `opengrep`
- `syft`

> Используйте локально запускаемые open-source инструменты. Никакие облачные сервисы не обязательны.

## Быстрый старт (рекомендуемый путь)
### Шаг 0. Базовый bootstrap (до `make`)
Сначала нужны `git` и `make`, чтобы склонировать репозиторий и запускать Make-команды.

```bash
# Linux (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y git make

# macOS (Homebrew)
brew install git make
```

### Шаг 1. Клонировать репозиторий
```bash
git clone <URL_ЭТОГО_РЕПО>
cd devsecops-intern-labs
```

### Шаг 2. Установить инструменты и запустить лабораторные команды
```bash
make help
make install-tools
make build-app
make full-scan-warn
make full-scan-gate
```

## Установка всего необходимого ПО (через Make)
> Перед этим шагом должны быть установлены `git` и `make` (см. bootstrap выше).
```bash
make install-tools
```

Что делает команда:
- ставит базовые инструменты и сканеры через `apt-get` (Linux) или `brew` (macOS/Linuxbrew);
- ставит Trivy, Gitleaks, Syft и OpenGrep;
- ставит Python-зависимости учебного приложения через `pip` с флагом `--break-system-packages`.

## Проверка, что инструменты доступны
```bash
git --version
docker --version
python3 --version
bash --version
trivy --version
gitleaks version
opengrep --version
syft version
```

## Структура репозитория
```text
devsecops-intern-labs/
  README.md
  Makefile
  scanner-scripts/
  vulnerable-app/
  docker-labs/
  webgoat-labs/
  solutions/
  reports/
```

## Полезные команды сканирования
### OpenGrep (обновлённый формат команды)
```bash
opengrep scan --config ./opengrep-rules/python/ ./vulnerable-app
```

### Остальные сканы
```bash
bash scanner-scripts/run_secret_scan.sh .
bash scanner-scripts/run_sca_scan.sh .
bash scanner-scripts/run_sast_scan.sh ./vulnerable-app
bash scanner-scripts/run_container_scan.sh vulnerable-app:lab
bash scanner-scripts/generate_sbom.sh ./vulnerable-app
```

Все отчёты сохраняются в папку `reports/`.

## Режимы pipeline
### 1) Informative (warn-only)
Сканы запускаются, но не валят итоговый статус.

```bash
WARN_ONLY=true FAIL_ON_ANY_ERROR=false bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app
```

### 2) Blocking (quality gate)
Если найдены проблемы по заданным порогам, pipeline завершится с ошибкой.

```bash
WARN_ONLY=false FAIL_ON_ANY_ERROR=true bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app
```

Пороговые значения и политика fail/pass настраиваются в:
- `scanner-scripts/security-thresholds.env`

## Как проходить практику
1. Начните с `vulnerable-app`.
2. Пройдите `docker-labs`.
3. Пройдите `webgoat-labs`.
4. Сверьте результаты с `solutions/`.
5. Сформируйте короткий план исправлений (remediation plan).
