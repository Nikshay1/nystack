#!/usr/bin/env bash
# Run one night of a generated night-<name> skill.
# Usage: run-night.sh <config.json> [run|plan]
# Lives in the generated skill folder, next to SKILL.md and headless-settings.json.
# State goes to ~/.local/state/night-<name>/ (ledger.json, runs/<id>/, latest).
set -euo pipefail

[ $# -ge 1 ] || { echo "usage: $0 <config.json> [run|plan]" >&2; exit 2; }
config="$(realpath "$1")" mode="${2:-run}"
case "$mode" in run|plan) ;; *) echo "mode must be run or plan" >&2; exit 2 ;; esac
skill_dir="$(cd "$(dirname "$0")" && pwd)"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a night-run "$1" "$2" || true; }
[ -f "$config" ] || { notify "night run did not start" "no config at $config"; exit 1; }
jq empty "$config" 2>/dev/null || { notify "night run did not start" "config is not valid JSON"; exit 1; }

name="$(jq -r '.name' "$config")"
state="$HOME/.local/state/night-$name"
run_dir="$state/runs/$(date +%Y-%m-%d_%H%M)-$mode"
mkdir -p "$run_dir"
log() { echo "$(date -Is) $*" | tee -a "$run_dir/run.log"; }
fail() { log "not started: $*"; notify "night-$name did not run" "$*"; exit 1; }

exec 9>"$state/lock"
flock -n 9 || fail "another run holds $state/lock"

export NIGHT_CONFIG="$config" NIGHT_STATE="$state" NIGHT_RUN_DIR="$run_dir" NIGHT_MODE="$mode"
export NIGHT_ID="$(date -d "12 hours ago" +%F)"
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-/run/user/$(id -u)/ssh-agent.socket}"
[ -f "$skill_dir/SKILL.md" ] || fail "no SKILL.md next to this script"
[ -f "$skill_dir/headless-settings.json" ] || fail "no headless-settings.json next to this script"
[ -x "$skill_dir/ship.sh" ] || fail "no executable ship.sh next to this script"
command -v claude >/dev/null || fail "claude is not on PATH"
gh auth status >/dev/null 2>&1 || fail "gh is not logged in"
if [ "$(jq -r '.gate.second_review.tool // "codex"' "$config")" = codex ]; then
  command -v codex >/dev/null || fail "codex is not on PATH"
fi
if [ "$mode" = run ] && [ "$(git config --global --get commit.gpgsign || true)" = true ] \
   && [ "$(git config --global --get gpg.format || true)" = ssh ]; then
  ssh-add -l >/dev/null 2>&1 || fail "commits are signed but the signing key is not loaded (ssh-add)"
fi
if [ "$(jq -r 'if .require_ac_power == false then "false" else "true" end' "$config")" = true ]; then
  on_ac=1
  for f in /sys/class/power_supply/A*/online; do
    [ -r "$f" ] || continue
    on_ac=0
    [ "$(cat "$f")" = 1 ] && { on_ac=1; break; }
  done
  [ "$on_ac" = 1 ] || fail "on battery power (set require_ac_power to false to allow)"
fi

hours="$(jq -r '.max_hours // 6' "$config")"
model="$(jq -r '.claude_model // "claude-opus-5-5"' "$config")"
prompt="Read $skill_dir/SKILL.md in full and run one night.
Mode: $mode. Config: $config. State directory: $state. Run directory: $run_dir. Skill folder: $skill_dir.
The operator is asleep. Act only within the skill's Authority section and the config."

log "starting $mode run, model $model, limit ${hours}h"
cd "$HOME"
set +e
timeout "${hours}h" systemd-inhibit --what=sleep:idle --who="night-$name" --why="night $mode run" \
  claude -p "$prompt" \
    --model "$model" \
    --permission-mode auto --permission-prompts none \
    --settings "$skill_dir/headless-settings.json" \
    --output-format stream-json --verbose \
    > "$run_dir/transcript.jsonl" 2> "$run_dir/stderr.log"
status=$?
set -e
log "claude exited with status $status"
ln -sfn "$run_dir" "$state/latest"

if [ -s "$run_dir/report.md" ]; then
  notify "night-$name: $mode run done" "$(head -c 300 "$run_dir/report.md")"
else
  notify "night-$name: no report" "exit $status, see $run_dir"
fi
exit "$status"
