#!/usr/bin/env bash
# Install a generated night run as a systemd user timer.
# Usage: install-timer.sh <name> <generated-skill-dir> [OnCalendar]
#   OnCalendar defaults to "*-*-* 01:30". Config is read from
#   ~/.config/night-<name>/config.json.
# Pause: systemctl --user stop night-<name>.timer
# Remove: systemctl --user disable --now night-<name>.timer
set -euo pipefail
[ $# -ge 2 ] || { echo "usage: $0 <name> <generated-skill-dir> [OnCalendar]" >&2; exit 2; }
name="$1" skill_dir="$(realpath "$2")" when="${3:-*-*-* 01:30}"
config="$HOME/.config/night-$name/config.json"
unit_dir="$HOME/.config/systemd/user"
[ -x "$skill_dir/run-night.sh" ] || { echo "no executable run-night.sh in $skill_dir" >&2; exit 1; }
[ -f "$config" ] || { echo "no config at $config" >&2; exit 1; }
mkdir -p "$unit_dir"

# systemd quoting: wrap in double quotes, escape backslash, double quote, and %.
unit_quote() { local s="${1//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//%/%%}"; printf '"%s"' "$s"; }

cat > "$unit_dir/night-$name.service" <<UNIT
[Unit]
Description=night-$name overnight run

[Service]
Type=oneshot
WorkingDirectory=%h
Environment=$(unit_quote "PATH=$PATH")
ExecStart=$(unit_quote "$skill_dir/run-night.sh") $(unit_quote "$config") run
TimeoutStartSec=infinity
UNIT

cat > "$unit_dir/night-$name.timer" <<UNIT
[Unit]
Description=Start night-$name each night

[Timer]
OnCalendar=$when
Persistent=true

[Install]
WantedBy=timers.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now "night-$name.timer"
systemctl --user list-timers "night-$name.timer" --no-pager
echo "user timers stop when you log out unless lingering is on: loginctl enable-linger $USER"
