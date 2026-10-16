---
name: issue-finder
description: "Find open-source GitHub issues to contribute to and verify that they remain available, unfixed, and realistically solvable. Use when selecting or vetting contribution opportunities."
---

# Issue Finder

Recommend an issue only after thoroughly checking that it is available and that the work is still needed. An open issue or a good-first-issue label alone is insufficient evidence.

## Scope the search

Use the user's repository, language, experience, and time constraints when provided. If a missing constraint materially affects the search, ask a focused question while investigating suitable candidates. Prefer fresh, unassigned issues with localized changes, a practical test strategy, and a likely clean, maintainable PR.

Use live GitHub information through available tools, the GitHub CLI, or browsing. Inspect current source through a local checkout or GitHub. Ensure the source corresponds to the current default branch; record the commit inspected when possible.

## Verify each candidate before recommending it

1. Read the full issue body, all comments, timeline, labels, assignees, and linked references. Confirm that the issue is open and inspect any contribution or assignment requirements.
2. Search open PRs for the exact issue number and issue URL. Inspect references in PR bodies and comments as well as titles; paginate results when needed.
3. Search open PRs semantically using the issue title, error messages, affected function names, and likely fix keywords. A PR may address the issue without mentioning its number.
4. Search repository branch names for the issue number and relevant keywords. Inspect plausible matches for overlapping work. This search cannot establish the absence of work in private branches or unobserved forks.
5. Search recent commits on the default branch for related fixes, using issue references and semantic terms. Inspect relevant diffs rather than relying only on commit messages.
6. Check whether the reported bug is already fixed on the current default branch, even if the issue remains open. Reproduce the behavior or use a focused test when feasible. Otherwise, trace the relevant code and clearly identify the limits of that evidence.
7. Check comments for people working on the issue, planning a PR, or asking to be assigned. Treat an active claim, assignee, or overlapping PR as a reason to exclude the candidate. If an old claim appears abandoned, look for explicit release or maintainer clarification; do not assume availability from silence.
8. Inspect older related issues and PRs to determine whether the proposed fix is still needed, superseded, deliberately rejected, or constrained by a prior design decision.
9. Inspect enough current source to identify a plausible root cause, affected files or functions, likely change scope, and a useful regression test. Distinguish a code-supported hypothesis from a confirmed diagnosis.
10. Compare the verified candidates using freshness, availability, localization, testability, and maintainability. Respect the user's constraints rather than selecting solely by labels or popularity.

Stop investigating a candidate once evidence rules it out and continue with another. Missing access, truncated results, failed searches, or unavailable source are verification gaps, not evidence that no competing work exists. Do not present an incompletely checked candidate as verified or available. If none pass, report that outcome and the remaining gaps instead of forcing a recommendation.

## Present the recommendation

For each recommended issue, include:

- The issue link, a concise explanation of the problem, and why it fits the user.
- When it was checked and which default-branch commit was inspected, if available.
- Availability evidence: assignees and work claims, exact and semantic PR searches, branch search, and relevant commits or historical discussions. Link material evidence and describe searches with no matches.
- Why the fix is still needed, the likely root cause and code locations, and the proposed regression test or reproduction.
- Expected scope and difficulty, plus any remaining uncertainty. Explain whether the bug was reproduced or assessed through source inspection.

Availability is a point-in-time assessment. Recheck the issue and competing work if the user later chooses it and meaningful time has elapsed.

Finding an issue does not authorize claiming it, commenting, opening a PR, or implementing the fix. Perform those actions only when the user requests them.

## Set up authorized contribution work

When the user requests implementation of a selected issue, follow their fork-first workflow before starting implementation:

1. Create or reuse the user's GitHub fork of the original repository.
2. Use a local checkout of that fork, with the remote named `fork` pointing to the user's fork and the remote named `main` pointing to the original repository. Verify the remotes before proceeding.
3. Create a separate Git worktree and task branch from that checkout, based on the original repository's current default branch fetched from the `main` remote.
4. Implement and test the contribution in that worktree.

Apply this setup when contribution work is authorized; issue discovery and vetting alone do not require creating a fork or starting implementation.
