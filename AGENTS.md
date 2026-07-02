# AGENTS.md - Luminous

## Documentation Rules

After every code change, the following docs **MUST** be updated:

| Change type | Update target | Action |
|-------------|---------------|--------|
| Any frontend code change | `docs/migration-log/YYYY-MM-DD.md` | Append change entry |
| Current UI/data/runtime state change | `docs/Current_State.md` | Add/update completed item |
| Closing a TODO item | `docs/TODO.md` | Delete the line |
| Finishing a plan section | `plans/*.md` | Delete the entire section |
| Visible text or l10n change | `docs/Localization.md` | Sync update |

- Completed items are **deleted** outright — no `✅`, `DONE`, strikethrough, or any other marker.

## Stack

- Flutter
- Riverpod, not GetX
- GoRouter, not `Navigator.push(MaterialPageRoute(...))`
- Backend: Lucent

## Commands

```powershell
flutter analyze
flutter test
```

## Architecture

- `lib/core/` — shared design system, theme, feedback, network, widgets
- `lib/features/{feature}/` — per-feature vertical slices
  - `data/` — repositories, data sources, providers
  - `domain/` — entities, repository interfaces, services
  - `presentation/` — pages, widgets, controllers, providers

## State Management

- Riverpod `Notifier` + `NotifierProvider` for mutable state
- `@freezed` for immutable state classes
- `ref.watch()` for reading, `ref.read()` for callbacks

## Routing

- `GoRouter` with `StatefulShellRoute` for bottom tabs
- Tab roots: `/`, `/record`, `/medicine`, `/report`, `/mine`
- All create/detail/edit sub-pages are top-level full-screen routes outside the shell

## Design System

- `AppTypographyScale` — `displayXl` through `buttonLg`
- `AppThemeSurface` — semantic color tokens (canvas, hairline, body, mute, link, accent, etc.)
- `AppSpacingTokens`, `AppRadiusTokens`, `AppColorTokens` — spacing, radius, color constants
- During the Forui migration, touched UI should prefer Forui primitives directly instead of adding new `App*` wrapper aliases around base components.
- During the Forui migration, touched UI should prefer Forui-bundled Lucide icons (`FLucideIcons`) over Material icons. If a screen still uses `Icons.*`, treat that as migration debt and replace it unless Forui/Lucide truly has no reasonable equivalent.
- When adopting Forui widgets with controllers or hook-oriented state, evaluate the companion `forui_hooks` package before writing manual controller plumbing. Do not ignore it by default when the page already uses `flutter_hooks` / `hooks_riverpod`.
- When Forui styling needs to be customized beyond small inline overrides, check the bundled CLI first (`dart run forui --help`, `dart run forui style create --help`) and prefer generated style/theme scaffolds over hand-writing large style boilerplate. If you intentionally stay on stock Forui styling, say so explicitly.

## Testing

- Unit tests: `flutter test`
- Widget tests: `flutter test` with `WidgetTester`
- Integration tests: `integration_test/`
- Mock repositories follow `Mock*Repository` naming
- Test helpers in `test/helpers/`

## Data Layer

- Repository pattern: `domain/repositories/` defines interfaces, `data/repositories/` implements
- Generated API client: `packages/lucent_openapi/`
- Mock repositories for development/demo: suffix `Mock*Repository`

## L10n

- ARB files: `lib/l10n/app_en.arb`, `app_zh.arb`
- Generated: `lib/l10n/app_localizations*.dart`
- Run `flutter gen-l10n` after changing ARB files

## OpenAPI Client

- Source: `Lucent/docs/openapi.json`
- Regenerate: `dart run tool/regenerate_lucent_openapi.dart`
- Generated output: `packages/lucent_openapi/`
