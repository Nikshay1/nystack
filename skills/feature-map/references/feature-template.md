# <Feature name>

<One paragraph in user terms: what the feature does for the person or caller using it. No implementation detail here.>

Verified at `<full commit SHA>` on <YYYY-MM-DD>.

## Entry points

- <How a user or caller reaches it: a route, a command, a menu item, an exported function.> Code: `path/to/file.ts::handlerName`.

## Code

| Layer | Code | Role |
| --- | --- | --- |
| UI | `src/components/foo/Foo.tsx::Foo` | Renders the panel and owns the open state. |
| Logic | `src/foo/foo-engine.ts::runFoo` | Decides what runs next. |
| Backend | `pkg/plugin/foo.go::handleFoo` | Serves `GET /foo`. |

## Data and contracts

- <Type, schema, storage key, route, event, or wire format.> Owned by `path::symbol`. Read by `path::symbol`, `path::symbol`.

## Tests

- `path/to/foo.test.ts` covers <behavior>.
- `tests/foo.spec.ts` mocks `<route>`. Update the mock when the route changes.

## Docs

- `docs/foo.md` states <the fact it states, e.g. the timeout value>.

## Change together

- Changing <X> means also changing <Y> because <reason>.

## Gotchas

- <A trap that wastes time or produces a wrong fix.>
