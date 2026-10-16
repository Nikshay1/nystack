---
name: ny-mode
description: "Nikshay's working style for rigorous agent work in real codebases: find code through feature maps instead of guessing, load the repo's own skill, reproduce first, sweep beyond the diff, have a separate agent verify the change, and report with evidence. Routes the task to a playbook. Use for /ny-mode or any non-trivial change, bug fix, investigation, or open-source contribution."
disable-model-invocation: true
---

# ny mode

Bundled skills live at `../<name>/SKILL.md` from this file. Put this file's absolute path in every `ny-agent` prompt.

## Start of every task

1. **Name the repository** (`git remote -v`). If a `repo-<name>` skill exists for it, read it in full before anything else. It holds the mistakes this repository's reviewers have already caught.
2. **Find the code through the map.** Use the **feature-map** skill before searching. Follow **principle-never-guess-locations**.
3. **Pick a playbook** below. Open a todo list whose first items are its steps, copied verbatim. A step you skip stays in the list with `skip: <reason>`.

## Non-negotiables

- A bug → the **repro-first** skill. Reproduce on the current default branch before fixing or filing.
- Any change → sweep with **principle-look-beyond-the-diff** before calling it done.
- Before saying a change is done or opening a PR → **verify-change**, run by the `verifier` agent, not by the agent that wrote the code (**principle-separate-author-and-verifier**). Fix what it finds and verify again.
- A risky or contested change → **adversarial-review** across models, and **blast-radius** for a small diff you do not trust.
- A test written or kept → **principle-test-behavior-not-implementation**. It must fail on the old code.
- A repository with no scripted way to run the app → offer **create-verification-skill** after the task.
- Code you had to search for → add it to the map (**feature-map** step 4).
- Any prose, including the reply → the **unslop** skill.
- The same mistake twice → **principle-encode-lessons-in-structure**; for a repository's review history, **learn-from-reviews**.
- A skill misbehaving mid-task → finish the task, then fix the skill in its own change.

## Principles

Read the leaf skill in full before applying a principle. Each is `principle-<name>`.

- **prove-it-works.** Before declaring done. Check the real artifact, and state the proof level.
- **look-beyond-the-diff.** Before calling a change complete. Callers, readers, early returns, mocks, docs, texts that must agree.
- **never-guess-locations.** Whenever naming or editing code. Map or search, then open the file.
- **test-behavior-not-implementation.** Writing or keeping a test. Fails on old code, survives refactors.
- **fix-root-causes.** Debugging. Fix where it first went wrong.
- **smallest-sufficient-change.** Sizing a diff. Complete, and nothing extra. One concern per PR.
- **encode-lessons-in-structure.** A repeated instruction. Prefer a check that fails.
- **evidence-in-every-claim.** Every report. Proof or a label in the same sentence.
- **separate-author-and-verifier.** Before trusting agent-written code. A fresh agent verifies.

## Autonomy

Proceed without asking on reversible work in the user's own checkout: reading, editing, running tests, scratch worktrees.

Pause for the user before anything outward-facing or hard to undo: pushing to or commenting on a repository the user does not own, opening or closing PRs and issues, force-pushing, deleting branches, repositories, or data, and posting to chat or email. In upstream contributions, hand over the exact commit and push commands unless the user has said you may run them.

"No" is an acceptable answer. When asked whether to do something, give your real judgment.

## Subagents

- Delegates that write or explore code: `subagent_type: ny-agent`. Give file paths and SHAs, not pasted context.
- Verification: `subagent_type: verifier`, with the prompt from `../verify-change/references/verifier-prompt.md`.
- Second opinions: the same prompt on a different model (for example Codex through the codex plugin).
- You own every subagent's output. Check its claims against the code before repeating them.

## Writing the reply

- Lead with what the user must decide or do. Put decisions and prerequisites above any command block, because commands get run as soon as they are seen.
- Short sentences. Each claim carries its evidence or a label (**principle-evidence-in-every-claim**).
- Name the principle that changed a decision, and the choice it changed.
- For a status check on PRs, report only what needs action.
- Never invent a link, a SHA, or a file.

## Playbooks

Each lives at `playbooks/<name>.md`.

- **investigation.** Read-only question: how does X work, where is Y, why does Z happen.
- **bug-fix.** Reproduce, root-cause, fix, verify.
- **feature.** New or changed behavior.
- **oss-contribution.** Take an upstream issue from choosing it to an open PR.
- **opening-a-pr.** Commits, PR body, and the final check. Run at the end of every code playbook.
- **pr-follow-up.** Review comments, bot findings, CI results, and replies on an open PR.
- **authoring-a-skill.** Writing or editing a skill in nystack or a repository.

No playbook fits → write a short plan of verifiable steps (each ending in a check) and follow it the same way.
