#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/trivy-fs-report.json"

mkdir -p "${REPORT_DIR}"

echo "[INFO] Запуск SCA (trivy fs) для: ${TARGET_DIR}"

if ! command -v trivy >/dev/null 2>&1; then
  echo "[ERROR] trivy не найден. Установите trivy и повторите запуск."
  exit 1
fi

trivy fs --scanners vuln --format json -o "${REPORT_FILE}" "${TARGET_DIR}"

echo "[OK] SCA scan завершён. Отчёт: ${REPORT_FILE}"
