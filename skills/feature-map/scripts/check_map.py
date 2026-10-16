#!/usr/bin/env python3
"""Check a feature map against a repository.

Cited code references in map files are backticked spans of two kinds:
  `path/to/file`            the path (or glob) must exist
  `path/to/file::symbol`    the path must exist and contain symbol as a word
A span counts as a path only when it contains a slash, no spaces, and does not start with "/" (URL routes).
A file's `Verified at `<sha>`` line enables a drift report: cited files changed since that commit.
Exit status: 0 clean (drift lines are warnings), 1 a missing path or symbol or an unknown commit, 2 no map found.
"""
import argparse
import fnmatch
import glob
import os
import re
import subprocess
import sys

SPAN = re.compile(r"`([^`\n]+)`")
VERIFIED = re.compile(r"Verified at `([0-9a-f]{7,40})`")
PATHLIKE = re.compile(r"^[\w.@*?+-]*(/[\w.@*?{}\[\]+-]+)+/?$")
GLOB = set("*?[")


def refs(text):
    for span in SPAN.findall(text):
        if " " in span or span.startswith(("http", "-", "$", "/")):
            continue
        path, _, symbol = span.partition("::")
        if "/" in path and PATHLIKE.match(path):
            yield path.rstrip("/"), symbol or None


def exists(repo, path):
    full = os.path.join(repo, path)
    if GLOB & set(path):
        return bool(glob.glob(full, recursive=True))
    return os.path.exists(full)


def has_symbol(repo, path, symbol):
    try:
        with open(os.path.join(repo, path), encoding="utf-8", errors="replace") as f:
            return re.search(r"(?<![\w$])" + re.escape(symbol) + r"(?![\w$])", f.read()) is not None
    except (IsADirectoryError, FileNotFoundError):
        return False


def changed_since(repo, sha):
    out = subprocess.run(["git", "-C", repo, "diff", "--name-only", f"{sha}..HEAD"],
                         capture_output=True, text=True)
    if out.returncode != 0:
        return None
    return set(out.stdout.split())


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", default=".", help="repository root (default: current directory)")
    ap.add_argument("--map", required=True, help="feature map directory")
    ap.add_argument("files", nargs="*", help="map files to check (default: every .md in --map)")
    args = ap.parse_args()

    if not os.path.isdir(args.map):
        print(f"error: map directory not found: {args.map}", file=sys.stderr)
        return 2
    files = args.files or sorted(glob.glob(os.path.join(args.map, "**", "*.md"), recursive=True))
    if not files:
        print(f"error: no .md files in {args.map}", file=sys.stderr)
        return 2
    failed = 0
    for md in files:
        text = open(md, encoding="utf-8").read()
        problems, cited = [], set()
        for path, symbol in refs(text):
            cited.add(path)
            if not exists(args.repo, path):
                problems.append(f"missing path: {path}")
            elif symbol and not has_symbol(args.repo, path, symbol):
                problems.append(f"missing symbol: {path}::{symbol}")
        drift = []
        m = VERIFIED.search(text)
        if m:
            changed = changed_since(args.repo, m.group(1))
            if changed is None:
                problems.append(f"unknown commit in Verified at: {m.group(1)}")
            else:
                drift = sorted(f for f in changed if any(f == p or (GLOB & set(p) and fnmatch.fnmatch(f, p)) for p in cited))
        failed += len(problems)
        status = "ok" if not problems and not drift else "check"
        print(f"{status}\t{md}\t{len(cited)} paths cited")
        for p in problems:
            print(f"  {p}")
        for p in drift:
            print(f"  changed since {m.group(1)[:12]}: {p}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
