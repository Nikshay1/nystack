---
name: principle-test-behavior-not-implementation
description: "Apply when writing, changing, or keeping a test. Assert what the code's users can observe, so the test fails when that behavior breaks and keeps passing when only internals change. Make sure the test would have failed on the old code."
disable-model-invocation: true
---

# Test behavior, not implementation

A test is a claim about what the code does for its users: a caller, an end user, or another service. Judge every test against two imagined edits.

- **Break the behavior.** Return a wrong value, skip an effect, run it twice. If the test still passes, it proves nothing. Common causes: an expected value computed by the code under test, an assertion looser than the contract, a fixture where the new value equals the old one, a test that only reads data it built itself.
- **Change the internals.** Keep every observable result and restructure underneath. If the test now fails, it is pinned to the implementation.

Keep tests that catch the first edit and survive the second.

## Rules

- Derive the expected value from the requirement, not from a run of the code.
- Pick fixtures where the new behavior differs from the old. Asserting a value that the old code also produced proves nothing.
- Run the new test against the old code and watch it fail for the intended reason. A regression test that passes on the base commit is not a regression test.
- Break each branch of the fix on purpose (drop the guard, the cleanup, the new argument) and confirm some test fails. A branch no test notices is untested.
- A guard test (an import check, a wiring check) should allow the one permitted form and fail on everything else. A list of forbidden forms always misses one.
- Match the test's weight to the change. Prefer extending an existing test file. Do not build new infrastructure (a server, a harness) for a small fix without asking.
