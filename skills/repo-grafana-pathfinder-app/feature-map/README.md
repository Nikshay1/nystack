# grafana-pathfinder-app feature map

Code-level map of grafana/grafana-pathfinder-app for agents. Open one feature file, run the checker on it, then open the files it cites.

Mapped at `35a90ab4c5447f9eaeebfcc39cbefed476909fef` on 2026-10-16.

```bash
python3 <nystack>/skills/feature-map/scripts/check_map.py --repo <pathfinder-checkout> --map <this-dir> <feature-file>
```

## Conventions

- Paths are from the repository root. Symbols are written `path::symbol`. No line numbers. URLs and routes start with `/` so the checker skips them.
- The repository's own routing table is `docs/developer/CONTEXT_INDEX.md` and the tier model is in `AGENTS.md`. This map adds what those do not: every reader, mock, and doc that a change to one feature makes stale.

## Editor

- [custom-guide-list](custom-guide-list.md): the block editor's list of saved custom guides, read through the plugin backend.

## Interactive guides

- [guided-step-cross-tab-wait](guided-step-cross-tab-wait.md): how long the controller tab waits for a guided step running in the live tab.

## Not yet mapped

Everything else. Add an entry the first time a task needs a feature. Likely next: learning-path progress storage (`src/lib/user-storage.ts`), kiosk catalog fallback (`src/components/kiosk/`), snippet resolution (`src/snippet-engine/`), the e2e CLI (`src/cli/e2e/`).
