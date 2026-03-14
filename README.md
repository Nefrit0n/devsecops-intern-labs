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
1. Откройте репозиторий.
2. Проверьте, что инструменты установлены.
3. Соберите учебное приложение.
4. Запустите сканы в режиме предупреждений.
5. Запустите сканы в блокирующем режиме.

Команды:

```bash
make help
make build-app
make full-scan-warn
make full-scan-gate
```

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
