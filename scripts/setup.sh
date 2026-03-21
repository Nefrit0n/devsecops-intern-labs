#!/bin/bash
# Быстрая установка базовых инструментов

echo "Установка Python-зависимостей..."
pip install pytm bandit semgrep 2>/dev/null || pip3 install pytm bandit semgrep

echo ""
echo "Установка Gitleaks..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -sSL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64 -o /usr/local/bin/gitleaks
    chmod +x /usr/local/bin/gitleaks
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install gitleaks 2>/dev/null || echo "Установите brew: https://brew.sh"
fi

echo ""
echo "Готово! Запустите ./scripts/check-tools.sh для проверки."
