# Authoring a skill

1. Check that no existing skill covers it. Extend one before adding one.
2. Write for an agent reading cold, mid-task. Keep only sentences that change a decision. Tell it what to do; explain only when the rule is confusing without a reason.
3. Frontmatter: `name` matching the folder, and a `description` that starts with what it does and names when to use it. Add `disable-model-invocation: true` when the skill should run only when called by name or by ny-mode.
4. Put long templates, prompts, and examples in `references/`, and scripts in `scripts/` (executable, invocation shown in the skill body).
5. Point at other skills and project files by name or path instead of restating them.
6. Prefer a script or check to a paragraph (**principle-encode-lessons-in-structure**).
7. Run `python3 scripts/validate.py` in nystack. It must pass.
8. Try the skill on one real task in a fresh agent and fix what it got wrong.
9. Ship the skill change on its own, not inside feature work.
