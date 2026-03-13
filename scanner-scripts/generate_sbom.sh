#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-./vulnerable-app}"
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/sbom.spdx.json"

mkdir -p "${REPORT_DIR}"

echo "[INFO] Генерация SBOM (syft) для: ${TARGET}"

if ! command -v syft >/dev/null 2>&1; then
  echo "[ERROR] syft не найден. Установите syft и повторите запуск."
  exit 1
fi

if [ -d "${TARGET}" ]; then
  syft "dir:${TARGET}" -o "spdx-json=${REPORT_FILE}"
else
  syft "${TARGET}" -o "spdx-json=${REPORT_FILE}"
fi

echo "[OK] SBOM сгенерирован. Отчёт: ${REPORT_FILE}"
