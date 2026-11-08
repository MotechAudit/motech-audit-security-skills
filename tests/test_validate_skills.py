"""Unit tests for the Agent Skills metadata validator."""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from validate_skills import validate  # noqa: E402


def make_skill(contents: str, dirname: str = "solidity-security-review") -> Path:
    temp = tempfile.TemporaryDirectory()
    # Keep the temporary directory alive through the returned Path.
    holder = Path(temp.name) / dirname
    holder.mkdir()
    file_path = holder / "SKILL.md"
    file_path.write_text(contents, encoding="utf-8")
    file_path._temp_owner = temp  # type: ignore[attr-defined]
    return file_path


class ValidateSkillsTests(unittest.TestCase):
    def test_accepts_valid_skill_metadata(self):
        path = make_skill(
            "---\nname: solidity-security-review\ndescription: Review authorized Solidity code.\n---\n# Review\n"
        )
        self.assertEqual(validate(path), [])

    def test_rejects_name_that_does_not_match_directory(self):
        path = make_skill(
            "---\nname: other-skill\ndescription: Review authorized Solidity code.\n---\n# Review\n"
        )
        self.assertTrue(any("must match skill directory" in item for item in validate(path)))

    def test_rejects_invalid_name_format(self):
        path = make_skill(
            "---\nname: Invalid_Name\ndescription: Review authorized Solidity code.\n---\n# Review\n",
            dirname="Invalid_Name",
        )
        self.assertTrue(any("lowercase letters/digits/hyphens" in item for item in validate(path)))

    def test_rejects_missing_description(self):
        path = make_skill("---\nname: solidity-security-review\n---\n# Review\n")
        self.assertTrue(any("missing description" in item for item in validate(path)))

    def test_rejects_description_over_1024_characters(self):
        path = make_skill(
            "---\nname: solidity-security-review\ndescription: "
            + ("x" * 1025)
            + "\n---\n# Review\n"
        )
        self.assertTrue(any("exceeds 1024" in item for item in validate(path)))

    def test_rejects_compatibility_over_500_characters(self):
        path = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\ncompatibility: "
            + ("x" * 501)
            + "\n---\n# Review\n"
        )
        self.assertTrue(any("compatibility must be 1-500" in item for item in validate(path)))

    def test_rejects_missing_markdown_heading(self):
        path = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\nNo heading.\n"
        )
        self.assertTrue(any("missing markdown title" in item for item in validate(path)))

    def test_rejects_skill_over_500_lines(self):
        path = make_skill(
            "---\nname: solidity-security-review\ndescription: Review code.\n---\n# Review\n"
            + ("instruction\n" * 500)
        )
        self.assertTrue(any("exceeds the recommended 500-line limit" in item for item in validate(path)))


if __name__ == "__main__":
    unittest.main()
