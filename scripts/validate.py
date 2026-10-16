#!/usr/bin/env python3
"""Validate nystack: skill frontmatter, names, local links, the README skill table, and manifest versions.

Run from anywhere: python3 scripts/validate.py
Exit status 1 lists every problem found.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NAME = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
LINK = re.compile(r"\]\(([^)#\s]+)(#[^)]*)?\)")
problems = []


def frontmatter(path):
    text = open(path, encoding="utf-8").read()
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---\n", 4)
    if end < 0:
        return None, text
    fields = {}
    for line in text[4:end].splitlines():
        key, sep, value = line.partition(":")
        if sep and not line.startswith(" "):
            fields[key.strip()] = value.strip().strip('"')
    return fields, text


def check_links(path, text):
    base = os.path.dirname(path)
    for target, _ in LINK.findall(text):
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        if not os.path.exists(os.path.normpath(os.path.join(base, target))):
            problems.append(f"{os.path.relpath(path, ROOT)}: broken link {target}")


skills_dir = os.path.join(ROOT, "skills")
skills = sorted(d for d in os.listdir(skills_dir) if os.path.isdir(os.path.join(skills_dir, d)))
for skill in skills:
    path = os.path.join(skills_dir, skill, "SKILL.md")
    if not os.path.exists(path):
        problems.append(f"skills/{skill}: no SKILL.md")
        continue
    fields, text = frontmatter(path)
    if fields is None:
        problems.append(f"skills/{skill}/SKILL.md: missing frontmatter")
        continue
    if fields.get("name") != skill:
        problems.append(f"skills/{skill}/SKILL.md: name '{fields.get('name')}' does not match folder")
    if not NAME.match(skill) or len(skill) > 64:
        problems.append(f"skills/{skill}: folder name must be lowercase-hyphenated, at most 64 chars")
    desc = fields.get("description", "")
    if not desc:
        problems.append(f"skills/{skill}/SKILL.md: empty description")
    elif len(desc) > 1024:
        problems.append(f"skills/{skill}/SKILL.md: description over 1024 chars ({len(desc)})")

for dirpath, dirnames, filenames in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if not d.startswith(".git")]
    for f in filenames:
        full = os.path.join(dirpath, f)
        if f.endswith(".md"):
            check_links(full, open(full, encoding="utf-8").read())
        if "/scripts/" in full and f.endswith((".py", ".sh")) and not os.access(full, os.X_OK):
            problems.append(f"{os.path.relpath(full, ROOT)}: script is not executable")

for agent in sorted(os.listdir(os.path.join(ROOT, "agents"))):
    fields, _ = frontmatter(os.path.join(ROOT, "agents", agent))
    if not fields or fields.get("name") != agent[:-3] or not fields.get("description"):
        problems.append(f"agents/{agent}: needs frontmatter with name matching the file and a description")

readme = open(os.path.join(ROOT, "README.md"), encoding="utf-8").read()
listed = set(re.findall(r"\]\(skills/([a-z0-9-]+)/SKILL\.md\)", readme))
for skill in sorted(set(skills) - listed):
    problems.append(f"README.md: skill '{skill}' missing from the skill tables")
for skill in sorted(listed - set(skills)):
    problems.append(f"README.md: lists '{skill}', which does not exist")

plugin = json.load(open(os.path.join(ROOT, ".claude-plugin", "plugin.json")))
market = json.load(open(os.path.join(ROOT, ".claude-plugin", "marketplace.json")))
versions = {plugin["version"], market["metadata"]["version"], *(p["version"] for p in market["plugins"])}
if len(versions) != 1:
    problems.append(f".claude-plugin: versions disagree {sorted(versions)}")

for p in problems:
    print(p)
print(f"{len(skills)} skills checked, {len(problems)} problems")
sys.exit(1 if problems else 0)
