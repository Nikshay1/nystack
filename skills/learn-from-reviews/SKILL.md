---
name: learn-from-reviews
description: "Turn a repository's review history into a repo skill: collect every review, inline comment, bot finding, and maintainer note on the user's PRs there, group the mistakes into classes, and write repo-<name> with one rule per class plus a cited history. Use for 'make a skill for <repo>', 'learn from my PRs in <repo>', or after a PR needed fixes."
disable-model-invocation: true
---

# Learn from reviews

Every review comment that asked for a fix is a lesson the next PR can skip. This skill mines them and writes them down where an agent will read them before its next change in that repository.

## 1. Collect everything

For each PR by the user in the repository (`gh pr list -R <owner>/<repo> --author <login> --state all --limit 200`), save to a scratch directory:

```bash
gh api --paginate repos/<owner>/<repo>/pulls/<n>/reviews    # review bodies, incl. bots
gh api --paginate repos/<owner>/<repo>/pulls/<n>/comments   # inline comments, incl. Copilot and Cursor Bugbot
gh api --paginate repos/<owner>/<repo>/issues/<n>/comments  # conversation
gh pr view <n> -R <owner>/<repo> --json title,body,commits,closingIssuesReferences
```

Also read the linked issues' comments. Maintainers often post readiness notes, corrections, and design decisions there. Count force-pushes from the timeline; a rewrite after review hides a fix.

## 2. Read the project's own rules

From the default branch: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, the PR template, `.cursor/rules`, `.claude/skills`, `.github/` review config, and any review bot's own skill or policy files. A finding that cites a project rule is a sign that rule was not read. If the maintainers run a review bot, find out what it checks; you can often run the same checks locally.

## 3. Classify

For every finding that asked for a change (blocking, changes requested, bot defects, suggestions, nits), record: PR, reviewer, severity, what was wrong, and the root mistake behind it. The root mistake is about process, not code: "searched `src/` but not `tests/`", "did not read the pattern doc's checklist", "test fixture made new and old values equal".

Group root mistakes into classes. Note what reviewers praised too; those habits are worth keeping. Note CI failures that are noise, so future checks do not chase them.

## 4. Write the repo skill

Create `skills/repo-<repo>/` in the user's skills checkout:

- `SKILL.md`, following [`references/repo-skill-template.md`](references/repo-skill-template.md): what to load from the project, how to read its issues, rules by phase (before coding, while coding, tests, before the PR, the PR body, after opening), each rule ending with the PR it came from.
- `references/review-history.md`: the table of every finding, the root mistake, and the rule it produced, plus praised habits and CI noise. Mark it as historical with the date compiled.
- Optionally `feature-map/` (see **create-feature-map**) and `verify/` (see **create-verification-skill**).

Prefer pointing at the project's files over copying them; they change. Copy only the specific rule a past finding showed was missed. When a lesson can be a script (a search command, a checker), write the script instead of a sentence (**principle-encode-lessons-in-structure**).

Keep private details out if the skills repository is public. Quoting public review comments is fine.

## 5. Check and install

Validate frontmatter and links (`python3 scripts/validate.py` in nystack), install the skill, and confirm it appears in the agent's skill list. Report the counts (PRs read, PRs with findings, classes found) and the top classes.

## Keep it current

After each new PR in that repository, add its findings to the history and adjust the rules. A rule that keeps failing despite being written down needs a stronger form: a script, a check, or a step in the playbook.
