# Luminous Current State — 历史归档

> 本文件保存从 `docs/Current_State.md` 移出的旧 completed baselines 与 audit remediation，供考古使用。
> 当前状态仍请以 `Luminous/docs/Current_State.md` 为准。

## Completed Baselines

- UI/UX pass and freezed migration are complete.
- Record fast-entry UX is in place: quick actions open a lightweight fast-entry surface first, common values save with the current time, and `more` opens the full form.
- **语音 / 拍照 OCR 记录录入**（2026-07-01）：Record 页面 AI 输入栏提供麦克风（`speech_to_text`）和相机（`google_mlkit_text_recognition` OCR）入口。语音录入会按当前 app locale 选择识别 locale（中文优先 `zh_CN`，英文优先 `en_US`，并回退到同语种可用变体），拍照识别会按当前 app locale 选择 OCR script（中文 `chinese`，其他 `latin`）。语音听写和拍照识别完成后都会把文本送入现有 `record_nlp_controller` NLP pipeline（解析→候选预览→确认保存），OCR 失败时使用专用失败 toast，而不是复用 NLP 输入提示。
- **OAuth Provider 扩展**（2026-06-29）：Apple Sign In + QQ 互联完成。后端 4 个 Provider（WeChat Web / WeChat Mobile / Apple / QQ）统一实现 `OAuthProvider` 接口，WeChat 共用 `WechatBaseOAuthProvider` 基类。`AuthOAuthStateService` 按 provider 隔离缓存 key，避免 state 碰撞。Apple 使用 `jsonwebtoken` 校验 identityToken（JWKS→PEM→jwt.verify），QQ 使用标准 OAuth 2.0 三步式流程。前端 `login_page.dart` 增加了 Apple（`sign_in_with_apple`）/ QQ 登录面板，`router.dart` 新增 `/login/oauth/qq` 路由。
- **Forui 迁移债务清偿计划**（2026-07-03）：引入 `forui_hooks: ^0.23.0` 作为带 controller 的 Forui 组件首选状态管理方式，并在 `Luminous/plans/2026-07-03-forui-debt-paydown-plan.md` 落地剩余债务清偿计划。剩余工作聚焦图标清理、手绘 surface 替换、wrapper 内联、token 定型和测试/CI 恢复。
- **Forui 运行时迁移收尾**（2026-07-03）：完成了 runtime `lib/` 中最后一批自定义 surface 的 Forui 替换，包括 `showModalBottomSheet` → `showFSheet`、自定义 `TodayLinearProgress` → `FDeterminateProgress`、chip/pill → `FBadge`、列表行 → `FTile`、自定义 tabs → `FButton` tab pills、toast → `showFToast`/`FToaster`，并删除了 `RecordIndentedDivider`、`RecordShortVerticalDivider`、`AuthSectionCard`、`MineSettingRow` 等薄包装。
- **Typography 统一到 Forui level token**（2026-07-03）：新增 `AppTypographyTokens`，将 `level1`–`level10` 映射到 Forui `FTypeface` 的 `xs3`–`xl4`，并把 runtime `lib/` 中所有 Material `textTheme.*` 引用（约 302 处）迁移到 `AppTypographyToken.levelN.body(context)` / `.display(context)`；剩余硬编码 `fontSize:` 也替换为对应 token。`flutter analyze --no-pub` 为 0 issues；测试修复工作仍未处理。
- **布局溢出修复**（2026-07-03）：修复了 `report_metrics_grid.dart` 在移动/桌面断点下的 Column 底部溢出（ mobile 164→192 / tablet 176→204 / desktop 188→216 ），并压缩了 Mine 退出登录状态的首屏高度（头像 84→64、account/archive/status 的 padding/间距收紧），使 `mine_page_test` 中档案入口在未登录首屏可点击并弹出登录对话框。`test/report/report_page_test.dart`、`test/app/shell_page_test.dart`、`test/mine/mine_page_test.dart` 全部通过。
- **全仓库 lint 自动清理**（2026-07-03）：在 `analysis_options.yaml` 启用 `prefer_const_constructors` 并移除 `test/**` 排除后，运行 `dart fix --apply` 修复 179 处 lint（`prefer_const_constructors`、`unused_import`、`duplicate_import`、`sort_child_properties_last`），涉及 56 个文件。`flutter analyze --no-pub` 现为 0 issues，`flutter test --no-pub` 854/854 passed。
- **Header 统一重构**（2026-07-03）：子页全面改用 `PageScaffold`（`FScaffold + FHeader.nested + SafeArea` 的统一封装，默认 `AppBackButton`），Tab 根页顶部栏全面改用 `AppTopBar`（`level9.display + w800`）。涉及 assistant、scan、notification、record、mine、medicine、settings、search、report、today 等页面；`SearchPage` 移除双重 header；`AuthShell` 标题样式与占位尺寸改用 design token。`flutter analyze --no-pub` 0 issues，`flutter test --no-pub` 854/854 passed。

## UX Audit Remediation (Completed)

### Phase 1: Interactions and Back Button Unification

- `lib/core/widgets/common/app_back_button.dart` is the single back-button component for non-auth child pages. It prefers `context.pop()` when the route can pop, otherwise falls back to `/today` (or a caller-supplied route), and its active UI is now a Forui ghost icon button with `FLucideIcons.chevronLeft`.
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
- Shared child-page infrastructure is now primarily Forui-based: child pages compose `FScaffold` / `FHeader` directly, `showAppDialog` / `AppDialogShell` wraps `showFDialog` / `FDialog.raw`, and `AppStateMessageView` / `AppStateErrorView` use `FCard` / `FButton`. No raw `TextField` instances remain in runtime `lib/`; assistant, medicine reminder, record NLP/forms, sleep fields, and search input now all use `FTextField`. Phase 1 of the Material-widget migration is complete across `lib/`: all `AlertDialog`/`showDialog` usages now use `FDialog`/`showFDialog`, `FilledButton`/`TextButton`/`IconButton`/`ElevatedButton`/`OutlinedButton` have been replaced by `FButton`/`FButton.icon` with the correct variants, `CircularProgressIndicator`/`LinearProgressIndicator` have been replaced by `FCircularProgress`/`FProgress`/`FDeterminateProgress`, and remaining `InkWell`/`Material + InkWell` tap targets have been replaced with `FTappable`.

### Medium/Low Remediation

- `HelpSettingsPage` filters support resources by `available == true` in addition to a non-empty actionable URL/type.
- `AboutSettingsPage` reads `privacyPolicyUrl`, `termsOfServiceUrl`, and `supportEmail` from `AppInfoDataDto` with hard-coded fallbacks; it displays the backend `buildDate` below the version and uses `mailto:` when a support email is present.
- `SettingsPage` data-sharing consent toggle now shows a confirmation dialog before calling `setDataSharingConsent`.
- `SettingsPage` data-export row routes to `/settings/export` consistently with the dedicated `DataExportPage`.
- The top-level `SettingsPage` itself is now rendered directly with Forui primitives (`FTile`, `FTileGroup`, `FSwitch`, `FButton`, `FAvatar`) and no longer depends on the old shared settings wrappers (`AppSectionSurface`, `AppSettingsSection`, `AppSettingsNavigationRow`, `AppSettingsSwitchRow`). Each settings group now uses a single Forui group outline instead of an outer card plus inner tile borders.
- The main secondary settings pages have now followed the same direction: `theme`, `language`, `advanced`, `notification`, `sleep reminder`, `AI`, `help`, `about`, and `data export` pages render directly through Forui tiles/groups/cards/buttons instead of building their UI out of the old shared settings wrappers.
- Those secondary settings pages now also use a unified group-only outline treatment: the visible border belongs to the enclosing `FTileGroup`, while inner `FTile`s no longer render a second nested border.
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
- **2026-06-30 follow-up**: All 11 raw `InkWell` usages in `lib/features/medicine/` were first migrated to a shared `AppInkWell` wrapper (auto splash/highlight + disabled opacity).
- **2026-07-02 follow-up**: `AppInkWell` has been deleted. All remaining call sites in `lib/features/medicine/` now use direct `FTappable`, with `borderRadius` dropped (children already carry matching shapes) and `padding` inlined as an outer `Padding` widget.

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

