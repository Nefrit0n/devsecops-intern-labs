#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET_DIR="${1:-./vulnerable-app}"
REPORT_DIR="${REPO_ROOT}/reports"
REPORT_FILE="${REPORT_DIR}/opengrep-report.json"
POLICY_FILE="${SCRIPT_DIR}/security-thresholds.env"

mkdir -p "${REPORT_DIR}"

if [[ -f "${POLICY_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${POLICY_FILE}"
fi

# Всегда используем локальные правила по умолчанию
DEFAULT_OPENGREP_CONFIG="${REPO_ROOT}/opengrep-rules/python"

# Если в policy остался auto — игнорируем его
if [[ -n "${OPENGREP_CONFIG:-}" && "${OPENGREP_CONFIG}" != "auto" ]]; then
  CONFIG="${OPENGREP_CONFIG}"
elif [[ -n "${SAST_CONFIG:-}" && "${SAST_CONFIG}" != "auto" ]]; then
  CONFIG="${SAST_CONFIG}"
else
  CONFIG="${DEFAULT_OPENGREP_CONFIG}"
fi

SAST_FAIL_ON_FINDINGS="${SAST_FAIL_ON_FINDINGS:-false}"
SAST_SEVERITY="${SAST_SEVERITY:-}"

echo "[INFO] Запуск SAST (OpenGrep) для: ${TARGET_DIR}"
echo "[INFO] Политика: config=${CONFIG}, fail_on_findings=${SAST_FAIL_ON_FINDINGS}, severity=${SAST_SEVERITY:-all}"

if ! command -v opengrep >/dev/null 2>&1; then
  echo "[ERROR] opengrep не найден. Установите OpenGrep и повторите запуск."
  exit 1
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "[ERROR] TARGET_DIR не найден: ${TARGET_DIR}"
  exit 1
fi

if [[ ! -d "${CONFIG}" && ! -f "${CONFIG}" ]]; then
  echo "[ERROR] Конфиг/директория правил OpenGrep не найдены: ${CONFIG}"
  echo "[HINT] Проверьте, что рядом с репозиторием есть папка opengrep-rules"
  exit 1
fi

opengrep_args=(
  scan
  --config "${CONFIG}"
  --json
  --output "${REPORT_FILE}"
)

if [[ "${SAST_FAIL_ON_FINDINGS}" == "true" ]]; then
  opengrep_args+=(--error)
fi

if [[ -n "${SAST_SEVERITY}" && "${SAST_SEVERITY}" != "all" ]]; then
  opengrep_args+=(--severity "${SAST_SEVERITY}")
fi

opengrep "${opengrep_args[@]}" "${TARGET_DIR}"

echo "[OK] SAST scan завершён. Отчёт: ${REPORT_FILE}"
