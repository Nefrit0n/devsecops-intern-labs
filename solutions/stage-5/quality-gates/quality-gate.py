#!/usr/bin/env python3
"""
Quality Gate Script · Эталонное решение

Парсит отчёты сканеров (SARIF/JSON) и принимает решение pass/fail
на основе требований безопасности из этапа 0.

Exit code: 0 = PASS, 1 = FAIL

Использование:
    python quality-gate.py --reports-dir ./reports
    python quality-gate.py --sarif semgrep.sarif --trivy trivy.json
"""
import json
import sys
import argparse
from pathlib import Path
from dataclasses import dataclass, field


@dataclass
class Finding:
    tool: str
    rule_id: str
    severity: str  # CRITICAL, HIGH, MEDIUM, LOW
    message: str
    file: str = ""
    line: int = 0


@dataclass
class GateResult:
    blockers: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    info: list = field(default_factory=list)
    findings_total: int = 0
    findings_by_tool: dict = field(default_factory=dict)


def parse_sarif(path: str, tool_name: str) -> list[Finding]:
    """Парсит SARIF-отчёт."""
    findings = []
    try:
        with open(path) as f:
            data = json.load(f)
        for run in data.get("runs", []):
            tool = run.get("tool", {}).get("driver", {}).get("name", tool_name)
            for result in run.get("results", []):
                level = result.get("level", "warning")
                severity_map = {"error": "CRITICAL", "warning": "HIGH", "note": "MEDIUM"}
                findings.append(Finding(
                    tool=tool,
                    rule_id=result.get("ruleId", "unknown"),
                    severity=severity_map.get(level, "LOW"),
                    message=result.get("message", {}).get("text", ""),
                    file=result.get("locations", [{}])[0]
                        .get("physicalLocation", {})
                        .get("artifactLocation", {})
                        .get("uri", ""),
                ))
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"  ⚠️  Cannot parse {path}: {e}")
    return findings


def parse_trivy_json(path: str) -> list[Finding]:
    """Парсит Trivy JSON-отчёт."""
    findings = []
    try:
        with open(path) as f:
            data = json.load(f)
        for result in data.get("Results", []):
            target = result.get("Target", "")
            for vuln in result.get("Vulnerabilities", []):
                findings.append(Finding(
                    tool="Trivy",
                    rule_id=vuln.get("VulnerabilityID", ""),
                    severity=vuln.get("Severity", "UNKNOWN").upper(),
                    message=vuln.get("Title", ""),
                    file=target,
                ))
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"  ⚠️  Cannot parse {path}: {e}")
    return findings


def evaluate(findings: list[Finding],
             max_critical: int = 0,
             max_high: int = 5) -> GateResult:
    """Применяет quality gate правила."""
    result = GateResult()
    result.findings_total = len(findings)

    critical = [f for f in findings if f.severity == "CRITICAL"]
    high = [f for f in findings if f.severity == "HIGH"]

    # Count by tool
    for f in findings:
        result.findings_by_tool[f.tool] = result.findings_by_tool.get(f.tool, 0) + 1

    # Blockers
    if len(critical) > max_critical:
        result.blockers.append(
            f"CRITICAL findings: {len(critical)} (max allowed: {max_critical})"
        )
        for f in critical[:5]:
            result.blockers.append(f"  → [{f.tool}] {f.rule_id}: {f.message[:80]}")

    # Warnings
    if len(high) > max_high:
        result.warnings.append(
            f"HIGH findings: {len(high)} (max allowed: {max_high})"
        )

    return result


def print_report(result: GateResult) -> int:
    """Выводит отчёт и возвращает exit code."""
    print("=" * 60)
    print("  🚦 QUALITY GATE REPORT")
    print("=" * 60)
    print(f"\n  Total findings: {result.findings_total}")
    print(f"  By tool: {result.findings_by_tool}")

    if result.blockers:
        print("\n  🛑 BLOCKERS:")
        for b in result.blockers:
            print(f"    {b}")

    if result.warnings:
        print("\n  ⚠️  WARNINGS:")
        for w in result.warnings:
            print(f"    {w}")

    if result.blockers:
        print(f"\n  ❌ QUALITY GATE: FAIL ({len(result.blockers)} blockers)")
        return 1
    else:
        print(f"\n  ✅ QUALITY GATE: PASS")
        return 0


def main():
    parser = argparse.ArgumentParser(description="Security Quality Gate")
    parser.add_argument("--sarif", nargs="*", default=[], help="SARIF report files")
    parser.add_argument("--trivy", nargs="*", default=[], help="Trivy JSON reports")
    parser.add_argument("--max-critical", type=int, default=0)
    parser.add_argument("--max-high", type=int, default=5)
    args = parser.parse_args()

    all_findings = []

    for sarif_path in args.sarif:
        name = Path(sarif_path).stem
        all_findings.extend(parse_sarif(sarif_path, name))

    for trivy_path in args.trivy:
        all_findings.extend(parse_trivy_json(trivy_path))

    if not all_findings:
        print("⚠️  No findings parsed. Check report paths.")
        print("Usage: python quality-gate.py --sarif semgrep.sarif --trivy trivy.json")
        return 0

    result = evaluate(all_findings, args.max_critical, args.max_high)
    return print_report(result)


if __name__ == "__main__":
    sys.exit(main())
