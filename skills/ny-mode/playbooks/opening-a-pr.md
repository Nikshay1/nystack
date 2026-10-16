# Opening a PR

1. Confirm **verify-change** returned VERIFIED, or VERIFIED WITH GAPS that you will list in the PR body.
2. Check scope: one concern, within the project's size guidance, only intended files (`git diff --stat`).
3. Run the project's fast checks on changed files and `git diff --check`.
4. Write commits the way the project does (conventional commits if it uses them, signed if it requires it). Credit every AI tool that worked on the change in the trailers, consistently.
5. Write the PR body with the project's template or summary skill. For a fix: problem, root cause, fix, how to verify. Add a **Not changed** section for deliberate omissions and known limits. Claim only results you saw. Link files at the head SHA. Proofread numbered lists.
6. Link the issue (`Fixes #N` for bugs, `Closes #N` otherwise).
7. Push and open, or hand the commands over (see **Autonomy** in ny-mode).

**Reply:** the PR link or the commands, the verifier's verdict, and anything the reviewer should look at first.
