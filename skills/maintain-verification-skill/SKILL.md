---
name: maintain-verification-skill
description: "Keep a project's verify-<app> skill honest: check its index, compare each feature recipe with source, then drive every feature live once, and ship one change of proven corrections. Use for /maintain-verification-skill or when a recipe no longer matches the app."
disable-model-invocation: true
---

# Maintain a verification skill

Recipes rot when the app changes. The unit of rigor is the feature: every recipe gets a source check and a live run, but not every sentence needs its own proof.

Edit only the verification skill's own folder (its `SKILL.md`, `features/`, and helper scripts). A recipe that describes behavior the app no longer has is either drift (fix the recipe) or a product regression (report it, and leave the app alone).

## Pass

1. **Find the target.** The `verify-*` skill for this repository. Several candidates, ask which. None, stop and point at `create-verification-skill`.
2. **Index.** Make the `features/` list match the files that exist, and the features in the repository's feature map.
3. **Source check.** One read-only subagent per recipe, run in parallel. Each reads the code behind the feature and returns: a one-line summary, the entry points, likely drift with `path::symbol` evidence, and one recipe to drive live. Subagents never drive the app or edit files.
4. **Live run.** Required even when the source check is clean. You drive, following the skill's own launch model. Run doctor before the first drive, after any failed drive, and on each fresh session. Keep evidence across every cleanup. Clean up what each failed attempt left behind. A feature that cannot be reached is `unreachable` only with the exact prerequisite (auth, entitlement, OS, external service) and the route attempted.
5. **Triage.** Wrong description, fix the recipe. Behavior that works but the harness cannot drive, fix the harness and drive it again. Behavior that is broken, report it to the user and keep it out of this change.
6. **Ship or stop.** Outcome is **clean** (nothing to change), **changed** (one commit or PR of proven corrections, each re-driven), or **blocked** (say what blocked it).
