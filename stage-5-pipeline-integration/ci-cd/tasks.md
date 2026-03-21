# Задания · Модуль 5.1 — CI/CD Pipeline

---

## Задание 1 · Pre-commit: первый рубеж
**Тег:** 🟢 практика · **Время:** ~30 мин

Создайте `pre-commit/.pre-commit-config.yaml`:

```yaml
repos:
  # Секреты (Gitleaks)
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks

  # Dockerfile (hadolint)
  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint-docker

  # SAST quick (Semgrep)
  - repo: https://github.com/semgrep/semgrep
    rev: v1.90.0
    hooks:
      - id: semgrep
        args: ['--config', 'auto', '--error', '--severity', 'ERROR']
```

```bash
# Установка
pip install pre-commit
cd targets/juice-shop/src
cp <path-to>/.pre-commit-config.yaml .
pre-commit install

# Тест: попробуйте закоммитить секрет
echo 'AWS_KEY="AKIAIOSFODNN7EXAMPLE"' > test.txt
git add test.txt && git commit -m "test"
# → Gitleaks должен заблокировать!
rm test.txt
```

---

## Задание 2 · GitHub Actions: PR pipeline
**Тег:** 🟢 практика · **Время:** ~1.5 ч

Создайте `github-actions/security-pr.yml`:

```yaml
name: Security · PR Checks

on:
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  sast:
    name: SAST (Semgrep + njsscan)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: auto
          generateSarif: "1"

      - name: Upload Semgrep SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: semgrep.sarif

      - name: njsscan
        run: |
          pip install njsscan
          njsscan --sarif -o njsscan.sarif . || true

      - name: Upload njsscan SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: njsscan.sarif
          category: njsscan

  sca:
    name: SCA (Trivy + npm audit)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Trivy filesystem scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
          format: 'sarif'
          output: 'trivy-fs.sarif'

      - name: Upload Trivy SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-fs.sarif

      - name: npm audit
        run: npm audit --audit-level=critical

  iac:
    name: IaC (Checkov + KubeLinter)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: dockerfile,kubernetes
          soft_fail: false
          output_format: sarif

      - name: KubeLinter
        run: |
          curl -sSL https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux -o kube-linter
          chmod +x kube-linter
          ./kube-linter lint k8s/ || true

  quality-gate:
    name: Quality Gate
    needs: [sast, sca, iac]
    runs-on: ubuntu-latest
    steps:
      - name: Check results
        run: |
          echo "All security checks passed — PR can be merged"
          # В реальности: парсинг SARIF и проверка на CRITICAL
```

### Ключевые моменты:

1. **SARIF upload** — результаты появляются в GitHub Security tab, прямо в PR
2. **Параллельные jobs** — SAST, SCA, IaC запускаются одновременно
3. **Quality gate** — финальный job, зависит от всех предыдущих
4. **soft_fail** — для начала можно поставить true (warn, не block), потом ужесточить

---

## Задание 3 · GitHub Actions: Main pipeline
**Тег:** 🟢 практика · **Время:** ~1.5 ч

Создайте `github-actions/security-main.yml`:

```yaml
name: Security · Main Pipeline

on:
  push:
    branches: [main]

permissions:
  contents: read
  packages: write
  security-events: write
  id-token: write  # для cosign keyless

env:
  IMAGE: ghcr.io/${{ github.repository }}:${{ github.sha }}

jobs:
  build-and-scan:
    name: Build + Container Security
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t $IMAGE .

      - name: Trivy image scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE }}
          format: 'json'
          output: 'trivy-image.json'
          severity: 'CRITICAL,HIGH'

      - name: Dockle
        run: |
          VERSION=$(curl -s "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
          curl -sSL "https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.tar.gz" | tar xz
          ./dockle --format json --output dockle.json $IMAGE || true

      - name: Syft SBOM
        run: |
          curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
          syft $IMAGE -o cyclonedx-json > sbom.cdx.json

      - name: Grype via SBOM
        run: |
          curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
          grype sbom:sbom.cdx.json --output json > grype.json || true

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: security-reports
          path: |
            trivy-image.json
            dockle.json
            sbom.cdx.json
            grype.json

  dast:
    name: DAST (ZAP baseline + Nuclei)
    needs: build-and-scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Start application
        run: docker run -d -p 3000:3000 $IMAGE

      - name: Wait for app
        run: |
          for i in $(seq 1 30); do
            curl -s http://localhost:3000 && break || sleep 2
          done

      - name: ZAP Baseline
        uses: zaproxy/action-baseline@v0.12.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-J zap-report.json'

      - name: Nuclei
        run: |
          go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
          nuclei -u http://localhost:3000 -severity critical,high -jsonl -o nuclei.json || true

  import-to-defectdojo:
    name: Import to DefectDojo
    needs: [build-and-scan, dast]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Download reports
        uses: actions/download-artifact@v4

      - name: Import to DefectDojo
        env:
          DD_URL: ${{ secrets.DEFECTDOJO_URL }}
          DD_TOKEN: ${{ secrets.DEFECTDOJO_TOKEN }}
          DD_ENGAGEMENT: ${{ secrets.DEFECTDOJO_ENGAGEMENT_ID }}
        run: |
          for report in trivy-image.json grype.json zap-report.json; do
            [ -f "security-reports/$report" ] && \
            curl -X POST "$DD_URL/api/v2/import-scan/" \
              -H "Authorization: Token $DD_TOKEN" \
              -F "scan_type=Trivy Scan" \
              -F "file=@security-reports/$report" \
              -F "engagement=$DD_ENGAGEMENT" \
              -F "active=true" \
              -F "verified=false" || true
          done
```

---

## Задание 4 · GitLab CI: альтернативный пайплайн
**Тег:** 🟢 практика · **Время:** ~30 мин

Создайте `gitlab-ci/.gitlab-ci.yml`:

```yaml
stages:
  - test
  - build
  - scan
  - dast
  - report

sast:
  stage: test
  image: semgrep/semgrep
  script:
    - semgrep --config auto --sarif -o semgrep.sarif .
  artifacts:
    reports:
      sast: semgrep.sarif

sca:
  stage: test
  image: aquasec/trivy
  script:
    - trivy fs --format sarif --output trivy.sarif .
  artifacts:
    reports:
      dependency_scanning: trivy.sarif

container_scan:
  stage: scan
  image: aquasec/trivy
  script:
    - trivy image --format json --output trivy-image.json $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    paths:
      - trivy-image.json

dast:
  stage: dast
  image: ghcr.io/zaproxy/zaproxy:stable
  script:
    - zap-baseline.py -t $APP_URL -J zap-report.json || true
  artifacts:
    paths:
      - zap-report.json

import_defectdojo:
  stage: report
  image: curlimages/curl
  script:
    - |
      curl -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
        -H "Authorization: Token $DEFECTDOJO_TOKEN" \
        -F "scan_type=Trivy Scan" \
        -F "file=@trivy-image.json" \
        -F "engagement=$DEFECTDOJO_ENGAGEMENT"
```

### Сравнение

Создайте `pipeline-comparison.md`:

| Аспект | GitHub Actions | GitLab CI |
|--------|---------------|-----------|
| SARIF upload | GitHub Security tab | GitLab Security Dashboard |
| Встроенные security templates | Нет (через Actions) | Да (Auto DevOps) |
| Self-hosted runner | ✓ | ✓ (GitLab Runner) |
| Стоимость для private repos | 2000 мин/мес бесплатно | 400 мин/мес бесплатно |

---

## Чеклист самопроверки

- [ ] Pre-commit: 3 хука (Gitleaks, hadolint, Semgrep) работают
- [ ] Pre-commit: секрет → коммит заблокирован
- [ ] GH Actions PR: SAST + SCA + IaC запускаются параллельно
- [ ] GH Actions PR: SARIF загружается в GitHub Security tab
- [ ] GH Actions Main: build + container scan + DAST + SBOM + import в DefectDojo
- [ ] GitLab CI: аналогичный пайплайн, сравнение с GH Actions
- [ ] `pipeline-comparison.md` заполнен

---

Далее → [`../defectdojo/`](../defectdojo/)
