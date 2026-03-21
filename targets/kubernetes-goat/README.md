# ☸ Kubernetes Goat

> Специализированная мишень для этапа 4, лаба по K8s security.

**Репозиторий:** [github.com/madhuakula/kubernetes-goat](https://github.com/madhuakula/kubernetes-goat)

---

## Почему Kubernetes Goat

- «Vulnerable by Design» Kubernetes-кластер
- 20+ сценариев: побег из контейнера, SSRF к metadata API, избыточные RBAC и др.
- Идеально для практики с kube-bench, OPA/Gatekeeper, Falco

---

## Быстрый запуск

```bash
# Требуется minikube или kind
minikube start

git clone https://github.com/madhuakula/kubernetes-goat.git
cd kubernetes-goat
bash setup.sh
```

---

## Что используем

| Этап | Лаба       | Задача                                            |
|------|------------|---------------------------------------------------|
| 4    | k8s-sec/   | kube-bench, анализ RBAC, OPA policies             |
| 4    | k8s-sec/   | Runtime security: Falco, сетевые политики         |
