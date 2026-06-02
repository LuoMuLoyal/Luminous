# Luminous Migration Log

Last updated: 2026-05-31

Records changes after the full reset only. Pre-reset history: `MigrationLog_Archive_PreReset.md`.

## 2026-06-02

### Settings/API Wiring Cleanup

- Mine page header now removes the leftover descriptive line and uses real session data for the account display name, so profile nickname/email changes made through Lucent-backed account settings show up immediately in Mine.
- Notification settings now keep local preference persistence but also read/request real system notification permission status through a dedicated settings-side permission service instead of pretending all notification behavior is purely local UI state.
- Notification settings widget behavior was tightened so row taps toggle once consistently, without double-triggering because of nested switch gestures.
- Added test-side permission-service fallback injection so settings persistence tests stay deterministic even when local notification plugins are unavailable in widget-test runtime.

### Settings Header Decoration Cleanup

- Removed the unexpected text decoration from shared centered child-page headers so settings-related titles no longer show the yellow underline on web/desktop rendering.

### Settings Child Pages + Locale Persistence

- Replaced the remaining placeholder settings entries with real child pages for `语言 / Language`, `通知设置 / Notifications`, and `更多设置 / More settings`.
- App locale now persists in `SharedPreferences`, drives both Flutter UI locale and Lucent `Accept-Language`, and is configurable from the new language settings page.
- Notification settings now persist three local toggles for reminder/alert preferences, and more settings now exposes cache clearing, defaults reset, and open-source licenses.
- Added widget coverage for settings child-page routing, language switching persistence, notification toggle persistence, and kept app startup restore coverage green.

### Standalone Settings Page

- Added a dedicated `/settings` page so theme, language, notification, and account-entry settings no longer render inline under Mine.
- Mine header settings action and the desktop sidebar settings action now route to the real settings page instead of showing a placeholder toast.
- The new settings page keeps the current Luminous surface style, uses grouped list sections inspired by the referenced settings layout, and ends with a standalone footer sign-out action.
- Added zh/en localization for the settings-page description and widget coverage for Mine -> Settings, Settings -> Account, and Settings footer logout routing.

### Settings Page Cleanup

- Removed low-value explanatory copy from the standalone settings page and from the currently linked account/settings subpages.
- Settings, account settings, and change-email pages now use a standard child-page header: left back arrow plus centered title.
- Kept spacing, radius, and section sizing aligned with the existing app surfaces instead of introducing a separate settings-page style.

### Auth Page Copy Cleanup

- Removed narrative, badge, and explanatory header copy from the auth entry pages that do not need it in normal app flow.
- Simplified login, register, and forgot-password pages to standard centered-title form pages instead of hybrid narrative panels.
- Project agent rules now explicitly forbid default explanatory/marketing-style page copy and require standard back-arrow child-page headers for in-app secondary pages.

### Auth Test Coverage Expansion

- Added widget tests for login, register, forgot-password, and change-email pages to cover verification-code sending, submit flows, and session updates.
- Expanded account-settings widget coverage to include profile save, password change, and account deletion paths in addition to the existing route checks.
- Re-ran auth-related widget suites plus static analysis to confirm the current auth flow remains green after the UI cleanup pass.

### Auth Startup Restore + Mine Logout Wiring

- `LuminousApp` now restores `authSessionProvider` once during app startup, so persisted Lucent sessions can recover before the user re-enters auth flows manually.
- `MinePage` now exposes a real signed-in logout action in the header; tapping it calls `authSessionProvider.logout()` and routes back to `/login`.
- `MineHeaderActionChip` now supports a disabled state so the logout action cannot be triggered repeatedly while auth state is already loading.
- Added widget coverage for startup `restore()` execution and for the Mine logout action wiring.

### Mine Account Entry + Auth Feedback Cleanup

- Lucent-backed Mine account headers now read the current session email from `authSessionProvider`, instead of rendering the signed-in state without an email address.
- Mine settings `账号与安全 / Account and security` now routes to the real `/account` auth account-settings page instead of showing a placeholder toast.
- Auth success feedback on forgot-password and change-email now uses shared `AppToast`, matching the project rule against page-local `SnackBar` prompts.
- Added tests for the Mine account-settings route and the Lucent Mine account email mapping.

### Auth Account Settings Page

- Added `/account` as a real account-settings page under the auth feature instead of leaving `authAccountProvider` half-wired behind provider-only methods.
- The new page now fronts Lucent-backed `updateProfile`, `changePassword`, and `deleteAccount`, while reusing the existing `/account/change-email` page for email changes.
- `AuthShell` now supports scrollable long-form pages and an optional form-animation switch so auth pages remain usable on mobile and testable without pending animation timers.
- Regenerated `gen-l10n` output for the new account-settings copy and added a dedicated widget test for the account page.

### OpenAPI Regeneration Check

- Re-ran Lucent `export:openapi` and regenerated `packages/lucent_openapi`.
- Confirmed this auth alignment pass did not require business-layer network wrapper changes; the only recurring post-generation fix remains restoring `packages/lucent_openapi/pubspec.yaml` to the app SDK / `json_annotation` constraints before `build_runner`.

## 2026-06-01

### Mine - Signed-Out Static View

- `mineDashboardProvider` now checks `authSessionProvider` first; when signed out it returns a local static Mine dashboard instead of fetching Lucent health-context data.
- `MinePage` no longer shows the loading skeleton while signed out, so the page stops repeatedly hitting the backend in the signed-out state.
- Added a signed-out notice card at the top of Mine with a direct login action, while keeping the rest of the page on the existing static layout.
- Added zh/en localization keys for signed-out Mine copy and a widget test that asserts signed-out Mine renders without fetching health-context data.

## 2026-05-30

### Today Mock UI Foundation

- Rebuilt `Today` into a mobile-first dashboard that visually tracks the design concept: greeting hero, water count card, medication reminder, health summary, meal suggestion, environment signals, and Lumi advice.
- Added `today` feature-first domain entities plus a `TodayRepository` interface so the page now depends on a repository boundary instead of embedding page-local mock state.
- Added `MockTodayRepository` and a Riverpod `todayDashboardProvider`; later API integration can replace the repository implementation without rewriting the page structure.
- Split Today UI into dedicated widgets under `lib/features/today/presentation/widgets/` and replaced the old shell-card placeholder content.
- Added zh/en localization strings for the full Today dashboard and a widget test covering the core Today sections.

## 2026-06-01

### Search - Lucent-Backed Medicine Search

- Regenerated OpenAPI client (Lucent `medicinesApi` updated).
- Created `lib/features/search/data/datasources/medicine_search_remote_data_source.dart` — wraps `MedicinesApi.search` and `MedicinesApi.getDetail`.
- Created `lib/features/search/data/mappers/medicine_search_mapper.dart` — converts `MedicineSearchItemDto` to `MedicineSearchResult`.
- Created `lib/features/search/data/repositories/lucent_medicine_search_repository.dart` — Lucent-backed `MedicineSearchRepository` implementation with `search()` / `fetchDetail()`.
- Refactored `MedicineSearchRepository` interface from one-shot `fetchDashboard()` to query-driven `search()` / `fetchDetail()`.
- Refactored `medicineSearchProvider` from `FutureProvider<MedicineSearchDashboard>` to `MedicineSearchNotifier` (a `Notifier<MedicineSearchState>`) with methods: `updateQuery`, `switchSource`, `selectResult`, `retry`.
- Rewrote `SearchPage` and `MedicineSearchView` to use new `MedicineSearchState` + interactive callbacks.
- Rewrote `_SearchInput` from static display to real `TextField` with controller.
- `_SourceSwitch` now calls real `onChanged` callback instead of mock toast.
- `_SearchResultTile` accepts `onTap` callback for result selection.
- `_PreviewPanel` now driven by `state.detailPreview` instead of `dashboard.safetyPreview`.
- Removed unused widgets: `_ReferenceNotice`, `_ResultsHeader`, `_SafetyPreviewCard`, `_ChecklistCard`.
- Added ARB keys: `medicineSearchPreviewClinical`, `medicineSearchPreviewSafety`, `medicineSearchPreviewEmpty`.
- Moved old `MockMedicineSearchRepository` to `data/repositories/mock/`.
- Rewrote `search_page_test.dart` to mock `medicineSearchRepositoryProvider` instead of the old `FutureProvider`.

#

## 增加 5 秒请求超时

- Today、Mine、More、Record、Search 五个页面的 dashboard provider 添加 .timeout(Duration(seconds: 5))，超时后触发 error 显示 AppStateErrorView。

## 2026-06-01

### 统一页面错误视图 + 修复居中

- 创建 AppStateErrorView 封装组件（SizedBox.expand + Center + SingleChildScrollView + AppStateMessageView），替代各页面手写的 ErrorView。
- Today、Record、Mine、More、Search 五个页面的 ErrorView 全部替换为 AppStateErrorView，错误卡片居中展示。
- 修复 Mine 页面错误视图不居中的问题。
- 添加 Search 缺失的 ARB key medicineSearchErrorDescription。

## 2026-06-01

### 统一页面骨架屏

- Record: _RecordLoadingView 从纯色块改为 Shimmer 骨架屏，与 mine/more/medicine 保持一致。
- Search: MedicineSearchLoadingView 从 CircularProgressIndicator 改为 Shimmer 骨架屏。
- 新页面 loading 时统一使用 Shimmer.fromColors + _SkeletonBlock 模式，优先复用 AppStateSkeletonView（非嵌套滚动场景）或直接 Column + SizedBox 块（嵌套滚动场景）。

## 2026-06-01

### 主题模式选择 UI

- 创建 ThemeModeSheet 底部弹窗，system/light/dark 三个选项。
- 将 Mine 设置中的主题行从 toast 改为弹出 sheet，写入 appThemeControllerProvider。
- 在 ARB 中添加 mineThemeModeSystem/Light/Dark 三个文案。

## 2026-06-01

### 网络层暴露 UserHealthContextApi

### 构建 health-context 共享数据层

- 创建 health_context feature 目录结构，包含 6 个 freezed entity、repository 接口、remote datasource、mapper、Lucent repository 实现和 provider 层。

### Mine 页面接入真实 health-context 数据

- 创建 LucentMineRepository，从 healthContextSnapshotProvider 读取数据并拼装 MineDashboard，后端不覆盖的字段保留 mock 回退。
- 切换 mineRepositoryProvider 实现为 LucentMineRepository。
- 更新 mine_page_test 和 widget_test，注入 mock healthContextSnapshotProvider。

### 网络层暴露 UserHealthContextApi

- 重新生成 Lucent OpenAPI 客户端，修复 SDK 约束。
- 在 LucentDioClient 添加 userHealthContextApi getter 和对应 provider。

## 2026-06-01

### Expose UserHealthContextApi in network layer

- Regenerated Lucent OpenAPI client from updated `openapi.json`.
- Fixed `packages/lucent_openapi/pubspec.yaml` SDK constraint reset by the generator (sdk `>=3.12.0`, `json_annotation ^4.12.0`).
- Added `UserHealthContextApi` getter to `LucentDioClient`.
- Added `lucentUserHealthContextApiProvider` to `lucent_network_providers.dart`.

### Build health-context data layer

- Created `health_context` feature: domain entities (snapshot, summary, profile, allergies, conditions, current medicines), repository interface, remote datasource, DTO-to-entity mapper, Lucent repository implementation, and Riverpod providers.

## 2026-06-01

### Expose UserHealthContextApi in network layer

- Regenerated Lucent OpenAPI client from updated `openapi.json`.
- Fixed `packages/lucent_openapi/pubspec.yaml` SDK constraint reset by the generator (sdk `>=3.12.0`, `json_annotation ^4.12.0`).
- Added `UserHealthContextApi` getter to `LucentDioClient`.
- Added `lucentUserHealthContextApiProvider` to `lucent_network_providers.dart`.

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
