# Guided step cross-tab wait

When a learner runs a guided block from the controller tab, the live tab performs the steps and reports back. The controller waits a bounded time for that report, then shows a failure with a retry, instead of hanging when the live tab drops the command.

Verified at `35a90ab4c5447f9eaeebfcc39cbefed476909fef` on 2026-10-16.

## Entry points

- Running a guided block while paired with a live tab. Code: `src/components/interactive-tutorial/interactive-guided.tsx::guidedStepWaitMs` call into `awaitStepComplete`.

## Code

| Layer | Code | Role |
| --- | --- | --- |
| Bound | `src/types/cross-tab.types.ts::guidedStepWaitMs` | max(`DEFAULT_STEP_WAIT_MS`, remaining substeps x (guided step timeout + slack)). |
| Default | `src/types/cross-tab.types.ts::DEFAULT_STEP_WAIT_MS` | 15 minutes; also the floor, because the live tab queues commands. |
| Controller wait | `src/global-state/controller-channel.tsx::awaitStepResult` | Sets the timer, posts step-cancel on timeout, clears the pending entry. |
| Controller API | `src/global-state/controller-channel.tsx::awaitStepComplete`, `src/global-state/controller-channel.tsx::cancelStepComplete` | Boolean wrapper and cancel. |
| Caller | `src/components/interactive-tutorial/interactive-guided.tsx::awaitStepComplete` | Passes `guidedStepWaitMs(internalActions.length - startIndex)`. |
| Live tab | `src/integrations/cross-tab/live-tab-executor.ts::runGuided` | Runs guided substeps from a serial queue; passes no timeout. |
| Per-substep budget | `src/interactive-engine/action-handlers/guided-handler.ts::stepTimeout` | Defaults to `src/constants/interactive-config.ts::stepTimeout` (120 s). |

## Data and contracts

- The authored `stepTimeout` on a guided block is not sent over the wire; the live tab always uses the config default. The controller bound assumes that.
- The command shape is `src/types/cross-tab.types.ts::StepCommandMessage`, checked on receipt by `src/types/cross-tab.types.ts::isValidStepCommand`. A new wire field needs validation there.
- Every field except `src/lib/pairing-manager.ts::UNSIGNED_FIELDS` is signed by `src/lib/pairing-manager.ts::canonicalSignedPayload`, so a new field is signed automatically.

## Tests

- `src/global-state/controller-channel.test.tsx` covers the timeout result, pending-entry removal, and timer clearing.
- `src/types/cross-tab.types.test.ts` covers the floor and the scaling of `guidedStepWaitMs`.
- `src/integrations/cross-tab/live-tab-executor.test.ts` asserts how `runGuided` calls `executeGuidedStep`, including the timeout argument.
- `src/integrations/cross-tab/cross-tab-protocol.acceptance.test.tsx` builds signed `step-command` messages.
- `src/components/interactive-tutorial/interactive-guided.test.tsx` checks the bound reaches `awaitStepComplete`. Its fixture has 2 substeps, so it asserts the floor; use 8 or more substeps to test scaling.

## Docs

- `docs/developer/CROSS_TAB_CONTROLLER.md` says composite actions wait up to 15 minutes. That is stale for guided blocks of 8 or more substeps (open follow-up from PR #2145's review). The `step-command` shape line in the same doc lists every wire field.
- `docs/developer/interactive-examples/json-guide-format.md` and `docs/developer/interactive-examples/guided-interactions.md` say the `stepTimeout` default is 30000 ms; the code default is 120000 ms. Pre-existing mismatch.

## Change together

- Changing the live tab's per-substep timeout or forwarding the authored `stepTimeout`: `guidedStepWaitMs`, its tests, and the cross-tab doc.
- Changing `DEFAULT_STEP_WAIT_MS`: the multi-step path in `controller-channel.tsx` uses it too.

## Gotchas

- `src/components/interactive-tutorial/interactive-guided.test.tsx` mocks `controller-channel` wholesale, which is why the helper lives in `cross-tab.types.ts`.
- A flaky fail-open pairing test in `src/components/interactive-tutorial/interactive-step.test.tsx` is a known CI gotcha, not caused by changes here.
