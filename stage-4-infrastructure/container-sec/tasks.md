# Задания · Модуль 4.1 — Container Security

---

## Starter kit (минимальный skeleton)

```text
stage-4-infrastructure/container-sec/
├── README.md
├── tasks.md
├── hardened-Dockerfile
└── container-comparison.md
```

Создайте каркас файлов для фиксаций и сравнения:

```bash
touch stage-4-infrastructure/container-sec/hardened-Dockerfile
touch stage-4-infrastructure/container-sec/container-comparison.md
```

---

## Задание 1 · Trivy image: полный скан образа
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Базовый скан

```bash
# Полный скан: CVE + misconfig + secrets
trivy image bkimminich/juice-shop --format json \
  --output stage-4-infrastructure/container-sec/trivy-image-report.json

# Только CRITICAL + HIGH
trivy image bkimminich/juice-shop --severity CRITICAL,HIGH

# Только fixable (есть патч)
trivy image bkimminich/juice-shop --ignore-unfixed
```

### Шаг 2: Разделите findings

Trivy находит два типа уязвимостей в Docker-образе:

| Тип | Источник | Кто чинит | Пример |
|-----|----------|-----------|--------|
| **OS packages** | apt/apk в base image | Обновить base image | CVE в libssl, curl, zlib |
| **App dependencies** | npm/pip в приложении | Обновить зависимости | CVE в lodash, express |

Посчитайте: сколько CVE в OS-пакетах vs app-зависимостях? Какой процент?

### Шаг 3: Base image analysis

```bash
# Скан только base image (без app-слоёв)
trivy image node:18-alpine --severity CRITICAL,HIGH

# Сравнить с другими base images
trivy image node:18-slim --severity CRITICAL,HIGH
trivy image node:18 --severity CRITICAL,HIGH
```

Какой base image содержит меньше всего CVE? Это информация для hardened Dockerfile (задание 5).

### Шаг 4: .trivyignore

Создайте `.trivyignore` для подавления FP с обоснованием:

```
# CVE-2023-XXXXX: не эксплуатируемо в нашем контексте (нет сетевого доступа к libX)
CVE-2023-XXXXX

# CVE-2024-YYYYY: fix доступен только в node:20, мы на node:18 (запланировано на Q2)
CVE-2024-YYYYY
```

---

## Задание 2 · Grype: SBOM-based scanning
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
# Прямой скан образа
grype bkimminich/juice-shop --output json > stage-4-infrastructure/container-sec/grype-image-report.json

# Через SBOM (Syft → Grype)
syft bkimminich/juice-shop -o cyclonedx-json > juice-shop-image.sbom.json
grype sbom:juice-shop-image.sbom.json --only-fixed
```

Сравните с Trivy:
- Общее количество CVE: Trivy vs Grype?
- Есть ли CVE которые нашёл только один из них?
- Совпадают ли severity оценки?

---

## Задание 3 · Dockle: CIS Docker Benchmark
**Тег:** 🟢 практика · **Время:** ~45 мин

```bash
dockle bkimminich/juice-shop --format json \
  --output stage-4-infrastructure/container-sec/dockle-report.json

# Человекочитаемый
dockle bkimminich/juice-shop
```

Dockle проверяет **не CVE, а практики сборки** по CIS Docker Benchmark:

| Check | Что проверяет | Пример нарушения |
|-------|---------------|------------------|
| CIS-DI-0001 | USER не root | `USER root` или отсутствие USER |
| CIS-DI-0005 | COPY вместо ADD | `ADD` скачивает из интернета |
| CIS-DI-0006 | HEALTHCHECK | Отсутствие healthcheck |
| CIS-DI-0008 | SETUID/SETGID binaries | chmod u+s в образе |
| DKL-DI-0006 | latest tag | `FROM node:latest` |

**Связь с этапом 1:** hadolint проверял *Dockerfile* (рецепт). Dockle проверяет *image* (результат). Что hadolint пропустил, но Dockle нашёл? (Подсказка: SETUID binaries появляются при `apt install`, их нет в Dockerfile.)

---

## Задание 4 · Docker Scout: рекомендации по base image
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
# CVE в образе
docker scout cves bkimminich/juice-shop

# Рекомендации по base image
docker scout recommendations bkimminich/juice-shop
```

Docker Scout предлагает конкретные альтернативы base image с меньшим количеством CVE. Запишите рекомендации в `scout-recommendations.md`:

| Текущий base | Рекомендованный | CVE до | CVE после | Комментарий |
|-------------|-----------------|--------|-----------|-------------|
| node:18 | node:18-alpine | ___ | ___ | -___% CVE |
| node:18-alpine | cgr.dev/chainguard/node | ___ | ___ | distroless |

---

## Задание 5 · Hardened Dockerfile
**Тег:** 🟡 артефакт · **Время:** ~30 мин

На основе findings из всех четырёх инструментов, создайте `hardened-Dockerfile`:

```dockerfile
# Hardened Dockerfile для Juice Shop
# Основано на findings из Trivy, Dockle, hadolint, Docker Scout

# 1. Минимальный base image (по рекомендации Scout)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
# 2. Non-root user (Dockle CIS-DI-0001)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# 3. Remove SETUID/SETGID binaries (Dockle CIS-DI-0008)
RUN find / -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# 4. Healthcheck (Dockle CIS-DI-0006)
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/ || exit 1

# 5. Non-root user
USER appuser

# 6. Фиксированный порт
EXPOSE 3000
CMD ["node", "build/app.js"]
```

Просканируйте hardened image всеми четырьмя инструментами — насколько уменьшилось количество findings?

---

## Задание 6 · Сводное сравнение
**Тег:** 🟡 артефакт · **Время:** ~20 мин

Создайте `container-comparison.md`:

```markdown
# Сравнение инструментов Container Security

| Метрика | Trivy | Grype | Dockle | Docker Scout |
|---------|-------|-------|--------|-------------|
| CVE (OS packages) | | | N/A | |
| CVE (app deps) | | | N/A | |
| Misconfigurations | ✓ | ✗ | ✓ (CIS) | ✗ |
| Secrets in image | ✓ | ✗ | ✗ | ✗ |
| Base image advice | ✗ | ✗ | ✗ | ✓ |
| Уникальные findings | | | | |

## Original vs Hardened image

| Метрика | Original | Hardened | Улучшение |
|---------|----------|---------|-----------|
| Trivy CRITICAL | | | |
| Dockle WARN+ | | | |
| Runs as root | ✓ | ✗ | ✓ |
```

---

## Чеклист самопроверки

- [ ] Trivy image: полный скан, разделены OS vs app CVE
- [ ] Trivy: base image comparison (alpine vs slim vs full)
- [ ] Trivy: .trivyignore с обоснованием
- [ ] Grype: прямой скан + через SBOM, сравнение с Trivy
- [ ] Dockle: CIS checks, связь с hadolint (этап 1)
- [ ] Docker Scout: рекомендации по base image
- [ ] Hardened Dockerfile создан и проверен всеми инструментами
- [ ] `container-comparison.md` с original vs hardened

---

Далее → [`../iac-sec/`](../iac-sec/)
