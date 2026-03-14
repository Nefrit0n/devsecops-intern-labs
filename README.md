# devsecops-intern-labs

`devsecops-intern-labs` — учебный репозиторий для практики Intern-уровня по DevSecOps в полностью локальной среде.

## Цель репозитория
- Дать реалистичный hands-on практикум по DevSecOps.
- Научить запускать security-проверки локально.
- Показать mini security pipeline без реального GitLab CI/CD.
- Показать разницу между уязвимыми и более безопасными практиками.

## Необходимые инструменты
- `git`
- `docker`
- `python 3.x`
- `bash`
- `trivy`
- `gitleaks`
- `opengrep`
- `syft`

## Установка инструментов
> Ниже пример для Linux/macOS. Проверяйте актуальные инструкции в официальной документации инструментов.

### 1) Базовые инструменты
```bash
# Ubuntu/Debian (пример)
sudo apt-get update
sudo apt-get install -y git docker.io python3 python3-pip bash

# macOS с Homebrew (пример)
brew install git docker python bash
```

### 2) Trivy
```bash
# macOS
brew install trivy

# Linux (вариант с установочным скриптом)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
sudo mv ./bin/trivy /usr/local/bin/trivy
```

### 3) Gitleaks
```bash
# macOS
brew install gitleaks

# Linux (скачайте релиз с GitHub и добавьте в PATH)
```

### 4) OpenGrep
```bash
python3 -m pip install --user opengrep
```

### 5) Syft
```bash
# macOS
brew install syft

# Linux
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

### Проверка установки
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
  AGENTS.md
  Makefile
  reports/
  vulnerable-app/
  webgoat-labs/
  scanner-scripts/
  docker-labs/
  solutions/
```

## Стандарт структуры лабораторных
Для единообразия все лабораторные в репозитории оформляются по шаблону:
- **Цель**
- **Шаги выполнения**
- **Ожидаемый результат**
- **Вопросы на понимание**

Дополнительно можно добавлять:
- **Команды**
- **Критерии проверки**
- **Подсказки**

## Roadmap прохождения
1. Подготовить окружение и проверить инструменты.
2. Запустить `vulnerable-app` локально и через Docker.
3. Пройти `docker-labs` для базового понимания контейнерной безопасности.
4. Запустить scanner scripts по `vulnerable-app`.
5. Пройти `webgoat-labs` для практики на более крупном проекте.
6. Сравнить результаты с подсказками в `solutions/`.
7. Сформировать краткий remediation plan.

## Что должен уметь студент после прохождения
- Понимать базовые практики DevSecOps и роль security checks.
- Запускать SCA, SAST, secret scanning, container scanning и SBOM локально.
- Читать отчёты Trivy / Gitleaks / OpenGrep / Syft.
- Запускать pipeline в информативном и blocking-режиме.
- Находить базовые анти-паттерны в Python/Flask и Dockerfile.

## Security policy для сканеров
Единые пороги и политики находятся в `scanner-scripts/security-thresholds.env`.

Что можно менять студенту:
- severity threshold (например, `HIGH,CRITICAL`);
- fail policy (`*_EXIT_CODE`, `SAST_FAIL_ON_FINDINGS`);
- путь к rules/config (`OPENGREP_CONFIG`, `SECRET_CONFIG`).

## Локальный pipeline: два режима

### 1) Informative / warn-only
Подходит для раннего этапа обучения и triage: сканы выполняются, но pipeline не падает.

```bash
WARN_ONLY=true FAIL_ON_ANY_ERROR=false bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app
# или
make full-scan-warn
```

### 2) Blocking / quality gate
Подходит для проверки готовности перед «условным релизом»: при ошибках pipeline завершится `exit 1`.

```bash
WARN_ONLY=false FAIL_ON_ANY_ERROR=true bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app
# или
make full-scan-gate
```

### Какие переменные влияют на pass/fail
- `WARN_ONLY=true` — принудительно переводит проверки в режим предупреждений.
- `FAIL_ON_ANY_ERROR=true` — при наличии ошибок финальный статус будет `FAILED` и `exit 1`.
- Пороговые переменные из `security-thresholds.env` задают, что считается ошибкой для конкретного сканера.

## Быстрый старт
```bash
make help
make build-app
make full-scan-warn
make full-scan-gate
```

## Ручной запуск отдельных скриптов
```bash
bash scanner-scripts/run_secret_scan.sh .
bash scanner-scripts/run_sca_scan.sh .
bash scanner-scripts/run_sast_scan.sh ./vulnerable-app
bash scanner-scripts/run_container_scan.sh vulnerable-app:lab
bash scanner-scripts/generate_sbom.sh ./vulnerable-app
```

Все результаты сохраняются в `reports/`.
