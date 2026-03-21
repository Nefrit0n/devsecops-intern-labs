---
hide:
  - navigation
  - toc
---

# DevSecOps Lab · ГОСТ Р 56939-2024

<div class="hero" markdown>

## Практический полигон для изучения безопасной разработки ПО

От теории ГОСТа до практического набора автоматизированных проверок безопасности и учебных артефактов.

[Начать обучение :material-rocket-launch:](quickstart.md){ .md-button .md-button--primary }
[Маршрут обучения :material-map-outline:](roadmap.md){ .md-button }

</div>

---

<div class="grid cards" markdown>

-   :material-shield-check:{ .lg .middle } **6 этапов**

    ---

    Последовательный курс: каждый этап наращивает навыки поверх предыдущего

-   :material-tools:{ .lg .middle } **Automation через Makefile**

    ---

    Преднастроенные цели `lab-*`, `stage1-*` … `stage5-*`, `scan-all` для запуска этапов и сборки отчётов

-   :material-target:{ .lg .middle } **4 мишени**

    ---

    Juice Shop, WrongSecrets, crAPI, Kubernetes Goat — проверенные уязвимые приложения

-   :material-file-document:{ .lg .middle } **ГОСТ Р 56939-2024**

    ---

    Каждый этап привязан к конкретным процессам ГОСТа. Готовит к аудиту ФСТЭК

-   :material-docker:{ .lg .middle } **Быстрый запуск стенда**

    ---

    `make lab-up` поднимает учебные мишени, `make lab-all` — расширенный стенд с management-сервисами

-   :material-certificate:{ .lg .middle } **Практика + шаблоны**

    ---

    Не видео-курс, а репозиторий с заданиями, шаблонами и зонами для самостоятельной реализации

</div>

---

## Маршрут обучения

| Этап | Название | Время | Инструменты |
|------|---------|-------|-------------|
| **0** | [Фундамент](stage-0/README.md) | ~12 ч | pytm, draw.io |
| **1** | [Код под микроскопом](stage-1-static-analysis/README.md) | ~10 ч | Semgrep, Bandit, Gitleaks, TruffleHog, ESLint |
| **2** | [Зависимости](stage-2-dependencies/README.md) | ~10 ч | Trivy, Dep-Check, Syft, Dependency-Track |
| **3** | [Атакуем приложение](stage-3-dynamic-analysis/README.md) | ~12 ч | ZAP, Nuclei, RESTler, Postman, ffuf |
| **4** | [Инфраструктура](stage-4-infrastructure/README.md) | ~12 ч | Dockle, Checkov, Kubescape, Falco, Kyverno |
| **5** | [Пайплайн](stage-5-pipeline-integration/README.md) | ~12 ч | GitHub Actions, DefectDojo, cosign, SLSA |

---

## Что уже реализовано

- Структура из 6 этапов обучения и документация по каждому этапу.
- Учебные мишени и инструкции по их запуску.
- Набор automation-targets в `Makefile` для инфраструктуры и этапов (`lab-*`, `stage1-*` … `stage5-*`, `scan-all`).
- Скрипты подготовки окружения и проверки инструментов.
- Базовые шаблоны/каркас для интеграции отчётов и quality gates.

## Что выполняет студент

- Последовательно проходит этапы и запускает соответствующие цели `Makefile`.
- Анализирует отчёты сканеров, устраняет проблемы и фиксирует результаты в артефактах этапов.
- Создаёт недостающие пользовательские артефакты (например, скрипты интеграции для этапа 5 в своей зоне решений).
- Настраивает требования и quality gates под контекст своей команды/учебной программы.

---

## Для кого этот курс

<div class="grid cards" markdown>

-   **Junior/Middle DevSecOps**

    ---

    Хотите системно изучить инструменты и процессы безопасной разработки

-   **AppSec-инженеры**

    ---

    Нужна практика с конкретными инструментами и привязка к ГОСТу

-   **Разработчики**

    ---

    Хотите понять, что делает DevSecOps и зачем все эти сканеры в CI

-   **Готовящиеся к аудиту**

    ---

    Нужно внедрить ГОСТ Р 56939-2024 и показать аудитору ФСТЭК артефакты

</div>

---

<div class="hero-cta" markdown>

[:material-rocket-launch: Начать с быстрого старта](quickstart.md){ .md-button .md-button--primary .md-button--stretch }

</div>
