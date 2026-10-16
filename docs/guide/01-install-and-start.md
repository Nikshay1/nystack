# Install and start

Install with the plugin commands or `scripts/install.sh`, as the [README](../../README.md#install) shows. Restart the agent session so it picks up the skills.

## The first task

With the plugin install, prefix every skill with `nystack:` (for example `/nystack:ny-mode`). The examples use the linked-skills names.

```text
/ny-mode fix <owner>/<repo>#<issue>. reproduce first, then fix and verify.
```

ny-mode then:

1. Loads `repo-<repo>` if it exists. That skill holds what reviewers in this repository have already flagged.
2. Looks the feature up in the repository's feature map, so it opens the right files.
3. Picks the bug-fix playbook and copies its steps into a todo list.
4. Reproduces the bug on the default branch before touching code.
5. Fixes it, sweeps for stale callers, mocks, and docs, and hands the result to the `verifier` agent.
6. Reports the root cause, the failing-then-passing output, and the verifier's verdict.

You can call any skill directly too, for example `/verify-change` on a branch someone else wrote, or `/blast-radius` on a diff you do not trust.

## What it will not do without you

ny-mode pauses before pushing to or commenting on repositories you do not own, opening or closing PRs and issues, force-pushing, and deleting anything. In upstream work it hands you the commit and push commands unless you have said it may run them.
