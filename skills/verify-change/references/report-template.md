# Verification report

**Verdict:** VERIFIED | VERIFIED WITH GAPS | NOT VERIFIED

Base `<sha>`, head `<sha>`. Verifier model: <model>. Request: <link or path>.

## Acceptance criteria

| # | Criterion | Evidence | Proof level | Result |
| --- | --- | --- | --- | --- |
| 1 | <what must be true> | <command, test name, or file::symbol> | 1 to 5 | met / not met / unchecked |

Proof levels: 1 said so, 2 pointed at the line, 3 traced, 4 ran it, 5 reproduced in the running app.

## Tests fail on the old code

| Test | Head | Base | Note |
| --- | --- | --- | --- |
| <name> | pass | fail: <message> | |

## Mutations

| Mutation | Caught by | Result |
| --- | --- | --- |
| <what was broken> | <test or none> | caught / survived |

## Real path

<Command or script, input, and output.>

## Beyond the diff

| Dependent | Kind | Status |
| --- | --- | --- |
| `<path::symbol>` | reader / caller / mock / doc / contract | updated / unaffected because <reason> / missed |

Searches run: <the patterns and directories, including ones that found nothing>.

## Author claims

| Claim | Status | Evidence |
| --- | --- | --- |
| "<quoted claim>" | confirmed / false / unverifiable | <evidence> |

## Findings

1. **<short title>.** <What is wrong, at `path::symbol`.> Reproduce: `<command>`. <Which criterion it breaks.>

## Not checked

- <What did not run and why: slow suite, no browser, no credentials.>
