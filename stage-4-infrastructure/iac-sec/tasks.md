# Задания · Модуль 4.2 — IaC Security

---

## Starter kit (минимальный skeleton)

```text
stage-4-infrastructure/iac-sec/
├── README.md
├── tasks.md
├── configs/
│   └── custom-policy.py
├── juice-shop-k8s-manifests/
│   ├── deployment.yaml
│   └── service.yaml
└── iac-comparison.md
```

Создайте каркас перед запуском сканеров:

```bash
mkdir -p stage-4-infrastructure/iac-sec/configs
mkdir -p stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests
touch stage-4-infrastructure/iac-sec/configs/custom-policy.py
touch stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/deployment.yaml
touch stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/service.yaml
touch stage-4-infrastructure/iac-sec/iac-comparison.md
```

---

## Задание 0 · Подготовка: K8s манифесты для Juice Shop
**Тег:** 🟢 практика · **Время:** ~20 мин

Создайте `juice-shop-k8s-manifests/` с *намеренно небезопасными* манифестами:

**deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: juice-shop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: juice-shop
  template:
    metadata:
      labels:
        app: juice-shop
    spec:
      containers:
      - name: juice-shop
        image: bkimminich/juice-shop:latest  # latest tag
        ports:
        - containerPort: 3000
        # Нет resource limits
        # Нет readiness/liveness probes
        securityContext:
          privileged: true        # Dangerous!
          runAsUser: 0            # root!
```

**service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: juice-shop
spec:
  type: LoadBalancer  # exposed externally
  ports:
  - port: 3000
  selector:
    app: juice-shop
```

Сохраните в `iac-sec/juice-shop-k8s-manifests/`. Эти манифесты — мишень для сканеров.

---

## Задание 1 · Checkov: 1000+ политик
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Скан Dockerfile

```bash
checkov -f targets/juice-shop/src/Dockerfile --framework dockerfile \
  --output json > stage-4-infrastructure/iac-sec/checkov-dockerfile-report.json

# Человекочитаемый
checkov -f targets/juice-shop/src/Dockerfile --framework dockerfile
```

### Шаг 2: Скан K8s манифестов

```bash
checkov -d stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/ \
  --framework kubernetes \
  --output json > stage-4-infrastructure/iac-sec/checkov-k8s-report.json
```

Сколько FAILED checks? Типичные находки:
- `CKV_K8S_1`: Privileged container
- `CKV_K8S_6`: Root user
- `CKV_K8S_8`: No liveness probe
- `CKV_K8S_9`: No readiness probe
- `CKV_K8S_11`: No CPU limit
- `CKV_K8S_13`: No memory limit

### Шаг 3: Кастомная политика

Создайте `configs/custom-policy.py` — политика, привязанная к требованию из этапа 0:

```python
from checkov.kubernetes.checks.resource.base_spec_check import BaseK8SCheck
from checkov.common.models.enums import CheckResult, CheckCategories

class JuiceShopNoLatestTag(BaseK8SCheck):
    def __init__(self):
        name = "Ensure Juice Shop does not use 'latest' tag"
        id = "CKV_JUICE_001"
        supported_resources = ["Deployment"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(name=name, id=id, categories=categories,
                         supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        containers = conf.get("spec", {}).get("template", {}).get("spec", {}).get("containers", [])
        for container in containers:
            image = container.get("image", "")
            if ":latest" in image or ":" not in image:
                return CheckResult.FAILED
        return CheckResult.PASSED

check = JuiceShopNoLatestTag()
```

### Шаг 4: Suppression с обоснованием

```yaml
# В K8s manifest добавить комментарий:
# checkov:skip=CKV_K8S_11: CPU limits будут добавлены в следующем спринте (JIRA-123)
```

---

## Задание 2 · KICS: максимальное покрытие
**Тег:** 🟢 практика · **Время:** ~45 мин

```bash
docker run --rm -v $(pwd):/app checkmarx/kics:latest scan \
  -p /app/stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests \
  -p /app/targets/juice-shop/src/Dockerfile \
  -o /app/stage-4-infrastructure/iac-sec/ \
  --report-formats json
```

### Сравнение с Checkov:
- Что KICS нашёл, а Checkov пропустил?
- KICS использует Rego, Checkov — Python/YAML. Какой подход удобнее для кастомных правил?
- Exit codes: KICS возвращает 60 (Critical), 50 (High), 40 (Medium) — удобно для CI gate

---

## Задание 3 · Trivy config: один инструмент для всего
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
# Скан Dockerfile
trivy config targets/juice-shop/src/Dockerfile

# Скан K8s манифестов
trivy config stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/ \
  --format json --output stage-4-infrastructure/iac-sec/trivy-config-report.json
```

Trivy config = бывший tfsec + misconfig scanner. Один бинарник для container scan + IaC scan + SCA + SBOM.

Сравните: Trivy config vs Checkov vs KICS на *одних и тех же файлах*. Кто нашёл больше? Кто точнее?

---

## Задание 4 · KubeLinter: быстрый K8s lint
**Тег:** 🟢 практика · **Время:** ~30 мин

```bash
kube-linter lint stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/ \
  --format json > stage-4-infrastructure/iac-sec/kubelinter-report.json
```

KubeLinter — специализированный линтер для K8s. Быстрее Checkov, но охватывает меньше. Проверяет:
- Resource requests/limits
- Liveness/readiness probes
- SecurityContext (runAsNonRoot, readOnlyRootFilesystem)
- Privileged containers
- Host network/PID/IPC

Сравните с Checkov K8s checks: KubeLinter нашёл что-то уникальное?

---

## Задание 5 · Исправленные манифесты + сводное сравнение
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `juice-shop-k8s-manifests/hardened-deployment.yaml` — исправленную версию на основе findings. Просканируйте снова — 0 FAILED?

Создайте `iac-comparison.md`:

```markdown
# Сравнение IaC-сканеров

| Метрика | Checkov | KICS | Trivy config | KubeLinter |
|---------|---------|------|-------------|------------|
| Findings (Dockerfile) | | | | N/A |
| Findings (K8s manifests) | | | | |
| Кастомные правила | Python/YAML | Rego | Rego | YAML |
| Уникальные findings | | | | |
| Время скана | | | | |

## Original vs Hardened manifests
| Метрика | Original | Hardened |
|---------|----------|---------|
| Checkov FAILED | | |
| KubeLinter FAILED | | |
```

---

## Чеклист самопроверки

- [ ] K8s манифесты с намеренными ошибками созданы
- [ ] Checkov: Dockerfile + K8s скан, кастомная Python-политика
- [ ] KICS: скан, сравнение с Checkov
- [ ] Trivy config: скан, сравнение с Checkov и KICS
- [ ] KubeLinter: быстрый lint, сравнение с Checkov
- [ ] Hardened manifests созданы, сканы чистые
- [ ] `iac-comparison.md` заполнен

---

Далее → [`../k8s-sec/`](../k8s-sec/)
