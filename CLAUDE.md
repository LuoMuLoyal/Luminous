# Luminous Claude Entry

`AGENTS.md` is the authoritative source of project rules. This file is a Claude-focused
quick reference — read `AGENTS.md` first for the full rules.

## Read First

1. `AGENTS.md`
2. `README.md`
3. `docs/README.md`
4. `docs/02-reference/AI_Development_Workflow.md`

## Stack

Flutter + Riverpod (not GetX) + GoRouter (not `Navigator.push(MaterialPageRoute(...))`) +
Forui (2026-07 全量从 Material Design 迁移完成)。Backend: Lucent。

## Common Commands

```bash
flutter pub get
flutter analyze
flutter test                                              # all unit/widget tests
flutter test test/path/to_test.dart                       # single test file
flutter test integration_test                             # all E2E
flutter test integration_test/<scenario>_e2e_test.dart    # one E2E scenario
flutter gen-l10n                                          # after ARB changes
dart scripts/arb_tools.dart merge                         # merge fragment ARBs before gen-l10n
cd generated/lucent_api && dart run build_runner build    # regenerate API client
dart run tool/check_doc_coverage.dart --warning-only      # after EVERY code change
dart run tool/bootstrap_generated_sources.dart            # after clone / ARB / contract change
```

While iterating use the narrow command; run `flutter analyze` + `flutter test` before
finishing.

## Documentation Rules (Non-Negotiable)

After **every** code change, run:

```bash
dart run tool/check_doc_coverage.dart --warning-only
```

It reads `docs/doc-map.yaml` and prints a per-rule report of which docs each touched code
area expects. The pre-commit hook runs the same tool in **blocking** mode: code files
staged but no `docs/` file staged → commit blocked. Bypass with `SKIP_DOC_CHECK=1`.

### Standing rules

- **Migration log**: append a dated entry to `docs/03-logs/migration-log/YYYY-MM-DD.md`.
- **Current state**: UI/data/runtime changes go into the relevant `docs/00-current/*.md`
  sub-file, not into `Current_State.md` (index only).
- **Visible text/l10n change**: sync `docs/02-reference/Localization.md`.
- **Closing a TODO**: delete the line from `docs/00-current/TODO.md`.
- **Finishing a plan**: delete the entire section from `plans/*.md`.
- Completed items are **deleted** outright — no `✅`, `DONE`, strikethrough, or any
  other marker.

## Architecture

- `lib/core/` — shared design system, theme, feedback, network, widgets.
- `lib/features/{feature}/` — per-feature vertical slices:
  - `data/` — repositories, data sources, providers
  - `domain/` — entities, repository interfaces, services
  - `presentation/` — pages, widgets, controllers, providers
- New code goes only under `lib/features/`, `lib/core/`, or `lib/shared/`. **Do not**
  add to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`, `lib/components/`.
- The five tabs are `today / record / medicine / report / mine`.

## State Management

- Riverpod `Notifier` + `NotifierProvider`; `@freezed` for immutable state.
- `ref.watch()` for reading, `ref.read()` for callbacks.
- Prefer `ref.watch(provider.select(...))` to slice state and avoid unnecessary rebuilds.

## Routing

- `GoRouter` with `StatefulShellRoute` for bottom tabs. Use typed routes
  (`@TypedGoRoute` + `go_router_builder`).
- Tab roots: `/`, `/record`, `/medicine`, `/report`, `/mine`.
- Sub-pages are top-level full-screen routes outside the shell.

## Design System

Forui-led theming. Details in `docs/02-reference/Design_System.md` and
`docs/02-reference/Forui_Reference.md`.

- `SemanticColor`, `Spacing`, `RadiusTokens`, `TypographyToken`, `DurationTokens`,
  `Breakpoints` — design tokens (via barrel `lib/core/design/design.dart`).
- Prefer Forui primitives directly over new `App*` wrappers.
- Prefer `FLucideIcons` over Material icons (treat `Icons.*` as migration debt).
- User-visible text goes through ARB + `flutter gen-l10n` — no hardcoded strings.
- Page-level error states use `AppStateErrorView` / `AppStateMessageView`, never
  hand-written error views.
- Loading states use shimmer skeletons (`AppSkeletonShimmer`), never
  `CircularProgressIndicator` or plain colored blocks.
- Lightweight feedback uses `AppToast`, not page-level `SnackBar`.

## L10n

- ARB source fragments: `lib/l10n/src/{fragment}_{locale}.arb` (10 fragments × 2 locales).
- Merged ARB (generated, gitignored): `lib/l10n/app_zh.arb`, `app_en.arb`.
- Workflow: edit fragment ARB → `dart scripts/arb_tools.dart merge` →
  `flutter gen-l10n`.
- `docs/02-reference/Localization.md` records ownership rules per ARB fragment —
  update it when adding new visible strings.

## OpenAPI Client

- Source: `Lucent/docs/openapi.json`.
- Regenerate: `pnpm export:openapi` in Lucent →
  `cd generated/lucent_api && dart run build_runner build` in Luminous.
- Tracked boundary: `generated/lucent_api/lib/api/**` except `**/*.g.dart`.

## Non-Negotiable Boundaries

- This is a Flutter + Riverpod + GoRouter + Forui project.
- Lucent owns shipping assistant/report AI backends.
- `lib/core/ai/` is an experiment seam, not the place to replace current Lucent
  production flows by default.
- Fix the requested problem directly — do not loosen TS/ESLint rules or refactor nearby
  working code.
- Do not touch unrelated dirty or untracked files in sibling projects.
