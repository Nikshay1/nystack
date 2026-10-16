---
name: principle-look-beyond-the-diff
description: "Apply before calling any change complete. The bugs reviewers find are usually outside the changed lines: other callers, other readers of the same data, test mocks of the old behavior, docs that state the old value, and texts that describe the same fact. Search the whole tree for them."
disable-model-invocation: true
---

# Look beyond the diff

The diff shows what you changed. It does not show what still depends on the old behavior. Most review findings live there.

For every symbol, route, storage key, constant, file path, and behavior the change touches, find:

- **Every caller and every bypass.** Callers of the function you changed, and callers of the lower-level function it wraps. A wrapper fix is skipped by anyone calling the inner function directly.
- **Every reader and writer of the same data.** A new key format, envelope, or field needs every reader updated, including counters, caches, cross-tab or cross-process listeners, migrations, and cleanup code.
- **Every early return.** Moving logic from callers into a callee loses it on any caller path that returns before the call.
- **Tests that encode the old behavior.** Mocks of an old URL, fixtures with the old shape, snapshot files, golden files.
- **Prose that states the old fact.** Docs, READMEs, "used by" lists, design docs, agent instruction files, comments, error messages. Search for the old value written as words ("15 minutes"), not only as code.
- **Texts that describe one fact in several places.** An allowlist reason, a comment, an advice string, and a doc often say the same thing. Edit one, reconcile all.
- **Alternate modes.** Feature flags, legacy paths, compact or stacked layouts, other platforms, other entry points.

Search the whole repository, including `tests/`, `docs/`, and agent folders, not only the source directory. A search that finds nothing is a result. Say you ran it.

Repeat the searches after the change is written. The second search catches what the first plan missed.
