---
name: blast-radius
description: "Find what a change could break outside its own lines, and prove the one fact that makes it safe by running real code. Use for 'blast radius of X', 'what could this break', or a small diff you do not trust yet."
disable-model-invocation: true
---

# Blast radius

Listing callers is the easy part; a search does it in a second. The job is the breakage a symbol search does not show: the data another reader decodes, the mock that still serves the old shape, the doc that still states the old number, the code that runs at teardown.

A writeup that sounds right is worth nothing on its own. Find the one or two facts the change's safety rests on and prove them by running code.

## Steps

1. **Read the change.** The diff, every symbol it adds, changes, or deletes, and what now behaves differently, including what the diff does not spell out.
2. **Find the fact it is safe because of.** Most risky-looking changes are safe because of one fact, such as "this key is only read by these two functions" or "this route has no other client". Find it. If it holds, most risks clear at once.
3. **Look where search stops.** Follow data, not only symbols: JSON returned to another service, a stored key or column, a wire format, a file another language reads, a feature flag, a cache. Check when things run: teardown, retries, background refresh, a second tab. Read the library source at its pinned version when your safety depends on its behavior.
4. **Sweep the usual misses** from **principle-look-beyond-the-diff**: other readers and writers, early returns in callers, test mocks and fixtures, docs and agent files that state the old fact, texts that must agree.
5. **Rate each risk.** How it breaks, the `path::symbol`, how likely, how bad, how to check. Keep confirmed risks apart from the ones you checked and cleared.
6. **Prove the fact.** Write a script or test that calls the real code and fails loudly if the fact is false. Run it. Paste the output.

## Reply

- **What it does**, including the non-obvious part.
- **The fact it is safe because of**, with its proof level (see **principle-prove-it-works**) and the proof, or marked unproven.
- **Risks**, each with location, likelihood, cost, and the check.
- **Cleared**, with the reason each is fine.
- **Before merging**, the cheapest test or repro that would catch the real bug.
