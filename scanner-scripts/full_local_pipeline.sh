#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
IMAGE_NAME="${2:-vulnerable-app:lab}"
SAST_TARGET="${3:-./vulnerable-app}"

REPORT_DIR="reports"
mkdir -p "${REPORT_DIR}"

WARN_ONLY="${WARN_ONLY:-false}"
FAIL_ON_ANY_ERROR="${FAIL_ON_ANY_ERROR:-true}"

if [[ "${WARN_ONLY}" == "true" ]]; then
  echo "[INFO] WARN_ONLY=true: сканы не валят запуск, только формируют предупреждения."
  export SECRET_EXIT_CODE=0
  export SCA_EXIT_CODE=0
  export CONTAINER_EXIT_CODE=0
  export SAST_FAIL_ON_FINDINGS=false
fi

echo "[INFO] Старт полного локального security pipeline"
echo "[INFO] TARGET_DIR=${TARGET_DIR}, IMAGE_NAME=${IMAGE_NAME}, SAST_TARGET=${SAST_TARGET}"
echo "[INFO] Режим: WARN_ONLY=${WARN_ONLY}, FAIL_ON_ANY_ERROR=${FAIL_ON_ANY_ERROR}"

secret_status="SKIPPED"
sca_status="SKIPPED"
sast_status="SKIPPED"
container_status="SKIPPED"
sbom_status="SKIPPED"

failure_count=0

run_step() {
  local step_name="$1"
  shift

  if "$@"; then
    echo "[OK] ${step_name}: завершён"
    return 0
  fi

  echo "[WARN] ${step_name}: завершён с ошибкой"
  failure_count=$((failure_count + 1))
  return 1
}

if run_step "Secret scan" bash scanner-scripts/run_secret_scan.sh "${TARGET_DIR}"; then
  secret_status="OK"
else
  secret_status="FAILED"
fi

if run_step "SCA scan" bash scanner-scripts/run_sca_scan.sh "${TARGET_DIR}"; then
  sca_status="OK"
else
  sca_status="FAILED"
fi

if run_step "SAST scan" bash scanner-scripts/run_sast_scan.sh "${SAST_TARGET}"; then
  sast_status="OK"
else
  sast_status="FAILED"
fi

if command -v docker >/dev/null 2>&1 && docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  if run_step "Container scan" bash scanner-scripts/run_container_scan.sh "${IMAGE_NAME}"; then
    container_status="OK"
  else
    container_status="FAILED"
  fi
else
  echo "[WARN] Образ ${IMAGE_NAME} не найден, container scan пропущен."
  container_status="SKIPPED"
fi

if run_step "SBOM" bash scanner-scripts/generate_sbom.sh "${SAST_TARGET}"; then
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

pipeline_status="PASSED"
exit_code=0

if (( failure_count > 0 )); then
  if [[ "${WARN_ONLY}" == "true" || "${FAIL_ON_ANY_ERROR}" != "true" ]]; then
    pipeline_status="WARNINGS"
    exit_code=0
  else
    pipeline_status="FAILED"
    exit_code=1
  fi
fi

echo "PIPELINE STATUS: ${pipeline_status}"
exit "${exit_code}"
