# Make it yours

Start small. Add a skill or a check when the same failure shows up twice, not before.

## Write a skill

```text
/ny-mode write a skill for verifying database migrations in this repo
```

The authoring-a-skill playbook covers the rules: write for an agent reading cold, keep only sentences that change a decision, put templates in `references/` and commands in `scripts/`, point at other skills by name. `python3 scripts/validate.py` checks names, frontmatter, links, and the README tables.

## Prefer checks to prose

A sentence in a skill fails silently when an agent skips it. A script fails loudly. When a lesson can be a search command, a checker, or a test, write that instead (`principle-encode-lessons-in-structure`). `check_map.py` exists because "make sure the map is current" never worked as a sentence.

## Test a skill change

Try the change on one real task in a fresh agent before keeping it. Better, give the same task to two fresh agents, one with the old skill and one with the new, without telling either it is being compared, and compare what each actually did. A rule written from one bad session tends to fit that session only.

## Keep skill changes separate

Do not edit a skill in the middle of feature work. Finish the task, then fix the skill in its own commit, so the change can be reviewed on its own.
