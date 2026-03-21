# ============================================================
# DevSecOps Lab · ГОСТ Р 56939-2024
# ============================================================
#
# make help        — показать все команды
# make lab-up      — поднять мишени
# make lab-all     — поднять всё
# make stage1-sast — запустить SAST-сканеры
#
# ============================================================

COMPOSE := docker compose -f lab-infra/docker-compose.lab.yml
JUICE_SHOP_SRC := targets/juice-shop/src
JUICE_SHOP_URL := http://localhost:3000
REPORTS := reports

.PHONY: help
help: ## Показать все команды
	@echo ""
	@echo "  DevSecOps Lab · Makefile"
	@echo "  ════════════════════════"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ────────────────────────────────────────────────────────────
# 🐳 Инфраструктура
# ────────────────────────────────────────────────────────────

.PHONY: lab-up lab-all lab-management lab-down lab-reset lab-status

lab-up: ## Поднять мишени (Juice Shop + WrongSecrets)
	$(COMPOSE) --profile targets up -d
	@echo "\n✅ Juice Shop:    http://localhost:3000"
	@echo "✅ WrongSecrets:  http://localhost:8080"

lab-all: ## Поднять всё (мишени + DefectDojo + Dependency-Track)
	$(COMPOSE) --profile all up -d
	@echo "\n✅ Juice Shop:       http://localhost:3000"
	@echo "✅ WrongSecrets:     http://localhost:8080"
	@echo "✅ DefectDojo:       http://localhost:8081  (admin / DevsecopsLab2024!)"
	@echo "✅ Dependency-Track: http://localhost:8083  (admin / admin)"
	@echo "\n⏳ DefectDojo может инициализироваться ~3 мин"

lab-management: ## Поднять только DefectDojo + Dependency-Track
	$(COMPOSE) --profile management up -d

lab-down: ## Остановить всё
	$(COMPOSE) --profile all down

lab-reset: ## Остановить и удалить все данные (полный сброс)
	$(COMPOSE) --profile all down -v
	@echo "✅ Все данные удалены"

lab-status: ## Статус контейнеров
	$(COMPOSE) --profile all ps

# ────────────────────────────────────────────────────────────
# 📥 Подготовка
# ────────────────────────────────────────────────────────────

.PHONY: clone-juice-shop check-tools setup

clone-juice-shop: ## Клонировать исходный код Juice Shop (для SAST)
	@if [ ! -d "$(JUICE_SHOP_SRC)" ]; then \
		git clone --depth 1 https://github.com/juice-shop/juice-shop.git $(JUICE_SHOP_SRC); \
		echo "✅ Juice Shop source cloned"; \
	else \
		echo "ℹ️  Juice Shop source already exists"; \
	fi

check-tools: ## Проверить установленные инструменты
	@chmod +x scripts/check-tools.sh && ./scripts/check-tools.sh

setup: ## Установить базовые инструменты (Python + npm)
	@chmod +x scripts/setup.sh && ./scripts/setup.sh

# ────────────────────────────────────────────────────────────
# 🔬 Этап 1 — Статический анализ
# ────────────────────────────────────────────────────────────

.PHONY: stage1-sast stage1-secrets stage1-linters stage1

$(REPORTS):
	@mkdir -p $(REPORTS)

stage1-sast: clone-juice-shop $(REPORTS) ## Этап 1: SAST (Semgrep + Bandit + njsscan)
	@echo "\n🔬 Semgrep..."
	semgrep --config auto --sarif -o $(REPORTS)/semgrep.sarif $(JUICE_SHOP_SRC) || true
	@echo "\n🔬 njsscan..."
	njsscan --sarif -o $(REPORTS)/njsscan.sarif $(JUICE_SHOP_SRC) || true
	@echo "\n✅ Отчёты: $(REPORTS)/semgrep.sarif, $(REPORTS)/njsscan.sarif"

stage1-secrets: clone-juice-shop $(REPORTS) ## Этап 1: Secrets (Gitleaks + TruffleHog)
	@echo "\n🔑 Gitleaks..."
	gitleaks detect --source $(JUICE_SHOP_SRC) --report-format json \
		--report-path $(REPORTS)/gitleaks.json || true
	@echo "\n🔑 TruffleHog..."
	trufflehog git file://$(JUICE_SHOP_SRC) --json > $(REPORTS)/trufflehog.json 2>/dev/null || true
	@echo "\n✅ Отчёты: $(REPORTS)/gitleaks.json, $(REPORTS)/trufflehog.json"

stage1-linters: clone-juice-shop $(REPORTS) ## Этап 1: Linters (hadolint + Ruff)
	@echo "\n📏 hadolint..."
	@if [ -f "$(JUICE_SHOP_SRC)/Dockerfile" ]; then \
		hadolint $(JUICE_SHOP_SRC)/Dockerfile --format json > $(REPORTS)/hadolint.json || true; \
	else \
		echo "  ⚠️  Dockerfile not found"; \
	fi
	@echo "\n✅ Отчёт: $(REPORTS)/hadolint.json"

stage1: stage1-sast stage1-secrets stage1-linters ## Этап 1: Все проверки

# ────────────────────────────────────────────────────────────
# 📦 Этап 2 — Зависимости
# ────────────────────────────────────────────────────────────

.PHONY: stage2-sca stage2-sbom stage2

stage2-sca: clone-juice-shop $(REPORTS) ## Этап 2: SCA (Trivy + Grype + npm audit)
	@echo "\n🔍 Trivy fs..."
	trivy fs $(JUICE_SHOP_SRC) --format json --output $(REPORTS)/trivy-fs.json \
		--severity CRITICAL,HIGH || true
	@echo "\n🔍 Trivy image..."
	trivy image bkimminich/juice-shop:v17.1.1 --format json \
		--output $(REPORTS)/trivy-image.json || true
	@echo "\n🔍 npm audit..."
	@cd $(JUICE_SHOP_SRC) && npm audit --json > ../../../$(REPORTS)/npm-audit.json 2>/dev/null || true
	@echo "\n✅ Отчёты в $(REPORTS)/"

stage2-sbom: clone-juice-shop $(REPORTS) ## Этап 2: SBOM (Syft → CycloneDX + SPDX)
	@echo "\n📦 Syft (CycloneDX)..."
	syft dir:$(JUICE_SHOP_SRC) -o cyclonedx-json > $(REPORTS)/sbom.cdx.json || true
	@echo "\n📦 Syft (SPDX)..."
	syft dir:$(JUICE_SHOP_SRC) -o spdx-json > $(REPORTS)/sbom.spdx.json || true
	@echo "\n📦 Grype (vuln scan по SBOM)..."
	grype sbom:$(REPORTS)/sbom.cdx.json --output json > $(REPORTS)/grype.json || true
	@echo "\n✅ SBOM + vuln scan в $(REPORTS)/"

stage2: stage2-sca stage2-sbom ## Этап 2: Все проверки

# ────────────────────────────────────────────────────────────
# 🌐 Этап 3 — Динамический анализ
# ────────────────────────────────────────────────────────────

.PHONY: stage3-dast stage3-nuclei stage3

stage3-dast: $(REPORTS) ## Этап 3: DAST (ZAP baseline)
	@echo "\n🌐 ZAP baseline scan..."
	docker run --rm --network=host \
		-v $(PWD)/$(REPORTS):/zap/wrk \
		ghcr.io/zaproxy/zaproxy:stable \
		zap-baseline.py -t $(JUICE_SHOP_URL) \
		-J /zap/wrk/zap-baseline.json || true
	@echo "\n✅ Отчёт: $(REPORTS)/zap-baseline.json"

stage3-nuclei: $(REPORTS) ## Этап 3: Nuclei scan
	@echo "\n🎯 Nuclei..."
	nuclei -u $(JUICE_SHOP_URL) -severity critical,high \
		-jsonl -o $(REPORTS)/nuclei.json || true
	@echo "\n✅ Отчёт: $(REPORTS)/nuclei.json"

stage3: stage3-dast stage3-nuclei ## Этап 3: Все проверки (нужен запущенный Juice Shop!)

# ────────────────────────────────────────────────────────────
# 🏗️ Этап 4 — Инфраструктура
# ────────────────────────────────────────────────────────────

.PHONY: stage4-container stage4-iac stage4

stage4-container: $(REPORTS) ## Этап 4: Container security (Trivy + Dockle)
	@echo "\n📦 Trivy image (full)..."
	trivy image bkimminich/juice-shop:v17.1.1 --format json \
		--output $(REPORTS)/trivy-image-full.json || true
	@echo "\n📦 Dockle..."
	dockle bkimminich/juice-shop:v17.1.1 --format json \
		--output $(REPORTS)/dockle.json || true
	@echo "\n✅ Отчёты в $(REPORTS)/"

stage4-iac: $(REPORTS) ## Этап 4: IaC security (Checkov)
	@echo "\n🏗️ Checkov..."
	checkov -d . --framework dockerfile,kubernetes --output json \
		> $(REPORTS)/checkov.json || true
	@echo "\n✅ Отчёт: $(REPORTS)/checkov.json"

stage4: stage4-container stage4-iac ## Этап 4: Все проверки

# ────────────────────────────────────────────────────────────
# 🚀 Этап 5 — Пайплайн
# ────────────────────────────────────────────────────────────

.PHONY: stage5-import stage5-gate

stage5-import: $(REPORTS) ## Этап 5: Импорт всех отчётов в DefectDojo
	@if [ -f "solutions/stage-5/defectdojo/import-reports.sh" ]; then \
		DD_URL=http://localhost:8081 bash solutions/stage-5/defectdojo/import-reports.sh; \
	else \
		echo "⚠️  import-reports.sh не найден. Создайте его в stage-5."; \
	fi

stage5-gate: $(REPORTS) ## Этап 5: Quality gate check
	@if [ -f "solutions/stage-5/quality-gates/quality-gate.py" ]; then \
		python solutions/stage-5/quality-gates/quality-gate.py \
			--sarif $(REPORTS)/semgrep.sarif \
			--trivy $(REPORTS)/trivy-fs.json; \
	else \
		echo "⚠️  quality-gate.py не найден. Создайте его в stage-5."; \
	fi

# ────────────────────────────────────────────────────────────
# 🔄 Полный прогон
# ────────────────────────────────────────────────────────────

.PHONY: scan-all

scan-all: stage1 stage2 stage3 stage4 ## Запустить ВСЕ сканеры (этапы 1–4)
	@echo ""
	@echo "════════════════════════════════════════"
	@echo "  ✅ Все сканы завершены"
	@echo "  📂 Отчёты: $(REPORTS)/"
	@echo "  📊 Следующий шаг: make stage5-import"
	@echo "════════════════════════════════════════"
