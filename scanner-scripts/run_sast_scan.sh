#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-./vulnerable-app}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/semgrep-report.json"

mkdir -p "${REPORT_DIR}"

echo "[INFO] Запуск SAST (semgrep) для: ${TARGET_DIR}"

if ! command -v semgrep >/dev/null 2>&1; then
  echo "[ERROR] semgrep не найден. Установите semgrep и повторите запуск."
  exit 1
fi

semgrep --config auto --json --output "${REPORT_FILE}" "${TARGET_DIR}"

echo "[OK] SAST scan завершён. Отчёт: ${REPORT_FILE}"
