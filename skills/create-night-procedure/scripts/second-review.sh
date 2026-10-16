#!/usr/bin/env bash
# Read-only second-model review of a committed change, for the night-run gate.
# Usage: second-review.sh <worktree> <base-sha> <issue-url-or-text> <out-file>
# Reads gate.second_review from $NIGHT_CONFIG (set by run-night.sh).
# Default: Codex, gpt-6.1-sol, high reasoning effort.
set -euo pipefail
[ $# -eq 4 ] || { echo "usage: $0 <worktree> <base-sha> <issue> <out-file>" >&2; exit 2; }
wt="$1" base="$2" issue="$3" out="$4"
tool="codex" model="gpt-6.1-sol" effort="high"
if [ -n "${NIGHT_CONFIG:-}" ] && [ -f "$NIGHT_CONFIG" ]; then
  tool="$(jq -r '.gate.second_review.tool // "codex"' "$NIGHT_CONFIG")"
  model="$(jq -r '.gate.second_review.model // "gpt-6.1-sol"' "$NIGHT_CONFIG")"
  effort="$(jq -r '.gate.second_review.effort // "high"' "$NIGHT_CONFIG")"
fi
[ "$tool" = codex ] || { echo "unsupported second_review.tool: $tool" >&2; exit 2; }

head="$(git -C "$wt" rev-parse HEAD)"
prompt="You are reviewing a change you did not write, in the git repository in the current directory. Do not edit any file.
Base commit: $base. Head commit: $head. Read the diff with: git diff $base..$head
The issue it should fix: $issue
Find real problems only: wrong behavior, missed callers or readers of changed data, tests or mocks or docs that still encode the old behavior, tests that would pass on the old code, broken project conventions. Trace each finding through the code and give the evidence.
Return a numbered list. Each item: severity (critical, warning, nit), location (path and line at head), finding, evidence. If you find nothing real, reply exactly: No findings."

codex exec -m "$model" -c "model_reasoning_effort=\"$effort\"" -s read-only -C "$wt" \
  --skip-git-repo-check "$prompt" > "$out" 2>&1
echo "second review ($tool $model $effort) written to $out"
