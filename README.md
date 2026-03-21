# 🛡️ DevSecOps Lab · ГОСТ Р 56939-2024

**Практический полигон для изучения безопасной разработки ПО в соответствии с ГОСТ Р 56939-2024**

[![GOST](https://img.shields.io/badge/ГОСТ_Р-56939--2024-blue)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)]()

---

## Что это такое

Это обучающий репозиторий для начинающих DevSecOps-инженеров. Здесь вы пройдёте путь от теории ГОСТа до практической автоматизации проверок безопасности и поймёте, зачем нужен каждый шаг.

Репозиторий построен как **последовательный курс из 6 этапов**. Каждый этап наращивает навыки поверх предыдущего. Вы работаете с реальными open-source инструментами на проверенных уязвимых приложениях.

## Что уже реализовано в репозитории

- Структура курса из 6 этапов (`stage-0` … `stage-5`) с отдельными README и тематическими директориями.
- Набор мишеней в `targets/` (Juice Shop, WrongSecrets, crAPI, Kubernetes Goat) с инструкциями по запуску.
- Базовая лабораторная инфраструктура и orchestration-цели в `Makefile`: `lab-up`, `lab-all`, `lab-down`, `lab-status`.
- Автоматизация сканирований по этапам в `Makefile`: `stage1-*`, `stage2-*`, `stage3-*`, `stage4-*`, `stage5-*`, а также сводные цели `stage1`, `stage2`, `stage3`, `stage4`, `scan-all`.
- Скрипты подготовки окружения и проверки инструментов в `scripts/`.
- Справочные материалы и маппинг процессов ГОСТ в `docs/` и `checklists/`.

## Что выполняет студент

- Поднимает нужные сервисы и мишени (`make lab-up`/`make lab-all`) и проверяет доступность стенда.
- Проходит этапы последовательно: изучает материалы, запускает соответствующие automation-targets и анализирует отчёты в `reports/`.
- Формирует артефакты этапов (модель угроз, требования безопасности, отчёты SAST/SCA/DAST/IaC и др.).
- Дополняет/адаптирует отсутствующие скрипты в зоне решений (например, интеграции для этапа 5), где `Makefile` прямо ожидает пользовательскую реализацию.
- Настраивает quality gates и процесс обработки уязвимостей под требования своей команды/учебной задачи.

**Для кого:**
- Junior/Middle DevSecOps, AppSec-инженеры
- Разработчики, которые хотят понять безопасную разработку
- Специалисты, готовящиеся к аудиту по ГОСТ Р 56939-2024
- Студенты профильных специальностей

**Что нужно для старта:**
- Docker и Docker Compose
- Git (базовый уровень)
- Знание любого языка программирования (Python — плюс)
- Терминал (Linux/macOS/WSL)

---

## Навигация по репозиторию

```
devsecops-intern-labs/
│
├── README.md                        ← вы здесь
├── CONTRIBUTING.md                  ← как контрибьютить
├── LICENSE
│
├── docs/                            ← справочные материалы
│   ├── gost-56939-overview.md       ← обзор ГОСТа человеческим языком
│   ├── gost-process-mapping.md      ← маппинг 25 процессов → этапы → инструменты
│   ├── glossary.md                  ← термины и определения
│   └── further-reading.md           ← ссылки для углублённого изучения
│
├── targets/                         ← 🎯 уязвимые приложения-мишени
│   ├── README.md                    ← обзор всех мишеней и когда что запускать
│   ├── juice-shop/                  ← 🥇 OWASP Juice Shop — основная мишень
│   │   ├── README.md                ← описание, запуск, что на каких этапах
│   │   └── docker-compose.yml       ← запуск одной командой
│   ├── wrong-secrets/               ← 🔑 OWASP WrongSecrets — для лабы по секретам
│   │   ├── README.md
│   │   └── docker-compose.yml
│   ├── crapi/                       ← 🔌 OWASP crAPI — для API security
│   │   └── README.md
│   └── kubernetes-goat/             ← ☸ Kubernetes Goat — для K8s security
│       └── README.md
│
│   ╔══════════════════════════════════════════════════════════════╗
│   ║                    ЭТАПЫ ОБУЧЕНИЯ                           ║
│   ╚══════════════════════════════════════════════════════════════╝
│
├── stage-0/                         ← Этап 0 · Фундамент
│   ├── README.md
│   ├── 0.1-gost-theory/             ← теория ГОСТа, маппинг процессов
│   ├── 0.2-threat-modeling/         ← STRIDE, DFD, pytm
│   └── 0.3-security-requirements/   ← требования безопасности
│
├── stage-1-static-analysis/         ← Этап 1 · Код под микроскопом
│   ├── README.md
│   ├── sast/                        ← SAST: Semgrep, Bandit, njsscan
│   ├── secrets/                     ← поиск секретов: Gitleaks, TruffleHog
│   └── linters/                     ← security linters
│
├── stage-2-dependencies/            ← Этап 2 · Зависимости и состав ПО
│   ├── README.md
│   ├── sca/                         ← SCA: OWASP Dep-Check, Trivy
│   ├── sbom/                        ← SBOM: CycloneDX, SPDX
│   └── license-audit/               ← анализ лицензий
│
├── stage-3-dynamic-analysis/        ← Этап 3 · Атакуем приложение
│   ├── README.md
│   ├── dast/                        ← DAST: OWASP ZAP, Nuclei
│   ├── fuzzing/                     ← фаззинг: AFL++, libFuzzer
│   └── api-testing/                 ← тестирование API (crAPI)
│
├── stage-4-infrastructure/          ← Этап 4 · Инфраструктура
│   ├── README.md
│   ├── container-sec/               ← Trivy, Grype, Dockle
│   ├── iac-sec/                     ← Checkov, tfsec
│   └── k8s-sec/                     ← kube-bench, OPA (Kubernetes Goat)
│
├── stage-5-pipeline-integration/    ← Этап 5 · Собираем пайплайн
│   ├── README.md
│   ├── ci-cd/                       ← шаблоны GitLab CI / GitHub Actions
│   ├── defectdojo/                  ← управление уязвимостями
│   └── quality-gates/               ← метрики и критерии прохождения
│
├── checklists/                      ← чеклисты по пунктам ГОСТа
│   ├── README.md
│   └── stage-{0..5}-checklist.md
│
└── scripts/                         ← утилиты
    ├── setup.sh                     ← быстрая установка зависимостей
    ├── check-tools.sh               ← проверка установленных инструментов
    └── reset-lab.sh                 ← сброс лабы в исходное состояние
```

---

## 🎯 Мишени

Мы не пишем своё уязвимое приложение — используем лучшие open-source проекты, каждый под свою задачу.

| Мишень | Роль в курсе | Стек | Этапы |
|--------|-------------|------|-------|
| [**OWASP Juice Shop**](targets/juice-shop/) | 🥇 Основная мишень | Node.js, Angular, SQLite | 0, 1, 2, 3, 5 |
| [**OWASP WrongSecrets**](targets/wrong-secrets/) | Лаба по секретам | Java, Docker, K8s | 1 |
| [**OWASP crAPI**](targets/crapi/) | API security | Go + Python + JS | 3 |
| [**Kubernetes Goat**](targets/kubernetes-goat/) | K8s security | K8s manifests | 4 |

**Не нужно ставить всё сразу.** Для начала достаточно Juice Shop — остальное понадобится на конкретных этапах.

```bash
# Запустить основную мишень — всё, можно начинать
docker run --rm -p 3000:3000 bkimminich/juice-shop
```

Подробности — в [`targets/README.md`](targets/README.md).

---

## Маршрут обучения

Этапы проходятся **строго последовательно** — каждый следующий опирается на результаты предыдущего.

### Этап 0 · Фундамент
> *«Сначала пойми что защищаем и от чего»*

Знакомство с ГОСТ Р 56939-2024, моделирование угроз (STRIDE, DFD), формирование требований безопасности. Никаких инструментов — только анализ и документация. Результат: модель угроз и security requirements для Juice Shop.

**Мишень:** Juice Shop (архитектура) · **Процессы ГОСТа:** 5.1, 5.5, 5.6, 5.7

📂 [`stage-0/`](stage-0/) · ⏱ ~8 часов · 🔧 draw.io, pytm

---

### Этап 1 · Код под микроскопом
> *«Ищем баги, не запуская приложение»*

Статический анализ кода (SAST), поиск захардкоженных секретов, security linters.

**Мишени:** Juice Shop (код) + WrongSecrets (секреты) · **Процессы ГОСТа:** 5.8, 5.9, 5.15

📂 [`stage-1-static-analysis/`](stage-1-static-analysis/) · ⏱ ~6 часов · 🔧 Semgrep, Bandit, Gitleaks

---

### Этап 2 · Зависимости и состав ПО
> *«Что тянем из интернета и насколько это безопасно»*

Композиционный анализ (SCA), генерация SBOM, аудит лицензий.

**Мишень:** Juice Shop (npm/node_modules) · **Процессы ГОСТа:** 5.4, 5.10

📂 [`stage-2-dependencies/`](stage-2-dependencies/) · ⏱ ~4 часа · 🔧 OWASP Dep-Check, Trivy, CycloneDX

---

### Этап 3 · Атакуем приложение
> *«Приложение запущено — бьём снаружи»*

Динамический анализ (DAST), фаззинг, тестирование API.

**Мишени:** Juice Shop (DAST) + crAPI (API security) · **Процессы ГОСТа:** 5.11, 5.12, 5.13

📂 [`stage-3-dynamic-analysis/`](stage-3-dynamic-analysis/) · ⏱ ~8 часов · 🔧 OWASP ZAP, Nuclei, AFL++

---

### Этап 4 · Инфраструктура
> *«Защищаем не только код, но и окружение»*

Безопасность контейнеров, Infrastructure as Code, Kubernetes.

**Мишени:** Juice Shop (Docker) + Kubernetes Goat (K8s) · **Процессы ГОСТа:** 5.3, 5.4

📂 [`stage-4-infrastructure/`](stage-4-infrastructure/) · ⏱ ~6 часов · 🔧 Trivy, Checkov, kube-bench

---

### Этап 5 · Собираем пайплайн
> *«Всё вместе — от коммита до деплоя»*

Интеграция отчётов и проверок в CI/CD-процесс: импорт в DefectDojo, quality gates, базовые метрики безопасности.

**Мишень:** Juice Shop (полный цикл) · **Процессы ГОСТа:** 5.14, 5.16, 5.17

📂 [`stage-5-pipeline-integration/`](stage-5-pipeline-integration/) · ⏱ ~8 часов · 🔧 GitLab CI / GitHub Actions, DefectDojo

---

## Быстрый старт

```bash
# 1. Клонируем репозиторий
git clone https://github.com/<your-username>/devsecops-intern-labs.git
cd devsecops-intern-labs

# 2. Проверяем инструменты
chmod +x scripts/check-tools.sh
./scripts/check-tools.sh

# 3. Запускаем основную мишень
docker run --rm -p 3000:3000 bkimminich/juice-shop

# 4. Открываем http://localhost:3000 — Juice Shop работает

# 5. Начинаем с этапа 0
cat stage-0/README.md
```

---

## Связь с ГОСТ Р 56939-2024

Каждый этап привязан к конкретным разделам ГОСТа. Полный маппинг 25 процессов — в [`docs/gost-process-mapping.md`](docs/gost-process-mapping.md).

| Процесс ГОСТа (раздел 5)                        | Этап  | Мишень             |
|--------------------------------------------------|-------|--------------------|
| 5.1 Планирование процессов РБПО                  | 0     | —                  |
| 5.2 Обеспечение инструментальной среды            | 0, 5  | —                  |
| 5.3 Управление ИТ-инфраструктурой                | 4     | K8s Goat           |
| 5.4 Управление конфигурацией ПО                   | 2, 4  | Juice Shop         |
| 5.5 Обучение сотрудников                          | 0     | —                  |
| 5.6 Формирование требований безопасности          | 0     | Juice Shop         |
| 5.7 Моделирование угроз                           | 0     | Juice Shop         |
| 5.8 Правила кодирования                           | 1     | Juice Shop         |
| 5.9 Статический анализ                            | 1     | Juice Shop         |
| 5.10 Композиционный анализ                        | 2     | Juice Shop         |
| 5.11 Динамический анализ                          | 3     | Juice Shop + crAPI |
| 5.12 Функциональное тестирование                  | 3     | Juice Shop + crAPI |
| 5.13 Нефункциональное тестирование                | 3     | Juice Shop         |
| 5.14 Управление недостатками                      | 5     | Juice Shop         |
| 5.15 Обеспечение безопасности секретов            | 1     | WrongSecrets       |
| 5.16 Обеспечение безопасности при выпуске         | 5     | Juice Shop         |
| 5.17–5.25 Эксплуатация, вывод и прочее           | 5     | —                  |

---

## Чеклисты

После каждого этапа пройдите чеклист самопроверки. Пункты привязаны к разделам ГОСТа.

📂 [`checklists/`](checklists/)

---

## Как устроен каждый этап

```
stage-N/
├── README.md          ← обзор: цели, мишень, привязка к ГОСТу
├── module-name/
│   ├── README.md      ← теория по модулю
│   ├── tasks.md       ← задания (практика + артефакты)
│   ├── examples/      ← примеры конфигов, отчётов, скриптов
│   └── templates/     ← шаблоны для выполнения заданий
```

Теги заданий:
- 🟣 **теория** — прочитать и разобраться
- 🟢 **практика** — сделать руками
- 🟡 **артефакт** — создать файл в репо

---

## Вклад в проект

Мы открыты для контрибьюций! Подробности — в [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## Полезные ссылки

- [ГОСТ Р 56939-2024 (полный текст)](https://docs.cntd.ru/document/1310017763)
- [ГОСТ Р 58412 — угрозы при разработке ПО](https://docs.cntd.ru/document/1200121884)
- [Приказ ФСТЭК № 240 — сертификация РБПО](https://fstec.ru/dokumenty/vse-dokumenty/spetsialnye-normativnye-dokumenty/poryadok-provedeniya-sertifikatsii-utverzhden-prikazom-fstek-rossii-ot-1-dekabrya-2023-g-n-240)
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
- [OWASP SAMM](https://owaspsamm.org/)
- [pytm — threat modeling as code](https://github.com/izar/pytm)

---

## Лицензия

MIT. Используйте, форкайте, обучайте.

---

<p align="center">
  <i>Сделано для тех, кто хочет не просто запускать инструменты, а понимать зачем.</i>
</p>
