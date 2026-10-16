# Notice

nystack's structure and several skills are adapted from [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan, Copyright (c) 2026 Lauren Tan, released under the MIT License. pstack's license applies to the adapted material.

Adapted from pstack, rewritten for Claude Code and this repository's focus:

| nystack | pstack source |
| --- | --- |
| `ny-mode` and its playbooks (structure: a mode skill routing to playbooks copied into a todo list) | `poteto-mode` |
| `agents/ny-agent.md` (a delegate that reads the mode skill first) | `agents/poteto-agent.md` |
| `create-verification-skill`, `maintain-verification-skill` | the skills of the same names |
| `feature-map/references/feature-template.md`, the four-section recipe format in `create-verification-skill` | `create-verification-skill/references/feature-map-example` |
| `blast-radius`, including the proof levels used across nystack | `blast-radius` |
| `adversarial-review` and its references | `interrogate` |
| `repro-first` | `tdd` |
| `principle-prove-it-works`, `principle-test-behavior-not-implementation`, `principle-fix-root-causes`, `principle-encode-lessons-in-structure`, `principle-smallest-sufficient-change` | `principle-prove-it-works`, `principle-test-behavior-not-implementation`, `principle-fix-root-causes`, `principle-encode-lessons-in-structure`, `principle-laziness-protocol` and `principle-subtract-before-you-add` |

Written for nystack: `feature-map`, `create-feature-map`, `maintain-feature-map` and `check_map.py` (code-level maps, where pstack's feature maps are behavior-level), `verify-change` and `agents/verifier.md`, `learn-from-reviews`, `principle-look-beyond-the-diff`, `principle-never-guess-locations`, `principle-evidence-in-every-claim`, `principle-separate-author-and-verifier`, the repo skills, `issue-finder`, and `unslop`.
