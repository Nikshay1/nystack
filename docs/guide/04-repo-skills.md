# Repo skills

Every review comment that asked for a fix is a lesson. Left in the PR, it is lost by the next session. `learn-from-reviews` collects all of them for one repository and writes `repo-<repo>`:

- Every review, inline comment, bot finding (Copilot, Cursor Bugbot), and conversation comment on your PRs there, plus the linked issues' maintainer notes.
- The project's own agent docs and review tooling, so the skill points at them instead of copying.
- Each finding classified by its root mistake, which is about process ("searched `src/` but not `tests/`"), not code.
- One rule per class, ending with the PR it came from, and a history file with every finding.

`repo-grafana-pathfinder-app` was built this way from 16 merged PRs. Nine had findings. Most were not wrong logic in the changed lines but stale things outside them: a doc with the old value, a Playwright spec mocking a retired route, an allowlist reason contradicting a new comment, storage counters never taught the new key format.

After each new PR in a repository, add its findings to the history (the pr-follow-up playbook does this). When a rule keeps failing even though it is written down, turn it into a script or a check.
