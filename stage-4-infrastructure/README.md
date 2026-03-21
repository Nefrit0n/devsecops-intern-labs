# Этап 4 · Инфраструктура

> *«Защищаем не только код, но и окружение»*

**Время:** ~12 часов · **Сложность:** выше средней
**Мишени:** Juice Shop Docker image (контейнеры, IaC) + Kubernetes Goat (K8s)
**Процессы ГОСТа:** 5.3 (управление ИТ-инфраструктурой), 5.4 (управление конфигурацией)

---

## Зачем защищать инфраструктуру

На этапах 1–3 вы нашли уязвимости в коде, зависимостях, и работающем приложении. Но код запускается не в вакууме — он живёт *внутри инфраструктуры*: Docker-контейнеры, Kubernetes-кластеры, Terraform-конфигурации. И эта инфраструктура тоже уязвима.

| Вектор атаки | Что происходит | Реальный кейс |
|-------------|----------------|---------------|
| Контейнер запущен от root | Побег из контейнера → доступ к хосту | Множество CVE в runc/containerd |
| Base image с 500+ CVE | Атакующий эксплуатирует уязвимость ОС | Уязвимые alpine/debian образы |
| Terraform с `0.0.0.0/0` ingress | Весь интернет имеет доступ к сервису | Массовые утечки через открытые S3/DB |
| K8s pod с privileged: true | Полный доступ к ноде из контейнера | Tesla crypto-mining (2018) |
| Отсутствие network policies | Lateral movement между подами | Capital One breach (2019) |

ГОСТ Р 56939-2024 добавил **процесс 5.3 (управление ИТ-инфраструктурой)** именно потому, что SolarWinds (2020) показал: компрометация *среды разработки* = компрометация продукта.

---

## Три слоя инфраструктурной безопасности

### 📦 Слой 1 · Container security — безопасность Docker-образов
*«Что внутри нашего контейнера и правильно ли он собран?»*

Инструменты: **Trivy image**, **Grype**, **Dockle**, **Docker Scout**

### 🏗️ Слой 2 · IaC security — безопасность инфраструктуры как кода
*«Наш Dockerfile, K8s манифесты, Terraform — нет ли мисконфигураций?»*

Инструменты: **Checkov**, **KICS**, **Trivy config**, **KubeLinter**

### ☸️ Слой 3 · Kubernetes security — безопасность кластера
*«Кластер настроен по CIS benchmark? Кто может деплоить privileged поды?»*

Инструменты: **Kubescape**, **kube-bench**, **Falco**, **Kyverno**

---

## Арсенал

### 📦 Container security

| Инструмент | Зачем | Суперсила |
|------------|-------|-----------|
| **Trivy image** | CVE + misconfig + secrets в образе | Всё-в-одном, швейцарский нож |
| **Grype** | Vuln scan через SBOM | Syft→Grype: инвентаризация → сканирование |
| **Dockle** | CIS Docker Benchmark | Не CVE, а best practices: root, SETUID, healthcheck |
| **Docker Scout** | Встроен в Docker | Рекомендации по base image: alpine vs distroless |

### 🏗️ IaC security

| Инструмент | Зачем | Суперсила |
|------------|-------|-----------|
| **Checkov** | Основной IaC-сканер | 1000+ политик, graph-based анализ связей |
| **KICS** | Максимальное покрытие | 22+ платформ, 2400+ Rego-запросов |
| **Trivy config** | Один инструмент для всего | Поглотил tfsec, Dockerfile + K8s + Terraform |
| **KubeLinter** | Быстрый K8s линтер | 40+ проверок, resource limits, probes, securityContext |

### ☸️ Kubernetes security

| Инструмент | Зачем | Суперсила |
|------------|-------|-----------|
| **Kubescape** | Posture scan | CNCF Incubating, CIS + NSA-CISA + MITRE ATT&CK |
| **kube-bench** | CIS Kubernetes Benchmark | Стандарт аудита кластера |
| **Falco** | Runtime threat detection | CNCF Graduated, syscall monitoring, real-time alerts |
| **Kyverno** | Policy enforcement | YAML-native admission control, блокировка небезопасных деплоев |

---

## Порядок прохождения

| #   | Модуль | Время | Мишень | Результат |
|-----|--------|-------|--------|-----------|
| 4.1 | Container security | ~4 ч | Juice Shop Docker image | Отчёты Trivy+Grype+Dockle+Scout, сравнение, hardened image |
| 4.2 | IaC security | ~4 ч | Dockerfile + K8s manifests | Отчёты Checkov+KICS+Trivy+KubeLinter, кастомные политики |
| 4.3 | Kubernetes security | ~4 ч | Kubernetes Goat (minikube) | CIS audit, runtime detection, policy enforcement |

---

## Подготовка

```bash
# Мишень 1: Docker-образ Juice Shop
docker pull bkimminich/juice-shop

# Мишень 2: Kubernetes Goat (нужен minikube или kind)
minikube start --memory=4096
git clone https://github.com/madhuakula/kubernetes-goat.git targets/kubernetes-goat/src
cd targets/kubernetes-goat/src && bash setup.sh

# Инструменты — Container
# Trivy и Grype уже установлены (этап 2)
# Dockle
brew install goodwithtech/r/dockle  # macOS
# или: docker run --rm goodwithtech/dockle

# Инструменты — IaC
pip install checkov
docker pull checkmarx/kics
# Trivy уже установлен
go install golang.stackrox.io/kube-linter/cmd/kube-linter@latest

# Инструменты — Kubernetes
curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash
# kube-bench запускается как Job в кластере
# Falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco
# Kyverno
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

---

## Главный принцип этапа

На этапах 1–3 вы защищали *приложение*. Здесь вы защищаете *платформу*, на которой приложение работает. Это сдвиг мышления:

- **Этапы 1–3:** «В коде есть SQL injection» → исправить код
- **Этап 4:** «Контейнер запущен от root» → даже если SQL injection исправлена, атакующий может эксплуатировать другие CVE и получить root на хосте

Ключевой навык: **defense in depth**. Каждый слой (код → контейнер → IaC → кластер) — отдельный рубеж. Пробили один — упёрлись в следующий.

---

## Начинаем

👉 [`container-sec/`](container-sec/)

---

## Артефакты этапа

```
stage-4-infrastructure/
├── container-sec/
│   ├── trivy-image-report.json        ← CVE в образе Juice Shop
│   ├── grype-image-report.json        ← Grype findings
│   ├── dockle-report.json             ← CIS Docker Benchmark
│   ├── scout-recommendations.md       ← Docker Scout рекомендации по base image
│   ├── hardened-Dockerfile            ← исправленный Dockerfile
│   └── container-comparison.md        ← сравнение 4 инструментов
├── iac-sec/
│   ├── checkov-report.json            ← Checkov findings
│   ├── kics-report.json               ← KICS findings
│   ├── trivy-config-report.json       ← Trivy config findings
│   ├── kubelinter-report.json         ← KubeLinter findings
│   ├── configs/custom-policy.py       ← кастомная Checkov-политика
│   ├── juice-shop-k8s-manifests/      ← K8s манифесты для Juice Shop
│   └── iac-comparison.md              ← сравнение 4 сканеров
├── k8s-sec/
│   ├── kubescape-report.json          ← Kubescape CIS + NSA + MITRE
│   ├── kube-bench-report.json         ← CIS Kubernetes Benchmark
│   ├── falco-alerts.json              ← Falco runtime alerts
│   ├── configs/kyverno-policies/      ← Kyverno policy YAMLs
│   └── k8s-comparison.md             ← сравнение + K8s Goat findings
└── stage-4-summary.md                 ← defense in depth: все слои вместе
```

После завершения → [`../checklists/stage-4-checklist.md`](../checklists/stage-4-checklist.md) → [Этап 5](../stage-5-pipeline-integration/)
