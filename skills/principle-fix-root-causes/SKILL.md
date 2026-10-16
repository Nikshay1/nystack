---
name: principle-fix-root-causes
description: "Apply while debugging. Trace each symptom back to the first place the system went wrong and fix it there. A guard or fallback is a fix only when the state it handles is legitimate."
disable-model-invocation: true
---

# Fix root causes

Follow the bad value backwards until you reach the first place it was wrong. Fix that place.

- A null check, retry, or default value that hides a broken invariant moves the bug somewhere harder to find.
- If every caller must meet a precondition, the shared function enforces it. If callers differ on purpose, fix the one that differs.
- When two fixes built on the same assumption have failed, stop. Write the assumption down and test it directly before writing a third fix.
- Every shipped line should trace to evidence. A change that "might help" is a hypothesis. Test it or leave it out.
