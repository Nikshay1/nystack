---
name: repo-grafana-pathfinder-app
description: "Prepare, implement, self-review, describe, and follow up on a pull request to grafana/grafana-pathfinder-app (Grafana Pathfinder / Interactive learning plugin). Use for any issue or PR in that repository: picking up an issue, writing the fix and tests, the pre-PR check, the PR body, and answering the maintainers' review bot. Built from the review findings on 16 merged PRs."
---

# grafana-pathfinder-app contributions

Most review findings on past PRs were not wrong logic in the changed lines. They were things the diff did not touch: a doc that still stated the old value, a Playwright spec still mocking the old route, a comment that contradicted another comment, a reader of a storage key that was never updated. This skill exists to catch those before a reviewer does. [references/review-history.md](references/review-history.md) lists every past finding and the rule it produced.

The repository has its own agent rules and its own review pipeline. This skill does not replace them; it points at them and adds what they did not prevent. Read the repository's files from the current `main`, not from memory, because they change often.

## 1. Load the repository's own guidance

Before writing code, read from the current default branch:

- `AGENTS.md` (always-on rules: tier model, App Platform proxy rule, comment rule, sentence case, no "Pathfinder" in user-facing text, commands).
- `CONTRIBUTING.md` (single concern, roughly 500 changed lines or fewer, signed commits, CLA).
- `docs/developer/CONTEXT_INDEX.md`, then only the docs it routes to for the touched area. Touching `pkg/` means reading `docs/design/BACKEND_PROXY_PATTERN.md` in full, including its "Author's checklist".
- `.cursor/skills/comment-hygiene/SKILL.md` before writing any comment.
- `.cursor/skills/pr-summary/SKILL.md` before writing the PR body.
- `docs/developer/KNOWN_GOTCHAS.md` before treating a red check as your fault.

## 2. Read the issue the way the maintainers wrote it

Most issues carry a `prep-issues` "Implementation readiness" comment and sometimes a "Grooming decision". These are the maintainers' spec.

- Use the readiness note's **Code basis** citations over the issue body; the note often says the body's line numbers or claims are stale.
- Treat every **Traps for the implementer** bullet as a requirement and check each one off before opening the PR.
- The hidden `paths=` list is the expected change surface; `prs=` lists related or overlapping PRs. Open each one.
- A grooming decision settles the design. Implement that design; do not reopen it in the PR.
- Read every later comment. Corrections ("Correction to the issue body") arrive after the note.
- If two open PRs (including our own) edit the same block, say so in both PR bodies and expect the second to rebase. After the rebase, the combined end state must be consistent, e.g. an allowlist that is now empty and docs that say it is empty.

Reproduce the bug on current `main` before fixing it, ideally as a failing test that drives the real code path. Maintainers value a reproduction with a real input (for a storage-key collision, use a pair of shipped guide IDs that actually collide, not `guide-a`/`guide-b`).

## 3. While implementing

Each rule below comes from a finding on a past PR.

**Every reader, every writer, every early return.**
- Changing a storage key format, data shape, or envelope: list every reader and writer of it (prefix scans, counters such as `countAllCompleted`, `hasProgress`, `countAllAcknowledged`, cross-tab listeners, e2e cleanup) and update or explicitly exclude each. A fixed write side with an unchanged read side was flagged on #1863.
- Moving an invariant from callers into a shared callee: check each caller for a path that returns before it reaches the callee; that path loses the behavior (#2012).

**Paths and loops.** Compare canonical paths on both sides (`realpathSync` both, or neither). Any loop that walks up with `dirname` must stop when `dirname(p) === p` (#2037).

**Tie coupled values in code, not in comments.** If your value depends on another module's constant (a timeout, a budget, a page size), import the constant or add a test that pins the relation. A comment saying "this matches X" is not enforced (#2145).

**Backend routes.** A new `pkg/plugin` route or response envelope needs everything in the "Author's checklist" and section 10 (Testing) of `BACKEND_PROXY_PATTERN.md`: a handler-captured contract golden registered in `contractRoots()`, a Zod schema in `BACKEND_RESPONSE_ENVELOPES` (and `GO_STRUCT_SCHEMAS` where it applies), and the route documented in `.cursor/rules/systemPatterns.mdc` (#2093).

**Comments.** Default to none. One short line, only for counterintuitive code, hidden invariants, external-bug workarounds with a link, or security/correctness warnings. No multi-line rationale blocks, no comment restating a constant's name, no issue or PR numbers in comments; that reasoning goes in the commit message and PR body. Trim bad-shape comments in the functions and adjacent declarations you touch, in the same PR. Do not defer that as "next time" (#1741, #2145).

**Several texts describing one thing must agree.** An allowlist entry's `reason`, its `ADVICE` text, the test header, a nearby comment, and the design doc often describe the same fact. Edit one and you must reread and reconcile all of them (#2092).

**Test weight matches the change.** Prefer extending an existing test file. Do not add new test infrastructure (an HTTP server, a new harness, a new test file under `scripts/tests/`) for a one- or two-line fix without asking first; the maintainer asked us to delete one (#1871).

## 4. Tests that would fail on the old code

- Every assertion about a new value must use a fixture where the new value differs from the old one. Asserting `900_000` when the old default was also `900_000` proves nothing (#2145).
- Test the integration point, not only the helper: if a helper computes a value, at least one component-level test should show a non-default value reaching the caller.
- Mutation-check: revert or break the fix (drop the `max()`, the `delete`, the third argument) and confirm a test fails. Do this for each branch of the fix, not just one.
- A guard test (an import or wiring check) should fail closed: allow the one permitted form and flag everything else, instead of listing forbidden forms. Otherwise state the unguarded forms in the PR body (#2133).
- Jest focused runs need `--coverage=false` (or `--no-coverage`), otherwise global thresholds report a false failure. Agents use `npm run test:ci`, not `npm test`.

## 5. Blast-radius sweep before opening the PR

Start from the feature map in [`feature-map/`](feature-map/README.md) (the **feature-map** skill): its **Change together**, **Tests**, and **Docs** sections list the dependents past reviews caught.

This is the step that would have prevented most blockers. For each changed symbol, route or URL, file path, constant, and old behavior described in prose, search the whole tree, not only `src/`:

```bash
git grep -n -e '<old-symbol>' -e '<old-route-or-url>' -e '<old value as prose, e.g. 15 minutes>' -- \
  src pkg tests docs .cursor .claude scripts '*.md'
```

Check in particular:

- `tests/**/*.spec.ts`: Playwright `page.route(...)` mocks of a URL you moved or retired (#2093).
- `docs/developer/**` and `docs/developer/utils/README.md` "Used by" lists after you add or remove an import (#2092).
- `docs/developer/*.md` sentences that state a number or bound you changed (#2145).
- `src/validation/*.test.ts` allowlists and ratchets that name the code you changed.

Then follow `.cursor/skills/prevent-doc-drift/SKILL.md` for the diff (it lists which guidance files each kind of change must update; it forbids editing `docs/design/`).

## 6. Self-review the way the maintainers will

The maintainer review is the repository's own `/review` skill run by a bot (the review body ends with a `pathfinder-review-state` marker). Its always-on concerns are security, correctness and reliability, testing and verification, reversibility, and cross-cutting architecture; it also routes subsystem concerns from `docs/design/CONCERNS.md`. Before opening the PR:

1. Find the concerns your changed paths trigger in the routing table of `docs/design/CONCERNS.md`, and read each one's packet: `node .cursor/skills/review/scripts/concern-context.mjs <concern-id>`.
2. For each concern, write down its invariant and check the diff against it.
3. Run the **verify-change** skill with the `verifier` agent on the final head, and **adversarial-review** for anything beyond a small fix. Check each finding yourself before acting on it.
4. Run the quick local checks on changed files (prettier, eslint, focused Jest, `go test` for touched packages). Hand the full `npm run check` to the user if it is slow.

In a fresh worktree, link or install `node_modules` first, or typecheck reports about 100,000 errors.

## 7. The PR body

Follow `.cursor/skills/pr-summary/SKILL.md`. In addition:

- For a fix: problem, root cause, and fix in three or four sentences, then How to verify. Add sections only when the change needs them.
- How to verify lists manual, PR-specific steps. Do not list `npm run check`, `test:ci`, lint, or typecheck; CI runs them.
- Keep a short **Not changed** section for deliberate omissions and known limits. The maintainer thanked us for it on #2145, and it stops a reviewer from filing the omission as a finding.
- Link files at the head commit SHA, never a branch or `main`.
- Claim only test results you have actually seen in this session. Say plainly what was not run (no browser, no cluster, no Grafana Cloud).
- Credit the AI tools that worked on the change the same way in the commit trailers and the PR body. Do not mix footers such as "Prepared with OpenAI Codex" and "Generated with Claude Code" across PRs without reason.
- Proofread numbered lists and code blocks (#2037 shipped a "4. 4." step).
- Use `Fixes #N` for bugs and `Closes #N` for other issues.

## 8. After opening

- Fork PRs need a maintainer to approve CI runs (`action_required`). `publish-report` and the bundle-size `compare` job fail on fork PRs with "Resource not accessible by integration". They are not caused by the change; mention that once, if at all.
- Every commit must be signed, or the signed-commits check fails.
- Cursor Bugbot comments within minutes. Treat each finding as a real hypothesis: reproduce it with a test, fix it in a new commit, and reply with what changed.
- The review bot labels findings `[blocking]`, `[follow_up]`, `[suggestion]`, and `[nit]`. Fix blockers. Fold a cheap follow-up (a one-line doc fix) into the PR before merge instead of leaving it for the maintainers. From round three on the bot adds no new nits, so finish optional work early.
- Reply on the PR once all blockers are pushed: list each finding and what changed, name the new head SHA, and ask for another look. Posting still needs the user's go-ahead.

## Final check before handing over

- [ ] Readiness-note traps and grooming decision each addressed.
- [ ] Failing test on `main`, passing with the fix; mutation-checked.
- [ ] Blast-radius grep run over `src pkg tests docs .cursor scripts`; docs, mocks, allowlists updated.
- [ ] Every reader and writer of a changed format updated; early-return paths checked.
- [ ] No new comments outside the keep-list; touched functions trimmed.
- [ ] Texts describing the same fact agree.
- [ ] Single concern, about 500 lines or fewer, commits signed.
- [ ] PR body follows pr-summary, has Not changed, claims only results actually seen.
