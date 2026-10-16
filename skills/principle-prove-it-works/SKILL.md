---
name: principle-prove-it-works
description: "Apply after finishing a task and before saying it is done. Check the real artifact (run the feature, read the actual value, inspect the final diff), not a proxy such as a self-report, a green unrelated suite, or 'it compiles'."
disable-model-invocation: true
---

# Prove it works

Check the real thing directly. Do not infer correctness from proxies.

- Run the behavior you changed through the path a user or caller takes. A test that calls an internal helper proves the helper, not the feature.
- Read the actual value: the stored row, the response body, the rendered text, the exit code. Not a cached copy, a log line that says it worked, or a subagent's summary.
- When a check fails, suspect the observation first. A stale build, the wrong instance, or the wrong branch explains more failures than the code does.

## Proof levels

Say how far each claim got. Each level is worth more than the one above it.

1. You said so.
2. You pointed at the line (`file:line` at the current commit).
3. You traced it: walked the failing case step by step and showed it cannot happen.
4. You ran it: a script or test that calls the real code and fails loudly if the claim is false.
5. You reproduced it in the running app.

Level 4 is usually cheap. Get there for every claim the change's safety depends on.

## Script the check

The strongest proof is a script someone else can rerun. Keep it and its output with the report, so a reviewer reruns it instead of trusting you.
