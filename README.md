# nystack

I'm Nikshay. I contribute to open-source projects (grafana-pathfinder-app, kpt, porch) with coding agents doing most of the typing. Reviewers kept catching the same kinds of mistakes in agent-written PRs: the agent guessed where code lived, fixed the changed lines but missed a mock or a doc that still described the old behavior, wrote a test that could not fail, or said "done" without proof.

nystack is the set of skills that stops that. Two ideas carry most of the weight:

- **Feature maps.** A short, script-checked map from each feature to its code, data, tests, docs, and change-together rules. The agent opens the right files instead of guessing, and knows what else a change makes stale.
- **Independent verification.** The agent that wrote the change does not grade it. A separate verifier writes acceptance criteria from the request before reading the diff, proves the tests fail on the old code, breaks each branch of the fix, runs the real path, and checks every claim the author made.

The structure is borrowed from [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan: one mode skill that routes to playbooks, situational skills, and one-rule principle skills. See [NOTICE.md](NOTICE.md) for what was adapted.

## Install

Pick one.

**As a Claude Code plugin** (skills are namespaced, for example `/nystack:ny-mode`):

```text
/plugin marketplace add Nikshay1/nystack
/plugin install nystack@nystack
```

**As linked skills** (unnamespaced, edits in the checkout apply immediately):

```bash
git clone https://github.com/Nikshay1/nystack.git ~/Projects/nystack
~/Projects/nystack/scripts/install.sh            # Claude Code: ~/.claude/skills and ~/.claude/agents
~/Projects/nystack/scripts/install.sh --codex    # also ~/.codex/skills
```

Do not use both, or every skill appears twice.

## Get started

Type `/ny-mode` before a task that needs rigor. With the plugin install, every skill name gets the plugin prefix: `/nystack:ny-mode`, `/nystack:verify-change`, and so on. The examples below use the linked-skills names.

```text
/ny-mode fix grafana/grafana-pathfinder-app#2005. reproduce first, then fix and verify.
```

It loads the repository's own skill if one exists, finds the code through the feature map, picks a playbook, and has the `verifier` agent check the result before calling it done. The [guide](docs/guide/README.md) walks through each part.

To have this happen while you sleep, run `/create-night-procedure`. It asks how many PRs you want each morning (2, 10, 100) and builds a nightly run that does the same steps unattended. See [Night runs](docs/guide/06-night-runs.md).

## Playbooks

`ny-mode` copies the matching playbook's steps into its todo list.

| Playbook | For |
| --- | --- |
| [investigation](skills/ny-mode/playbooks/investigation.md) | A read-only question: how does X work, where is Y. |
| [bug-fix](skills/ny-mode/playbooks/bug-fix.md) | Reproduce, root-cause, fix, verify. |
| [feature](skills/ny-mode/playbooks/feature.md) | New or changed behavior. |
| [oss-contribution](skills/ny-mode/playbooks/oss-contribution.md) | An upstream issue, from choosing it to an open PR. |
| [opening-a-pr](skills/ny-mode/playbooks/opening-a-pr.md) | Commits, PR body, and the last checks. |
| [pr-follow-up](skills/ny-mode/playbooks/pr-follow-up.md) | Reviews, bot findings, CI, and replies on an open PR. |
| [authoring-a-skill](skills/ny-mode/playbooks/authoring-a-skill.md) | Writing or editing a skill. |

## Skills

| Skill | Use it when |
| --- | --- |
| [ny-mode](skills/ny-mode/SKILL.md) | Any non-trivial task. Routes to a playbook and the skills below. |
| [feature-map](skills/feature-map/SKILL.md) | You need the code, data, tests, or docs for a feature. Reads the map, checks it by script, and updates it. |
| [create-feature-map](skills/create-feature-map/SKILL.md) | A repository has no map, or agents keep searching for the same code. |
| [maintain-feature-map](skills/maintain-feature-map/SKILL.md) | The map has drifted from the code. |
| [verify-change](skills/verify-change/SKILL.md) | You need to know whether a change is correct, with evidence, from someone other than its author. |
| [create-verification-skill](skills/create-verification-skill/SKILL.md) | A repository has no scripted way to launch the app and prove behavior. |
| [maintain-verification-skill](skills/maintain-verification-skill/SKILL.md) | A verify-app skill's recipes no longer match the app. |
| [blast-radius](skills/blast-radius/SKILL.md) | A small change you do not trust. Finds what it breaks elsewhere and proves the safety fact. |
| [adversarial-review](skills/adversarial-review/SKILL.md) | You want reviewers on different models to try to break a diff. |
| [repro-first](skills/repro-first/SKILL.md) | A bug to fix or file. Reproduce on the default branch first. |
| [learn-from-reviews](skills/learn-from-reviews/SKILL.md) | Turn a repository's review history into a repo skill. |
| [create-night-procedure](skills/create-night-procedure/SKILL.md) | You want PRs waiting when you wake up. Interviews you (repositories, how many PRs, what it may do alone), measures what each repository can absorb, and generates your own overnight run with a timer. |
| [issue-finder](skills/issue-finder/SKILL.md) | Find open-source issues that are available, unfixed, and realistic. |
| [unslop](skills/unslop/SKILL.md) | Remove AI writing patterns from prose. |

## Principles

One rule each. `ny-mode` indexes them; read the file before applying one.

| Principle | Rule |
| --- | --- |
| [prove-it-works](skills/principle-prove-it-works/SKILL.md) | Check the real artifact, and say which proof level each claim reached. |
| [look-beyond-the-diff](skills/principle-look-beyond-the-diff/SKILL.md) | Find the callers, readers, mocks, docs, and texts the change made stale. |
| [never-guess-locations](skills/principle-never-guess-locations/SKILL.md) | Map or search, open the file, then name it. |
| [test-behavior-not-implementation](skills/principle-test-behavior-not-implementation/SKILL.md) | A test must fail on the old code and survive a refactor. |
| [fix-root-causes](skills/principle-fix-root-causes/SKILL.md) | Fix where it first went wrong, not where it showed up. |
| [smallest-sufficient-change](skills/principle-smallest-sufficient-change/SKILL.md) | Complete, and nothing extra. One concern per PR. |
| [encode-lessons-in-structure](skills/principle-encode-lessons-in-structure/SKILL.md) | A check that fails beats another sentence of instructions. |
| [evidence-in-every-claim](skills/principle-evidence-in-every-claim/SKILL.md) | Proof or a label in the same sentence. Never report an unrun check. |
| [separate-author-and-verifier](skills/principle-separate-author-and-verifier/SKILL.md) | The agent that wrote the code does not grade it. |

## Repo skills

Per-repository rules learned from real review history, made with `learn-from-reviews`. Each loads automatically when working in its repository.

| Repo skill | Repository |
| --- | --- |
| [repo-grafana-pathfinder-app](skills/repo-grafana-pathfinder-app/SKILL.md) | grafana/grafana-pathfinder-app, from the findings on 16 merged PRs. |
| [repo-grafana](skills/repo-grafana/SKILL.md) | grafana/grafana: tracing the behavior graph, running the backend locally. |

## Agents

- [`ny-agent`](agents/ny-agent.md): the delegate for code-writing and exploration during an ny-mode run.
- [`verifier`](agents/verifier.md): the read-only verifier that runs `verify-change` on code it did not write.

## Contributing

[AGENTS.md](AGENTS.md) has the authoring rules. `python3 scripts/validate.py` must pass; CI runs it on every push.

MIT licensed. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
