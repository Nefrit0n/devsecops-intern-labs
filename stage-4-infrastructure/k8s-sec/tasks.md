# Задания · Модуль 4.3 — Kubernetes Security

> **Важно:** нужен работающий K8s кластер (minikube) с Kubernetes Goat.
> ```bash
> minikube start --memory=4096
> cd targets/kubernetes-goat/src && bash setup.sh
> ```

---

## Задание 1 · Kubescape: комплексный posture scan
**Тег:** 🟢 практика · **Время:** ~1 ч

Kubescape — CNCF Incubating проект, поддерживает три фреймворка:

### Шаг 1: CIS Kubernetes Benchmark

```bash
kubescape scan framework cis-v1.23-t1.0.1 --format json \
  --output stage-4-infrastructure/k8s-sec/kubescape-cis-report.json
```

### Шаг 2: NSA-CISA Hardening Guide

```bash
kubescape scan framework nsa --format json \
  --output stage-4-infrastructure/k8s-sec/kubescape-nsa-report.json
```

### Шаг 3: MITRE ATT&CK for Containers

```bash
kubescape scan framework mitre --format json \
  --output stage-4-infrastructure/k8s-sec/kubescape-mitre-report.json
```

### Шаг 4: Скан YAML-манифестов (без кластера)

```bash
kubescape scan stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/
```

Это работает даже без запущенного кластера — полезно для CI.

### Анализ

Для каждого фреймворка запишите:
- Risk score (0–100)
- Top-5 failed controls с описанием
- Какие remediation steps предлагает Kubescape

---

## Задание 2 · kube-bench: CIS Benchmark аудит
**Тег:** 🟢 практика · **Время:** ~45 мин

kube-bench — эталонный инструмент для CIS Kubernetes Benchmark. Запускается *внутри* кластера:

```bash
# Запуск как Job
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

# Посмотреть результат
kubectl logs job.batch/kube-bench
```

### Анализ

kube-bench проверяет конфигурацию компонентов кластера:
- **Master node:** API server, controller manager, scheduler, etcd
- **Worker node:** kubelet, proxy

Для каждого раздела запишите: PASS / FAIL / WARN.

| Компонент | PASS | FAIL | WARN | Самый критичный FAIL |
|-----------|------|------|------|---------------------|
| API Server | | | | |
| Kubelet | | | | |
| etcd | | | | |

### Сравнение с Kubescape CIS

Оба инструмента используют CIS Benchmark, но подход разный:
- kube-bench: проверяет *конфигурацию компонентов* (kubelet flags, api-server args)
- Kubescape: проверяет *ресурсы в кластере* (pods, deployments, RBAC)

Что нашёл kube-bench, но не Kubescape? И наоборот?

---

## Задание 3 · Falco: runtime threat detection
**Тег:** 🟢 практика · **Время:** ~1 ч

Falco — CNCF Graduated проект. Мониторит syscalls и детектит аномалии в реальном времени.

### Шаг 1: Установка

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco falcosecurity/falco \
  --set falcosidekick.enabled=true \
  --set falcosidekick.webui.enabled=true \
  -n falco --create-namespace
```

### Шаг 2: Trigger alerts через Kubernetes Goat

Kubernetes Goat содержит сценарии, которые Falco должен задетектить:

```bash
# 1. Shell в контейнере (terminal shell in container)
kubectl exec -it <juice-shop-pod> -- /bin/sh

# 2. Чтение sensitive файлов
kubectl exec -it <pod> -- cat /etc/shadow

# 3. Запись в /etc
kubectl exec -it <pod> -- touch /etc/malicious
```

### Шаг 3: Проверьте алерты

```bash
kubectl logs -n falco -l app.kubernetes.io/name=falco -f
```

Какие правила Falco сработали? Типичные:
- `Terminal shell in container`
- `Read sensitive file untrusted`
- `Write below etc`
- `Contact K8S API Server From Container`

### Шаг 4: Кастомное правило

Создайте `configs/falco-custom-rules.yaml`:

```yaml
- rule: Juice Shop suspicious outbound connection
  desc: Detect outbound network connection from Juice Shop to unexpected IP
  condition: >
    outbound and container.name = "juice-shop" and
    not (fd.sip in (rfc_1918_addresses))
  output: >
    Unexpected outbound connection from Juice Shop
    (command=%proc.cmdline connection=%fd.name container=%container.name)
  priority: WARNING
  tags: [network, juice-shop]
```

---

## Задание 4 · Kyverno: policy enforcement
**Тег:** 🟢 практика · **Время:** ~1 ч

Kyverno — admission controller. Он не *обнаруживает* проблемы — он *блокирует* небезопасные деплойменты.

### Шаг 1: Установка

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

### Шаг 2: Политика: запрет privileged контейнеров

Создайте `configs/kyverno-policies/deny-privileged.yaml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-privileged-containers
spec:
  validationFailureAction: Enforce
  rules:
  - name: deny-privileged
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Privileged контейнеры запрещены (Требование D-02)"
      pattern:
        spec:
          containers:
          - securityContext:
              privileged: "!true"
```

```bash
kubectl apply -f configs/kyverno-policies/deny-privileged.yaml
```

### Шаг 3: Проверка

```bash
# Попробуйте задеплоить privileged pod — должно быть rejected!
kubectl apply -f stage-4-infrastructure/iac-sec/juice-shop-k8s-manifests/deployment.yaml
# Error: admission webhook denied the request
```

### Шаг 4: Дополнительные политики

Создайте ещё 2 политики:

1. **Enforce resource limits** — pod без CPU/memory limits → rejected
2. **Deny latest tag** — image с `:latest` → rejected

### Шаг 5: Kyverno vs OPA/Gatekeeper

Kyverno использует нативный YAML. OPA/Gatekeeper требует Rego. Для начинающих Kyverno проще, но OPA мощнее для сложных правил.

---

## Задание 5 · Сводный отчёт
**Тег:** 🟡 артефакт · **Время:** ~30 мин

Создайте `k8s-comparison.md`:

```markdown
# Kubernetes Security · Kubernetes Goat

## Posture scan

| Фреймворк | Kubescape risk score | Top failure | Remediation |
|-----------|---------------------|-------------|-------------|
| CIS | ___/100 | | |
| NSA-CISA | ___/100 | | |
| MITRE ATT&CK | ___/100 | | |

## kube-bench CIS Benchmark

| Компонент | PASS | FAIL | WARN |
|-----------|------|------|------|
| API Server | | | |
| Kubelet | | | |

## Runtime detection (Falco)

| Trigger | Rule сработал? | Priority | Alert text |
|---------|---------------|----------|------------|
| Shell in container | | | |
| Read /etc/shadow | | | |
| Write below /etc | | | |

## Policy enforcement (Kyverno)

| Политика | Тип | Тест | Результат |
|----------|-----|------|-----------|
| deny-privileged | Enforce | Deploy privileged pod | Rejected ✓/✗ |
| require-limits | Enforce | Deploy pod without limits | Rejected ✓/✗ |
| deny-latest | Enforce | Deploy with :latest | Rejected ✓/✗ |

## Ключевой вывод
Pre-deploy (Kubescape + kube-bench) + Admission (Kyverno) + Runtime (Falco) = defense in depth для K8s.
```

---

## Чеклист самопроверки

- [ ] Kubescape: три фреймворка (CIS, NSA, MITRE), risk scores
- [ ] kube-bench: CIS Benchmark PASS/FAIL для master и worker
- [ ] Сравнение Kubescape vs kube-bench: кто что покрывает
- [ ] Falco: установлен, 3+ alerts triggered через K8s Goat
- [ ] Falco: кастомное правило создано
- [ ] Kyverno: 3 политики (privileged, limits, latest), enforce работает
- [ ] Попытка деплоя небезопасного пода → rejected
- [ ] `k8s-comparison.md` заполнен

---

🏁 **Этап 4 завершён!**

Создайте `stage-4-summary.md`:
- **Defense in depth:** сколько слоёв защиты покрыли (Dockerfile → Image → IaC → Cluster → Runtime)
- **Hardened Dockerfile:** на сколько процентов уменьшились CVE
- **Hardened manifests:** 0 FAILED checks?
- **K8s Goat:** сколько сценариев обнаружены инструментами
- Какие **требования из этапа 0** закрыты инфраструктурным анализом
- Что **осталось** для этапа 5 (пайплайн)

Чеклист: [`../../checklists/stage-4-checklist.md`](../../checklists/stage-4-checklist.md)

Переходите к [Этапу 5 → Собираем пайплайн](../../stage-5-pipeline-integration/)
