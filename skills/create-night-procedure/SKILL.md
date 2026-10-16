---
name: create-night-procedure
description: "Interview the user and generate their own night-procedure skill: an unattended overnight run that follows up on their open PRs, fixes vetted issues in their chosen repositories, gates every change on independent verification and a second-model review, and leaves the number of PRs they asked for (2, 10, 100) plus a morning report. Measures each repository's capacity and policy first so the user chooses with the facts. Use for /create-night-procedure or 'set up an overnight PR run'."
disable-model-invocation: true
---

# Create a night procedure

You build a personal overnight run for the user. They choose the target. You make sure they choose knowing what each repository will accept, and that the run they get is safe to leave alone.

The generated run is a skill (`night-<name>`), a config file, a runner script, a permissions file, and a timer. The skill body comes from [`references/night-procedure-template.md`](references/night-procedure-template.md); the user's choices live in the config, so changing a number later never means editing the skill.

## 1. Interview

Ask these in order, a few at a time. Offer the default in brackets and accept any answer.

1. **Name** for the run [their GitHub login].
2. **Repositories.** Which repositories, and for each: their checkout path, the fork and upstream remote names, and where good issues come from (a label such as `good first issue` or `agent/ready`, issues assigned to them, or a search).
3. **Morning target.** How many new PRs do they want waiting each morning, in total and per repository? 2, 10, 100, or any number. It is their choice.
4. **Authority, per repository.** What may the run do without them?
   - `local`: verified branches committed locally; they push in the morning with one command each.
   - `draft`: push to their fork and open draft PRs.
   - `ready`: push and open PRs ready for review.
   - `merge-own`: for repositories they own only, merge when the gate and CI pass.
5. **Follow-ups.** Should the run fix findings on their already-open PRs and push the fixes [yes]? Replies to reviewers are always drafted into the report, never posted; say so.
6. **Where and when.** Their machine with a systemd timer [01:30, stop starting new work by 06:00], or another scheduler they use. Must the laptop be on AC power [yes]?
7. **Review gate.** The verifier is always a separate Claude agent running **verify-change**. Which second model reviews each change [Codex `gpt-6.1-sol` on `high`, if `codex` is installed]?

## 2. Measure each repository

Run, once per repository:

```bash
<nystack>/skills/create-night-procedure/scripts/repo-capacity.sh <owner>/<repo> <their-login>
```

It prints: outside PRs merged in the last 30 days, the median days from open to merge, their PRs currently open there, the open issues matching common good-issue labels, and every line of `CONTRIBUTING.md`, the PR template, and agent docs that mentions AI, agents, LLMs, or generated code.

Show the user a table: their target per repository next to what the repository merged from outside contributors last month, how many of their PRs already wait for review, and the policy lines. Say plainly what their number means in practice, for example "100 a night against a repository that merges 12 outside PRs a month leaves about 3,000 unreviewed PRs by month end, and maintainers usually block accounts that do that". Then let them confirm or change the number. Do not change it for them.

Two rules are not the user's to waive, because they belong to the repository:

- If a repository's written policy requires a human to review agent-written work before it is submitted, its authority is `local`: the run leaves verified branches and the morning report gives one command per PR, which the user runs after reading the change. If the policy only requires disclosure, any authority is fine and the PR body discloses. If it forbids AI-written contributions, leave the repository out and say why.
- `merge-own` is only for repositories they own or administer (`gh repo view --json viewerPermission` is `ADMIN`).

## 3. Generate

Write to the user's skills location (`~/.claude/skills/night-<name>/`, or their skills repository if they keep one), and their config to `~/.config/night-<name>/config.json`:

1. `SKILL.md` from the template, with `{{NAME}}` filled in.
2. `config.json` from [`references/config-template.json`](references/config-template.json) with every interview answer.
3. Copy `scripts/run-night.sh`, `scripts/ship.sh`, `scripts/second-review.sh`, and `references/report-template.md` into the generated skill, and keep the scripts executable.
4. `headless-settings.json` from [`references/headless-settings-template.json`](references/headless-settings-template.json), with `{{SKILL_DIR}}` replaced by the generated skill's absolute path. Keep the deny list whole: it blocks every raw `git push`, `gh pr create`, and `gh pr merge`, so the only way out is `ship.sh`, which enforces each repository's authority and the nightly numbers itself. Do not add allow rules for raw push, create, or merge commands.
5. Check that every repository has a `repo-<name>` skill. For each one missing, offer **learn-from-reviews** if the user has past PRs there, or warn that the run will skip that repository until one exists.

## 4. Prove it

1. Run `<generated-skill>/run-night.sh ~/.config/night-<name>/config.json plan` once. It reads, vets candidates, and writes a report, with no worktrees, commits, or pushes. Show the user the report.
2. Fix whatever the plan run got wrong: unreadable config, missing checkouts, wrong remotes, labels that match nothing.
3. Install the timer: `scripts/install-timer.sh <name> <skill-dir> "<OnCalendar>"`.

## 5. Hand over

Tell the user: where the skill, config, and runs live, how to change the number (edit the config), how to pause (`systemctl --user stop night-<name>.timer`), what the morning report contains, and what the run will never do. Remind them that their signing key, if commits are signed, must be loaded after each reboot.
