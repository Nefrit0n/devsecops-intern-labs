#!/bin/bash
# DefectDojo Import Script · Эталонное решение
# Импортирует все отчёты из этапов 1-4 через API

set -euo pipefail

DD_URL="${DD_URL:-http://localhost:8080}"
DD_TOKEN="${DD_TOKEN:-your-api-token-here}"
ENGAGEMENT_ID="${DD_ENGAGEMENT:-1}"

import_scan() {
    local scan_type="$1"
    local file="$2"

    if [ ! -f "$file" ]; then
        echo "  ⚠️  Skip: $file not found"
        return
    fi

    echo "  📥 Importing: $file → $scan_type"
    response=$(curl -s -w "\n%{http_code}" -X POST "$DD_URL/api/v2/import-scan/" \
        -H "Authorization: Token $DD_TOKEN" \
        -F "scan_type=$scan_type" \
        -F "file=@$file" \
        -F "engagement=$ENGAGEMENT_ID" \
        -F "active=true" \
        -F "verified=false" \
        -F "close_old_findings=false" \
        -F "minimum_severity=Info")

    http_code=$(echo "$response" | tail -1)
    if [ "$http_code" -eq 201 ]; then
        echo "  ✅ Success"
    else
        echo "  ❌ Failed (HTTP $http_code)"
    fi
}

echo "========================================"
echo "  DefectDojo Import · All Stages"
echo "  URL: $DD_URL"
echo "  Engagement: $ENGAGEMENT_ID"
echo "========================================"

echo ""
echo "Этап 1 — SAST + Secrets:"
import_scan "Semgrep JSON Report" "stage-1-static-analysis/sast/semgrep-report.sarif"
import_scan "Bandit Scan" "stage-1-static-analysis/sast/bandit-report.json"
import_scan "njsscan Scan" "stage-1-static-analysis/sast/njsscan-report.sarif"
import_scan "Gitleaks Scan" "stage-1-static-analysis/secrets/gitleaks-report.json"
import_scan "Trufflehog Scan" "stage-1-static-analysis/secrets/trufflehog-report.json"

echo ""
echo "Этап 2 — SCA:"
import_scan "Trivy Scan" "stage-2-dependencies/sca/trivy-fs-report.json"
import_scan "Dependency Check Scan" "stage-2-dependencies/sca/dependency-check-report.json"
import_scan "Anchore Grype" "stage-2-dependencies/sca/grype-report.json"

echo ""
echo "Этап 3 — DAST + Fuzzing:"
import_scan "ZAP Scan" "stage-3-dynamic-analysis/dast/zap-full-report.json"
import_scan "Nuclei Scan" "stage-3-dynamic-analysis/dast/nuclei-report.json"

echo ""
echo "Этап 4 — Container + IaC:"
import_scan "Trivy Scan" "stage-4-infrastructure/container-sec/trivy-image-report.json"
import_scan "Checkov Scan" "stage-4-infrastructure/iac-sec/checkov-report.json"

echo ""
echo "========================================"
echo "  Done! Open $DD_URL to see the dashboard."
echo "========================================"
