# devsecops-intern-labs

`devsecops-intern-labs` — это учебный репозиторий для практики Intern-уровня по DevSecOps в полностью локальной среде.

## Цель репозитория
- Дать реалистичный hands-on практикум по DevSecOps.
- Научить запускать security-проверки локально.
- Показать mini security pipeline без реального GitLab CI/CD.
- Использовать уязвимое учебное приложение как полигон для анализа.

## Необходимые инструменты
- `git`
- `docker`
- `python 3.x`
- `bash`
- `trivy`
- `gitleaks`
- `semgrep`
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

### 4) Semgrep
```bash
python3 -m pip install --user semgrep
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
semgrep --version
syft version
```

## Структура репозитория
```text
devsecops-intern-labs/
  README.md
  AGENTS.md
  .gitignore
  Makefile
  reports/
  vulnerable-app/
  webgoat-labs/
  scanner-scripts/
  docker-labs/
  solutions/
```

## Roadmap прохождения лабораторных
1. Подготовить окружение и проверить инструменты.
2. Запустить `vulnerable-app` локально и через Docker.
3. Пройти `docker-labs` для базового понимания контейнерной безопасности.
4. Запустить scanner scripts по `vulnerable-app`.
5. Пройти `webgoat-labs` для практики на более крупном проекте.
6. Сравнить свои результаты с подсказками в `solutions/`.
7. Сформировать краткий remediation plan.

## Что должен уметь студент после прохождения
- Понимать базовые практики DevSecOps и роль security checks.
- Запускать SCA, SAST, secret scanning, container scanning и SBOM локально.
- Читать отчёты Trivy / Gitleaks / Semgrep / Syft.
- Находить базовые анти-паттерны в Python/Flask и Dockerfile.
- Собирать мини pipeline в Bash без CI/CD.

## Как проверять результат локально
### Быстрый старт
```bash
make help
make build-app
make full-scan
```

### Ручной запуск скриптов
```bash
bash scanner-scripts/run_secret_scan.sh .
bash scanner-scripts/run_sca_scan.sh .
bash scanner-scripts/run_sast_scan.sh ./vulnerable-app
bash scanner-scripts/run_container_scan.sh vulnerable-app:lab
bash scanner-scripts/generate_sbom.sh ./vulnerable-app
```

Все результаты сохраняются в `reports/`.

## Типичные ошибки студентов
- Запуск сканеров без установки CLI-инструментов.
- Запуск `trivy image` до сборки Docker-образа.
- Неправильный путь к директории сканирования.
- Игнорирование ложноположительных/контекстных срабатываний.
- Отсутствие итогового краткого вывода по результатам сканов.
- Использование `latest` тегов и root-пользователя в Dockerfile.

## Полезные команды
```bash
make run-app
make build-app
make secret-scan
make sca-scan
make sast-scan
make container-scan
make sbom
make full-scan
```
