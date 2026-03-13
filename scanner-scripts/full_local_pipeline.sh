#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
IMAGE_NAME="${2:-vulnerable-app:lab}"
SAST_TARGET="${3:-./vulnerable-app}"

REPORT_DIR="reports"
mkdir -p "${REPORT_DIR}"

echo "[INFO] Старт полного локального security pipeline"
echo "[INFO] TARGET_DIR=${TARGET_DIR}, IMAGE_NAME=${IMAGE_NAME}, SAST_TARGET=${SAST_TARGET}"

secret_status="SKIPPED"
sca_status="SKIPPED"
sast_status="SKIPPED"
container_status="SKIPPED"
sbom_status="SKIPPED"

if bash scanner-scripts/run_secret_scan.sh "${TARGET_DIR}"; then
  secret_status="OK"
else
  secret_status="FAILED"
fi

if bash scanner-scripts/run_sca_scan.sh "${TARGET_DIR}"; then
  sca_status="OK"
else
  sca_status="FAILED"
fi

if bash scanner-scripts/run_sast_scan.sh "${SAST_TARGET}"; then
  sast_status="OK"
else
  sast_status="FAILED"
fi

if command -v docker >/dev/null 2>&1 && docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  if bash scanner-scripts/run_container_scan.sh "${IMAGE_NAME}"; then
    container_status="OK"
  else
    container_status="FAILED"
  fi
else
  echo "[WARN] Образ ${IMAGE_NAME} не найден, container scan пропущен."
  container_status="SKIPPED"
fi

if bash scanner-scripts/generate_sbom.sh "${SAST_TARGET}"; then
  sbom_status="OK"
else
  sbom_status="FAILED"
fi

echo ""
echo "===== ИТОГОВАЯ СВОДКА ====="
echo "Secret scan    : ${secret_status}"
echo "SCA scan       : ${sca_status}"
echo "SAST scan      : ${sast_status}"
echo "Container scan : ${container_status}"
echo "SBOM           : ${sbom_status}"
echo "Отчёты сохранены в: ${REPORT_DIR}/"
