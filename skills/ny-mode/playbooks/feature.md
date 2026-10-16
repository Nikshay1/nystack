# Feature

1. Load the repo skill and the feature map entries the feature touches.
2. Write the acceptance criteria: inputs, outputs, edge cases, and what must not change.
3. Name the data shape first: the types, keys, routes, or formats the feature adds or changes, and every reader and writer of each.
4. Build in small steps that each end in a passing check.
5. Write tests that fail without the feature (**principle-test-behavior-not-implementation**).
6. Sweep beyond the diff, and add or update the feature map entry.
7. Snapshot the change for the verifier. Commit it to the task branch when you may commit there. Otherwise write a patch, untracked files included: `git add -N . && git diff <base> > <scratch>/change.patch`.
8. Run **verify-change** with the `verifier` agent on that commit or patch. Fix its findings and verify again.
9. Run **opening-a-pr**.

**Reply:** what users can now do, the evidence, and the verifier's verdict.
