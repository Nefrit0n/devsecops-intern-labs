---
description: "Практический полигон для изучения безопасной разработки ПО по ГОСТ Р 56939-2024. 6 этапов, 30+ инструментов, 4 учебные мишени."
hide:
  - navigation
  - toc
---

<div class="hero" markdown>

# DevSecOps Lab

## Практический полигон по ГОСТ Р 56939-2024

От теории стандарта до работающего пайплайна безопасности — за 6 последовательных этапов.

[Начать обучение :material-rocket-launch:](quickstart.md){ .md-button .md-button--primary }
[Маршрут обучения :material-map-outline:](roadmap.md){ .md-button }

</div>

---

## Маршрут обучения

<div class="timeline" markdown>
  <a class="timeline-step" href="stage-0/README.md">
    <div class="timeline-icon stage-0">0</div>
    <div class="timeline-label">Фундамент</div>
    <div class="timeline-time">~12 ч</div>
  </a>
  <div class="timeline-arrow">→</div>
  <a class="timeline-step" href="stage-1-static-analysis/README.md">
    <div class="timeline-icon stage-1">1</div>
    <div class="timeline-label">Статика</div>
    <div class="timeline-time">~10 ч</div>
  </a>
  <div class="timeline-arrow">→</div>
  <a class="timeline-step" href="stage-2-dependencies/README.md">
    <div class="timeline-icon stage-2">2</div>
    <div class="timeline-label">Зависимости</div>
    <div class="timeline-time">~10 ч</div>
  </a>
  <div class="timeline-arrow">→</div>
  <a class="timeline-step" href="stage-3-dynamic-analysis/README.md">
    <div class="timeline-icon stage-3">3</div>
    <div class="timeline-label">Динамика</div>
    <div class="timeline-time">~12 ч</div>
  </a>
  <div class="timeline-arrow">→</div>
  <a class="timeline-step" href="stage-4-infrastructure/README.md">
    <div class="timeline-icon stage-4">4</div>
    <div class="timeline-label">Инфраструктура</div>
    <div class="timeline-time">~12 ч</div>
  </a>
  <div class="timeline-arrow">→</div>
  <a class="timeline-step" href="stage-5-pipeline-integration/README.md">
    <div class="timeline-icon stage-5">5</div>
    <div class="timeline-label">Пайплайн</div>
    <div class="timeline-time">~12 ч</div>
  </a>
</div>

---

## Ключевые цифры

<div class="stat-cards">
  <div class="stat-card">
    <div class="stat-number">25</div>
    <div class="stat-label">процессов ГОСТа</div>
  </div>
  <div class="stat-card">
    <div class="stat-number">30+</div>
    <div class="stat-label">инструментов</div>
  </div>
  <div class="stat-card">
    <div class="stat-number">6</div>
    <div class="stat-label">этапов</div>
  </div>
  <div class="stat-card">
    <div class="stat-number">~60</div>
    <div class="stat-label">часов практики</div>
  </div>
</div>

---

## Что внутри

<div class="grid cards" markdown>

-   :material-shield-check:{ .lg .middle } **6 этапов обучения**

    ---

    Последовательный курс: каждый этап наращивает навыки поверх предыдущего

-   :material-tools:{ .lg .middle } **Automation через Makefile**

    ---

    Цели `lab-*`, `stage1-*` … `stage5-*`, `scan-all` для запуска этапов и сборки отчётов

-   :material-target:{ .lg .middle } **4 учебные мишени**

    ---

    Juice Shop, WrongSecrets, crAPI, Kubernetes Goat — проверенные уязвимые приложения

-   :material-file-document:{ .lg .middle } **ГОСТ Р 56939-2024**

    ---

    Каждый этап привязан к конкретным процессам ГОСТа. Готовит к аудиту ФСТЭК

-   :material-docker:{ .lg .middle } **Быстрый запуск стенда**

    ---

    `make lab-up` поднимает мишени, `make lab-all` — расширенный стенд с management-сервисами

-   :material-certificate:{ .lg .middle } **Практика + шаблоны**

    ---

    Не видео-курс, а репозиторий с заданиями, шаблонами и зонами для самостоятельной работы

</div>

---

## Для кого этот курс

<div class="grid cards" markdown>

-   :material-account-hard-hat:{ .lg .middle } **Junior/Middle DevSecOps**

    ---

    Хотите системно изучить инструменты и процессы безопасной разработки

-   :material-shield-account:{ .lg .middle } **AppSec-инженеры**

    ---

    Нужна практика с конкретными инструментами и привязка к ГОСТу

-   :material-code-braces:{ .lg .middle } **Разработчики**

    ---

    Хотите понять, что делает DevSecOps и зачем все эти сканеры в CI

-   :material-clipboard-check:{ .lg .middle } **Готовящиеся к аудиту**

    ---

    Нужно внедрить ГОСТ Р 56939-2024 и показать аудитору ФСТЭК артефакты

</div>

---

<div class="hero-cta" markdown>

[:material-rocket-launch: Начать обучение](quickstart.md){ .md-button .md-button--primary .md-button--stretch }

</div>
