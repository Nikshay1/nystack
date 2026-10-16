# Custom guide list

Editors and admins see the guides saved to their stack in the block editor's guide library, open one, and save or publish changes to it. The list is read through the plugin backend as the signed-in user, never straight from the App Platform API.

Verified at `35a90ab4c5447f9eaeebfcc39cbefed476909fef` on 2026-10-16.

## Entry points

- The block editor's guide library. Code: `src/components/block-editor/GuideLibraryModal.tsx::GuideLibraryModal`, fed by `src/components/block-editor/BlockEditor.tsx::useBackendGuides`.
- Save and publish, which re-read the list to find the saved resource. Code: `src/components/block-editor/hooks/useBackendGuides.ts::useBackendGuides`.

## Code

| Layer | Code | Role |
| --- | --- | --- |
| UI | `src/components/block-editor/GuideLibraryModal.tsx::GuideLibraryModal` | Lists guides; reads `metadata.creationTimestamp` and `uid`, so items must keep full metadata. |
| Hook | `src/components/block-editor/hooks/useBackendGuides.ts::useBackendGuides` | Loads the list, saves, and probes the list after a save. |
| Client | `src/utils/fetchBackendGuides.ts::fetchBackendGuides` | `GET /custom-guides`; filters published guides; maps unavailable statuses to an empty list. |
| Backend route | `pkg/plugin/resources.go::handleCustomGuides` | Registers `/custom-guides`. |
| Backend handler | `pkg/plugin/custom_guides.go::handleCustomGuides` | Caller identity and namespace, then drains pages. |
| Backend drain | `pkg/plugin/custom_guides.go::drainGuideResources` | Bounded paging with a byte budget; passes each item through as raw JSON. |

## Data and contracts

- Response envelope `pkg/plugin/custom_guides.go::customGuidesResponse` (`{ items }`). Mirrored by `src/types/backend-api.schema.ts::CustomGuidesResponseWireSchema`, registered under `custom-guides` in that file's envelope map.
- Contract goldens: `pkg/plugin/contract_fixtures_test.go::captureCustomGuidesDefault`, `pkg/plugin/contract_fixtures_test.go::captureCustomGuidesEmpty`, files `pkg/plugin/testdata/contract/custom-guides.default.json` and `pkg/plugin/testdata/contract/custom-guides.empty.json`, checked by `src/validation/backend-api-contract.test.ts`.
- Unavailable statuses `src/utils/fetchBackendGuides.ts::UNAVAILABLE_STATUSES` become `[]`; other errors throw and show an error in the editor.

## Tests

- `pkg/plugin/custom_guides_test.go` covers paging, failures, identity and method gates, the byte budget, no cross-caller caching, and cancellation.
- `src/utils/fetchBackendGuides.test.ts` and `src/components/block-editor/hooks/useBackendGuides.test.ts` cover the client and hook.
- `tests/private-guide-copy.spec.ts` and `tests/customize-guide.spec.ts` mock the URL `/api/plugins/grafana-pathfinder-app/resources/custom-guides` (as a `**` glob) with `{ items }`. Change these mocks with the route or envelope.
- `src/validation/app-platform-transport.test.ts` fails on any direct browser read of `/apis/...`; its allowlist is empty. Its advice string names the `/custom-guides` route.
- `src/utils/fetchBackendGuides.test.ts` asserts the request URL. `pkg/plugin/custom_guides_test.go` and `pkg/plugin/contract_fixtures_test.go::doCustomGuidesGolden` build requests with the literal path.

## Docs

- `docs/design/BACKEND_PROXY_PATTERN.md` describes `GET /custom-guides` and lists what a new route needs (Author's checklist, section 10).
- `docs/developer/utils/README.md` documents `fetchBackendGuides.ts` and its "Used by" list.

## Change together

- Route path: `resources.go`, the client and its test, both Playwright mocks, the Go test request paths, the transport test's advice string, the header comment of `src/validation/backend-api-contract.test.ts`, and the proxy pattern doc. The contract key `custom-guides` (envelope map, `contractRoots`, golden file names) is a separate name and can stay.
- Envelope field: Go struct, Zod schema, contract goldens, both Playwright mocks.
- Adding or removing an importer of `fetchBackendGuides.ts`: the "Used by" list in `docs/developer/utils/README.md`.
- Any new browser read of guide resources: go through a backend route; never add an allowlist entry.

## Gotchas

- Do not use `src/lib/custom-guide-repository-client.ts` for the editor. It returns summaries without `resourceVersion` or annotations, which the save path needs.
- An identity-gate 403 from the proxy becomes an empty list, while a 502 throws. Keep both cases tested.
- `[custom-guides]` log prefixes in `src/lib/custom-guide-repository-client.ts` and the `customGuides*` ids in `src/constants/testIds.ts` belong to other things. `/custom-guide` and `/custom-guide-repository` are separate routes.
- History: PR #2093 added this route; its blocker was the two Playwright mocks above.
