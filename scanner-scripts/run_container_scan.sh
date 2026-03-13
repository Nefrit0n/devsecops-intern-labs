#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:-vulnerable-app:lab}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/trivy-image-report.json"

mkdir -p "${REPORT_DIR}"

echo "[INFO] Запуск container scan (trivy image) для: ${IMAGE_NAME}"

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

trivy image --format json -o "${REPORT_FILE}" "${IMAGE_NAME}"

echo "[OK] Container scan завершён. Отчёт: ${REPORT_FILE}"
