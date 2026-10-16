# Verification

An agent that wrote a change reads its own diff as it intended it. Its summary repeats its plan, not what the code does. Asking it "are you sure?" gets the same blind spots a second time.

nystack splits the roles. The author writes. The `verifier` agent, started fresh and preferably on another model, checks. It never edits the code, so its verdict stays independent.

## What the verifier does

`verify-change` runs these steps in order:

1. **Acceptance criteria from the request, before the diff.** Otherwise the diff decides what "correct" means.
2. **Read the diff as a stranger.** Every behavior change, including unmentioned ones.
3. **Prove the tests can fail.** Run each new test against the old code. A test that passes on the base commit proves nothing.
4. **Break the fix on purpose.** Remove each branch of it in a scratch worktree and see whether a test notices.
5. **Run the real path,** through the project's `verify-<app>` skill or a script against the real entry point.
6. **Sweep beyond the diff** for stale callers, readers, mocks, docs, and texts.
7. **Check every author claim** in the PR body: confirmed, false, or unverifiable.
8. **Run the fast project checks.**

The report leads with VERIFIED, VERIFIED WITH GAPS, or NOT VERIFIED, and every line carries the command that reproduces it.

## Proof levels

Every claim says how far it got: 1 said so, 2 pointed at the line, 3 traced, 4 ran it, 5 reproduced in the running app. Level 4 is usually one small script.

## Driving the real app

`verify-change` step 5 is only as good as the project's way to run the app. `/create-verification-skill` builds a `verify-<app>` skill once: launch, doctor, drive, evidence, cleanup, and a recipe per feature. `/maintain-verification-skill` keeps it working.

## More eyes

For risky changes, add `/adversarial-review` (models trying to break the diff) and `/blast-radius` (what it breaks elsewhere, with the safety fact proven by running code).
