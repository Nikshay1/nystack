#!/usr/bin/env bash
# Link nystack skills and agents into Claude Code (and Codex, with --codex).
# Symlinks mean edits in this checkout take effect immediately.
# Usage: scripts/install.sh [--codex] [--dry-run]
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
targets=("$HOME/.claude/skills")
agents_dir="$HOME/.claude/agents"
dry=0
for arg in "$@"; do
  case "$arg" in
    --codex) targets+=("$HOME/.codex/skills") ;;
    --dry-run) dry=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && return 0
    echo "relink  $dest"
  elif [ -e "$dest" ]; then
    echo "skip    $dest exists and is not a symlink; move it away to install"
    return 0
  else
    echo "link    $dest"
  fi
  [ "$dry" = 1 ] || ln -sfn "$src" "$dest"
}

for target in "${targets[@]}"; do
  [ "$dry" = 1 ] || mkdir -p "$target"
  for skill in "$root"/skills/*/; do
    skill="${skill%/}"
    link "$skill" "$target/$(basename "$skill")"
  done
done

[ "$dry" = 1 ] || mkdir -p "$agents_dir"
for agent in "$root"/agents/*.md; do
  link "$agent" "$agents_dir/$(basename "$agent")"
done
