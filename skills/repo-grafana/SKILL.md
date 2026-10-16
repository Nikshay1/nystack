---
name: repo-grafana
description: "Work on a fix or PR in grafana/grafana: trace the behavior graph (every state producer, consumer, caller, alternate mode, and recovery path) before and after implementing, and run the backend locally without exhausting a RAM-backed /tmp. Use for any issue or PR in grafana/grafana."
---

# grafana/grafana contributions

Grafana fixes go wrong when the change follows the file named in the issue instead of the behavior. A wrapper gets the fix while another mode renders the inner component directly. An error title fits one producer of a state but not the others. [references/behavior-trace-example.md](references/behavior-trace-example.md) is the full checklist and the worked example (issue #130945, `dsError`, stacked query editor) it came from. Treat the symbols there as history; check current source.

## Before implementing

- Name the state, components, and contexts involved. Search each one in the feature directory, and exported ones repository-wide.
- Write down every producer, consumer, and reset path of the state, and every caller of each component you will touch, including callers of the lower-level component under a wrapper.
- Search for alternate modes: stacked, compact, legacy, drawer, sidebar, feature-flagged.
- Write the behavior matrix (load, change, failure, recovery, each mode) before coding.

## While implementing

- Put the behavior at the layer every relevant caller passes through. Do not render global state inside a repeated item.
- Check every user-facing string against every condition that can show it.
- Match nearby UI conventions for alerts, wording, and placement.

## Before the PR

- Run the targeted tests, Prettier, ESLint, and `git diff --check`.
- Repeat the symbol searches on the final diff and account for every result.
- Run **verify-change**. Its beyond-the-diff step is where the two classic misses above get caught.

## Running the backend locally

Go builds can fill a RAM-backed `/tmp`. Check with `df -hT /tmp "$HOME"`. If `/tmp` is tmpfs and the home directory is on disk:

```bash
mkdir -p "$HOME/.cache/grafana-go-tmp"
export TMPDIR="$HOME/.cache/grafana-go-tmp"
export GOTMPDIR="$HOME/.cache/grafana-go-tmp"
make run
```

The exports last for the current shell only. [references/backend-run-guide.md](references/backend-run-guide.md) has the memory, disk, cache, and mount checks; its absolute paths describe one workstation. Clear caches only when the user asks.
