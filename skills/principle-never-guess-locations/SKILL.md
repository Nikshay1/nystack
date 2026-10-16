---
name: principle-never-guess-locations
description: "Apply whenever you name, open, or edit the code for a feature. Find it through the repo's feature map or a search you ran, open the file at the current commit, and only then state where something lives. Never answer from memory or from what the code 'probably' looks like."
disable-model-invocation: true
---

# Never guess locations

A guessed path, function name, or line number sends the next step to the wrong place, and it reads exactly like a correct one.

- Look up the feature in the repo's feature map first (the **feature-map** skill). Use a search when there is no map or the map has no entry.
- Open every file you are about to cite. Cite `path:symbol`, or `path:line` only at a commit you name.
- Memory from an earlier session, an issue body, or a readiness note can be stale. Treat them as hints and check them against current code.
- If you could not find something, say what you searched and that it found nothing. Do not fill the gap with a plausible name.
- When you had to search for a location the map lacked, add it to the map before you finish, so the next agent does not search again.
