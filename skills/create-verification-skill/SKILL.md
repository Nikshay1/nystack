---
name: create-verification-skill
description: "Generate a project-local verify-<app> skill that launches the real app, drives a feature the way a user does, captures evidence, and cleans up, with a per-feature recipe file for each mapped feature. Any language or surface (web, CLI, TUI, service, library). Use for /create-verification-skill or when a repo has no scripted way to prove behavior."
disable-model-invocation: true
---

# Create a verification skill

`verify-change` needs a way to run the real path. This skill builds that way once per project, so every later verification starts from working commands instead of rediscovering how to launch the app. Write it for an agent reading it cold, mid-task.

## 1. Learn the app from the repository

Answer from the code and docs. Ask the user only what you cannot observe.

- **Surface.** What a user touches: web UI, CLI, TUI, desktop app, HTTP service, library. Pick the primary one and note the others.
- **Run.** The repository's own documented dev command (package scripts, Makefile, README). Ports, environment variables, seed data, auth.
- **Drive.** Existing harnesses first: Playwright or Cypress specs, e2e runners, CLI test helpers, a debug port. Then a generic route: a browser driver for web, a PTY or tmux session for CLI and TUI, plain HTTP for services, a script importing the public API for libraries.
- **Observe.** What counts as evidence: screenshots, accessibility snapshots, terminal transcripts, response bodies, exit codes, files written, rows stored.
- **Isolate.** Can two instances run side by side (ports, data directories, profiles)? If not, the skill must refuse to drive an instance it did not start.
- **Limits.** What this machine cannot do (no Docker, no GPU, no cloud credentials). The skill says so instead of pretending.

If the checkout does not build or start, fix that or report it exactly before generating. A skill written against a broken base teaches wrong steps.

## 2. Decide where it lives

- Repository the user owns: `.claude/skills/verify-<app>/`.
- Upstream repository: `skills/repo-<repo>/verify/` in the user's skills checkout, linked from the repo skill. Never add it to an upstream PR unless the project asks for it.

## 3. Write the skill

`SKILL.md` with frontmatter (`name: verify-<app>`, and a `description` naming the app, the surface, and when to use it) and these sections, each filled from what step 1 found. No placeholders survive.

- **Launch.** The exact command, and the signal that the app is ready to use, not merely that a process answers. Must work from an empty data directory, migrations and seed data included. For short-lived CLIs: build once, then one isolated session per drive.
- **Doctor.** One read-only check that this instance is worth driving: our process, the right build of the right commit, the expected port, valid auth. Run it first and after anything surprising.
- **Drive.** The harness commands with real selectors, routes, or prompts from this repository. Prefer stable handles: ARIA roles and names, `data-*` attributes, route paths, exact prompt strings.
- **Evidence.** What to capture and where it is saved. The proof standard: drive the real user path, not internal setters or test-only endpoints. Capture the action and the resulting state. Check side effects (files, rows, requests) as well as what is visible. Mocks only at boundaries production already isolates.
- **Cleanup.** Stop what this run started, never by process name. Evidence survives cleanup.
- **Helpers.** Any script the skill ships is executable, and its invocation is written in the skill body.

## 4. Add per-feature recipes

For each feature in the repository's feature map (or the top 3 to 5 features if there is no map), add `features/<feature>.md` with four sections: `Sub-features`, `How a user gets to it`, `Driving it` (preconditions, then each action with its exact command and the observable result), and `Gotchas`. Keep implementation detail out; the feature map holds that. If seed data cannot satisfy a recipe, the recipe reports a failure and the reason goes in `Gotchas`. Never weaken a recipe so it passes.

## 5. Prove it

Run the generated skill end to end once: launch, doctor, drive one feature, capture evidence, clean up. Confirm the evidence still exists after cleanup. Run cleanup after every failed attempt too. A skill that never ran is a draft. If you proved it in a stand-in environment, list each step the real target will do differently.

Point the user at `maintain-verification-skill` for upkeep.
