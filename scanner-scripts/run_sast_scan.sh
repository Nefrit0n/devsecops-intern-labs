#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-./vulnerable-app}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/semgrep-report.json"
POLICY_FILE="scanner-scripts/security-thresholds.env"

mkdir -p "${REPORT_DIR}"

if [[ -f "${POLICY_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${POLICY_FILE}"
fi

SAST_CONFIG="${SAST_CONFIG:-auto}"
SAST_FAIL_ON_FINDINGS="${SAST_FAIL_ON_FINDINGS:-true}"
SAST_SEVERITY="${SAST_SEVERITY:-}"

echo "[INFO] Запуск SAST (semgrep) для: ${TARGET_DIR}"
echo "[INFO] Политика: config=${SAST_CONFIG}, fail_on_findings=${SAST_FAIL_ON_FINDINGS}, severity=${SAST_SEVERITY:-all}"

if ! command -v semgrep >/dev/null 2>&1; then
  echo "[ERROR] semgrep не найден. Установите semgrep и повторите запуск."
  exit 1
fi

semgrep_args=(
  --config "${SAST_CONFIG}"
  --json
  --output "${REPORT_FILE}"
)

if [[ "${SAST_FAIL_ON_FINDINGS}" == "true" ]]; then
  semgrep_args+=(--error)
fi

if [[ -n "${SAST_SEVERITY}" ]]; then
  semgrep_args+=(--severity "${SAST_SEVERITY}")
fi

semgrep "${semgrep_args[@]}" "${TARGET_DIR}"

echo "[OK] SAST scan завершён. Отчёт: ${REPORT_FILE}"
