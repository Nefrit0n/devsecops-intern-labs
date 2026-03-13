#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:-vulnerable-app:lab}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/trivy-image-report.json"
POLICY_FILE="scanner-scripts/security-thresholds.env"

mkdir -p "${REPORT_DIR}"

if [[ -f "${POLICY_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${POLICY_FILE}"
fi

CONTAINER_SEVERITY="${CONTAINER_SEVERITY:-HIGH,CRITICAL}"
CONTAINER_EXIT_CODE="${CONTAINER_EXIT_CODE:-1}"
CONTAINER_IGNORE_UNFIXED="${CONTAINER_IGNORE_UNFIXED:-false}"

echo "[INFO] Запуск container scan (trivy image) для: ${IMAGE_NAME}"
echo "[INFO] Политика: severity=${CONTAINER_SEVERITY}, exit_code=${CONTAINER_EXIT_CODE}, ignore_unfixed=${CONTAINER_IGNORE_UNFIXED}"

if ! command -v trivy >/dev/null 2>&1; then
  echo "[ERROR] trivy не найден. Установите trivy и повторите запуск."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker не найден. Установите docker и повторите запуск."
  exit 1
fi

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  echo "[ERROR] Docker image '${IMAGE_NAME}' не найден локально. Сначала соберите образ."
  exit 1
fi

trivy image \
  --severity "${CONTAINER_SEVERITY}" \
  --ignore-unfixed="${CONTAINER_IGNORE_UNFIXED}" \
  --exit-code "${CONTAINER_EXIT_CODE}" \
  --format json \
  -o "${REPORT_FILE}" \
  "${IMAGE_NAME}"

echo "[OK] Container scan завершён. Отчёт: ${REPORT_FILE}"
