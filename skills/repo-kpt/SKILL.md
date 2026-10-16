---
name: repo-kpt
description: "Prepare, implement, verify, describe, and follow up on a pull request to kptdev/kpt (the kpt CLI and function runtime). Use for any issue or PR in that repository: claiming an issue, design questions, the fix and tests, SonarCloud, copyright headers, DCO and AI attribution, the PR body, and maintainer review. Built from the review history of 5 PRs (October 2026)."
---

# kpt contributions

Past kpt PRs rarely failed on logic. They went back for rework because a behavior choice was made before a maintainer agreed with it, because a claim raced another contributor, or because a project convention (logging library, copyright year form, SonarCloud on new code) was missed. [references/review-history.md](references/review-history.md) lists every finding and the rule it produced.

## 1. Load the project's own rules

Read from the current default branch, not from memory:

- `CONTRIBUTING.md`: DCO, copyright, the pre-review checklist (tests, lint, SonarCloud, first-run bot comments addressed), AI declaration, `Assisted-by` trailers, docs in separate PRs, two code-owner approvals, PRs closed after two weeks without a response.
- `AGENTS.md`: `make all` before every commit, `make generate` after CLI doc changes, `pkg/` versus `internal/`, golangci-lint version, design documents for large features and CLI/API changes, and "Always ask for a final review from a human before committing".
- `.github/copilot-code-review.yml`: what Copilot is told to check, including the logging convention (`log.FromContext(ctx)`).
- `architecture/style-guides/errors.md` before writing any error message.

Human review before commit is a project rule. An unattended run may prepare and verify a branch, but the operator reads the change before it is committed and pushed.

## 2. Claim before you build

- Comment on the issue and tag `@kptdev/maintainers`, not one person. A maintainer asked for this after a claim race on #4473 ("please ping @kptdev/maintainers next time if you would like an issue assigned to you").
- Our own precaution, stricter than that quote: wait for the assignment (or a maintainer reply) before opening the PR. Every PR opened minutes after its claim or question either raced someone or left the question unanswered.
- Read the whole issue thread first. If someone else claimed it or posted a design, coordinate on the issue before writing code.
- An issue you open yourself still needs the assignment ping.

## 3. Settle behavior with a maintainer first

When the issue leaves a behavior open (what a flag limits, which default applies, which limitations are acceptable), ask on the issue and wait for an answer before implementing. On #4798 the `--timeout` flag was built per function; the maintainer wanted it to bound the whole pipeline, with per-function limits from the Kptfile, and the PR was reworked. On #4800 and #4802 the PR was opened minutes after posting design questions that are still unanswered.

If you must open the PR before an answer, open it as a draft and say which choice is pending.

For CLI or API changes and large features, check whether a design document under `docs/design-docs/` is required first.

## 4. While implementing

- **Logging.** Never add `klog` calls, even when copying code that uses them. A maintainer asked to remove copied `klog.V(6)` lines (#4795); the repo is moving off klog, and `.github/copilot-code-review.yml` names `log.FromContext(ctx)` as the convention.
- **Context.** Pass `context.Context` as a parameter. Do not store it in a struct field; SonarCloud flags that as major (#4798, `ExecFn.Ctx` became `ExecFn.RunContext(ctx, ...)`).
- **Error messages.** Follow `architecture/style-guides/errors.md` and say what happened in plain words. For limits, name the limit and that it was exceeded ("pipeline execution timeout of 5m0s exceeded"), as a maintainer asked on #4798.
- **Empty functions** need a one-line comment saying why they are empty, or SonarCloud reports them as critical (#4798).
- **Comments** must name the right subject. A doc comment copied from a neighbouring field said "Container function" on an exec field (#4798).
- **Concurrency.** For signals, timers, and channels, check what happens when two `select` cases are ready at once, and when a signal arrives as the work finishes (#4800).
- **Out-of-scope findings.** When a bot or reviewer finds a real pre-existing problem, reproduce it on main, keep the PR scoped, and open a follow-up issue or PR. Maintainers accepted this every time (#4795 led to #4796; #4798 led to #4799 and #4800).
- **Docs.** CLI reference changes need `make generate` and the regenerated files committed. Standalone docs changes go in a separate PR whose description starts with `Docs:`.

## 5. Copyright headers

`CONTRIBUTING.md` says all files should have the notice. Add it in the comment syntax of the file's format, the way neighbouring files of that type do. Formats without comments (JSON) and test fixtures whose exact bytes are under test get none; check what the existing files in that directory do. For a modified file, apply the year table in Porch's contribution guide, which kpt's `AGENTS.md` points to (`docs/content/en/docs/12_contributing/code-contribution/_index.md` in kptdev/porch): contiguous years become a range (`2025` → `2025-2026`), a gap takes a comma (`2021` → `2021, 2026`, `2022-2024` → `2022-2024, 2026`). On #4802 `2021-2026` was written where `2021, 2026` was correct, and a maintainer fixed it in the PR.

## 6. Tests and checks

- Run `make all` before committing (fix, vet, fmt, lint, test, build, tidy). Many tests need git configured.
- Every new code path gets a test, including the container variant of a runtime change (#4798 had none until Copilot asked).
- Tests that need Docker or a cluster carry build tags; say in the PR which ones you could not run.
- Run **verify-change**, then **adversarial-review** for anything beyond a small fix.

## 7. SonarCloud and bots before human review

`CONTRIBUTING.md` asks that the first round of bot comments (Copilot, SonarCloud) is addressed before human review. Fix every SonarCloud issue the PR introduces, not only explain the pre-existing ones (#4798: a critical and a major on new code were missed while three old minors were explained). If a bot finding cannot be fixed, reply under it with the reason.

## 8. Commits and the PR body

- Sign off every commit (`git commit -s`). Put an `Assisted-by: <agent>:<model>` trailer on every commit an AI tool touched, in the same order each time, including fix-up commits (two fix-ups on these PRs had none).
- Follow `.github/PULL_REQUEST_TEMPLATE.md`: description, motivation, `Fixes #N`.
- Declare AI use in the description: which tools and for what. You must be able to explain every line without the tools.
- Keep the sections that worked: testing done, known limits, AI usage, notes for reviewers. Say plainly which tests did not run locally.

## 9. After opening

- Until a contributor has a merged PR, every push needs a maintainer to approve the workflow runs (`action_required`). After the first merge, runs start on their own.
- Two code-owner approvals are required (`CODEOWNERS`: liamfallon, kispaljr, mozesl-nokia, efiacor). mozesl-nokia usually responds first; reviews arrive Monday to Friday, roughly 06:00 to 15:00 UTC.
- Failures that were flakes on past PRs: `Install Kind` checksum errors, podman `maintenance.lock` in `commands/live/apply` tests, and `crd-and-cr` reconcile timeouts in live-apply. A matching symptom is a hint, not proof. Before calling a failure unrelated, read its log, check the failing package against your diff, and look for the same failure on main or an unrelated PR. Only then ask a maintainer to re-run, with that evidence. Never push empty commits.
- Answer every review thread with what changed and the commit. Do not repeat a comment on a thread a maintainer resolved.
- A PR whose comments go unanswered for two weeks is closed. Keep threads moving.

## Final check

- [ ] Issue assigned to you after a `@kptdev/maintainers` ping; nobody else's claim.
- [ ] Open behavior choices answered by a maintainer, or the PR is a draft that says what is pending.
- [ ] No new `klog`; no `context.Context` fields; error text follows the style guide.
- [ ] Copyright header years follow the Porch table.
- [ ] `make all` passes; `make generate` run if CLI docs changed.
- [ ] No SonarCloud issues introduced; every first-round bot comment answered.
- [ ] Every commit signed off with a consistent `Assisted-by` trailer; AI use declared in the body.
- [ ] The operator has read the change before it is committed.
