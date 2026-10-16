# Working in nystack

This repository is a Claude Code plugin and a skills library. Every skill is a folder under `skills/` with a `SKILL.md`.

## Layout

- `skills/<name>/SKILL.md`: one skill. Long templates and prompts go in `references/`, scripts in `scripts/`.
- `skills/ny-mode/playbooks/`: the playbooks ny-mode routes to.
- `skills/principle-*`: one rule each, read by ny-mode by path.
- `skills/repo-*`: rules for one repository, learned from its review history.
- `agents/`: subagent definitions.
- `.claude-plugin/`: plugin and marketplace manifests. Bump the version in all three places together.
- `scripts/validate.py`: the repository check. `scripts/install.sh`: links skills into `~/.claude` (and `~/.codex`).
- `docs/guide/`: the human guide.

## Rules for skills

- The folder name and the frontmatter `name` match: lowercase, hyphenated, at most 64 characters.
- `description` says what the skill does and when to use it, in under 1024 characters. Add `disable-model-invocation: true` when the skill should run only by name or through ny-mode.
- Write for an agent reading cold, mid-task. Keep only sentences that change a decision.
- Point at other skills and project files instead of restating them.
- A rule that can be a script should be a script. Scripts are executable and their invocation is shown in the skill.
- Repo skills in this public repository quote only public material. Nothing machine-specific without a label saying so.
- Add every new skill to the README tables. `validate.py` fails otherwise.
- Adapted material from another project gets a line in `NOTICE.md`.

## Before committing

```bash
python3 scripts/validate.py
bash -n scripts/install.sh
git diff --check
```
