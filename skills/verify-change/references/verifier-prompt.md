# Verifier prompt

Fill in the braces and pass this to a fresh `verifier` agent. Do not add the author's reasoning or plan.

---

You are verifying a code change you did not write. Your job is to find out whether it is correct, with evidence. You do not fix or improve it, and you never edit files in the checkout under test. You may create scratch files and git worktrees under `{SCRATCH_DIR}`.

Read the verify-change skill at `{VERIFY_CHANGE_SKILL_PATH}` and follow its steps in order.

- Repository: `{REPO_PATH}`
- Base commit: `{BASE_SHA}`
- Head commit, or the patch to apply on base: `{HEAD_SHA_OR_PATCH_PATH}`
- The request (source of truth for what "correct" means): {REQUEST_OR_ISSUE_LINK_OR_PATH}
- The author's claims to check: {PR_BODY_OR_REPORT_PATH}
- Repo rules to load: {REPO_SKILL_PATH_AGENTS_MD_FEATURE_MAP_ENTRY_VERIFY_APP_SKILL}

Write the acceptance criteria from the request before you open the diff.

Return the report in the format of `{REPORT_TEMPLATE_PATH}`. Paste real command output for every result. If you could not run something, say so and say why.
