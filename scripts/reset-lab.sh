#!/bin/bash
# Сброс лабы в исходное состояние

echo "Останавливаем контейнеры..."
cd "$(dirname "$0")/../vulnerable-app" && docker compose down -v 2>/dev/null

echo "Удаляем артефакты студента..."
find "$(dirname "$0")/.." -name "gost-mapping.md" -path "*/0.1-*" -delete
find "$(dirname "$0")/.." -name "stride-analysis.md" -path "*/0.2-*" -delete
find "$(dirname "$0")/.." -name "security-requirements.md" -path "*/0.3-*" -delete
find "$(dirname "$0")/.." -name "threat-model.py" -path "*/0.2-*" -delete
rm -rf "$(dirname "$0")/../stage-0/0.2-threat-modeling/pytm-report"

echo "Лаба сброшена. Начинайте с stage-0/README.md"
