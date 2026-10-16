---
name: principle-smallest-sufficient-change
description: "Apply when sizing a diff or tempted to add an abstraction, option, or drive-by cleanup. Make the smallest change that fully solves the problem, delete before adding, and keep one concern per pull request."
disable-model-invocation: true
---

# Smallest sufficient change

- Solve the stated problem completely, and nothing beyond it. "Completely" includes the readers, docs, and tests the change makes stale (the **principle-look-beyond-the-diff** skill). "Nothing beyond" excludes refactors, renames, and options nobody asked for.
- Remove dead code and redundant checks before building on top of them.
- One concern per pull request. If the description needs "and also", it is two pull requests.
- No abstraction with one caller. No configuration for a case that does not exist yet.
- Follow the repository's own rule for drive-by edits. Some projects ask you to trim comments in functions you touch. Do what they ask, and no more.
