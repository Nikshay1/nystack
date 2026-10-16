---
name: verify-change
description: "Independently verify that a code change written by an agent (or anyone) is correct: derive acceptance criteria from the request before reading the diff, prove the tests fail on the old code, break each branch of the fix, run the real path, sweep beyond the diff, and check every claim the author made. Returns a verdict with evidence. Use for 'verify this change', 'is this PR correct', before opening a PR, and before saying agent work is done."
---

# Verify a change

This skill answers one question: does the change do what was asked, without breaking anything else, and is there evidence for that. It does not judge style or improve the code. That comes later, from other skills.

The verifier is not the author (**principle-separate-author-and-verifier**). Run this in a fresh subagent, preferably the `verifier` agent from this plugin, and preferably on a different model from the one that wrote the code. The verifier never edits the code under test. It may write scratch files and throwaway worktrees.

## Inputs

Collect these before starting. Ask only for what you cannot find.

- **The request:** the issue, the user's message, or the task description. Not the author's summary of it.
- **Base and head:** the commit the change started from and the commit to verify. Record both SHAs. Verify that head, not a moving branch. If the change is not committed, the author hands over a patch made with `git add -N . && git diff <base> > change.patch`; apply it with `git apply` in a scratch worktree at base and treat that worktree as head. Never verify a working tree another agent is still editing.
- **The author's claims:** the PR body or final report. Every claim in it will be checked.
- **Repo rules:** the repo skill (`repo-<name>`), `AGENTS.md`, `CONTRIBUTING.md`, the feature map entry for the area, and the project's verification skill (`verify-<app>`) if one exists.

To spawn a verifier, fill [`references/verifier-prompt.md`](references/verifier-prompt.md) and pass it to the `verifier` agent. Give file paths and SHAs, not pasted context.

## Steps

### 1. Write the acceptance criteria first

From the request and repo rules only, before reading the diff, write the list of things that must be true when the change is correct:

- The behavior the request asks for, with concrete inputs and expected outputs.
- Edge cases the request names or implies: empty, missing, repeated, concurrent, failure, recovery.
- What must not change: existing behavior next to the fix, public contracts, storage formats, other modes.
- Repo contracts the change touches (from the repo skill and feature map).

Number them. Each one gets a result in the report.

### 2. Read the diff as a stranger

`git diff <base>..<head>`. List every behavior change the diff makes, including ones the author did not mention. Map each to a criterion. A change no criterion asked for is a scope finding.

### 3. Prove the tests can fail

For every new or changed test:

1. Run it on head. It must pass.
2. Run it against the base code: `git worktree add <scratch>/base <base>`, copy the new test files in, run them there. It must fail, for the reason the bug describes.

A test that passes on base proves nothing about the change. Report it.

### 4. Break the fix on purpose

In a scratch worktree at head, undo or break each branch of the fix one at a time (drop the guard, the new argument, the cleanup call, the `max()`), run the relevant tests, and record which mutation no test catches. Each surviving mutation is an untested behavior. Restore the worktree between mutations.

### 5. Run the real path

Exercise the behavior the way a user or caller reaches it:

- With the project's `verify-<app>` skill when one exists.
- Otherwise, a short script that imports or calls the real entry point with the inputs from step 1, or a CLI invocation, or an HTTP request against a local instance.

Capture the input and the output. Unit tests show branch behavior, not that the feature works.

### 6. Sweep beyond the diff

Apply **principle-look-beyond-the-diff** to every symbol, route, key, constant, and path the diff touches. Start from the feature map's **Change together**, **Tests**, and **Docs** sections, then search the whole tree, `tests/` and `docs/` included. For each hit, decide: updated, unaffected (say why), or missed. For a risky change, also run the **blast-radius** skill.

### 7. Check the author's claims

Split the PR body or report into individual claims ("tests cover X", "Y is unchanged", "npm run check passes"). Mark each `confirmed` (with your evidence), `false` (with the counter-evidence), or `unverifiable` (say why).

### 8. Run the project's checks

Run the fast checks on the changed files: formatter, linter, type checker, focused tests. Note slow suites you did not run.

## Report

Use [`references/report-template.md`](references/report-template.md). Lead with one verdict:

- **VERIFIED**: every criterion is met at proof level 4 or 5, no surviving mutation hides a criterion, no missed dependents.
- **VERIFIED WITH GAPS**: the criteria hold, but some are only at level 2 or 3, or some checks could not run. List the gaps.
- **NOT VERIFIED**: at least one criterion fails, a test cannot fail, a dependent was missed, or an author claim is false.

Every finding carries a command or file reference that reproduces it. Follow **principle-evidence-in-every-claim**. Do not suggest rewrites beyond what a finding needs.

## Second opinion

For a risky change, run a second verifier on a different model with the same prompt (for example Codex through the codex plugin, read-only). Merge the two reports. A finding both raised is strong. A finding only one raised gets checked by hand before it counts.
