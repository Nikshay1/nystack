---
name: repro-first
description: "Reproduce a bug on the current default branch before fixing it or filing it: a failing test that drives the real code path, or the closest executable check, run against the unfixed code. Use when fixing a bug, before filing an issue, or when asked for a regression test."
---

# Reproduce first

A fix without a reproduction is a guess, and an issue without one asks a maintainer to do your work. Make the broken behavior run before changing anything.

## Steps

1. **State the bug.** Intended behavior, actual behavior, the affected path, and the smallest input that shows it.
2. **Use the latest base.** Fetch upstream and make sure the task branch starts from the current default branch (rebase it if it does not). To check the default branch on its own, use a detached worktree: `git worktree add --detach <scratch>/base <remote>/<default>`. Confirm the bug is still there; it may already be fixed.
3. **Pick the narrowest real check.** The existing test file closest to the code path. Use real data where it matters: if two shipped IDs collide, use those IDs, not invented ones.
4. **Write it and watch it fail** on the unfixed code, for the reason the bug describes. Passing, or failing for another reason, means the reproduction is wrong. Fix it before touching production code.
5. **Fix**, then rerun. The same test now passes.
6. **Order the commits** so the failing test can be seen before the fix when the project likes that, or keep them together when it does not.

## When a test does not fit

Do not force one when it needs a large new harness, heavy mocks, a slow end-to-end environment, or production-only state. Use the closest executable check instead (a script against the real function, a CLI run, a request against a local server) and say why. No test is better than a test that mostly tests mocks.

## Filing an issue

Write how it was reproduced (test name, command, commit) and what was not tried ("not run on a cluster", "not run in a browser").

## Report

The failing-before output and the passing-after output, verbatim, plus any check you could not run.
