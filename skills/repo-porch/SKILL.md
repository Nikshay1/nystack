---
name: repo-porch
description: "Prepare, implement, verify, describe, and follow up on a pull request to kptdev/porch (Porch, the kpt package orchestration server, controllers, and porchctl). Use for any issue or PR in that repository: claiming, the fix and tests, make check/test, copyright year amendments, commit and PR template conventions, Copilot's single review, SonarCloud, CI flakes, and maintainer follow-ups. Built from the review history of 4 PRs (October 2026)."
---

# Porch contributions

Porch PRs merged fast when they were small, tested, and fully described. The findings that did come back were small consistency slips that Copilot caught (a doc comment left naming the wrong test, a docs step that ignored the Draft-only rule, an error message missing accepted aliases), bot threads left unanswered or unresolved, a known gap deferred without filing the promised issue, and a maintainer request (rebase on another PR) left waiting. [references/review-history.md](references/review-history.md) lists every finding.

## 1. Load the project's own rules

Porch has no `AGENTS.md` or `CONTRIBUTING.md` at the root. Its rules live in the docs site source. Read from the current default branch:

- `docs/content/en/docs/12_contributing/code-contribution/_index.md`: checks to run, copyright headers and the year table, commit format, review requirements, rebasing.
- `docs/content/en/docs/12_contributing/_index.md`: claim etiquette, the CLA note.
- `.github/PULL_REQUEST_TEMPLATE.md`: the sections every PR body fills in, including AI Disclosure.
- `scripts/boilerplate.go.txt` and `scripts/boilerplate.yaml.txt`: headers for new files.

## 2. Claim and scope

- The guide says to comment on issues you want to work on. Comment first, even though PRs without a claim were tolerated (#571, #948, #1267). Check open PRs and branches for duplicates.
- If you widen scope beyond the issue (a fourth call site, a broader condition), say so in the PR body and why. If you narrow it (the issue proposed `!= True`, the PR blocks only `False`), say so too, because Copilot and reviewers compare the PR with the issue's proposal (#1283).
- A gap you knowingly leave open is either fixed in the PR or filed as an issue before the PR goes for review, with the link in the body and in the thread that raised it. "Happy to open it" without opening it leaves the thread unresolvable (#1283).

## 3. While implementing

- **Edit around existing code with care.** When inserting a function or test, check the doc comment above the insertion point still describes the right symbol (#1283).
- **User-facing text must match every accepted input.** Validation messages list every accepted form, aliases included (#1258).
- **Docs follow the lifecycle rules.** Recovery or how-to steps must respect the package lifecycle (resources change only in `Draft`, so a `Proposed` package goes back to `Draft` first) (#1283).
- **Keep complexity under SonarCloud's limit.** Adding a branch to a long function can push cognitive complexity past 15, which SonarCloud reports as critical even when the gate passes. Extract a helper instead (#1282, `mapTaskToMutation`).
- **Pre-existing problems** found along the way get their own issue with a reproduction (#1264, #1297, #1298 were well received).

## 4. Copyright headers

- New Go files: `scripts/boilerplate.go.txt` with the current year. Other new files the guide covers (YAML, scripts, test data): `scripts/boilerplate.yaml.txt`, in the file's own comment syntax. Formats without comments (JSON) and fixtures whose exact bytes are under test get none; follow what existing files in that directory do.
- Modified files: amend the years with the table in the code-contribution guide. Contiguous years become a range (`2025` → `2025-2026`); a gap takes a comma (`2024` → `2024, 2026`, `2022-2024` → `2022-2024, 2026`). #1258 and #1282 did this correctly.
- An existing file with no header at all: note it in the PR rather than guessing a creation year.

## 5. Tests and checks

- The guide asks for `make check` (fmt, vet, lint, test), `make test`, and `make test-e2e` before a PR. Run `make check` at least. When the e2e suites cannot run locally (no cluster, no Docker), say exactly which ones in the PR; every past PR had to say "compiled only" for e2e changes.
- Write unit tests that fail on main; every merged PR had them.
- Run **verify-change**, then **adversarial-review** for anything beyond a small fix.

## 6. Commits and the PR body

- `git commit -s` with a conventional, imperative subject: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:` ("fix: add …", not "Added …"). Past commit subjects had no prefix; nobody objected, but the guide asks for it.
- Branch names in the guide use `feature-`, `fix-`, `refactor-`, `docs-` prefixes.
- Add an `Assisted-by: <agent>:<model>` trailer on every commit an AI tool touched.
- Fill in every section of `.github/PULL_REQUEST_TEMPLATE.md`: Description (what, why, how), Related Issue(s), Type of Change, Checklist, Testing Instructions, Additional Notes (known issues, further improvements, review notes), and AI Disclosure (tick it and say how AI was used). You must be able to explain the code without the tools.
- Do not tick "All tests and gating checks pass" unless you ran them.

## 7. Copilot reviews once

The Copilot workflow runs only when a PR is opened, marked ready, or reopened, not on later pushes. Its first review is the one reviewers expect addressed before merge, and the guide requires all discussions resolved.

- Self-review hard before opening, or open as a draft and mark it ready when it is ready, because that triggers the one Copilot review.
- Answer every Copilot thread: "Fixed in <sha>" with the test name, or the reason it is not changed. Make a decision on each finding; do not hand the choice back with "if you prefer".
- Resolve each thread once it is answered or fixed. Fixed-but-silent threads stay open and block merge (#1283).

## 8. After opening

- Reviews and merges come from the CODEOWNERS (efiacor, liamfallon, kispaljr, mozesl-nokia) and the contributors team (kushnaidu and JamesMcDermott approved past PRs). Merge needs one contributors-team and one maintainers-team approval, green checks, and resolved discussions. Small fixes merged within a day.
- Only a first PR waits for workflow approval; later PRs start CI on their own.
- When a maintainer asks to wait for or rebase on another PR, watch that PR and rebase as soon as it merges, with `--force-with-lease` as the guide says (#1283 waited on #1284).
- Explain every red check on the PR, not just one. Failures that were flakes on past PRs: CRD e2e v1alpha2 lifecycle tests timing out ("awaiting render"), the PRR race-condition test's one-shot assertion, Go proxy or sumdb network errors in lint and image builds, and the data race in `pkg/cli/commands/rpkg/push` `TestCmd` (#1298). A matching symptom is a hint, not proof, especially when your change touches lifecycle or rendering. Read the log, compare with main or an unrelated PR's run, then explain it on the PR and ask for a re-run. Never push empty commits.
- Unaddressed review comments for two weeks can get a PR closed.

## Final check

- [ ] Claim comment on the issue; no duplicate PR or branch.
- [ ] Every deliberate difference from the issue's proposal stated in the body; known gaps fixed or filed with a link.
- [ ] Doc comments, messages, and docs consistent with the change and the lifecycle rules.
- [ ] No new SonarCloud issues, including cognitive complexity.
- [ ] Headers: boilerplate on new files, years amended per the table.
- [ ] `make check` run; the e2e suites not run are named.
- [ ] Commits signed off, conventional imperative subjects, `Assisted-by` trailers.
- [ ] Every PR template section filled in, AI Disclosure ticked.
- [ ] Every Copilot thread answered and resolved; every red check explained.
