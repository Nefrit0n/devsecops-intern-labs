#!/bin/bash
# Проверка установленных инструментов для прохождения курса

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  DevSecOps Lab — Проверка инструментов"
echo "========================================"
echo ""

check() {
    if command -v "$1" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $1 ($($1 --version 2>/dev/null | head -1))"
        return 0
    else
        echo -e "  ${RED}✗${NC} $1 — не найден"
        return 1
    fi
}

echo "Обязательные:"
check docker
check git
check python3

echo ""
echo "Этап 0 (моделирование угроз):"
python3 -c "import pytm" 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} pytm (Python)" || \
    echo -e "  ${YELLOW}○${NC} pytm — pip install pytm"

echo ""
echo "Этап 1 (статический анализ):"
check semgrep
check bandit
check gitleaks

echo ""
echo "Этап 2 (зависимости):"
check trivy

echo ""
echo "Этап 3 (динамический анализ):"
check zap-cli 2>/dev/null || check zaproxy 2>/dev/null || \
    echo -e "  ${YELLOW}○${NC} OWASP ZAP — будет запущен в Docker"
check nuclei

echo ""
echo "Этап 4 (инфраструктура):"
check checkov
check grype

echo ""
echo "========================================"
echo "  ${YELLOW}○${NC} = установите позже, перед соответствующим этапом"
echo "  ${RED}✗${NC} = необходимо для старта"
echo "========================================"
