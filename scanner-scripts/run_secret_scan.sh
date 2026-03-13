#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/gitleaks-report.json"

mkdir -p "${REPORT_DIR}"

echo "[INFO] Запуск secret scan (gitleaks) для: ${TARGET_DIR}"

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "[ERROR] gitleaks не найден. Установите gitleaks и повторите запуск."
  exit 1
fi

gitleaks detect --source "${TARGET_DIR}" --report-path "${REPORT_FILE}" --report-format json

echo "[OK] Secret scan завершён. Отчёт: ${REPORT_FILE}"
