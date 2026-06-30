# ADR-0002: GoRouter Navigation

- **Status**: accepted
- **Date**: 2026-05-30
- **Deciders**: LuoMuLoyal

## Context

The app has a five-tab bottom navigation (today / record / medicine / report / mine) with sub-pages that should hide the tab bar. The legacy codebase used `Navigator.push(MaterialPageRoute(...))` ad-hoc, which gave no control over deep linking, URL-based navigation, or tab state preservation.

## Decision

Use `go_router` with `StatefulShellRoute` for the five main tabs and top-level `GoRoute`s for all sub-pages. Sub-pages are placed outside the shell so entering them hides the bottom navigation.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| GoRouter + StatefulShellRoute | Declarative routing, URL-based deep links, built-in tab state preservation, redirect guards | More upfront setup than ad-hoc push |
| Navigator 2.0 (raw) | Full flexibility | Extremely verbose, no built-in shell support |
| Navigator 1.0 (push/pop) | Simple for small apps | No deep links, tab state not preserved, URL bar not synced |
| auto_route | Code generation, type-safe | Another code-gen dependency, less community adoption than go_router |

## Consequences

- Five `ShellBranch`es model the visible tabs; no hidden branches.
- Sub-pages (`/record/create`, `/settings/*`, `/assistant`, etc.) are outside the shell → entering them hides bottom nav.
- `context.push()` for sub-page navigation preserves tab state.
- `context.go()` for auth redirects and tab switching.
- `AppBackButton` uses `context.pop()` with `/today` fallback.
- Deep linking works via URL paths (e.g., `/record/create?kind=sleep`).
