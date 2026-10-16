---
name: maintain-feature-map
description: "Bring a repository's feature map back in line with the code: run the checker, re-trace every feature touched since the map's commit, add features that appeared, and record the new commit. Use for /maintain-feature-map, 'refresh the feature map', or when the checker reports stale entries."
disable-model-invocation: true
---

# Maintain a feature map

A map goes stale with every merged PR. The checker finds broken references for free. This pass finds the rest: entries that still resolve but no longer tell the truth.

Edit only the map. A map that disagrees with the code is fixed by changing the map. If the code itself looks broken, report it and leave the code alone.

## Pass

1. **Mechanical check.** Run the checker over the whole map:

   ```bash
   python3 <nystack>/skills/feature-map/scripts/check_map.py --repo <repo> --map <map-dir>
   ```

   Every `missing` line is a confirmed error. Every `changed since` line marks an entry to re-trace.

2. **What changed.** `git log --oneline <mapped-at>..HEAD` and `git diff --stat <mapped-at>..HEAD`. Note new directories, new routes or commands, renamed or deleted files, and new docs.

3. **Re-trace.** One read-only subagent per affected feature file. Each one compares the entry with current code and returns corrections with `path::symbol` evidence, including readers, tests, and docs the entry lacks. Spot-check what they report before you accept it.

4. **New features.** For each user-facing surface added since the map's commit, add an entry, or list it under `Not yet mapped`. Require a concrete path before calling something new.

5. **Record.** Update each touched entry's `Verified at` and the README's `Mapped at` to the commit you checked. Run the checker again. It must be clean.

## Outcome

Say which one applies:

- **clean**: nothing needed changing.
- **changed**: list each corrected entry and the evidence.
- **blocked**: say what stopped the pass.

Commit the map change on its own. In an upstream contribution, it goes in the user's skills checkout, never in the upstream PR.
