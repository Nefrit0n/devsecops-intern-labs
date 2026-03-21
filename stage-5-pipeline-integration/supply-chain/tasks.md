# Задания · Модуль 5.4 — Supply Chain Security

---

## Starter kit (минимальный skeleton)

```text
stage-5-pipeline-integration/supply-chain/
├── README.md
├── tasks.md
├── configs/
│   └── cosign-verify-policy.yaml
└── supply-chain-setup.md
```

Создайте минимальный набор перед практикой:

```bash
mkdir -p stage-5-pipeline-integration/supply-chain/configs
touch stage-5-pipeline-integration/supply-chain/configs/cosign-verify-policy.yaml
touch stage-5-pipeline-integration/supply-chain/supply-chain-setup.md
```

---

## Задание 1 · cosign: подписание Docker-образов
**Тег:** 🟢 практика · **Время:** ~1 ч

### Шаг 1: Генерация ключей

```bash
cosign generate-key-pair
# Создаст cosign.key (private) и cosign.pub (public)
```

### Шаг 2: Подписание образа

```bash
# Соберите образ (или используйте существующий)
docker build -t juice-shop-signed:latest targets/juice-shop/src
docker tag juice-shop-signed:latest ghcr.io/<your-user>/juice-shop:signed

# Подпись
cosign sign --key cosign.key ghcr.io/<your-user>/juice-shop:signed
```

### Шаг 3: Верификация

```bash
cosign verify --key cosign.pub ghcr.io/<your-user>/juice-shop:signed
```

Если подпись валидна — вывод JSON с деталями. Если образ подменён — ошибка.

### Шаг 4: Keyless signing (через GitHub Actions)

В GitHub Actions можно подписывать без ключей — через OIDC:

```yaml
- name: Sign image with cosign
  env:
    COSIGN_EXPERIMENTAL: "true"
  run: cosign sign ghcr.io/${{ github.repository }}:${{ github.sha }}
```

GitHub Actions выступает Identity Provider — cosign получает короткоживущий сертификат от Sigstore. Не нужно управлять ключами.

### Шаг 5: Attach SBOM к образу

```bash
# Подпишите SBOM и прикрепите к образу
cosign attest --key cosign.key --predicate sbom.cdx.json --type cyclonedx \
  ghcr.io/<your-user>/juice-shop:signed

# Верификация
cosign verify-attestation --key cosign.pub --type cyclonedx \
  ghcr.io/<your-user>/juice-shop:signed
```

Теперь SBOM криптографически привязан к образу. Нельзя подменить образ, оставив старый SBOM.

---

## Задание 2 · SLSA provenance
**Тег:** 🟢 практика · **Время:** ~45 мин

SLSA (Supply-chain Levels for Software Artifacts) — фреймворк от Google для гарантии происхождения артефактов. Provenance отвечает на вопрос: **«Этот образ точно собран нашим CI из нашего репозитория?»**

### GitHub Actions SLSA Generator

Добавьте в `security-main.yml`:

```yaml
  provenance:
    name: Generate SLSA provenance
    needs: build-and-scan
    permissions:
      actions: read
      id-token: write
      contents: write
      packages: write
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v2.0.0
    with:
      image: ghcr.io/${{ github.repository }}
      digest: ${{ needs.build-and-scan.outputs.digest }}
    secrets:
      registry-username: ${{ github.actor }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}
```

### Верификация provenance

```bash
slsa-verifier verify-image ghcr.io/<your-user>/juice-shop:signed \
  --source-uri github.com/<your-user>/devsecops-intern-labs \
  --source-tag v1.0.0
```

Это подтверждает:
- Образ собран *этим* репозиторием (не форком)
- Через *этот* CI/CD workflow (не локально)
- Из *этого* коммита (не подменённого)

---

## Задание 3 · Политика верификации при деплое
**Тег:** 🟢 практика · **Время:** ~30 мин

Создайте `configs/cosign-verify-policy.yaml` — политика для Kyverno, которая блокирует деплой неподписанных образов:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signature
spec:
  validationFailureAction: Enforce
  rules:
  - name: check-cosign-signature
    match:
      any:
      - resources:
          kinds:
          - Pod
    verifyImages:
    - imageReferences:
      - "ghcr.io/<your-user>/*"
      attestors:
      - entries:
        - keys:
            publicKeys: |
              -----BEGIN PUBLIC KEY-----
              <your cosign.pub content>
              -----END PUBLIC KEY-----
```

Попробуйте задеплоить неподписанный образ → **rejected!**

---

## Задание 4 · Сводка supply chain security
**Тег:** 🟡 артефакт · **Время:** ~15 мин

Создайте `supply-chain-setup.md`:

```markdown
# Supply Chain Security · Juice Shop

## Подписание образов
- Метод: cosign (key-pair / keyless через GH Actions)
- Подписан: ✓/✗
- SBOM attached: ✓/✗

## Provenance
- SLSA level: 3
- Generator: slsa-github-generator
- Верификация: slsa-verifier → ✓/✗

## Admission control
- Kyverno policy: verify-image-signature
- Неподписанный образ → rejected: ✓/✗

## Цепочка доверия
Code → CI Build → cosign sign → SLSA provenance → Registry → Kyverno verify → Deploy
Каждое звено криптографически подтверждено.
```

---

## Чеклист самопроверки

- [ ] cosign: ключи сгенерированы, образ подписан
- [ ] cosign: верификация подписи работает
- [ ] cosign: SBOM прикреплён к образу как attestation
- [ ] SLSA: provenance сгенерирован через GitHub Actions
- [ ] SLSA: верификация через slsa-verifier
- [ ] Kyverno: политика блокирует неподписанные образы
- [ ] `supply-chain-setup.md` заполнен

---

🏁 **Этап 5 завершён! Курс пройден!**

Создайте финальный `stage-5-summary.md` — **итог всего курса**:

1. **Пайплайн работает:** PR → сканы → quality gate → build → sign → deploy
2. **DefectDojo:** все findings из этапов 1–4 в одном месте, SLA настроен
3. **Quality gate:** requirements coverage ___%, blockers определены
4. **Supply chain:** образ подписан, provenance есть, admission control работает
5. **ГОСТ Р 56939-2024:** какие из 25 процессов покрыли практикой?

Итоговый чеклист: [`../../checklists/stage-5-checklist.md`](../../checklists/stage-5-checklist.md)

## 🎉 Поздравляем!

Вы прошли путь от «что такое ГОСТ» до работающего DevSecOps пайплайна с 30+ инструментами безопасности. Это реальный навык, который ценится на рынке.
