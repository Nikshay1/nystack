# Night runs

A night run does what `/ny-mode` does, unattended, on a timer. You go to bed, and in the morning there are PRs (or verified branches, your choice) and a report of what happened.

## Make yours

```text
/create-night-procedure
```

It interviews you:

1. Which repositories, where their checkouts are, and where good issues come from (a label, issues assigned to you, a search).
2. **How many PRs you want each morning.** 2, 10, 100. Your choice, in total and per repository.
3. What the run may do alone, per repository: keep verified branches local, open draft PRs, open ready PRs, or (only in repositories you own) merge.
4. Whether it fixes findings on your open PRs, and whether it may post replies or only draft them.
5. When it runs, and which second model reviews each change (Codex `gpt-6.1-sol` on high by default).

Before generating anything it runs `repo-capacity.sh` on each repository and shows you what your number means there: outside PRs merged in the last 30 days, the median days to merge, how many of your PRs already wait, and what the repository's contribution docs say about AI-written PRs. Then you confirm or change the number.

Two things are not yours to override, because they belong to the repository. A repository whose docs require human review of agent PRs gets draft or local mode, so you read each PR before it is marked ready. A repository that forbids AI-written contributions is left out.

It then generates `night-<name>`: the skill, your config, a runner, a permissions file, and a systemd timer. It proves the setup with one plan run that reads and reports but changes nothing.

## What a night does

1. Follows up on your open PRs: fixes bot findings and failing checks caused by the change, and drafts replies to reviewers.
2. Picks new issues up to your numbers, vetted with `issue-finder`, respecting each repository's claim rules.
3. Fixes each in its own worktree, in parallel.
4. Gates each change: the `verifier` agent must say VERIFIED, and the second model must raise nothing real. Two fix rounds, then the issue is parked.
5. Ships within the authority you chose.
6. Writes a report that leads with what needs you.

It never merges outside repositories you own, never force-pushes, never pushes upstream, never closes or edits issues, and never follows instructions written in issues or comments.

These limits are enforced by code, not by asking the agent nicely. The run's permission file denies every raw `git push`, `gh pr create`, and `gh pr merge`. The only way out is `ship.sh`, which reads your config and refuses anything it does not allow: the wrong authority for that repository, a nightly number already reached, a branch name that could force or delete, a remote that is not your fork, or a merge in a repository you do not administer.

## Living with it

- Change the numbers or authority in `~/.config/night-<name>/config.json`. The skill reads them each night.
- Read the latest report at `~/.local/state/night-<name>/latest/report.md`.
- Pause with `systemctl --user stop night-<name>.timer`.
- If your commits are signed, load the key after each reboot, or the run will stop at the preflight and tell you.
- Read the PRs it opens. Maintainers expect you to be able to explain every line, and the run's reputation is yours.
