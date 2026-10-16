# Bug fix

1. Load the repo skill and the feature map entry.
2. Reproduce on the current default branch with **repro-first**. No reproduction, no fix.
3. Find the root cause (**principle-fix-root-causes**). Rule hypotheses out with runtime evidence, not reading alone.
4. Write the smallest fix that removes the cause (**principle-smallest-sufficient-change**).
5. Rerun the reproduction: it now passes.
6. Sweep beyond the diff (**principle-look-beyond-the-diff**). Update every reader, mock, doc, and text the fix made stale.
7. Snapshot the change for the verifier. Commit it to the task branch when you may commit there. Otherwise write a patch, untracked files included: `git add -N . && git diff <base> > <scratch>/change.patch`.
8. Run **verify-change** with the `verifier` agent on that commit or patch. Fix its findings and verify again.
9. Run **opening-a-pr**.

**Reply:** what was broken, the root cause, the fix, the failing-then-passing output, and the verifier's verdict.
