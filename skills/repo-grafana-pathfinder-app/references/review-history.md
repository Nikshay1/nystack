# Review history: grafana-pathfinder-app PRs by Nikshay1

Historical record, compiled on 2026-10-16 from the reviews, inline comments, and conversation on all 16 PRs (all merged). File paths and line numbers are as they were at review time; check current source before relying on them.

Nine of the 16 PRs drew at least one finding. Two had blockers, one had a change request, two had Cursor Bugbot defects, and the rest had suggestions or nits. Seven PRs had no findings at all.

## Findings and the rule each produced

| PR | Reviewer | Severity | Finding | Root mistake | Rule (SKILL.md section) |
| --- | --- | --- | --- | --- | --- |
| [#2093](https://github.com/grafana/grafana-pathfinder-app/pull/2093) proxy guide list reads | moxious (review bot) | blocking | `tests/private-guide-copy.spec.ts` and `tests/customize-guide.spec.ts` still mocked the old `/apis/.../interactiveguides` list route, so the editor's Publish step would fail and the save path lost coverage. | Searched `src/` for callers of the moved read, not `tests/` for mocks of the old URL. | Blast-radius sweep over `tests/` (§5) |
| #2093 | moxious | follow-up | The new `/custom-guides` envelope had no contract golden or Zod schema, which `BACKEND_PROXY_PATTERN.md` section 10 requires. | Did not read the pattern doc's new-route checklist to the end. | Backend routes (§3) |
| #2093 | moxious | rebase | Conflicted with our own #2092 in the same allowlist block and doc wording; later also with #2058. | Two of our PRs edited the same block at once. The readiness note had flagged the overlap. | Overlapping PRs (§2) |
| [#2092](https://github.com/grafana/grafana-pathfinder-app/pull/2092) remove dead guide fetch | moxious | blocking | `docs/developer/utils/README.md` still listed `context.init.ts` under "Used by" for `interactive-guides-api.ts` after the import was removed. | Doc drift outside the diff. | Blast-radius sweep, `Used by` lists (§5) |
| #2092 | moxious | blocking | A new comment said the remaining read needs a full-resource proxy, while the retained allowlist entry's reason and `ADVICE` text still named `fetchCustomGuideRepository` as the fix. | Edited one of three texts describing the same fact. The readiness note had said the reason text was wrong. | Several texts must agree (§3) |
| [#2145](https://github.com/grafana/grafana-pathfinder-app/pull/2145) guided step wait | moxious | follow-up | `docs/developer/CROSS_TAB_CONTROLLER.md:76` still said composite actions wait up to 15 minutes. | Did not grep docs for the old bound in prose. | Blast-radius sweep, prose values (§5) |
| #2145 | moxious | suggestion | The component test asserted `900_000` with a 2-substep fixture, which equals the old default, so it could not catch a wrong substep count or a dropped `max()` branch. | Test value did not differ from the old behavior; mutation check covered only the helper. | Tests that fail on old code (§4) |
| #2145 | moxious | suggestion | The controller's per-substep budget matched the live tab's only by comments; a later change to the executor would diverge silently. | Coupling stated in a comment instead of code or a test. | Tie coupled values in code (§3) |
| #2145 | moxious | nit | Comments broke the default-to-no-comments rule: one restated a constant name, one multi-line block mixed four topics. | Did not apply `comment-hygiene` (QC8). | Comments (§3) |
| [#2133](https://github.com/grafana/grafana-pathfinder-app/pull/2133) RudderStack fixture guard | moxious | suggestion | The spec import guard only saw import declarations from three known modules; `import { default as test }` or a namespace import from another module would pass. | Guard listed forbidden forms instead of allowing one form. | Guard tests fail closed (§4) |
| [#2037](https://github.com/grafana/grafana-pathfinder-app/pull/2037) local-tier skip | Cursor Bugbot | medium | Ancestor walk compared the unresolved `selectedPath` with a realpath'd `root`; a different spelling of the same checkout was rejected, and with no symlink on the way up the loop never ended at `/`. Fixed in a second commit. | Mixed canonical and raw paths; no termination at the filesystem root. | Paths and loops (§3) |
| [#1863](https://github.com/grafana/grafana-pathfinder-app/pull/1863) prefixed content keys | Cursor Bugbot | medium | After resetting a guide, legacy keys stayed, and a never-reset shorter sibling still counted them through `countAllCompleted`, `hasProgress`, `countAllAcknowledged`. The maintainers took the read-side work as a follow-on. | Changed the write and reset side of a storage format without the read-side counters. | Every reader and writer (§3) |
| [#2012](https://github.com/grafana/grafana-pathfinder-app/pull/2012) reset progress at step 0 | moxious | nit | `runGuided()` returns before calling `executeGuidedStep` when the first action has a non-guided verb, so the moved reset never ran on that path (not observable today). | Moved an invariant into a callee without checking callers' early returns. | Every early return (§3) |
| [#1871](https://github.com/grafana/grafana-pathfinder-app/pull/1871) quote curl auth header | moxious | changes requested | "Just remove the test file, it's more weight than it's worth." The PR had added `scripts/tests/app-platform.test.sh`, which starts an HTTP server to run real curl, for a one-line quoting fix. | Test infrastructure out of proportion to the fix. | Test weight (§3) |
| [#1741](https://github.com/grafana/grafana-pathfinder-app/pull/1741) remove metadata modal | moxious | suggestion | Trim the hand-maintained modal inventory and restating JSDoc in the touched declarations. We replied that we would do it next time instead. | Did not trim on touch, which `AGENTS.md` asks for. | Comments, trim on touch (§3) |

## PR body problems found on rereading

Nobody flagged these, but they cost reviewer time or contradict `pr-summary`:

- #2092's How to verify asked the reviewer to run `npm run test:review-contract`; `pr-summary` says not to list CI-enforced commands.
- #2037's body ran to several screens, and its How to verify had a "4. 4." step.
- Footers were inconsistent: some PRs said "Prepared with OpenAI Codex", others "Generated with Claude Code", and #1863 used the template checklist.

## What reviewers praised

Keep doing these:

- A **Not changed** section that names deliberate omissions and known limits (#2145, #2133).
- A reproduction on the real shipped data and tests that cover top-level and nested cases (#1863, #2011, #2052).
- Following the readiness note and grooming decision exactly, with no design detour (#2012).
- Taking a review follow-up in the same push as the blocker fix (#2093's contract golden).
- Small, exact doc fixes whose claims the reviewer could verify, such as #1868's figures matching the measured numbers in #1823.

## PRs with no findings

#2052, #2011, #1868, #1835, #1804, #1750, #1733.

## Recurring CI noise (not caused by the change)

- `publish-report` fails on every fork PR, and the bundle-size `compare` job fails on some ("Resource not accessible by integration" when commenting from a fork).
- Fork PRs wait in `action_required` until a maintainer approves the CI run.
- Two unchanged UI suites (`BlockEditor.persistence`, `SandboxRecovery`) hit the five-second Jest timeout in full local coverage runs and passed on rerun.
