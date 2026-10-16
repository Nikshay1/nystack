# Review rubric

Use the lenses that apply. A small fix does not need an architecture essay.

## Correctness

- Edge cases: empty, missing, boundary values, repeated calls, concurrent access.
- Errors: caught, propagated, or silently swallowed?
- State: stale closures, race conditions, cleanup on every exit path, early returns that skip new logic.
- Idempotency: what happens if this runs twice, or after a crash halfway?
- Trace a suspected bug through the call chain that triggers it. "This could be null" is not a finding until a caller can pass null.

## Beyond the diff

- Other callers, and callers that bypass the changed wrapper.
- Other readers and writers of changed data, keys, routes, or formats.
- Tests, mocks, fixtures, and docs that still encode the old behavior.
- Texts that describe the same fact and now disagree.

## Root cause

- Is this fixing the cause or hiding a symptom (a guard, retry, or cast over a broken invariant)?
- Would the fix belong in a shared function instead of one caller?
- Is a rule enforced only by a comment that a type, test, or check could enforce?

## Tests

- Would each test fail on the old code? Does any fixture make new and old values equal?
- Does each test check observable behavior, or internals?
- Which branch of the fix could be deleted without any test failing?

## Fit

- Does the change follow the repository's documented patterns and contracts?
- Is the complexity justified? One-caller abstractions, options for cases that do not exist, dead code.

## Security

- Untrusted input reaching a dangerous sink without validation. Show the path.
- Missing auth on a new endpoint. Secrets in code, logs, or errors.
