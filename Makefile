.PHONY: help install-tools install-python-deps run-app build-app full-scan full-scan-warn full-scan-gate secret-scan sca-scan sast-scan container-scan sbom

help:
	@echo "Доступные команды:"
	@echo "  make install-tools    - установка необходимого ПО для лабораторных (Linux/macOS)"
	@echo "  make install-python-deps - установка Python-зависимостей (с --break-system-packages)"
	@echo "  make run-app          - запуск Flask-приложения локально"
	@echo "  make build-app        - сборка Docker-образа vulnerable-app"
	@echo "  make secret-scan      - запуск gitleaks"
	@echo "  make sca-scan         - запуск trivy fs"
	@echo "  make sast-scan        - запуск opengrep"
	@echo "  make container-scan   - запуск trivy image (если образ существует)"
	@echo "  make sbom             - генерация SBOM через syft"
	@echo "  make full-scan        - полный локальный security pipeline (по умолчанию gate)"
	@echo "  make full-scan-warn   - pipeline в информативном warn-only режиме"
	@echo "  make full-scan-gate   - pipeline в blocking quality gate режиме"

install-tools:
	@set -e; \
	if command -v apt-get >/dev/null 2>&1; then \
		echo "[install-tools] Detected apt-get (Linux)."; \
		sudo apt-get update; \
		sudo apt-get install -y git docker.io python3 python3-pip bash curl; \
		echo "[install-tools] Installing Trivy..."; \
		curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh; \
		sudo mv ./bin/trivy /usr/local/bin/trivy; \
		echo "[install-tools] Installing Syft..."; \
		curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin; \
		echo "[install-tools] Installing Gitleaks..."; \
		GL_VERSION=$$(curl -fsSL https://api.github.com/repos/gitleaks/gitleaks/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -n1); \
		curl -fsSL -o /tmp/gitleaks.tar.gz https://github.com/gitleaks/gitleaks/releases/download/v$$GL_VERSION/gitleaks_$$GL_VERSION_linux_x64.tar.gz; \
		tar -xzf /tmp/gitleaks.tar.gz -C /tmp gitleaks; \
		sudo install -m 0755 /tmp/gitleaks /usr/local/bin/gitleaks; \
		echo "[install-tools] Installing OpenGrep..."; \
		OG_VERSION=$$(curl -fsSL https://api.github.com/repos/opengrep/opengrep/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -n1); \
		ARCH=$$(uname -m); \
		if [ "$$ARCH" = "x86_64" ]; then OG_ASSET="opengrep_manylinux_x86"; elif [ "$$ARCH" = "aarch64" ] || [ "$$ARCH" = "arm64" ]; then OG_ASSET="opengrep_manylinux_aarch64"; else echo "Unsupported arch for OpenGrep: $$ARCH"; exit 1; fi; \
		curl -fsSL -o /tmp/opengrep https://github.com/opengrep/opengrep/releases/download/v$$OG_VERSION/$$OG_ASSET; \
		sudo install -m 0755 /tmp/opengrep /usr/local/bin/opengrep; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "[install-tools] Detected Homebrew (macOS/Linuxbrew)."; \
		brew install git docker python bash trivy gitleaks syft; \
		echo "[install-tools] Installing OpenGrep from GitHub release..."; \
		OG_VERSION=$$(curl -fsSL https://api.github.com/repos/opengrep/opengrep/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -n1); \
		ARCH=$$(uname -m); \
		if [ "$$ARCH" = "x86_64" ]; then OG_TAR="opengrep-core_osx_x86.tar.gz"; else OG_TAR="opengrep-core_osx_aarch64.tar.gz"; fi; \
		curl -fsSL -o /tmp/opengrep.tar.gz https://github.com/opengrep/opengrep/releases/download/v$$OG_VERSION/$$OG_TAR; \
		tar -xzf /tmp/opengrep.tar.gz -C /tmp; \
		sudo install -m 0755 /tmp/opengrep-core /usr/local/bin/opengrep; \
	else \
		echo "[install-tools] ERROR: supported package manager not found (apt-get or brew)."; \
		exit 1; \
	fi; \
	$(MAKE) install-python-deps

install-python-deps:
	python3 -m pip install --break-system-packages -U pip
	python3 -m pip install --break-system-packages -r vulnerable-app/requirements.txt

run-app:
	python3 vulnerable-app/app.py

build-app:
	docker build -t vulnerable-app:lab ./vulnerable-app

secret-scan:
	bash scanner-scripts/run_secret_scan.sh .

sca-scan:
	bash scanner-scripts/run_sca_scan.sh .

sast-scan:
	bash scanner-scripts/run_sast_scan.sh ./vulnerable-app

container-scan:
	bash scanner-scripts/run_container_scan.sh vulnerable-app:lab

sbom:
	bash scanner-scripts/generate_sbom.sh ./vulnerable-app

full-scan:
	WARN_ONLY=false FAIL_ON_ANY_ERROR=true bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app

full-scan-warn:
	WARN_ONLY=true FAIL_ON_ANY_ERROR=false bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app

full-scan-gate:
	WARN_ONLY=false FAIL_ON_ANY_ERROR=true bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab ./vulnerable-app
