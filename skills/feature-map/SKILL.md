---
name: feature-map
description: "Find where a feature's code, data, tests, and docs live by reading the repo's feature map instead of guessing or grepping blind. Use before reading, changing, reviewing, or explaining a named feature in any repo that has a map, when asked 'where is X implemented', and to record a location you had to search for."
---

# Feature map

A feature map is a small set of Markdown files that say, for each user-facing feature, which files and symbols implement it, which data and contracts it owns, which tests and docs describe it, and what must change together. It lets an agent open the right three files instead of searching the whole tree, and it lists the places a change makes stale.

## 1. Find the map

Look in this order and use the first that exists:

1. In the repository: `.claude/skills/map-*/`, `.agents/skills/map-*/`, or `docs/feature-map/`.
2. In the user's skills checkout, for repositories the user does not own: `skills/repo-<repo-name>/feature-map/` (installed under `~/.claude/skills/repo-<repo-name>/feature-map/`).

No map → locate the code by searching, follow **principle-never-guess-locations**, and offer `create-feature-map` once the task is done. Do not stop the task to build a map.

## 2. Read only what you need

1. Read the map's `README.md`. Check its `Mapped at` commit against `git rev-parse HEAD`.
2. Open the one or two feature files that match the task. Do not read the whole map.
3. Run the checker on those files before trusting them:

   ```bash
   python3 <path-to-this-skill>/scripts/check_map.py --repo . --map <map-dir> <feature-file>...
   ```

   It confirms every cited path exists, every `path::symbol` still appears in its file, and lists cited files that changed since the map was verified. Treat a reported entry as stale and confirm it by opening the file.

## 3. Use it

- Open the files the entry names. Cite `path::symbol` in your work, not line numbers.
- Use the **Change together** and **Docs** sections as the starting list for the sweep in **principle-look-beyond-the-diff**. The map lists the known dependents; the search still has to find unknown ones.
- Use **Tests** to choose which suites to run and which mocks to update.

## 4. Leave it better

Before you finish, fix what you learned:

- A path or symbol was wrong → correct it.
- You had to search for a file the entry lacked → add it.
- The feature has no entry → add a short one in the format of [`references/feature-template.md`](references/feature-template.md).

Update the entry's `Verified at` line with the commit you checked. Keep these edits in the map, not in product code. In a repository you do not own, the map lives in the user's skills checkout, so the edit never enters an upstream PR.
