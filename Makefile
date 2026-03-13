.PHONY: help run-app build-app full-scan secret-scan sca-scan sast-scan container-scan sbom

help:
	@echo "Доступные команды:"
	@echo "  make run-app          - запуск Flask-приложения локально"
	@echo "  make build-app        - сборка Docker-образа vulnerable-app"
	@echo "  make secret-scan      - запуск gitleaks"
	@echo "  make sca-scan         - запуск trivy fs"
	@echo "  make sast-scan        - запуск semgrep"
	@echo "  make container-scan   - запуск trivy image (если образ существует)"
	@echo "  make sbom             - генерация SBOM через syft"
	@echo "  make full-scan        - полный локальный security pipeline"

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
	bash scanner-scripts/full_local_pipeline.sh . vulnerable-app:lab
