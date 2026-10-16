# Think about these too

## Purpose

This file is a reusable checklist for agents working on open-source issues and pull requests.

It exists because a narrow implementation review can produce a patch that passes targeted tests but still misses real behavior elsewhere in the repository.

The failure that triggered this checklist was:

- The implementation path was reviewed as `PanelDataPaneNext → QueryEditorContextWrapper → QueryEditorRenderer`.
- `dsError` was surfaced in `QueryEditorRenderer`.
- Targeted tests passed.
- But `QueryEditorPanel` was also rendered directly by the stacked editor, so that path bypassed the new error UI.
- `dsError` was also produced by initial datasource loading, not only datasource changes, so the alert title `"Failed to change datasource"` was too specific.

The core lesson:

> Do not stop at the file named in the issue. Trace the behavior through the whole relevant codebase.

---

# 1. Think in terms of behavior, not files

An issue may mention one component, one function, or one state field. That does not mean the behavior is isolated there.

Before changing anything, ask:

1. Where is this state created?
2. Where is it mutated?
3. Where is it cleared?
4. Where is it consumed?
5. Where is the component rendered?
6. Does anything bypass this component?
7. Are there alternate UI modes?
8. Are there fallback/loading/recovery paths?
9. Does the same state represent more than one type of failure?
10. What happens after failure?
11. What happens after recovery?

Never assume the main path is the only path.

---

# 2. Build a behavior map before coding

Identify the important symbols involved in the issue.

For example:

- state: `dsError`
- renderer: `QueryEditorRenderer`
- lower-level component: `QueryEditorPanel`
- state owner: `PanelDataPaneNext`
- context: `QueryEditorContextWrapper`

Then search them across the relevant feature.

```bash
rg -n "dsError" public/app/features/dashboard-scene
rg -n "QueryEditorRenderer" public/app/features/dashboard-scene
rg -n "QueryEditorPanel" public/app/features/dashboard-scene
```

For exported/reusable symbols, search repository-wide when practical:

```bash
rg -n "QueryEditorPanel" .
```

Build the actual flow:

```text
PanelDataPaneNext
  └─ owns dsError
       ├─ loadDatasource()
       ├─ changeDataSource()
       └─ bulkChangeDataSource()

QueryEditorContextWrapper
  └─ exposes dsError

QueryEditorRenderer
  └─ renders QueryEditorPanel

StackedQueryItem
  └─ renders QueryEditorPanel directly
```

That last path is exactly what was missed.

---

# 3. Trace every producer of shared state

Never decide what a state field means based on one function.

Search every place that writes it.

```bash
rg -n "dsError" public/app/features/dashboard-scene/panel-edit/PanelEditNext
```

Then classify the producers.

For this issue:

```text
loadDatasource
- datasource loading failure
- fallback loading failure

changeDataSource
- datasource not found
- datasource loading failure

bulkChangeDataSource
- datasource not found
- datasource loading failure
```

This shows that `dsError` does not only mean:

```text
A datasource change failed.
```

Therefore:

```text
Failed to change datasource
```

is too specific as a universal title.

Before writing user-facing text, understand every state producer.

---

# 4. Search every call site of components you touch

If you place behavior inside a wrapper component, search for direct users of the component underneath it.

This is mandatory.

If changing:

```text
QueryEditorRenderer
```

and it renders:

```text
QueryEditorPanel
```

search both:

```bash
rg -n "QueryEditorRenderer" .
rg -n "QueryEditorPanel" .
```

In this case that would have exposed:

```text
StackedItem.tsx → QueryEditorPanel
```

The reasoning should then be:

```text
QueryEditorRenderer contains the new error UI.

StackedItem does not use QueryEditorRenderer.

StackedItem uses QueryEditorPanel directly.

Therefore stacked mode will bypass the new error UI.
```

This should have been discovered before implementation.

---

# 5. Search for alternate modes

Whenever UI behavior changes, explicitly look for alternate modes.

Examples:

- stacked
- compact
- legacy
- mobile
- sidebar
- drawer
- fullscreen
- experimental
- feature-flagged

Example:

```bash
rg -n "stacked|compact|legacy|drawer|sidebar" \
public/app/features/dashboard-scene/panel-edit/PanelEditNext
```

Do not assume the primary renderer is universal.

---

# 6. Decide where behavior belongs only after reading callers

Before placing a fix somewhere, ask:

> Why does this behavior belong at this level?

For this issue, the choices should have been evaluated.

### Option A — `QueryEditorRenderer`

Problem:

```text
Normal mode → works
Stacked mode → bypasses it
```

### Option B — `QueryEditorPanel`

Potential benefit:

```text
Both render paths use it
```

But then investigate whether a global `dsError` would incorrectly appear inside every stacked query.

### Option C — shared error component

Could be rendered in both normal and stacked paths at the correct level.

The correct abstraction should be chosen only after all callers are understood.

---

# 7. Think about state scope

When shared state is being rendered in a repeated UI, ask:

- Is this state global?
- Is it associated with one query?
- Would rendering it in every stacked item duplicate the error?
- Should it appear once above the stack?
- Does the error identify which query caused it?

Do not fix one missing path by accidentally creating duplicated UI.

---

# 8. Build a behavior matrix before implementation

Write down the scenarios that matter.

For this issue:

| Scenario | Expected behavior |
| --- | --- |
| Initial datasource load succeeds | No error |
| Initial datasource load fails | Error shown |
| Single datasource change fails | Error shown |
| Bulk datasource change fails | Error shown |
| Failed single change then succeeds | Error clears |
| Failed bulk change then succeeds | Error clears |
| Normal editor | Error visible |
| Stacked editor | Error visible |
| Query runtime failure | Existing behavior preserved |
| Missing query editor | Existing warning preserved |

Then compare implementation and tests against this matrix.

---

# 9. Tests should cover behaviors, not just files

A passing test suite only proves the paths exercised by those tests.

Ask:

```text
Which user-visible path is still not mounted by these tests?
```

For this issue, regression coverage should include:

- normal editor displays datasource error
- stacked editor displays datasource error
- failed single change followed by success clears error
- failed bulk change followed by success clears error
- load-related errors use accurate wording

If there are multiple render paths, at least one test should explicitly exercise each important path.

---

# 10. Passing tests are not permission to stop thinking

After tests pass, ask:

1. What exactly did these tests exercise?
2. Which components were never mounted?
3. Which UI modes were never used?
4. Which state producers were never simulated?
5. Which callers bypass the tested component?

In this case:

```text
90/90 tests passing
```

proved the tested paths worked.

It did not prove stacked mode worked.

The correct conclusion should have been:

```text
The targeted tests pass. Now inspect alternate render paths and all dsError producers before calling the fix complete.
```

---

# 11. Perform a second repository search after implementation

Once the patch works, repeat the important searches.

```bash
rg -n "dsError" \
public/app/features/dashboard-scene/panel-edit/PanelEditNext

rg -n "QueryEditorPanel" \
public/app/features/dashboard-scene

rg -n "QueryEditorRenderer" \
public/app/features/dashboard-scene
```

Now ask:

> Is there any result here whose behavior is not covered by the patch?

This second audit would have caught the stacked editor problem.

---

# 12. Review user-facing wording against state semantics

Whenever adding:

- an alert
- toast
- error message
- title
- warning
- status text

trace every condition capable of triggering it.

Ask:

```text
Is this sentence true in every case where it can appear?
```

If not:

- make the wording more generic, or
- make the state more specific.

Do not derive user-facing wording from whichever function you happened to be editing.

---

# 13. Search existing UI conventions

Before inventing new UI/error language, inspect nearby patterns.

```bash
rg -n 'severity="error"' <feature-directory>
rg -n "datasource.*error|error.*datasource" public/app
rg -n "Failed to .*datasource" public/app
```

Check:

- wording
- placement
- severity
- translation style
- whether alerts appear globally or inline

Match existing project conventions where possible.

---

# 14. Review your patch as an adversarial reviewer

Before pushing, stop thinking like the author.

Pretend this is somebody else's PR.

Ask:

## Architecture

- Is this behavior at the correct abstraction level?
- Does another caller bypass this wrapper?
- Is there a lower-level shared component?

## State

- Who creates this state?
- Who clears it?
- Does it represent multiple conditions?
- Can stale state survive recovery?

## UI

- Normal mode?
- Stacked mode?
- Alternate layout?
- Loading?
- Empty state?
- Recovery?

## Tests

- What does each test actually prove?
- What relevant path is not tested?

## Regression

- Could the error render twice?
- Could it remain stale?
- Could another mode still fail silently?
- Is the text misleading for some producers?

---

# 15. Exact steps that should have been taken for issue #130945

## Step 1 — Read the issue

Extract behavior:

```text
dsError exists.
Datasource failures can be silent.
The error needs to be surfaced.
Stale errors need to clear after success.
```

Do not decide the implementation location yet.

## Step 2 — Search every `dsError` usage

```bash
rg -n "dsError" \
public/app/features/dashboard-scene/panel-edit/PanelEditNext
```

Identify:

```text
loadDatasource
changeDataSource
bulkChangeDataSource
QueryEditorContext
QueryEditorContextWrapper
```

This would reveal that the error is not change-specific.

## Step 3 — Trace the context

Understand:

```text
PanelDataPaneNext
→ QueryEditorContextWrapper
→ datasource context
→ query editor components
```

## Step 4 — Search both renderer levels

```bash
rg -n "QueryEditorRenderer|QueryEditorPanel" \
public/app/features/dashboard-scene
```

This would reveal:

```text
QueryEditorRenderer → QueryEditorPanel
StackedQueryItem → QueryEditorPanel
```

## Step 5 — Inspect `StackedItem.tsx`

Before coding, verify whether stacked mode bypasses `QueryEditorRenderer`.

It does.

Therefore putting the alert only in `QueryEditorRenderer` is incomplete.

## Step 6 — Decide shared placement

Investigate whether the error belongs:

- inside `QueryEditorPanel`,
- in a shared wrapper,
- above the stacked editor,
- or through a reusable error component.

Consider state scope before deciding.

## Step 7 — Inspect all `dsError` producers

Because `loadDatasource()` also sets it, do not use:

```text
Failed to change datasource
```

as a universal title.

Choose wording valid for every producer or introduce richer state.

## Step 8 — Define tests before implementation

Required behaviors:

```text
normal editor shows error
stacked editor shows error
load error has accurate wording
single failure → success clears error
bulk failure → success clears error
```

## Step 9 — Implement

Only after understanding all those paths.

## Step 10 — Run targeted tests

Then:

```text
Prettier
ESLint
git diff --check
```

## Step 11 — Repeat symbol searches

```bash
rg -n "dsError" \
public/app/features/dashboard-scene/panel-edit/PanelEditNext

rg -n "QueryEditorPanel|QueryEditorRenderer" \
public/app/features/dashboard-scene
```

Review every result against the new behavior.

## Step 12 — Perform semantic diff review

Ask:

```text
Can anyone bypass the behavior I added?

Is every user-facing message accurate for every state producer?
```

Those two questions would have caught both Bugbot findings.

---

# 16. Pre-PR checklist

Do not say the PR is clean until these are checked.

## Understanding

- [ ] Read issue completely
- [ ] Read relevant comments
- [ ] Confirm bug still exists on current main
- [ ] Check competing PRs if relevant

## Architecture

- [ ] Search definitions
- [ ] Search all call sites
- [ ] Search lower-level components
- [ ] Search wrappers
- [ ] Search alternate modes
- [ ] Search feature-flagged paths if relevant

## State

- [ ] Find every producer
- [ ] Find every consumer
- [ ] Find every clearing/reset path
- [ ] Check failure → recovery behavior
- [ ] Confirm state semantics

## UI

- [ ] Normal path
- [ ] Alternate modes
- [ ] Loading
- [ ] Failure
- [ ] Recovery
- [ ] User-facing copy accurate

## Tests

- [ ] Regression test for original issue
- [ ] Test alternate path
- [ ] Test recovery
- [ ] Tests prove behavior rather than implementation only

## Patch quality

- [ ] Targeted tests pass
- [ ] Prettier passes
- [ ] ESLint passes
- [ ] `git diff --check` passes
- [ ] Only intended files changed
- [ ] Final diff manually reviewed
- [ ] Symbol search repeated after implementation

---

# 17. Warning signs that your investigation is too narrow

Stop and investigate more when:

- a state value is passed through context
- a component is exported
- a wrapper contains the new behavior
- a lower-level `Panel`, `Body`, `Content`, or `Item` exists
- the feature has stacked/compact/legacy modes
- the state has a generic name like `error`
- several functions write the same state
- tests exercise only one renderer
- you have not searched all call sites
- you are about to say "clean" based primarily on passing tests

---

# 18. The mindset to use

Continually ask:

> What assumption am I making right now?

Then try to disprove it.

Example:

```text
Assumption:
QueryEditorRenderer is the only query-editor render path.

Check:
Search every QueryEditorPanel call site.

Result:
StackedItem renders QueryEditorPanel directly.

Conclusion:
The assumption was false.
```

Another example:

```text
Assumption:
dsError means datasource change failure.

Check:
Search every dsError assignment.

Result:
loadDatasource also writes dsError.

Conclusion:
The assumption was false.
```

This should be standard agent behavior.

---

# 19. Final rule

Before saying:

```text
This fix is complete.
This PR is clean.
We're ready to submit.
```

the agent must be able to explain, without guessing:

1. Every relevant producer of the affected state.
2. Every relevant consumer.
3. Every caller of the component being changed.
4. Every important alternate mode.
5. Every failure path.
6. Every recovery path.
7. Why the user-facing wording is correct.
8. What each test proves.
9. What the tests do not prove.
10. Why no important caller bypasses the implementation.

If any of those answers are unknown, the investigation is not finished.

> Search outward until you understand the behavior graph. Then implement at the correct shared layer.