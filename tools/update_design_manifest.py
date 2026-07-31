"""Regenerate the design-document manifest with canonical UTF-8/LF evidence."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DESIGN_ROOT = ROOT / "docs" / "design"
MANIFEST_PATH = DESIGN_ROOT / "manifest.json"


def role_for(relative_path: str) -> str:
    if relative_path == "GOGO_完整设计文档合集_v0.1.md":
        return "historical"
    if relative_path == "兼容性要求规范.md" or relative_path.startswith("arenas/"):
        return "auxiliary"
    return "authoritative"


def canonical_bytes(path: Path) -> bytes:
    return path.read_bytes().decode("utf-8").replace("\r\n", "\n").replace("\r", "\n").encode("utf-8")


def main() -> None:
    documents = []
    for path in sorted(DESIGN_ROOT.rglob("*.md")):
        relative = path.relative_to(DESIGN_ROOT).as_posix()
        content = canonical_bytes(path)
        documents.append(
            {
                "file": relative,
                "role": role_for(relative),
                "bytes": len(content),
                "sha256": hashlib.sha256(content).hexdigest(),
            }
        )
    manifest = {
        "schema_version": 2,
        "project": "GOGO",
        "design_version": "0.4",
        "date": "2026-07-31",
        "coverage": {"root": "docs/design", "include": ["**/*.md"], "exclude": []},
        "documents": documents,
        "catalog_targets": {"upgrade_count": 47, "wave_range": [1, 20]},
    }
    rendered = json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
    with MANIFEST_PATH.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(rendered)
    print(f"updated {MANIFEST_PATH} ({len(documents)} Markdown files)")


if __name__ == "__main__":
    main()
