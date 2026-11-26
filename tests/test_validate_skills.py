"""Unit tests for the Agent Skills metadata and local-link validator."""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from validate_skills import validate  # noqa: E402

_TEMP_DIRS: list[tempfile.TemporaryDirectory] = []


def make_skill(contents: str, dirname: str = "solidity-security-review") -> tuple[Path, Path]:
    temp = tempfile.TemporaryDirectory()
    _TEMP_DIRS.append(temp)
    root = Path(temp.name)
    holder = root / "skills" / dirname
    holder.mkdir(parents=True)
    file_path = holder / "SKILL.md"
    file_path.write_text(contents, encoding="utf-8")
    return file_path, root


class ValidateSkillsTests(unittest.TestCase):
    def test_accepts_valid_skill_metadata(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review authorized Solidity code.\n---\n# Review\n"
        )
        self.assertEqual(validate(path, root), [])

    def test_rejects_name_that_does_not_match_directory(self):
        path, root = make_skill(
            "---\nname: other-skill\ndescription: Review authorized Solidity code.\n---\n# Review\n"
        )
        self.assertTrue(any("must match skill directory" in item for item in validate(path, root)))

    def test_rejects_invalid_name_format(self):
        path, root = make_skill(
            "---\nname: Invalid_Name\ndescription: Review authorized Solidity code.\n---\n# Review\n",
            dirname="Invalid_Name",
        )
        self.assertTrue(any("lowercase letters/digits/hyphens" in item for item in validate(path, root)))

    def test_rejects_missing_description(self):
        path, root = make_skill("---\nname: solidity-security-review\n---\n# Review\n")
        self.assertTrue(any("missing description" in item for item in validate(path, root)))

    def test_rejects_description_over_1024_characters(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: "
            + ("x" * 1025)
            + "\n---\n# Review\n"
        )
        self.assertTrue(any("exceeds 1024" in item for item in validate(path, root)))

    def test_rejects_compatibility_over_500_characters(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\ncompatibility: "
            + ("x" * 501)
            + "\n---\n# Review\n"
        )
        self.assertTrue(any("compatibility must be 1-500" in item for item in validate(path, root)))

    def test_rejects_missing_markdown_heading(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\nNo heading.\n"
        )
        self.assertTrue(any("missing markdown title" in item for item in validate(path, root)))

    def test_rejects_skill_over_500_lines(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n# Review\n"
            + ("instruction\n" * 500)
        )
        self.assertTrue(any("exceeds the recommended 500-line limit" in item for item in validate(path, root)))

    def test_accepts_existing_relative_reference(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n"
            "# Review\nSee [guide](../../docs/guide.md).\n"
        )
        (root / "docs").mkdir()
        (root / "docs" / "guide.md").write_text("# Guide\n", encoding="utf-8")
        self.assertEqual(validate(path, root), [])

    def test_rejects_missing_relative_reference(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n"
            "# Review\nSee [guide](../../docs/missing.md).\n"
        )
        errors = validate(path, root)
        self.assertTrue(any("broken local link" in item for item in errors))

    def test_ignores_external_links_and_anchor_only_links(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n"
            "# Review\n[Web](https://example.com/path) [Section](#section)\n"
        )
        self.assertEqual(validate(path, root), [])

    def test_ignores_markdown_examples_inside_fenced_code(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n"
            "# Review\n\n\`\`\`md\n[Not a real link](./missing.md)\n\`\`\`\n"
        )
        self.assertEqual(validate(path, root), [])

    def test_rejects_path_that_escapes_repository_root(self):
        path, root = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n"
            "# Review\n[Outside](../../../outside.md)\n"
        )
        errors = validate(path, root)
        self.assertTrue(any("escapes repository root" in item for item in errors))


if __name__ == "__main__":
    unittest.main()
