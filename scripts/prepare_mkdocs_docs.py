from __future__ import annotations

import os
import re
import shutil
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
BUILD_DIR = REPO_ROOT / ".mkdocs-build-docs"
SOURCE_DOCS_DIR = REPO_ROOT / "site-docs"

COPY_DIRS = [
    "stage-0",
    "stage-1-static-analysis",
    "stage-2-dependencies",
    "stage-3-dynamic-analysis",
    "stage-4-infrastructure",
    "stage-5-pipeline-integration",
    "targets",
    "docs",
    "checklists",
    "solutions",
    "lab-infra",
]

# Markdown inline links/images. External URLs and anchors are skipped later.
LINK_RE = re.compile(r'(!?\[[^\]]*\]\()([^)\s]+(?:\s+"[^"]*")?)(\))')
FENCE_RE = re.compile(
    r'(^```.*?$.*?^```\s*$|^~~~.*?$.*?^~~~\s*$)',
    re.MULTILINE | re.DOTALL,
)


def copy_tree(src: Path, dest: Path) -> None:
    if src.exists():
        shutil.copytree(src, dest, dirs_exist_ok=True)


def ensure_build_tree() -> None:
    if BUILD_DIR.exists():
        shutil.rmtree(BUILD_DIR)
    BUILD_DIR.mkdir(parents=True)

    # Copy base docs pages and assets from site-docs, but keep theme overrides outside docs_dir.
    for item in SOURCE_DOCS_DIR.iterdir():
        if item.name == "overrides":
            continue

        target = BUILD_DIR / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy2(item, target)

    # Bring the rest of the content tree into the generated docs_dir.
    for rel in COPY_DIRS:
        copy_tree(REPO_ROOT / rel, BUILD_DIR / rel)

    # Merge demo docs under assets/ so nav path assets/demos/README.md resolves.
    (BUILD_DIR / "assets").mkdir(exist_ok=True)
    copy_tree(REPO_ROOT / "assets" / "demos", BUILD_DIR / "assets" / "demos")


def split_fences(text: str) -> list[tuple[str, bool]]:
    parts: list[tuple[str, bool]] = []
    last = 0

    for match in FENCE_RE.finditer(text):
        if match.start() > last:
            parts.append((text[last:match.start()], False))
        parts.append((match.group(0), True))
        last = match.end()

    if last < len(text):
        parts.append((text[last:], False))

    return parts


def split_target_and_title(raw_target: str) -> tuple[str, str]:
    if ' "' in raw_target and raw_target.endswith('"'):
        path_part, title_part = raw_target.split(' "', 1)
        return path_part, ' "' + title_part
    return raw_target, ""


def maybe_rewrite_target(md_file: Path, raw_target: str) -> str:
    target, title_suffix = split_target_and_title(raw_target)

    if target.startswith(("#", "/", "http://", "https://", "mailto:")):
        return raw_target

    if target.startswith("site-docs/"):
        target = target.removeprefix("site-docs/")

    resolved = (md_file.parent / target).resolve()

    try:
        resolved.relative_to(BUILD_DIR.resolve())
        candidate = resolved
    except ValueError:
        candidate = None
        try:
            relative_to_repo = resolved.relative_to(REPO_ROOT.resolve())
        except ValueError:
            relative_to_repo = None

        if relative_to_repo is not None:
            copied_candidate = BUILD_DIR / relative_to_repo
            if copied_candidate.exists() or copied_candidate.parent.exists():
                candidate = copied_candidate
                target = os.path.relpath(copied_candidate, md_file.parent).replace("\\", "/")

    if candidate is None:
        candidate = (md_file.parent / target).resolve()

    # Convert directory links into explicit README.md links for strict validation.
    if candidate.is_dir() and (candidate / "README.md").exists():
        candidate = candidate / "README.md"
        target = os.path.relpath(candidate, md_file.parent).replace("\\", "/")
    elif not candidate.exists():
        as_dir = (md_file.parent / target.rstrip("/")).resolve()
        if as_dir.is_dir() and (as_dir / "README.md").exists():
            candidate = as_dir / "README.md"
            target = os.path.relpath(candidate, md_file.parent).replace("\\", "/")
        elif target.endswith("README.md") and (candidate.parent / "index.md").exists():
            candidate = candidate.parent / "index.md"
            target = os.path.relpath(candidate, md_file.parent).replace("\\", "/")

    return target + title_suffix


def rewrite_links_in_markdown(md_file: Path) -> None:
    original = md_file.read_text(encoding="utf-8")
    updated_parts: list[str] = []

    for chunk, is_fence in split_fences(original):
        if is_fence:
            updated_parts.append(chunk)
            continue

        def replacer(match: re.Match[str]) -> str:
            prefix, raw_target, suffix = match.groups()
            new_target = maybe_rewrite_target(md_file, raw_target)
            return f"{prefix}{new_target}{suffix}"

        updated_parts.append(LINK_RE.sub(replacer, chunk))

    updated = "".join(updated_parts)
    if updated != original:
        md_file.write_text(updated, encoding="utf-8")


def main() -> None:
    ensure_build_tree()

    for md_file in BUILD_DIR.rglob("*.md"):
        rewrite_links_in_markdown(md_file)

    print(f"Prepared MkDocs build tree at: {BUILD_DIR}")


if __name__ == "__main__":
    main()
