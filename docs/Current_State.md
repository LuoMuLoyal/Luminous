# Luminous Current State

Last updated: 2026-07-01

This file records current implementation facts only. Product direction lives in `Product_Vision.md`; next work lives in `Next_Plan.md`; reusable rules live in `Project_Guardrails.md`.

## Project Governance

- **Solo maintainer**: All design, development, testing, and deployment decisions are made by a single person. There is no team division of labor, no PR review requirement, and no multi-stakeholder approval process.
- **Architecture**: Modular monolith (NestJS modules) over microservices. Each Lucent `@Module` maintains clear boundaries so future extraction is possible without a rewrite, but there is no current plan to split services.
- **Test toolchain**: Jest remains the test runner for Lucent. Vitest was considered but rejected — NestJS ecosystem support and migration cost outweigh marginal speed gains.
- **Monorepo workspace**: Three child repositories (`Lucent`, `Luminous`, `Luminous-site`) under a non-git workspace root. Each has its own `package.json` / `pubspec.yaml`, `node_modules`, and git history. Cross-project contract is owned by Lucent's OpenAPI spec.

## Repository Split

- `Lucent` is the active NestJS backend.
- `Luminous` is the active Flutter client.
- `Luminous/backend` is legacy reference only.
- The shared workspace root is not a git repository; `Lucent` and `Luminous` are separate child repositories.

## Product Surface

- Mobile is the current product surface.
- Bottom tabs are fixed at `today / record / medicine / report / mine`.
- Web is reserved for report preview/export and competition display.
- `Luminous-site` currently serves as a competition/marketing homepage, not a signed-in report preview surface.
- Desktop visual behavior is not part of current UI acceptance.

## Lucent Contract Snapshot

- API base: `/api/v1`.
- Response envelope: `{ code, message, data }`.
- Generated API contract: `Lucent/docs/openapi.json`.
- Current generated client baseline after business scope cleanup: 79 paths / 185 schemas.
- Implemented backend areas used by Luminous: auth/account, user-scoped health context, medicine search/detail, current medicines, dose logs, medicine reminders, daily records with single-image attachment metadata, environment snapshot, user settings, support resources, app info, and data export requests.
- User-scoped business data is served under `/api/v1/user/*`; account profile/security actions remain under `/api/v1/account/*`.

## Completed Baselines

- UI/UX pass and freezed migration are complete.
- Record fast-entry UX is in place: quick actions open a lightweight fast-entry surface first, common values save with the current time, and `more` opens the full form.
- **语音 / 拍照 OCR 记录录入**（2026-07-01）：Record 页面 AI 输入栏提供麦克风（`speech_to_text`）和相机（`google_mlkit_text_recognition` OCR）入口。语音录入会按当前 app locale 选择识别 locale（中文优先 `zh_CN`，英文优先 `en_US`，并回退到同语种可用变体），拍照识别会按当前 app locale 选择 OCR script（中文 `chinese`，其他 `latin`）。语音听写和拍照识别完成后都会把文本送入现有 `record_nlp_controller` NLP pipeline（解析→候选预览→确认保存），OCR 失败时使用专用失败 toast，而不是复用 NLP 输入提示。
- **OAuth Provider 扩展**（2026-06-29）：Apple Sign In + QQ 互联完成。后端 4 个 Provider（WeChat Web / WeChat Mobile / Apple / QQ）统一实现 `OAuthProvider` 接口，WeChat 共用 `WechatBaseOAuthProvider` 基类。`AuthOAuthStateService` 按 provider 隔离缓存 key，避免 state 碰撞。Apple 使用 `jsonwebtoken` 校验 identityToken（JWKS→PEM→jwt.verify），QQ 使用标准 OAuth 2.0 三步式流程。前端 `login_page.dart` 增加了 Apple（`sign_in_with_apple`）/ QQ 登录面板，`router.dart` 新增 `/login/oauth/qq` 路由。

## UX Audit Remediation (Completed)

### Phase 1: Interactions and Back Button Unification

- `lib/core/widgets/app_back_button.dart` is the single back-button component for non-auth child pages. It prefers `context.pop()` when the route can pop, otherwise falls back to `/today` (or a caller-supplied route).
- `AppBackButton` is wired into: all `/settings/*` sub-pages, `/record/create`, `/record/:id`, `/record/:id/edit`, medicine reminder detail/edit, medicine risk-check, `/mine/*` edit pages, `/assistant`, `/notifications/list`, `/login`, `/register`, and `/forgot-password`.
- `lib/features/settings/presentation/widgets/settings_components.dart` (the old `SettingsBackButton`) and `lib/features/auth/presentation/widgets/auth_back_button.dart` have been removed.
- `SearchPage` is now wrapped in `PageScaffoldShell` with an `AppBar` and `AppBackButton` so it no longer traps the user.
- `TodayEmptyView` action now routes to `/record/create`.
- `TodayRecommendationSection` "查看更多" now refreshes the recommendations provider instead of showing a toast. Each recommendation row navigates by `category`: `medicine` → `/medicine`, `sleep` → `/record/create?kind=sleep`, `record` → `/record/create?kind=water`, `report` → `/report`, `habit`/unknown → `/record`.
- Medicine dashboard reminder quick action now falls back to `/medicine/reminders/new`. `MedicineReminderEditPage` shows an inline "请先选择药品" prompt with a button to `/medicine/search` when opened without a `medicineId`.

### Phase 2: Shell Routing Unification

- The `StatefulShellRoute` now contains only the five main tab roots: `/`, `/record`, `/medicine`, `/report`, `/mine`.
- All create/detail/edit sub-pages (`/record/*`, `/medicine/*`, `/mine/*`) are top-level full-screen `GoRoute`s; entering them hides the mobile bottom navigation and the desktop sidebar because they are outside the shell.
- `/settings`, `/settings/*`, `/assistant`, `/notifications`, and `/notifications/:id` are also top-level full-screen routes.
- `ShellBranch` only models the five visible tab branches; hidden branches have been removed.
- Desktop sidebar settings/help actions now `context.push('/settings')` and `context.push('/assistant')` instead of using `goBranch`.
- Report metric taps now push `/record?filter=<kind>` (filter encoded via `RecordEntryType.name`). `RecordPage` reads the URL query parameter in `didChangeDependencies` and syncs it into `selectedRecordFilterProvider`, so refresh/deep-link preserves the filter.

### Phase 3: Mock Data Marking (HIGH-1, HIGH-2)

- Mock repositories are now explicitly documented as demo-only and are not used by production providers.
- User-visible mock values are marked with `[DEMO]` or placeholder values (`--`, `demo@example.com`, `2099-01-01`, empty arrays) so they cannot be mistaken for real data.
- `MockMedicineSearchRepository` IDs use `__mock_*__` format to prevent them from being sent to backend APIs as real `sourceRefId`s.
- **2026-06-30 update**: All 5 dashboard/workspace providers now gate mock data behind `kDebugMode`. Release builds show clean empty states via each domain model's `signedOut()` factory.

### Phase 4: Error/Empty State Hardening

- `TodayRecommendationSection` error state renders `AppStateErrorView` in compact mode with localized title, description, and retry action.
- `MedicineReminderDetailPage` distinguishes a missing reminder (404) from a generic load failure and surfaces localized copy for each.
- `AppStateErrorView` supports a `compact` flag and uses `LayoutBuilder` to avoid infinite-height issues inside scrollable parents.

### Medium/Low Remediation

- `HelpSettingsPage` filters support resources by `available == true` in addition to a non-empty actionable URL/type.
- `AboutSettingsPage` reads `privacyPolicyUrl`, `termsOfServiceUrl`, and `supportEmail` from `AppInfoDataDto` with hard-coded fallbacks; it displays the backend `buildDate` below the version and uses `mailto:` when a support email is present.
- `SettingsPage` data-sharing consent toggle now shows a confirmation dialog before calling `setDataSharingConsent`.
- `SettingsPage` data-export row routes to `/settings/export` consistently with the dedicated `DataExportPage`.
- `PageScaffoldShell` FAB bottom inset adds `MediaQuery.paddingOf(context).bottom` to avoid system gesture overlaps.
- `TodayDashboardView` mobile bottom padding now combines the existing clearance token with `MediaQuery.paddingOf(context).bottom`.
- `MedicineMobileDrugboxSection` filters out plan items whose `currentMedicineId` is null before rendering rows.
- `MedicineReminderDetailPage` hides the delete button entirely when there are no reminders (previously disabled).
- `loginRouteForReturnTo` / `loginRouteForCurrentLocation` encode the return path with `Uri`, preserving query parameters.
- All tab scroll views use distinct `PageStorageKey` values per surface (mobile/desktop), preserving scroll position across tab switches.

## 2026-06-30 Audit Remediation

### Mock Data kDebugMode Gating

Mock data in 5 dashboard/workspace providers now gated behind `kDebugMode`:
- Debug: rich placeholder data for signed-out preview
- Release: clean empty states via `XxxDashboard.signedOut()` domain factories

| Model | Domain Factory |
|-------|---------------|
| `TodayDashboard` | `signedOut()` — 空体征、零计数、空列表 |
| `RecordDashboard` | `signedOut(date)` — 空时间线、标准快速操作/过滤器 |
| `MedicineWorkspace` | `signedOut()` — 零剂量、空用药计划 |
| `ReportDashboard` | `signedOut()` — 零评分、空指标 |
| `MineDashboard` | `signedOut()` — 访客档案、零完成度 |

### InkWell Click Feedback

- `sleep_structured_fields.dart` `_TimePickerField`: added missing `Material` ancestor
- `record_quick_entry_panel.dart`: locked quick actions now include `isLocked` guard in `onTap`
- 3 dead `InkWell(onTap: null)` removed (record guide row, report findings/patterns)
- `app_text_action.dart` + `MedicineHeaderActionChip` + voice entry button: `Opacity(0.5)` when `onTap == null`
- `notification_list_page.dart`: added `AppBackButton`
- **2026-06-30 follow-up**: All 11 raw `InkWell` usages in `lib/features/medicine/` migrated to shared `AppInkWell` wrapper (auto splash/highlight + disabled opacity). `AppInkWell` now consistently used across today + medicine modules.

### Auth Form Validation

- `LoginFormNotifier` now uses `AuthValidationMixin` + `CooldownTimerMixin` (same as `RegisterFormNotifier` and `PasswordResetNotifier`)
- Removed hand-written `_isValidEmail()` regex from login — all email validation goes through `email_validator` package via mixin

### TextEditingController Migration

All 16 files with manual `TextEditingController` lifecycle (`late final` + `initState` + `dispose`) migrated to `flutter_hooks`:

| 文件 | 模式 |
|------|------|
| `change_email_page.dart` + `register_page.dart` + `forgot_password_page.dart` | 简单: `ConsumerStatefulWidget` → `HookConsumerWidget` |
| `profile_edit.dart` + `allergy_edit.dart` + `condition_edit.dart` + `current_medicine_edit.dart` | `useState` 替代 `setState` |
| `sleep_structured_fields.dart` `_NumberField` + `search_input.dart` + `record_nlp_candidate_editor.dart` | `didUpdateWidget` → `useEffect` |
| `record_create.dart` + `record_edit.dart` | 复杂 `initState` → `useEffect` + `useState` |
| `assistant_page.dart` | `ref.listenManual` → `ref.listen` |
| `medicine_reminder_edit_page.dart` | `setState` → `useState` |
| `login_page.dart` | OAuth 回调 → `useEffect`（手工重写） |
| `account_settings_page.dart` | 用户同步 → `useEffect`（手工重写） |

53 个 controller 全部消除手动 `initState`/`dispose`。

### Test Additions

- Record/Medicine/Mine page-level error tests (3 new)
- Dio error mapping tests covering all 8 `DioExceptionType` fallback messages + envelope extraction (10 new)
- Total: 910 passing tests

## Luminous Runtime Snapshot

- Stack: Flutter + Riverpod + GoRouter + `hooks_riverpod` + `flutter_hooks`.
- Android app module now follows Flutter-managed default `minSdk` instead of pinning Android 12+ only in Gradle; Android 12 splash behavior remains handled by the existing `values-v31/` resource split rather than by artificially raising the compatibility floor.
- Generated Lucent client: `packages/lucent_openapi`.
- Auth/session state is split into restoring, confirmed signed-out, and signed-in.
- Integration coverage now includes four real Android-emulator full-stack lanes against Lucent test runtime:
  - auth sign-in smoke
  - Record create/detail/edit/delete CRUD lane
  - Record sleep structured-entry lane
  - Today + Report protected-dashboard lane with Report sync verification plus real Today/Report AI streaming generation
- Repo-local validation entrypoints are now split into:
  - `tool/run_daily_checks.dart` for repo-safe checks (`flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`)
  - `tool/run_fullstack_checks.dart` for Android emulator + Lucent test-runtime lanes
- Frontend tests are now grouped by feature under nested `test/` and `integration_test/` directories instead of one flat root.
- Full-stack mobile E2E is intentionally local/manual right now. It is not part of the current GitHub Actions pipeline.
- Shared support-resource reads now live under a dedicated `features/support/` frontend boundary instead of staying nested under `settings`.
- Protected providers do not call Lucent while auth is restoring or confirmed signed out.
- Protected entry taps show a modal login prompt on the current page; direct/deep-link protected pages keep destination guards as fallback.
- Skeleton loading is section-scoped: stable chrome and local/mock/static sections render immediately, backend-backed fields shimmer locally.
- Report now fetches the Lucent report dashboard on page entry for signed-in users, keeps section-level shimmer loading, shows explicit signed-out gating, and now wires all three export cards to Lucent data-export request flows.

## Active Mobile UI

### Today

Compressed health overview, repository-provided medication/hydration priority list, medication tasks, hydration tasks with count targets, UI-only custom todos, manual Lucent-backed Today AI analysis generation with signed-out/disabled/loading/success/error card states, real incremental summary streaming through `/api/v1/user/today-analysis/generate/stream`, final structured bullets/action/confidence render after stream completion, immediate risk/proactive suggestions, sleep vital row reading real duration from persisted sleep records (falls back to `--` when no data), and neutral error copy instead of `mock` phrasing.

### Record

Symptoms, hydration with selectable units, diet/meal, note as a first-class type (own quick action, filter, and timeline entry), sleep as a create-capable kind with structured bedtime/wake-time/quality/stage inputs backed by payload fields `startAt/endAt/durationMinutes/quality/deepMinutes/lightMinutes/remMinutes`, medication as non-create quick action, mobile natural-language bottom-sheet intake wired to Lucent candidate parsing plus confirm-before-save flow, selected-date timeline/detail/create/edit, top date bar, filters, and panel-backed quick record/timeline sections whose inner rows use dividers instead of nested cards. Active create kinds are water, meal, symptom, note, and sleep. Active quick actions for those kinds now open a quick-choice bottom sheet first: tapping a quick choice saves immediately with the selected date plus the real current `HH:mm`, while `more` opens the full create form with editable date and time fields. Record create/edit now expose explicit date + time pickers, Lucent daily-record persistence keeps `occurredAt` as the day key plus a separate persisted `occurredTime`, and Record timeline/detail now display the saved concrete hour/minute instead of implying time from a timestamp fallback. Natural-language candidate kinds currently stay bounded to water, meal, symptom, note, and sleep. Candidate review is now editable and selectively savable: user can adjust title/value/unit/note, edit sleep duration/quality payload, unselect items, keep failed items in place, and explicitly retry only failed candidates instead of resubmitting the full batch. Candidate editors now also apply light per-kind polish for MVP usability: water uses a numeric amount plus the same `ml / cup / times` unit picker as the formal form, meal/symptom cards use more specific field labels, and note cards emphasize body text instead of a generic remark field. Sleep timeline rows now derive their compact duration label from payload when `value/unit` are intentionally null. Lucent-backed filter results no longer fall back to a static mock timeline, and record error copy now uses neutral boundary wording instead of `mock data`.

### Medicine

Active current-medicine drugbox, reminder-derived next dose, Lucent schedule-only reminder detail/create/edit/delete UI with optional start/end date window, local sound preference, on-device local notification scheduling synced from reminder schedules, SMS unavailable state, read-only reminder delivery history display, panel-backed medication actions, same-day taken/skipped dose logs, a real current-medicine risk-check page, workspace safety cards sourced from the same risk result, add-before-save risk precheck on medicine search results, source-review safety previews, allergy safety checks, and backend-driven medicine safety tips with "refresh" support and adjacent-request deduplication. The risk-check boundary is intentionally narrow but now explicit and consistent across entry points: it evaluates current medicines plus the pending add candidate, uses existing medicine-detail data only, surfaces a shared coverage summary when manual entries, missing source detail, or fully unchecked medicine sets cannot be checked, and applies a bounded reviewed rule set for allergy matching (with 8-group cross-language token map), duplicate-ingredient checks for reviewed `cn` ingredient strings plus DrugBank synonym overlap, food-interaction detection (alcohol/caffeine), and DrugBank-sourced interaction pair detection. The risk-check result carries a `coverageSummary` string for human-readable gap reporting. Severity is now derived from the conclusion tier rather than hardcoded per context. The risk-check page and workspace safety panel show a two-layer display: structured conclusion label (e.g. "禁用", "慎用") as the title, context+medicine as the body, and source evidence text as the detail. Red-flag escalation now uses three explicit action tiers with per-rule action copy: L1 "立即联系急救" (`severeAllergy`, links to campus-emergency), L2 "高风险状态/建议线下确认" (`informationGap`, no resource link), L3 "高风险状态/建议线下确认" (`informationGap`, no resource link — per the principle of not pretending a verified resource loop exists). Resource buttons render disabled when no real action target is available from Lucent. Tests: 39 domain unit tests + 6 red-flag evaluator tests + 8 page/widget tests = 53 total across three test files. The system does not claim broad cross-source normalization or unreviewed interaction expansion.

### Report

Lucent-backed report dashboard with real medication/water/sleep aggregates and user-selectable `last_7_days`/`last_30_days`/`custom` range via a platform date-range picker, contract-driven findings/patterns text, manual AI summary generation with real incremental summary streaming through `/api/v1/user/reports/summary/generate/stream`, local signed-out/disabled/loading/success/error AI-summary states, in-card `近 7 天 / 近 30 天` AI summary switching with per-range cached state, a mobile-safe wrapped header layout for the AI summary controls, mobile pull-to-refresh plus explicit sync action, a tightened mobile report layout with a balanced 2x2 metric grid, a real derived fourth metric card for overall report status based on the report score, and a lighter signed-out inline notice instead of a large warning block. Four export actions are wired: `给校医院` (hospital PDF), `月度报告` (monthly PDF), `打印预览` (print PDF), and `分享给医生` (clinic share link via Redis 24h TTL + native OS share sheet). Report export cards show active in-flight progress and bounded status wording. Mine/Settings still uses the same real data-export request flow. Privacy settings are owned by Mine/Settings.

### Clinic Summary (New — 2026-06-30)

Backend-side privacy-preserving clinic summary for doctor sharing:

- `POST /reports/clinic-summary/preview` — de-identified summary with masked name (张**), age (not birthDate), diagnosis year only
- `POST /reports/clinic-summary/share` — Redis-backed share link with 24h TTL
- `GET /reports/clinic-summary/shared/:token` — public access (no auth), returns 410 when expired
- `GET /reports/clinic-summary/preview/pdf` — PDF download (auth required), A4 formatted with profile/allergies/conditions/medicines/disclaimer sections, CJK font rendering
- `GET /reports/clinic-summary/shared/:token/pdf` — public PDF download of shared summary
- `@Public()` decorator + updated `JwtAuthGuard` with `Reflector` support for mixed auth/public routes
- Frontend share button in Report export section: `Share.share(url)` via `share_plus`

### Mine / Settings

Account, basic health archive, allergies, current medicines, contract-backed support resources, server-backed privacy/AI settings, data export request status, help/about metadata, Advanced settings, and assistant controls. Settings page follows a standard app pattern with five groups (Account & Security, Notifications, Privacy, General, About); two-state toggles use inline switches, multi-state items route to sub-pages, and the sleep reminder page uses a master toggle with disabled sub-items when off. Notification inbox is now real: unread red-dot badge on Today and Mine bell icons driven by real backend unread count, grouped list page (today/yesterday/earlier) with paginated load-more, batch mark-all-read, swipe-to-delete, detail page with action routing ("去处理" navigates to Today/Report/Account depending on notification type), and explicit mark-unread/delete actions. Backend generates notifications for AI summary completion, report export completion, and password change. Settings privacy copy is scoped to report sharing and AI summaries/advice rather than broad AI memory, the sleep reminder row now shows a local-only placeholder label instead of an enabled/disabled state, and Mine uses neutral error copy instead of `mock` wording. The assistant experience is no longer hidden as a settings-only subpage: Today top bar now exposes a first-level assistant entry that routes to a standalone `/assistant` workspace, while Settings keeps the same capability/permission controls as a secondary way to reach it. The assistant workspace reads real Lucent capabilities, restores the latest persisted conversation, exposes a top-right add action to start a new conversation by archiving the current active one, exposes a top-right history entry that opens a recent conversation list and lets the user switch/open one persisted conversation, exposes the authenticated user's assistant enable toggle, a separate persistent-memory toggle, plus fine-grained context toggles, and streams Markdown replies through SSE. Assistant conversation history is now intentionally separate from "historical AI summaries": historical AI summaries mean persisted Today/Report summaries, while cross-conversation assistant memory is optional and default-off behind the `assistantMemoryEnabled` setting. Assistant replies can now also carry proposal-only write intents for records and assistant settings; streamed proposals now include explicit target metadata, user-visible constraints, and proposal expiry timestamps, while backend-side read tools now resolve to higher-certainty envelopes and refuse vague update/delete targeting instead of guessing. The page still routes confirmation back into the existing record/settings write flows instead of creating an AI-only mutation path. Mine profile editing currently surfaces birth date, height, blood type, unit system, and onboarding state only. Campus/support resource rows are now backed by real support-resource data, and rows without a server action target render as visible but inactive instead of pretending they can open something.

## Mock Or Deferred

- Assistant Phase 1 mobile surface now exists as a standalone `/assistant` workspace reachable from the Today top bar and Settings: authenticated users can view real backend capabilities, choose whether the assistant is enabled, choose whether persistent memory is enabled across new conversations, choose whether health profile / recent records / sleep data / current medicines may be used as assistant context, restore the latest persisted conversation, open a recent conversation list, switch to one persisted conversation, start a new conversation from the top-right add action, and send real SSE streaming assistant requests with Markdown rendering. The current Lucent backend tool inventory has now moved past the original 4-tool foundation and includes explicit read tools for today/date/range records, exact-date Today summary lookup, exact-range Report summary lookup, recent Today/Report historical AI summaries, user profile/settings, current medicines, and sleep-by-range reads, but it is still a controlled server-side pre-generation tool layer rather than free-form function calling.
- Export lifecycle polish is still intentionally lightweight: there is no in-page request history list, no explicit retry queue, and the clinic share link has no in-app link management beyond regenerating a new one.
- Worker-populated reminder delivery history; the UI can read audit rows, but no local/push/SMS worker writes them yet.
- Lightweight mood record wiring.
- Environment contextual wiring for Today or Mine.
- Medicine-side scan/OCR/photo/barcode/prescription recognition. The underlying `MedicineWorkspace.quickActions` and related enums/entities are kept but not surfaced in the UI.
- Mock repositories (`mock_*_repository.dart`) retained for dev preview and testing. Release builds use domain `signedOut()` factories via `kDebugMode` gating. `MockMedicineSearchRepository` is test-only.
- **2026-06-30**: Removed 11 `medicineMock*` ARB keys containing `[DEMO]` hardcoded drug names from `app_en.arb`/`app_zh.arb`. Replaced with 3 generic fallback keys (`medicineGenericName`/`medicineGenericDosage`/`medicineGenericSchedule`). Corresponding `MedicineCopyKey` enum values updated, mock repository `MedicinePlanItem` data switched to `rawName`/`rawDosage`/`rawSchedule` pattern.
- **2026-06-30**: `MemorySessionStore` and `StaticTodayRepository` now support configurable `delay` parameter (default `Duration.zero`) for testing loading states with simulated network latency.
- **2026-06-30**: `test/today/today_test_helpers.dart` duplicated `SignedInAuthSessionNotifier` / `SignedOutAuthSessionNotifier` removed; all test files now import from shared `test/helpers/test_helpers.dart`.

Deferred code that remains useful should be marked with:

```dart
// Deferred by Product_Vision MVP: keep this code because the capability is useful,
// but do not surface it until the matching contract/product job is ready.
```

## Removed From Active Scope

- Old More tab and its leftover `features/more` mock workspace.
- Women-health and period management.
- Sport recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Report photo import.
- Desktop-first workflows.
- Feature-level palette classes (`MedicinePalette`, `TodayPalette`, `ReportPalette`) have been removed entirely. All color references now use `AppColorTokens` directly.
- Pregnancy/lactation/children/elderly special-group fields from health context, risk checker, and Prisma schema.

## Design System

- Theme tokens live in `lib/core/design/` (spacing, radius, shadow, layout, typography, colors) and `lib/core/theme/` (`AppThemeSurface` extension with 6 surface variants across classic / bluePink / yellowGreen × light / dark).
- `AppColorTokens` provides 40+ semantic color constants including `accent` (`#159B55`), `accentSoft`, `health`, `errorDark`, `cyanDeep`, `warningDeep`, `violet` etc.
- `AppThemeSurface` (ThemeExtension) exposes 17 semantic surface fields: `canvas`, `canvasSoft`, `canvasSoft2`, `hairline`, `hairlineStrong`, `body`, `mute`, `link`, `linkSoft`, `accent`, `teal`, `tealSoft`, `success`, `error`, `warning`, `warningDeep`, `warningSoft`, `violet`. All features access colors through `Theme.of(context).extension<AppThemeSurface>()`.
- `RecordTypeColors` (`lib/features/record/domain/entities/record_type_colors.dart`) centralizes per-record-type foreground/background color pairs consumed by mock data, Lucent repository, detail pages, and dashboard tokens.
- UI components standardize on: pill alpha `0.12`, status pill radius `AppRadiusTokens.sm`, panel radius `AppRadiusTokens.lg`, section header fontWeight `w600`, icon badge size `48px`, text action icon `16px`.
- Spacing uses `AppSpacingTokens` (xxs=4 … section=192); hardcoded `12`/`24` pixel values are replaced with `sm`/`lg` tokens project-wide.
- Breakpoints reference `AppBreakpoints` constants; no hardcoded `600`.
- Responsive sizing helpers live in `lib/core/design/app_responsive_sizing.dart` and are used for card widths, sidebar widths, grid heights, and scalable hero/chart dimensions.
- Route transitions use `CustomTransitionPage` with `FadeTransition` for auth pages (400ms in / 280ms out) and `SlideTransition`+`FadeTransition` for drill-down pages (220ms in / 150ms out).
- Today and Mine pages support pull-to-refresh via `RefreshIndicator` + `AlwaysScrollableScrollPhysics`.
- ShellPage uses lazy tab loading (`_pages[currentIndex]` instead of `IndexedStack`); only the current tab's providers fire on startup. Riverpod caches already-fetched data so tab-switch-back is instant.
- Charts (record trends) use `fl_chart` (`LineChart`/`BarChart`) instead of handwritten `CustomPainter` widgets.
- Freezed is applied to 74 classes across presentation state and domain entities; all hand-written data classes have been migrated.
- Shared dialog shell `AppDialog` (`lib/core/widgets/app_dialog.dart`) is the default for new dialogs; `RecordNlpDialog` and `MedicineAddPrecheckDialog` already use it.
- Auth form validation is shared through `AuthValidationMixin` and `CooldownTimerMixin` (`lib/features/auth/presentation/providers/shared/auth_form_mixin.dart`). `RegisterFormNotifier`, `PasswordResetNotifier`, and `LoginFormNotifier` all use both mixins. Email validation delegates to the `email_validator` package — no hand-written email regexes remain in any auth provider.
- `flutter_hooks` / `hooks_riverpod` are used project-wide: all 16 files that previously managed `TextEditingController` lifecycle manually have been migrated to `HookConsumerWidget` / `HookWidget` with `useTextEditingController()`. Zero manual `initState`/`dispose` controller boilerplate remains.
- Shared utility `coerceToStringMap` in `lib/core/network/map_utils.dart` deduplicates 5 copies of the same `_coerceToMap` helper.
- `compareReminderTime` deduplicated from 3 copies to 1 public version in `medicine_reminder_formatters.dart`.
- Login page password/code mode switch uses `flutter_animate`'s `.fadeIn().slideX()` instead of `AnimatedSwitcher`, matching the project-wide entrance animation pattern.
