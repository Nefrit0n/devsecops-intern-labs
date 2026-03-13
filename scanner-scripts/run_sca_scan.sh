#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/trivy-fs-report.json"
POLICY_FILE="scanner-scripts/security-thresholds.env"

mkdir -p "${REPORT_DIR}"

if [[ -f "${POLICY_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${POLICY_FILE}"
fi

SCA_SEVERITY="${SCA_SEVERITY:-HIGH,CRITICAL}"
SCA_EXIT_CODE="${SCA_EXIT_CODE:-1}"
SCA_IGNORE_UNFIXED="${SCA_IGNORE_UNFIXED:-false}"

echo "[INFO] Запуск SCA (trivy fs) для: ${TARGET_DIR}"
echo "[INFO] Политика: severity=${SCA_SEVERITY}, exit_code=${SCA_EXIT_CODE}, ignore_unfixed=${SCA_IGNORE_UNFIXED}"

if ! command -v trivy >/dev/null 2>&1; then
  echo "[ERROR] trivy не найден. Установите trivy и повторите запуск."
  exit 1
fi

trivy fs \
  --scanners vuln \
  --severity "${SCA_SEVERITY}" \
  --ignore-unfixed="${SCA_IGNORE_UNFIXED}" \
  --exit-code "${SCA_EXIT_CODE}" \
  --format json \
  -o "${REPORT_FILE}" \
  "${TARGET_DIR}"

echo "[OK] SCA scan завершён. Отчёт: ${REPORT_FILE}"
