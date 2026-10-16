# Grafana Backend Run Guide

> **For future agents:** Before running the Grafana backend on this machine, use the SSD-backed temp directory below. Do **not** run Grafana builds against the default `/tmp`, because `/tmp` is RAM-backed on this system and large Go builds can consume too much memory or crash.

## Run the Grafana backend safely

From the Grafana repository root:

```bash
mkdir -p "$HOME/.cache/grafana-go-tmp"

export TMPDIR="$HOME/.cache/grafana-go-tmp"
export GOTMPDIR="$HOME/.cache/grafana-go-tmp"
```

Verify the temp paths:

```bash
echo "$TMPDIR"
echo "$GOTMPDIR"
```

Expected output:

```text
/home/nikshay/.cache/grafana-go-tmp
/home/nikshay/.cache/grafana-go-tmp
```

Then start the backend:

```bash
make run
```

## Why this is necessary

On this machine, `/tmp` is RAM-backed (`tmpfs`). Grafana's Go build can create a large amount of temporary build data, so allowing Go to use `/tmp` can consume RAM quickly and cause the build or system to crash.

Setting both:

```bash
TMPDIR="$HOME/.cache/grafana-go-tmp"
GOTMPDIR="$HOME/.cache/grafana-go-tmp"
```

moves temporary build files to the user's SSD-backed home directory instead.

`GOTMPDIR` specifically controls Go's temporary build directory. `TMPDIR` also redirects other temporary files created by tools involved in the build.

## Important persistence note

The directory:

```text
~/.cache/grafana-go-tmp
```

persists across reboots.

The `export` commands do **not** persist across a new terminal session or reboot unless they are added to the shell configuration.

Therefore, before every `make run`, either:

1. run the two `export` commands again, or
2. verify that `TMPDIR` and `GOTMPDIR` are already set correctly.

## Quick checklist for agents

Before running the backend:

```bash
pwd
```

Confirm you are in the Grafana repository root.

Then:

```bash
mkdir -p "$HOME/.cache/grafana-go-tmp"
export TMPDIR="$HOME/.cache/grafana-go-tmp"
export GOTMPDIR="$HOME/.cache/grafana-go-tmp"

echo "$TMPDIR"
echo "$GOTMPDIR"

make run
```

Do not skip the temp-directory setup.

## Frontend

If the frontend is also required, run it in a separate terminal:

```bash
yarn start
```

The backend and frontend may both consume substantial RAM, so avoid running unrelated heavy processes at the same time.

## Troubleshooting

### Build crashes, gets killed, or runs out of memory

First confirm the temp paths:

```bash
echo "$TMPDIR"
echo "$GOTMPDIR"
```

They should both point to:

```text
/home/nikshay/.cache/grafana-go-tmp
```

Check RAM and swap:

```bash
free -h
```

Check disk space:

```bash
df -h "$HOME"
```

Check the size of relevant caches:

```bash
du -sh ~/.cache/grafana-go-tmp ~/.cache/go-build 2>/dev/null
```

### `/tmp` is filling RAM

Check how `/tmp` is mounted:

```bash
df -h /tmp
mount | grep ' /tmp '
```

If it is `tmpfs`, keep using the SSD-backed cache directory above.

### Clean temporary Go build files

Stop `make run`, `yarn start`, and any active Go builds first.

Then these rebuildable caches can be removed if needed:

```bash
rm -rf ~/.cache/grafana-go-tmp
rm -rf ~/.cache/go-build
```

Recreate the Grafana temp directory before the next run:

```bash
mkdir -p ~/.cache/grafana-go-tmp
```

Do **not** blindly delete unrelated folders under `~/.cache`.

## One-line setup

For a fresh terminal, this is enough:

```bash
mkdir -p "$HOME/.cache/grafana-go-tmp" && export TMPDIR="$HOME/.cache/grafana-go-tmp" && export GOTMPDIR="$HOME/.cache/grafana-go-tmp" && make run
```

For debugging, prefer running the commands separately so the temp paths can be verified before starting the build.
