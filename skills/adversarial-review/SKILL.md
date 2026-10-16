---
name: adversarial-review
description: "Have reviewers on different models (for example Claude and Codex) independently try to break a diff, then judge every finding as act on, consider, noted, or dismissed. Use for 'adversarial review', 'tear this apart', 'second opinion on this PR', or before opening a risky PR."
disable-model-invocation: true
---

# Adversarial review

The signal comes from model diversity, not from assigned personas. Different models catch different real bugs. The deliverable is a judged list of findings. Do not apply changes automatically.

`verify-change` asks "is it correct, with evidence". This skill asks "how could it be wrong". Use both on risky work.

## 1. Scope

The diff (`git diff <base>...HEAD`) plus the context files a reviewer needs: callers, types, the feature map entry, the repo skill's rules.

## 2. Intent

Write the intent in one paragraph from the request, the PR body, and the commits. Unsure of the intent → ask before spawning.

## 3. Spawn reviewers

All in parallel, read-only, one per model:

- Reviewer A: a Claude subagent.
- Reviewer B: Codex (through the codex plugin's rescue agent or `codex review`), read-only.
- Optional Reviewer C: another available model.

Each gets [`references/reviewer-prompt.md`](references/reviewer-prompt.md) filled with the intent, the diff or file paths, and [`references/rubric.md`](references/rubric.md).

## 4. Merge

Merge findings that describe the same problem. Note which reviewers raised each. Findings raised independently by two models are the strongest signal. A lone finding is read, then weighed.

## 5. Judge

You are the lead reviewer, not an aggregator. Read [`references/lead-judgment.md`](references/lead-judgment.md). Check each finding against the code yourself, then put it in one bucket with the reviewers that raised it and a one-line reason:

- **Act on**: a real problem that would block a PR.
- **Consider**: legitimate, but the cost of fixing it now may not pay off. The user decides.
- **Noted**: valid but not actionable now.
- **Dismissed**: wrong, out of scope, or missing context, with the reason.

## Output

Intent, reviewers (model and finding count), the four buckets, and an agreement map: where the models agreed, where they split, and what that suggests.
