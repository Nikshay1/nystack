---
name: principle-encode-lessons-in-structure
description: "Apply when you catch yourself writing the same instruction a second time, or when a reviewer flags a mistake that has happened before. Prefer a check that fails (type, lint, test, script) over another sentence of instructions."
disable-model-invocation: true
---

# Encode lessons in structure

Text is the weakest fix. Nothing fails when an agent skips a sentence. Rank fixes by how well they hold.

1. Make the mistake impossible: one owner for each piece of state, one supported way to do each task, delete the old way.
2. Block it with a type, or a lint or CI check whose error message names the fix.
3. Catch it with a test.
4. Write it down in a skill or doc. Use this only for judgment calls.

A mistake class counts once it has happened twice. When you add a check, prove it fails on a real past instance of the mistake.

For skills themselves, this means: a validation script beats a checklist line, and a helper script beats a paragraph describing commands.
