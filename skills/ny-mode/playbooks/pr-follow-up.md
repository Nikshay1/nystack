# PR follow-up

1. Fetch reviews, inline comments, conversation, and check results for the PR.
2. Separate CI noise the repo skill lists (for example fork-permission failures) from real failures.
3. For each bot or reviewer finding: reproduce it with a test or trace before changing code. Fix real ones in new commits. Dismiss wrong ones with a concrete reason.
4. Fix blockers. Fold cheap follow-ups into the same push.
5. Run **verify-change** on the new head (snapshot it first, as in **bug-fix** step 7).
6. Draft one reply listing each finding and what changed, with the new head SHA. Post only with the user's go-ahead. Resolve threads only where the user has allowed it.
7. Add new findings to the repo skill's review history (**learn-from-reviews**, "Keep it current").

**Reply:** only what needs the user: decisions, replies to approve, commands to run.
