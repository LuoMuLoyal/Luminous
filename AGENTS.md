# AGENTS.md - Luminous

## Documentation Rules

After every code change, the following docs **MUST** be updated:

- Any frontend code change
  - Update target: `docs/03-logs/migration-log/YYYY-MM-DD.md`
  - Action: Append change entry
- Current UI/data/runtime state change
  - Update target: `docs/00-current/Current_State.md`
  - Action: Add/update completed item
- Closing a TODO item
  - Update target: `docs/00-current/TODO.md`
  - Action: Delete the line
- Finishing a plan section
  - Update target: `plans/*.md`
  - Action: Delete the entire section
- Visible text or l10n change
  - Update target: `docs/02-reference/Localization.md`
  - Action: Sync update

Completed items are **deleted** outright — no `✅`, `DONE`, strikethrough, or any other marker.

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

## File Naming Rules

### Core Principle: File Name = Responsibility, Not Location

```
Directory = namespace (tells you the type/layer)
File name = specific responsibility (tells you WHAT it does, not WHERE it is)
```

### Quality Hierarchy

| Level | Example (in `providers/`) | Problem |
|---|---|---|
| **Worst** | `provider.dart` | Pure type word, zero business meaning |
| **Worst** | `providers.dart` | Same, pluralized |
| Bad | `auth_provider.dart` | Business word too vague + type suffix redundant |
| Redundant | `session_provider.dart` | Good business word, but `_provider` suffix repeats directory |
| **Best** | `session.dart` | Clear responsibility, no redundant type word |

### Rules

1. **No type-suffix when the directory already conveys the type.** The suffixes `_provider`,
   `_page`, `_widget`, `_section`, `_data_source`, `_repository`, `_controller` (when inside
   `controllers/` or `providers/`) are redundant — the directory already says what kind of file it
   is.
   - ❌ `providers/session_provider.dart` → ✅ `providers/session.dart`
   - ❌ `pages/login_page.dart` → ✅ `pages/login.dart`
   - ❌ `widgets/sections/summary_section.dart` → ✅ `widgets/sections/summary.dart`
   - ❌ `datasources/suggestion_remote_data_source.dart` → ✅ `datasources/suggestion_remote.dart`
   - ❌ `repositories/lucent_repository.dart` → ✅ `repositories/lucent.dart`

2. **Never use a pure type word as a file name.** `provider.dart`, `providers.dart`,
   `repository.dart`, `controller.dart` carry zero responsibility information. Always include a
   business word.
   - ❌ `providers/provider.dart` → ✅ `providers/medicine_search.dart`
   - ❌ `domain/repositories/repository.dart` → ✅ `domain/repositories/dashboard.dart`

3. **No directory-name prefix on files.** A file inside `lib/features/medicine/` must not start
   with `medicine_`; the directory already provides that context. Same for `wechat/` subdirectory:
   files inside `data/datasources/wechat/` must not start with `wechat_`.
   - ❌ `medicine/presentation/pages/medicine_page.dart` → ✅ `medicine/presentation/pages/page.dart`
   - ❌ `datasources/wechat/wechat_mobile_auth_client.dart` → ✅ `datasources/wechat/mobile_auth_client.dart`

4. **No `app_` prefix on `core/` files.** `app_` is not a business word — everything in the app
   is part of the app. Files in `lib/core/` must not start with `app_`.
   - ❌ `core/database/app_database.dart` → ✅ `core/database/database.dart`
   - ❌ `core/logger/app_logger.dart` → ✅ `core/logger/logger.dart`
   - ❌ `core/feedback/app_toast.dart` → ✅ `core/feedback/toast.dart`

5. **Keep business words.** `session`, `login`, `dashboard`, `suggestion`, `risk_check` describe
   what the file does — these stay. Only strip the redundant type suffix.
   - `session_provider.dart` → `session.dart` (keep `session`, drop `_provider`)
   - `risk_check_provider.dart` → `risk_check.dart` (keep `risk_check`, drop `_provider`)

6. **Implementation qualifiers are not type words.** `lucent`, `mock`, `remote`, `cached` are
   implementation qualifiers that distinguish variants — keep them.
   - `repositories/lucent_repository.dart` → `repositories/lucent.dart` (keep `lucent`, drop `_repository`)
   - `datasources/dose_log_remote_data_source.dart` → `datasources/dose_log_remote.dart` (keep `remote`, drop `_data_source`)

7. **`_settings_page` is double redundancy.** In `settings/presentation/pages/`, both `_settings`
   (repeats the feature directory) and `_page` (repeats the pages directory) are redundant.
   - ❌ `pages/about_settings_page.dart` → ✅ `pages/about.dart`
   - ❌ `pages/theme_settings_page.dart` → ✅ `pages/theme.dart`

8. **Class names are unaffected.** This rule covers file names only. Class names like
   `AppSpacingTokens` or `LucentDioClient` retain their prefixes for clarity at the call site.

9. **Scattered files belong in subdirectories.** Do not place files directly in
   `presentation/widgets/` or `presentation/` — use `shared/`, `sections/`, `dialogs/`, `views/`,
   etc.

10. **Test files mirror source names.** `test/` paths and file names follow the corresponding
    `lib/` file, with a `_test.dart` suffix. Example: `lib/core/network/dio_client.dart` →
    `test/core/network/dio_client_test.dart`.

### Decision Flow

```
File name has a business word (not just a type word)?
├─ No (e.g. provider.dart, repository.dart) → MUST rename, add a business word
└─ Yes (e.g. session_provider.dart)
   └─ Has a type-suffix that repeats the directory?
      ├─ Yes (e.g. _provider, _page, _section) → Strip the type suffix
      └─ No (e.g. session.dart) → Already optimal, do not change
```

### Reference

The naming cleanup has been completed. See `docs/03-logs/migration-log/2026-07-12.md` for the
migration record.

## State Management

- Riverpod `Notifier` + `NotifierProvider` for mutable state
- `@freezed` for immutable state classes
- `ref.watch()` for reading, `ref.read()` for callbacks

## Routing

- `GoRouter` with `StatefulShellRoute` for bottom tabs
- Tab roots: `/`, `/record`, `/medicine`, `/report`, `/mine`
- All create/detail/edit sub-pages are top-level full-screen routes outside the shell

## Design System

- Root theming is Forui-led: `lib/theme/theme.dart` owns the app theme-family catalog and maps `theme.family` to stock Forui `FThemes.*` light/dark touch themes; `lib/app/app.dart` derives `ThemeData` from the selected family and injects `FTheme` at the app root.
- `AppColors` (`lib/core/design/app_colors.dart`) — semantic color enum used by data/domain layers. Widgets resolve it via `AppColors.resolve(context.theme.colors)`.
- `AppSpacingTokens` — `level1` through `level12` spacing scale retained as the project layout vocabulary because Forui has no generic spacing scale.
- `AppRadiusTokens` — `level0` through `level9` plus `levelFull`, mapped to Forui’s `FBorderRadius` scale.
- `AppTypographyTokens` (`lib/core/design/app_typography_tokens.dart`) — `level1` through `level10` mapped to Forui’s `FTypeface` scale (`xs3` through `xl4`). Widgets resolve a token via `AppTypographyToken.levelN.body(context)` or `.display(context)`.
- `AppLayoutTokens`, `AppBreakpoints`, `AppResponsiveSizing` — layout helpers, not visual tokens.
- Legacy token aliases (`AppThemeSurface`, `AppSectionSurface`, `AppColorTokens`, `AppShadowTokens`) and legacy interaction aliases (`AppInkWell`, `AppDialog`) have been removed from runtime `lib/`.
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
- Generated API client: `generated/lucent_api/`
- Mock repositories for development/demo: suffix `Mock*Repository`

## L10n

- ARB files: `lib/l10n/app_en.arb`, `app_zh.arb`
- Generated: `lib/l10n/app_localizations*.dart`
- Generated files stay ignored; run `dart run tool/bootstrap_generated_sources.dart` after
  changing ARB files or before analyze/test on a fresh clone

## OpenAPI Client

- Source: local export `Lucent/docs/openapi.json`
- Regenerate: run `pnpm export:openapi` in `Lucent`, then
  `dart run tool/bootstrap_generated_sources.dart` in `Luminous`
- Tracked generated client boundary: `generated/lucent_api/lib/api/**` except `**/*.g.dart`
- Ignored local-only file: `generated/lucent_api/pubspec.lock`

## Forui Reference

- **项目速查**：`docs/02-reference/Forui_Reference.md` — 项目实际用法、常用组件示例、应避免的习惯。
- **完整机器可读文档**：`forui-docs/llms-full.txt` — 纯 Markdown，聚合全部官方文档和代码示例，喂给 LLM 的首选。
- **文档索引**：`forui-docs/llms.txt` — 快速看有哪些页面。
- **官方站**：https://forui.dev/docs
- **API 文档**：https://pub.dev/documentation/forui
- **源码参考**：`Pub/Cache/hosted/pub.dev/forui-0.23.0/lib/src/widgets/`（查 API 签名和默认样式最准确）。
