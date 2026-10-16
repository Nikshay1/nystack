---
name: principle-separate-author-and-verifier
description: "Apply before declaring agent-written code correct. The agent that wrote a change does not grade it. A fresh agent, ideally on a different model, checks it against the original request with its own evidence."
disable-model-invocation: true
---

# Separate the author and the verifier

The author of a change shares its blind spots. It reads its own diff as intended, and its summary repeats its plan, not what the code does.

- Verification runs in a fresh context that did not write the code (the **verify-change** skill, or the `verifier` agent).
- The verifier gets the request, the base and head commits, and the author's claims. It does not get the author's reasoning, because that reasoning carries the same mistakes.
- The verifier writes acceptance criteria from the request before reading the diff, so the diff cannot shape what counts as correct.
- Use a different model for the verifier when one is available. Two models agreeing is strong evidence. Two models disagreeing is a finding.
- The author fixes what the verifier finds. The verifier does not fix code, so its verdict stays independent.
