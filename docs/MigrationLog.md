# Luminous Migration Log

Last updated: 2026-05-31

Records changes after the full reset only. Pre-reset history: `MigrationLog_Archive_PreReset.md`.

## 2026-05-30

### Today Mock UI Foundation

- Rebuilt `Today` into a mobile-first dashboard that visually tracks the design concept: greeting hero, water count card, medication reminder, health summary, meal suggestion, environment signals, and Lumi advice.
- Added `today` feature-first domain entities plus a `TodayRepository` interface so the page now depends on a repository boundary instead of embedding page-local mock state.
- Added `MockTodayRepository` and a Riverpod `todayDashboardProvider`; later API integration can replace the repository implementation without rewriting the page structure.
- Split Today UI into dedicated widgets under `lib/features/today/presentation/widgets/` and replaced the old shell-card placeholder content.
- Added zh/en localization strings for the full Today dashboard and a widget test covering the core Today sections.

## 2026-05-31

### Record Mock Dashboard Foundation

- Replaced the `record` tab placeholder with a concept-aligned mock dashboard: mobile stacks week strip, quick record, day summary, timeline, trends, and specialist health bag; desktop expands into calendar/filter left rail, central summary/timeline, and trend/new-entry right rail.
- Added `record` feature-first domain entities, repository contract, mock repository, and Riverpod provider so later Lucent-backed record APIs can replace the data source without rewriting the page structure.
- Added a shared `AppImagePlaceholder` under `lib/core/widgets/` and used it for record meal imagery placeholders instead of adding fixed raster assets.
- Wired `ShellPage` to render `RecordPage`, added zh/en localization strings for record copy and toast feedback, and added `test/record_page_test.dart` for mobile and desktop layout coverage.
- Kept record interactions mock-only: clickable dates, filters, timeline entries, trend cards, and create actions show `AppToast` hints.
- Reworked the desktop/web shell navigation from a narrow `NavigationRail` into a wider grouped left sidebar: the top keeps the same five tabs as mobile, the bottom adds separate `settings / help` actions, and the content workspace now sits inside a larger framed desktop container.
- Flattened the placeholder experience for `mine / more`: those pages now render a single placeholder surface directly inside the page scaffold instead of nesting a placeholder card inside another section card.

### Mine Mock Dashboard Foundation

- Replaced the `mine` tab placeholder with a concept-driven mock dashboard under `lib/features/mine/`, following the same feature-first layering used by `record` and `medicine`: `domain/entities`, `domain/repositories`, `data/repositories`, `presentation/providers`, and `presentation/widgets`.
- Shaped the page around the approved Mine concept image: account header, profile completion, health-context summary, profile entry grid, health plan center, report/privacy cards, and a desktop-only right rail for profile status, onboarding progress, quick entries, and settings.
- Kept the data boundary mock-only for now: `mineDashboardProvider` reads from `MockMineRepository`, so later Lucent health-context and account/profile APIs can replace the repository without rewriting the page structure.
- Added zh/en localization coverage for the Mine mock page and a dedicated widget test covering mobile core sections plus desktop right-rail panels.

### More Mock Utility Workspace Foundation

- Replaced the `more` tab placeholder with a concept-driven mock workspace under `lib/features/more/`, matching the same feature-first layering already used by `mine`, `record`, and `medicine`: `domain/entities`, `domain/repositories`, `data/repositories`, `presentation/providers`, and split `presentation/widgets`.
- Shaped the page around the approved More concept image: emergency help, family health, AI recognition tools, smart device management, knowledge/services, and environment reminders on mobile; desktop adds a right rail for environment status, recent activity, quick entries, and care guidance.
- Kept the data boundary mock-only for now: `moreDashboardProvider` reads from `MockMoreRepository`, so later emergency, environment, device, and utility APIs can replace the repository without rewriting the page structure.
- Added zh/en localization coverage for the More mock page and a dedicated widget test covering mobile core sections plus desktop side panels.

### Today Concept Alignment

- Refined the Today tab against the 2026-05-31 concept image: mobile keeps the compact health feed, while desktop now expands into a wide dashboard instead of being capped at phone width.
- Split Today visual primitives into `today_components.dart` so the panel, section header, text action, water ring, mascot, meal illustration, environment chip, and health metric tile can be reused by later Today-adjacent modules.
- Added `lib/core/widgets/app_state_views.dart` for reusable loading skeleton and error/empty state surfaces; Today now uses it for loading/error and has an empty state component ready for real data integration.
- Expanded zh/en Today copy for the concept-aligned hero, status labels, actions, and empty state, then regenerated localizations.
- Extended `test/today_page_test.dart` to cover both the existing mobile section flow and the new desktop dashboard branch.
- Simplified the Today visual treatment to match the plainer medicine workspace style: removed Today entrance/stagger animations and background glow orbs, fixed the hero double-surface shadow, replaced unavailable hero/meal artwork with localized image placeholders, and switched health/environment summaries to single surfaces separated by dividers.

### Medicine Mock Workspace Foundation

- Replaced the `medicine` tab placeholder with a mobile-first mock medication workspace that surfaces photo recognition, barcode scan, manual search, today's dosing plan, refill risk, interaction alerts, and a clear safety-boundary block.
- Kept this step UI-first: no real Lucent medicine API calls yet, but the page structure now matches the intended medication intake and safety workflow.
- Reworked the `medicine` feature into the repo's feature-first layering instead of keeping one oversized page file:
  `domain/entities` for workspace models, `domain/repositories` for the repository contract, `data/repositories` for mock data, `presentation/providers` for Riverpod state, and `presentation/widgets` for the split UI surface.
- Wired `ShellPage` to render the real `MedicinePage` instead of a placeholder tab label.
- Added zh/en localization strings for the medicine workspace and a widget test covering the core mock sections.
- Tightened the medicine UI toward the five-tab concept image: the hero now foregrounds only `today doses` and `on-time adherence`, click feedback now uses `core/feedback/AppToast`, extra nested boxes were reduced, and the page radius treatment was pushed larger to better match the current visual direction.
- Added `/medicine/search` as a source-aware mock search workspace under the standalone `lib/features/search/` feature, with domain/repository/provider/data boundaries, zh/en text, mobile search flow, desktop result/preview layout, and a widget test. Real Lucent search, detail, recognition, and add-to-drugbox calls remain intentionally unwired until the UI stabilizes.
- Refined the medicine tab against the 2026-05-31 concept image: mobile keeps a single stacked feed, desktop uses main workspace plus right-side safety rail, plan cards now show nested dose rows and stock warnings, safety cards split refill / interaction / other reminders, and the safety-boundary block uses a calmer green reference-only treatment.
- Expanded the mock medicine contract with dose slots, alert details, a low-stock warning, and localized click-feedback copy while keeping Lucent API calls intentionally mocked.

### Auth Contract Sync

- Regenerated `packages/lucent_openapi` after Lucent removed `currentEmail` from `ChangeEmailDto`.
- `ChangeEmailDto` now sends only `newEmail` and `code`; new-email ownership is verified by Lucent.
- `RegisterDto` now sends `email`, `password`, and register-scene `code`; Lucent verifies email before creating the account.
- Added account/password-reset logic providers for profile update, email verification, email change, password change, password reset, and account deletion.
- Fixed Lucent token injection to use the stored access token even when generated OpenAPI `secure` metadata is empty.
- Migrated auth entities and form/account/session states to `freezed` generated `copyWith` / equality / JSON support where needed.

### Auth UI Foundation

- Added shared auth form components for headers, status messages, code rows, and footer actions.
- Refactored Login/Register to reuse shared auth UI components.
- Added Forgot Password page and wired `/forgot-password` from Login.
- Added Change Email page and registered `/account/change-email` for the upcoming account settings flow.
- Added zh/en localization strings for the new auth pages and actions.
- Tuned Login footer links into a lightweight left/right action row and aligned code-send buttons with input height.
- Used `flutter_animate` for restrained auth form entrance motion and login-mode field transitions.
- Restored the compact Login narrative panel and replaced the code-send button with a custom input-matched control.
- Added registration email-code UI and confirm-password validation on Forgot Password.
- Split code-sending loading state from submit loading state so send-code requests no longer spin the submit button.
- Added localized toast prompts for empty auth form submissions.
- Rebuilt auth text fields and code-send buttons on one shared fixed-height control frame so height, border, and radius stay aligned.
- Added auth widget regression tests for code-row height and independent loading indicators.

### Theme Foundation

- Added a Riverpod-backed app theme preference controller for `system / light / dark`.
- Persisted the selected theme mode in `SharedPreferences` under `theme.mode`.
- Wired `LuminousApp` to consume the persisted theme preference instead of hardcoding `ThemeMode.system`.
- Added theme preference tests for default fallback, restore, and persistence.
- Reworked shared toast feedback into a custom rounded Flutter overlay with lower-saturation theme-aware colors.

### Reset Baseline

- Kept five-tab shell: `today / record / medicine / mine / more`.
- Removed old business pages, old utilities, old infra, and legacy backend coupling.
- Kept minimal runnable Flutter mainline.

### OpenAPI Client

- Generated Lucent client into `packages/lucent_openapi/`.
- Added wrapper/export under `lib/core/network/`.
- Regenerated Lucent client after Lucent added medicines APIs and cache-bypass header support; `LucentDioClient` now exposes `medicinesApi` plus a `medicinesHeaders(bypassCache: true)` helper for one-off fresh medicine reads.

### Design Tokens

- Added color, type, radius, spacing, shadow, layout, and breakpoint tokens.
- Wired tokens into shell, Today, placeholders, and theme extensions.

### i18n

- Added `l10n.yaml`, zh/en ARB files, and generated localizations.
- Moved app title, tabs, Today, placeholders, Login, Register, and AuthShell text to l10n.
- Expanded l10n coverage to the medicine workspace mock UI.

### Network

- Added base URL, envelope, result code, API exception, session store, and providers.
- Added token injection, `Accept-Language`, `401002` refresh/retry, and Dio error unwrapping.

### Auth UI

- Added auth domain/session mapping, remote datasource, providers, LoginPage, RegisterPage, and AuthShell.
- Registered `/login` and `/register`.
- Added login/register/logout entry points from Today.

### Responsive Shell

- Added `ResponsiveContentFrame` and `PageScaffoldShell`.
- Mobile uses bottom navigation; desktop/web uses navigation rail.
- Today and four placeholder tabs use the shared page shell.

### Lucent Alignment

- Aligned token-expired handling with `401002`.
- Lucent fallback language is `en`.
- API docs now define `Accept-Language`.

### Security / E2E Fixes

- Lucent login now requires exactly one credential: `password` or `code`.
- Soft-deleted users are excluded from default lookups.
- Fixed JWT `sub` / `subject` duplication.
- Fixed i18n type output for test/dist.
- `pnpm test:e2e` passes with Docker PostgreSQL running.

### Docs

- Added `docs/README.md` as the frontend doc map.
- Marked reset/history docs as reference only.
- Unified API contract path to `../Lucent/docs/public/api-contract.md`.

## Verified

```bash
flutter gen-l10n
flutter analyze
flutter test
flutter test test/app_theme_controller_test.dart test/widget_test.dart test/auth_widgets_test.dart
flutter test test/today_page_test.dart
flutter test test/medicine_page_test.dart

cd ../Lucent
pnpm build
pnpm test
pnpm test:e2e
```

## Next

1. Replace Today mock repository data with Lucent-backed sources when the API contract is ready.
2. Upgrade `record / mine / more` skeletons.
3. Replace medicine mock repository data with Lucent-backed search, detail, recognition, and reminder flows.
4. Add theme selection UI under Mine/settings and later expand palette variants.
