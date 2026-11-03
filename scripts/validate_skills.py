#!/usr/bin/env python3
"""Validate the basic structure of Motech Audit agent skills (stdlib only)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
REQUIRED = ("name", "description")

def validate(path: Path) -> list[str]:
    errors = []
    text = path.read_text(encoding="utf-8")
    match = re.match(r"\A---\s*\n(.*?)\n---\s*\n", text, re.S)
    if not match:
        return [f"{path}: missing YAML frontmatter"]
    frontmatter = match.group(1)
    for key in REQUIRED:
        if not re.search(rf"(?m)^{key}:\s*\S+", frontmatter):
            errors.append(f"{path}: missing {key}")
    if not re.search(r"(?m)^#\s+\S+", text[match.end():]):
        errors.append(f"{path}: missing markdown title")
    return errors

def main() -> int:
    paths = sorted(SKILLS.glob("*/SKILL.md"))
    if not paths:
        print("No skills found", file=sys.stderr)
        return 1
    errors = [error for path in paths for error in validate(path)]
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Validated {len(paths)} skill(s): " + ", ".join(p.parent.name for p in paths))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
