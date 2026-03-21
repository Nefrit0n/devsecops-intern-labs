#!/usr/bin/env python3
"""Validate that artifacts listed in stage README files are either present or marked as student-generated."""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
README_PATHS = [
    ROOT / "stage-2-dependencies/README.md",
    ROOT / "stage-3-dynamic-analysis/README.md",
    ROOT / "stage-4-infrastructure/README.md",
    ROOT / "stage-5-pipeline-integration/README.md",
]
STUDENT_MARKER = "ожидаемые артефакты студента (создаются в ходе выполнения)"


@dataclass
class ArtifactEntry:
    readme: Path
    path: Path
    marker: bool
    source_line: str


def extract_tree_block(text: str) -> str:
    match = re.search(r"## Артефакты этапа\n\n```\n([\s\S]*?)\n```", text)
    if not match:
        raise ValueError("Не найден блок 'Артефакты этапа'")
    return match.group(1)


def parse_entries(readme: Path) -> list[ArtifactEntry]:
    block = extract_tree_block(readme.read_text(encoding="utf-8"))
    entries: list[ArtifactEntry] = []
    stack: list[str] = []
    root_prefix: Path | None = None

    for raw in block.splitlines():
        if not raw.strip():
            continue

        if "├" not in raw and "└" not in raw and raw.strip().endswith("/"):
            root_prefix = Path(raw.strip().rstrip("/"))
            continue

        tree_match = re.match(r"(?P<prefix>[│\s]*)(?:├──|└──)\s(?P<body>.+)$", raw)
        if not tree_match:
            continue

        prefix = tree_match.group("prefix")
        depth = len(prefix.replace("│", " ")) // 4

        body = tree_match.group("body")
        item = body.split("←", 1)[0].strip()
        marker = STUDENT_MARKER in body

        while len(stack) > depth:
            stack.pop()

        is_dir = item.endswith("/")
        clean = item.rstrip("/")
        stack.append(clean)

        rel_path = Path(*stack)
        if root_prefix is not None:
            rel_path = root_prefix / rel_path
        entries.append(
            ArtifactEntry(
                readme=readme,
                path=ROOT / rel_path,
                marker=marker,
                source_line=raw,
            )
        )

        if not is_dir:
            stack.pop()

    return entries


def main() -> int:
    missing: list[ArtifactEntry] = []

    for readme in README_PATHS:
        entries = parse_entries(readme)
        for e in entries:
            if e.path.exists() or e.marker:
                continue
            missing.append(e)

    if missing:
        print("[docs-artifacts-check] Найдены несоответствия docs ↔ repo:\n")
        for e in missing:
            rel = e.path.relative_to(ROOT)
            print(f"- {e.readme.relative_to(ROOT)}: '{rel}' отсутствует и не помечен как student-generated")
            print(f"  line: {e.source_line}")
        return 1

    print("[docs-artifacts-check] OK: все пути существуют или помечены как student-generated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
