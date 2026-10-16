---
name: create-feature-map
description: "Build a feature map for a repository: an index plus one file per user-facing feature naming the code, data, tests, docs, and change-together rules, every path checked by script. Use for /create-feature-map, 'map this repo', or when an agent keeps searching for the same code."
disable-model-invocation: true
---

# Create a feature map

The map is written for an agent that has never seen the repository and will read it cold, mid-task, with one question: where is the code for this feature, and what else breaks if I change it. Every line either answers that or goes.

## 1. Decide where the map lives

- The user owns the repository, or the project wants agent docs in-tree: `.claude/skills/map-<repo>/` with a `SKILL.md` whose description names the repository and says "use to find where a feature's code lives". Commit it with the code.
- The user contributes upstream and the project does not want it: `skills/repo-<repo>/feature-map/` in the user's skills checkout (nystack). Link it from that repo skill's `SKILL.md`. It never enters an upstream PR.

Check ownership with `gh repo view --json owner` against `gh api user --jq .login` instead of asking.

## 2. Inventory features from the user's side

List what a user or caller can do, not how the code is organized. Sources, in order: routes and pages, CLI commands and flags, menu items and settings, public API exports, the README and user docs, issue labels and `area/*` labels, and the repository's own architecture docs. Group them into areas.

Start with the 5 to 10 features that recent issues and PRs touch most (`gh pr list --state merged --limit 50 --json files` shows where changes land). Add the rest over time. A small map that is right beats a large one that guesses.

## 3. Trace each feature

Use one read-only subagent per feature when there are several. Each one traces from the entry point inward and returns the entry in [the feature template](../feature-map/references/feature-template.md):

- Entry points: how the feature is reached, and the handler or component for each.
- Code: the files and the symbols that do the work, by layer. Name symbols with `path::symbol`, never line numbers.
- Data and contracts: types, schemas, storage keys, routes, events, and every reader and writer of each.
- Tests: the suites that cover it, and every mock or fixture that encodes its behavior (search `tests/` for its routes and keys).
- Docs: every document, comment-heavy README, or agent instruction that states a fact about it. Search for its key values as words.
- Change together: pairs that must move as one, learned from the above and from past PR review comments on this area.
- Gotchas: traps a newcomer falls into.

Subagents read code. They do not run the app or edit files.

## 4. Write the index

`README.md` in the map directory holds:

- `Mapped at` with the full commit SHA and date.
- How to use it: open one feature file, run the checker on it, open the cited files.
- Conventions: paths from the repository root, `path::symbol` for symbols, behavior in user terms, no line numbers. URLs and routes start with `/` (write a mock's `**/api/x` pattern as `/api/x`), because the checker treats every other backticked span with a slash as a repository path.
- The areas, each with its feature files and one line per file.
- `Not yet mapped`: features you know exist but did not trace. An honest gap is better than a missing feature the reader assumes does not exist.

## 5. Prove the map

Run the checker over the whole map and fix every missing path and symbol:

```bash
python3 <nystack>/skills/feature-map/scripts/check_map.py --repo <repo> --map <map-dir>
```

Then test it the way it will be used: give a fresh subagent one realistic task ("where would you change X, and what else must change with it?") with only the map, and compare its answer to the code. Fix what it got wrong. A map that was never used on a task is a draft.

## 6. Hand over

Report the features mapped, the ones listed as not yet mapped, the checker output, and the test-task result. Point at `maintain-feature-map` for upkeep.
