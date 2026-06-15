from __future__ import annotations

import importlib.machinery
import importlib.util
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).with_name('minify-md')
loader = importlib.machinery.SourceFileLoader('minify_md', str(MODULE_PATH))
spec = importlib.util.spec_from_loader('minify_md', loader, origin=str(MODULE_PATH))
module = importlib.util.module_from_spec(spec)
module.__file__ = str(MODULE_PATH)
loader.exec_module(module)


class MinifyAgentFacingMarkdownTest(unittest.TestCase):
    def test_minify_markdown_compacts_frontmatter_rules_and_tables(self) -> None:
        original = """---
name: \"example\"
description: \"compact {{ value }}\"
---
# Title

---

| Left | Right |
| ---- | ----- |
| a | b |
"""

        self.assertEqual(
            module.minify_markdown(original),
            """---
name: example
description: compact {{value}}
---
# Title

---

|Left|Right|
|-|-|
|a|b|
""",
        )

    def test_minify_markdown_keeps_unsafe_frontmatter_quotes(self) -> None:
        original = """---
description: \"needs: quotes\"
---
body
"""

        self.assertEqual(module.minify_markdown(original), original)

    def test_minify_markdown_keeps_yaml_implicit_scalar_quotes(self) -> None:
        original = """---
enabled: "false"
empty: "null"
count: "123"
ratio: "1.5"
featureFlag: "on"
hexValue: "0xFF"
releaseDate: "2026-05-18"
---
body
"""

        self.assertEqual(module.minify_markdown(original), original)

    def test_minify_markdown_prune_empty_lines(self) -> None:
        original = """---
enabled: false

empty: null


---

# Title


body


"""

        self.assertEqual(
            module.minify_markdown(original),
            """---
enabled: false
empty: null
---
# Title

body
""",
        )

if __name__ == '__main__':
    unittest.main()