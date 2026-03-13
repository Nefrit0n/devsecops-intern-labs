#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/gitleaks-report.json"
POLICY_FILE="scanner-scripts/security-thresholds.env"

mkdir -p "${REPORT_DIR}"

if [[ -f "${POLICY_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${POLICY_FILE}"
fi

SECRET_EXIT_CODE="${SECRET_EXIT_CODE:-1}"
SECRET_CONFIG="${SECRET_CONFIG:-}"

echo "[INFO] Запуск secret scan (gitleaks) для: ${TARGET_DIR}"
echo "[INFO] Политика: exit_code=${SECRET_EXIT_CODE}, config=${SECRET_CONFIG:-default}"

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "[ERROR] gitleaks не найден. Установите gitleaks и повторите запуск."
  exit 1
fi

gitleaks_args=(
  detect
  --source "${TARGET_DIR}"
  --report-path "${REPORT_FILE}"
  --report-format json
  --exit-code "${SECRET_EXIT_CODE}"
)

if [[ -n "${SECRET_CONFIG}" ]]; then
  gitleaks_args+=(--config "${SECRET_CONFIG}")
fi

gitleaks "${gitleaks_args[@]}"

echo "[OK] Secret scan завершён. Отчёт: ${REPORT_FILE}"
