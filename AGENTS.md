# AGENTS.md - Luminous

## Documentation Rules

After every code change, run `dart run tool/check_doc_coverage.dart --warning-only`.
It reads `docs/doc-map.yaml` and prints a per-rule report of which docs each touched code
area expects. The pre-commit hook runs the same tool in **blocking** mode: code files
staged but no `docs/` file staged → commit blocked. Bypass with `SKIP_DOC_CHECK=1`.

### Standing rules

- **Migration log**: append a dated entry to `docs/03-logs/migration-log/YYYY-MM-DD.md`.
- **Current state**: UI/data/runtime changes go into the relevant `docs/00-current/*.md`
  sub-file, not into `Current_State.md` (index only).
- **Closing a TODO**: delete the line from `docs/00-current/TODO.md`.
- **Finishing a plan**: delete the entire section from `plans/*.md`.
- **Visible text/l10n change**: sync `docs/02-reference/Localization.md`.
- Completed items are **deleted** outright — no markers.

## Stack

- Flutter, Riverpod (not GetX), GoRouter (not `Navigator.push(MaterialPageRoute(...))`).
- Backend: Lucent.

## Commands

```powershell
flutter analyze
flutter test
```

## Architecture

- `lib/core/` — shared design system, theme, feedback, network, widgets.
- `lib/features/{feature}/` — per-feature vertical slices:
  - `data/` — repositories, data sources, providers, mappers, utils
  - `domain/` — entities, repository interfaces, services, constants
  - `presentation/` — pages, widgets, controllers, providers, utils, models, services

## Barrel Exports

- `core/` cross-cutting barrels (`design.dart`, `api.dart`, `state_views.dart`) are the
  only legitimate barrel files — they aggregate design tokens, network symbols, and
  state views consumed by all features.
- No feature-level barrel files — cross-feature imports use full `package:` paths:
  - ❌ `export '../sections/ai_summary.dart';` in a `shared/sections.dart` barrel
  - ✅ `import 'package:luminous/features/report/presentation/widgets/sections/ai_summary.dart';`
- No cross-layer re-exports — a provider file must not `export` a repository or entity;
  consumers import from the correct layer directly.
- Platform conditional exports (`if (dart.library.io)`) are exempt.

## File Naming Rules

**Core principle**: File name = responsibility, not location.

1. **No type-suffix when the directory conveys the type** — `_provider`, `_page`, `_widget`,
   `_section`, `_data_source`, `_repository` are redundant.
   - ❌ `providers/session_provider.dart` → ✅ `providers/session.dart`
2. **Never use a pure type word** (`provider.dart`, `repository.dart`). Add a business word.
3. **No directory-name prefix** on files inside that directory.
   - ❌ `medicine/presentation/pages/medicine_page.dart` → ✅ `medicine/presentation/pages/page.dart`
4. **No `app_` prefix on `core/` files** — `app_` is not a business word.
5. **Keep business words and implementation qualifiers** (`session`, `lucent`, `remote`, `mock`).
6. **Class names are unaffected** — only file names change.
7. **Test files mirror source** with `_test.dart` suffix.

## State Management

- Riverpod `Notifier` + `NotifierProvider`; `@freezed` for immutable state.
- `ref.watch()` for reading, `ref.read()` for callbacks.

## Routing

- `GoRouter` with `StatefulShellRoute` for bottom tabs.
- Tab roots: `/`, `/record`, `/medicine`, `/report`, `/mine`.
- Sub-pages are top-level full-screen routes outside the shell.

## Design System

Forui-led theming. Details in `docs/02-reference/Design_System.md` and
`docs/02-reference/Forui_Reference.md`. Reference in `D:\25080\Documents\VSCodeProject\Lumos\forui-docs`

- `SemanticColor`, `Spacing`, `RadiusTokens`, `TypographyToken` — design tokens.
- Prefer Forui primitives directly. Don't add thin wrappers that only preset styles;
  existing wrappers (`AppBackButton`, `AppDivider`, etc.) are kept as-is.
- Prefer `FLucideIcons` over Material icons (treat `Icons.*` as migration debt).
- Evaluate `forui_hooks` before writing manual controller plumbing.
- Use Forui CLI (`dart run forui style create`) for custom styling scaffolds.

## Testing

- Unit/widget: `flutter test`. Integration: `integration_test/`.
- Mock repositories: `Mock*Repository`. Test helpers: `test/helpers/`.

## Data Layer

- Repository pattern: `domain/repositories/` interfaces, `data/repositories/` implements.
- Generated API client: `generated/lucent_api/`.

## L10n

**CRITICAL — ARB Editing Workflow**

The source of truth for l10n strings is the fragment files in `lib/l10n/src/`
(e.g., `record_zh.arb`, `mine_en.arb`). The main files `lib/l10n/app_zh.arb`
and `app_en.arb` are **generated** by merging these fragments — **never edit
them directly**.

Correct workflow when adding or modifying any user-visible string:

1. Edit the fragment file(s) in `lib/l10n/src/`
2. Run `dart scripts/arb_tools.dart merge` to regenerate `app_zh.arb` / `app_en.arb`
3. Run `flutter gen-l10n` to regenerate Dart localization code

Direct edits to `app_zh.arb` / `app_en.arb` **will be lost** on the next merge.

- Run `dart run tool/bootstrap_generated_sources.dart` after fresh clone or
  ARB / contract changes (includes the merge + gen-l10n + build_runner above).

## OpenAPI Client

- Source: `Lucent/docs/openapi.json`.
- Regenerate: `pnpm export:openapi` in Lucent → `dart run tool/bootstrap_generated_sources.dart` in Luminous.
- Tracked boundary: `generated/lucent_api/lib/api/**` except `**/*.g.dart`.
