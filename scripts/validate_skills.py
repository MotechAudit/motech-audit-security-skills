#!/usr/bin/env python3
"""Validate Agent Skills metadata and layout using only the Python standard library."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def scalar(frontmatter: str, key: str) -> str | None:
    """Read a simple single-line YAML scalar used by required metadata fields."""
    match = re.search(rf"(?m)^{re.escape(key)}:\s*(.*?)\s*$", frontmatter)
    if not match:
        return None
    value = match.group(1).strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"" + "'":
        value = value[1:-1]
    return value


def validate(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        return [f"{path}: cannot read skill file: {exc}"]

    match = re.match(r"\A---\s*\n(.*?)\n---\s*\n", text, re.S)
    if not match:
        return [f"{path}: missing or invalid YAML frontmatter"]

    frontmatter = match.group(1)
    name = scalar(frontmatter, "name")
    description = scalar(frontmatter, "description")
    compatibility = scalar(frontmatter, "compatibility")

    if not name:
        errors.append(f"{path}: missing name")
    else:
        if len(name) > 64 or not NAME_PATTERN.fullmatch(name):
            errors.append(f"{path}: name must be 1-64 lowercase letters/digits/hyphens, without leading, trailing, or repeated hyphens")
        if name != path.parent.name:
            errors.append(f"{path}: name '{name}' must match skill directory '{path.parent.name}'")

    if not description:
        errors.append(f"{path}: missing description")
    elif len(description) > 1024:
        errors.append(f"{path}: description exceeds 1024 characters")

    if compatibility is not None and not (1 <= len(compatibility) <= 500):
        errors.append(f"{path}: compatibility must be 1-500 characters when present")

    body = text[match.end():]
    if not re.search(r"(?m)^#\s+\S+", body):
        errors.append(f"{path}: missing markdown title")
    if len(text.splitlines()) > 500:
        errors.append(f"{path}: SKILL.md exceeds the recommended 500-line limit")

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
