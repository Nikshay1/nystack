# Feature maps

An agent new to a repository does one of two things when asked to change a feature: it searches broadly and reads too much, or it guesses a plausible file and edits the wrong place. Both are expensive. Worse, neither tells it what else depends on the code: the test that mocks the route, the doc that states the timeout, the other reader of the storage key.

A feature map answers both questions in one short file per feature:

- **Entry points**: how a user or caller reaches it, and the handler for each.
- **Code**: the files and symbols that do the work, as `path::symbol`.
- **Data and contracts**: types, keys, routes, and formats, with every reader and writer.
- **Tests**: the suites that cover it and the mocks that encode its behavior.
- **Docs**: every document that states a fact about it.
- **Change together**: what must move as one.
- **Gotchas**: traps.

pstack's feature maps describe behavior for driving the app. nystack's describe code, because the problem they solve is finding and safely changing it. The two fit together: `create-verification-skill` writes one driving recipe per mapped feature.

## Build one

```text
/create-feature-map
```

It maps the features recent PRs touch most first, traces each with a read-only subagent, writes the index, checks every path by script, and tests the map by giving a fresh agent a real "where would you change X" task.

Where it goes depends on ownership. In your own repository it lives in `.claude/skills/map-<repo>/` and is committed. For an upstream project it lives in `skills/repo-<repo>/feature-map/` in nystack, so it never enters an upstream PR.

## Keep it honest

```bash
python3 skills/feature-map/scripts/check_map.py --repo <repo> --map <map-dir>
```

The checker fails on any cited path or symbol that no longer exists, and lists cited files that changed since each entry's `Verified at` commit. Agents run it on the entries they use, fix what they find, and add what they had to search for. `/maintain-feature-map` does a full pass.
