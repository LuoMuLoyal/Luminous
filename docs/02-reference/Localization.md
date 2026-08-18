---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-17
---

# Flutter Localization

Last updated: 2026-08-17 (T9c added 18 `assistant*` keys to the assistant fragment — F-5b `assistantReplacedLabel` (已替换 / Replaced); F-10 `assistantCapabilitiesAction` / `assistantCapabilitiesSummaryTitle` / `assistantCapabilitiesToolsTitle` / `assistantCapabilitiesRagLabel` / `assistantCapabilitiesEnabledValue` / `assistantCapabilitiesDisabledValue` / `assistantToolEnabledLabel` / `assistantToolDisabledGeneric` / `assistantToolDisabledChat` / `assistantToolDisabledContext` / `assistantToolDisabledModel` / `assistantToolDisabledNotImplemented` plus 3 completed tool-name keys `assistantToolSearchCnMedicineProducts` / `assistantToolCnMedicineDetail` / `assistantToolDrugbankDetail`; F-14 `assistantSourceDataAsOfLabel` (数据截至 / Data as of) / `assistantSourceVersionLabel` (版本 / Version). Earlier: T9a/F-4 added the markdown link confirm keys — `assistantMarkdownLinkConfirmTitle` / `assistantMarkdownLinkConfirmDescription` / `assistantMarkdownLinkOpenAction` (打开外部链接？/ Open external link?) — to the assistant fragment; F-5b added `assistantContinueGeneratingAction` (继续生成 / Continue generating) to the assistant fragment for the send-error bar's continue-generating button, replacing the previous retry label; `assistantRegenerateAction` / `assistantResendAction` keys already existed and are now wired to the message context menu; F-2 added `assistantConversationRenameDialogTitle` / `assistantConversationRenameHint` / `assistantConversationDeleteConfirmTitle` / `assistantConversationDeleteConfirmDescription` / `assistantConversationDeletedToast` / `assistantClearingConversationLabel` / `assistantConversationTapToName` to the assistant fragment for the conversation rename/delete drawer flow; F-9 added `assistantMemoryHintTitle` / `assistantMemoryHintDescription` (已开启跨会话记忆 / Cross-conversation memory is on) to the assistant fragment for the welcome-panel memory hint; F-11/F-16 added `assistantProposalRegenerateAction` (重新生成 / Regenerate) to the assistant fragment for the expired-proposal regenerate button; F-7 assistant source strip added 14 `assistantSource*` keys to the assistant fragment; removed `todayMedicationName*` keys; rewrote `todaySummaryFallbackNarrative` to neutral onboarding copy; F-9 afternoon water greeting keys changed to ml-gap semantics and added unknown key; F-1 skip_dose error toast key added; F-10 health event options retry action key added; F-12 todayQuickActionWaterSubtitle key added; F-8+F-16 todayMetricDegraded key added; F-6+F-7 Today AI summary materialization keys corrected to `todayAnalysis*` and `todayAnalysisEmptyBody` added; F-3 todaySuggestionRuleBasedLabel added; F-13+F-15 added 7 assistant disclaimer / trust-tier keys — `assistantDisclaimerText`, `assistantSourceBadgeLeaflet` / `assistantSourceBadgeDrugbank` / `assistantSourceBadgeMedicalQa` / `assistantSourceLowTrustHint` / `assistantDisclaimerShowAction` / `assistantDisclaimerCollapseAction` — to the assistant fragment; T8 added 5 settings keys — `settingsAiContextChangeNextTurnToast`, `settingsAiPrivacySectionTitle`, `settingsAiPrivacyMemoryNote`, `settingsAiPrivacyContextNote`, `settingsAiPrivacyHistoricalNote` — to the settings fragment for the AI settings context-toggle next-turn toast and AI privacy notes)

This file records the localization workflow and ownership rules. It is not a catalog of every
current string.

## Files

- Config: `l10n.yaml`
- ARB source fragments: `lib/l10n/src/{fragment}_{locale}.arb` (11 fragments × 2 locales)
- Merged ARB (generated, gitignored): `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`
- Generated Dart output (gitignored): `lib/l10n/app_localizations*.dart`
- Merge/split tool: `scripts/arb_tools.dart`

### Fragment Map

| Fragment | Key prefixes | Aligns with |
|----------|-------------|-------------|
| `common` | `app*`, `tab*`, `desktop*`, `state*`, `placeholder*`, `legal*` | Shell / global |
| `record` | `record*` | Record feature |
| `medicine` | `medicine*`, `scan*` | Medicine feature |
| `today` | `today*` | Today feature |
| `report` | `report*` | Report feature |
| `settings` | `settings*`, `sidebar*` | Settings feature |
| `auth` | `auth*` | Auth feature |
| `mine` | `mine*` | Mine feature |
| `assistant` | `assistant*` | AI assistant feature |
| `notification` | `notification*` | Notification feature |
| `network` | `network*` | Network layer error messages |

New feature modules should add a row to `fragmentRules` in `scripts/arb_tools.dart`.

## Supported Locales

- `system`
- `zh-CN`
- `en`

Persisted preference keys:

- Locale: `app.locale`
- Theme mode: `theme.mode`
- Theme family: `theme.family`

## Rules

- Do not hardcode user-visible text in pages or widgets.
- Add visible text to both ARB files.
- The fifth tab's user-visible task name is Review (`回顾` / `Review`): the `tabReport`
  ARB key (owned by the `common` fragment) renders the Review label for the tab, page app
  bar, and command-palette entry. The `/report` route path, `ShellTab.report` enum,
  `SemanticIcons.tabReport` icon token, feature directory, and telemetry keys are unchanged
  (code-layer rename deferred until after the compatibility period). Legacy `report*` export
  and suggestion-history strings keep their Report wording in export/history compatibility
  contexts.
- Assistant strings use `assistant*` ARB keys directly. Do not reintroduce compatibility alias
   layers for assistant l10n.
- Report AI summary state copy such as generate/loading/error/disabled hints is owned by the Report
   ARB entries, not by repository/domain fallback strings.
- Report readiness state copy such as status badges, updated-at wording, locked-feature hints,
  keep-recording CTA labels, and score summary is owned by the Report ARB entries.
- Health data import and auto-sync availability copy (`healthSyncNotAvailable`,
  `healthSyncAutoSyncNotConfigured`, `healthSyncAutoSyncUnsupported`) is owned by the Health Sync
  ARB fragments; the import page and Settings use these keys to distinguish unsupported platforms
  from the unconfigured background executor.
- Health Sync metric labels and preview titles are owned by the Health Sync ARB fragments: the
  `healthSyncMetric*` keys render the metric type buttons, and the `healthSyncMetricTitle*`
  template keys (with value/unit placeholder args) compose the preview tile titles. The import
  page no longer hardcodes Chinese metric titles; sleep duration h/m formatting stays in Dart and
  only the formatted text is passed to the `healthSyncMetricTitleSleep` placeholder.
- Sparse Record Semantics Task 9 does not add or rename user-visible strings. The existing Record
  keys cover quick-entry water, medication, and sleep flows; the existing Health Sync keys cover
  platform import and auto-sync boundaries. Canonical ml, observed/unknown, coverage, source, dose
  slot, and sleep episode values are data-contract semantics, not new localization copy.
- Report preview empty-state copy (`reportPreviewBannerMessage`, `reportTrendPreviewTitle`,
  `reportFindingsPreviewTitle`, `reportSuggestionHistoryPreviewTitle`, `reportExportPreviewTitle`
  and their `*Body` counterparts) is owned by the Report ARB entries.
- Record natural-language intake strings such as bottom-sheet title, parse/save actions, candidate
   counts, selection hints, partial-save toasts, candidate failure hints, and per-kind candidate
   editor labels are owned by the Record ARB entries.
- Record fast-entry quick-choice labels plus date/time field labels are owned by the Record ARB
   entries.
- Record voice/OCR intake copy (sheet titles, action labels, microphone-permission wording,
   speech-unavailable / locale-unsupported errors, editable-result hint, OCR failure toasts) was
   owned by the Record ARB entries. The active UI that used these keys has been deleted (voice and
   OCR features removed); the l10n keys remain orphaned in `record_*.arb` and should be cleaned up
   in a follow-up.
- Record NLP header action label (`recordNlpHeaderAction`) is owned by the Record ARB entries.
  The mobile header NLP entry button uses `SemanticIcons.aiEntry` (sparkles) and triggers
  `_openNlpDialog` directly from the header, replacing the old `RecordAiInputBar` top input bar.
- Record quick-entry settings strings (`recordQuickSettings*`) and quick panel help copy
  (`recordQuickHelpTooltip`, `recordQuickHelpLongPressRule`) are owned by the Record ARB entries.
  Settings only owns the secondary
  entry subtitle (`settingsQuickEntrySubtitle`) because that row lives on the Settings page.
- Record quick-entry icon customization strings (`recordQuickIcon*`) are owned by the Record ARB
  entries and used by the quick-entry settings page, the create/edit record forms
  (`RecordKindIconField`), and the long-press type-settings dialog.
- Record quick-entry daily-flow feedback strings (`recordQuickSavedToast`,
  `recordQuickUndoAction`, `recordQuickUndoFailedToast`) and symptom multi-select fast-entry strings
  (`recordFastEntryMultiSelectAction`, `recordFastEntryPartialFailedToast`) are owned by the Record
  ARB entries.
- Record detail page strings (`recordDetail*`, including water progress, copy summary,
  adjacent-navigation labels, and the in-body edit primary action `recordDetailEditAction`) and
  record edit strings (`recordEditDiscard*`, plus the form status hints `recordEditUnsavedHint` /
  `recordEditUnsavedWarning`) are owned by the Record ARB entries. Water default customization
  strings (`recordQuickSettingsWaterCustom*`) are also Record-owned and used by both the
  quick-entry settings page and the long-press dialog.
- Record quick medication strings (`recordQuickMedication*`) are owned by the Record ARB entries,
  even when an action routes to Medicine search, because the prompt and selection dialog live on the
  Record page. Temporary dose feedback uses `recordQuickMedicationTemporaryToast` and must remain
  explicit that no reminder slot was matched.
- Record quick sleep strings (`recordQuickSleep*`) are owned by the Record ARB entries because the
  start-type selection, optional approximate duration/quality fields, start toast, multi-start
  selection, merge confirmation, and sleep in-progress badge live on the Record page.
- Record quick meal strings (`recordQuickMeal*`) are owned by the Record ARB entries because the
  camera confirmation dialog lives on the Record page and saves a Record daily entry.
- Record NLP generate-failure copy such as the `recordNlpGenerateFailedToast` fallback message is
  owned by the Record ARB entries.
- Record meal-analysis strings such as status/coverage labels, summary section titles, estimate
   disclaimer, dish-editor helper text, and confirm-result action are owned by the Record ARB
   entries.
- Record root-page CTA strings such as timeline continuation actions (`查看全部记录` / `收起`) are
  owned by the Record ARB entries.
- Today root-page action-panel copy such as primary-suggestion titles, evidence/boundary labels,
  observation wording, and quick-action labels is owned by the Today ARB entries. The one-tap water
  quick-action subtitle uses `todayQuickActionWaterSubtitle`.
- Today health-event copy such as the start entry, short-title form, daily check-in, end flow,
  fixed outcome labels, validation, and retry errors is owned by the Today ARB entries.
- Today root page no longer owns a standalone "no records yet" banner; keep the active surface
  compact and avoid reintroducing preview-only record prompts there.
- Reminder UI strings for date windows, local sound preference, SMS unavailable state, delivery
   history, on-device notification title/body/channel labels, and reminder toggle failure toast
   (`medicineReminderToggleFailedToast`) are owned by the Medicine feature ARB entries.
- Medicine add-before-save risk precheck strings such as confirmation sheet title, warning
   description, confirm action, and failure toast are owned by the Medicine/Search ARB entries.
- Medicine dashboard empty-state copy (`medicineTodayPlanEmpty`,
  `medicineSafetyPanelEmptyTitle`, `medicineSafetyPanelEmptyBody`) is owned by the Medicine
  feature ARB entries.
- Mine archive empty-state copy (`mineArchiveEmptyTitle`, `mineArchiveEmptyDescription`) is
  owned by the Mine feature ARB entries.
- Search result "already added" label (`medicineSearchAlreadyAddedLabel`) is owned by the
  Medicine/Search ARB entries.
- Sleep structured-record strings such as bedtime/wake-time labels, duration, quality, and
   sleep-stage labels are owned by the Record feature ARB entries.
- Mine no longer owns any campus-service strings; support-resource copy is limited to settings
   help/about surfaces plus backend-provided titles when present.
- Settings help page FAQ and feedback strings (`settingsHelpFaqSectionTitle`, `settingsHelpFaqLoadError`,
  `settingsHelpFeedbackSectionTitle`, `settingsHelpFeedbackSubject`, `settingsHelpFeedbackUnavailable`,
  `settingsHelpFeedbackOpenFailed`) are owned by the Settings ARB entries. The `mineHelpFaqTitle` /
  `mineHelpFaqSubtitle` keys have been removed (unused after help page self-containment).
- Settings About page version-check strings (`settingsAboutCheckUpdate`, `settingsAboutCheckUpdateChecking`,
  `settingsAboutCheckUpdateUpToDate`, `settingsAboutCheckUpdateAvailable` with `{version}` placeholder,
  `settingsAboutCheckUpdateFailed`) are owned by the Settings ARB entries. The About page uses
  `compareSemver()` to compare the local `package_info_plus` version against the backend-provided
  `latestVersion` from `GET /api/v1/public/app-info`.
- Mine root-page readiness copy such as preview/signed-in badges, locked/incomplete/ready titles,
  readiness descriptions, primary CTA labels, and the account/privacy section title is owned by
  the Mine ARB entries.
- Mine root-page boundary-section copy such as `AI 与隐私` section title and the `AI 设置 / 报告分享`
  entry labels shown on the root page is owned by the Mine ARB entries.
- Mine root-page lightweight notification/reminder summary copy such as section title, inbox label,
  unread-count wording, and signed-out inbox hint is owned by the Mine ARB entries.
- Mine health-form copy such as record-not-found title/description, back action label, medicine
  section labels (info/dosage/timeline), field hints (blood type/strength/dose/route), allergy
  severity descriptions, condition status descriptions, and the "+N more" readiness gap badge is
  owned by the Mine ARB entries.
- Mine sync-failure details copy (dialog title/description, diagnostic field labels, empty/error
  states, retry action and retrying state, user-facing error messages `mineSyncFailedError*`, and
  diagnostics panel labels `mineSyncFailedDetailsDiagnostics*`) is owned by the Mine ARB entries.
  Network-layer specific strings continue to live in the `network*` fragment and are mapped via
  `NetworkErrorL10n`.
- Report root-page suggestion-history copy such as section title, empty state, lifecycle
  badges, and suggestion detail sheet labels (rule ID, trigger type, confidence, generated-at,
  feedback, expired-at) is owned by the Report ARB entries.
- Event review copy (`reportReview*`) — four section titles, event status/kind/outcome labels,
  unknown-section reason codes, whatHappened/keyChanges/completedActions/nextStep fact wording,
  red-flag safety notes, history, history status filter (`reportReviewHistoryFilterAll`; the
  active/ended filter chips reuse `reportReviewStatusActive` / `reportReviewStatusEnded`),
  no-event and error states — is owned by the Report ARB entries
  (`report_*.arb` fragments, zh/en in sync). The review UI composes these keys over structured
  contract arguments; no review copy is hardcoded in widgets.
- Theme settings now own both mode strings (`system / light / dark`) and theme-family strings
  (`blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc`), plus the
  section labels used by the theme settings subpage and the general-settings summary.
- Assistant tool inventory strings are owned by the Assistant ARB entries, including medicine
   retrieval tools such as leaflet search, DrugBank entity resolution, DrugBank passage search, and
   medical-QA search.
- Assistant controls drawer strings such as the drawer title (`assistantControlsDrawerTitle`) and the
  disabled-by-user hint (`assistantConversationDisabledByUserHint`) are owned by the Assistant ARB
  entries. The hint text references the top-right settings entry point.
- Assistant chat welcome and conversation search strings (`assistantWelcome*` and
  `assistantConversationSearch*`) are owned by the Assistant ARB entries.
- Assistant hero toggle strings (`assistantHeroCollapseAction` / `assistantHeroExpandAction`), the input
   disabled hint (`assistantInputDisabledHint`), and the desktop send shortcut hint
   (`assistantSendShortcutHint`) are owned by the Assistant ARB entries.
- Keep normal app pages limited to necessary titles, labels, values, statuses, and actions.
- Avoid explanatory, onboarding, or marketing-style page copy unless a task explicitly requires it.
- Remove l10n keys when the active UI that owns them is deleted.
- Scan feature strings such as recognition result titles, retake/confirm/close actions, method picker
  labels, barcode not-found toasts, recognition-failed dialog title/body, manual-search action, and
  recognizing hint (`scanRecognizingHint`) are owned by the Scan ARB entries (`scan*` keys).
- Scan OCR unavailable strings (`scanOcrUnavailableTitle`, `scanOcrUnavailableMessage`,
  `scanOcrUnavailableUseAi`) shown when the OCR engine fails to initialise (ABI mismatch, model
  corruption) are owned by the Scan ARB entries (`scan*` keys in `medicine_*.arb`).
- Record create-page section title strings (`recordCreateSectionBasicTitle` /
  `recordCreateSectionDetailsTitle`) and discard-changes confirmation copy
  (`recordDiscardChangesTitle` / `Message` / `Action`) are owned by the Record ARB entries.
- Record OCR empty-result copy (`recordOcrEmptyResult`) and back-to-today action
  (`recordBackToTodayAction`) are owned by the Record ARB entries.
- Record image camera action (`recordImageCameraAction`) is owned by the Record ARB entries.
- Mine account role text (`mineAccountStudentRole`) changed from "Student"/"大学生" to
  "User"/"用户" — owned by the Mine ARB entries.
- Auth QQ sign-in strings are owned by the Auth ARB entries (`authQqSignIn`,
  `authQqCallbackLabel`, `authQqCompleteAction`).
- Auth Weibo sign-in strings (`authWeiboSignIn`, `authWeiboCallbackLabel`,
  `authWeiboCallbackHint`, `authWeiboCompleteAction`, `authWeiboBrowserOpenFailed`,
  `authWeiboAuthorizeOpened`, `authWeiboCallbackRequiredToast`,
  `authWeiboCallbackInvalidToast`) are owned by the Auth ARB entries.
- Auth Google sign-in strings (`authGoogleSignIn`, `authGoogleCallbackLabel`,
  `authGoogleCallbackHint`, `authGoogleCompleteAction`, `authGoogleBrowserOpenFailed`,
  `authGoogleAuthorizeOpened`, `authGoogleCallbackRequiredToast`,
  `authGoogleCallbackInvalidToast`) are owned by the Auth ARB entries.
- Auth identity provider display names (`authIdentityProviderWeibo`,
  `authIdentityProviderGoogle`) are owned by the Auth ARB entries.
- Auth form strings such as login password hint (`authPasswordLoginHint`), register terms-required
  hint (`authRegisterTermsRequiredHint`), email verify action (`authEmailVerifyAction`), and danger-zone
  label (`authDeleteAccountDangerZoneLabel`) are owned by the Auth ARB entries.
- Notification accessibility semantics keys such as `notificationUnreadSemantics` are owned by the
  Notification ARB entries. Swipe-action labels (`notificationActionMarkRead` / `notificationActionMarkUnread`)
  are also owned by the Notification ARB entries.
- Deferred strings may remain only when deferred code still references them and the code is
   annotated.
- When an action moves to another tab, remove the old tab's action strings instead of keeping
   inactive labels.

## Add Or Change Text

1. Edit the appropriate fragment ARB file(s) in `lib/l10n/src/`.
2. Run merge + gen-l10n:

```bash
dart scripts/arb_tools.dart merge
flutter gen-l10n
```

3. Read strings through:

```dart
AppLocalizations.of(context)
```

4. Run at least:

```bash
flutter analyze
flutter test
```

## Locale Ownership

- `LuminousApp` reads `appLocaleControllerProvider` and passes the resolved locale into
   `MaterialApp.router.locale`.
- Lucent network requests reuse the same preference for `Accept-Language`.
- 网络层已迁移到 `generated/lucent_api`（`openapi_retrofit_generator` 生成的 Retrofit 客户端），
  `LucentDioClient` 仍然在拦截器中注入 `Accept-Language` header，行为不变。
- Signed-in language changes currently sync to Lucent profile fields through `locale / timezone /
   unitSystem`.
- Choosing `system` clears the backend locale preference.
- After auth restore or sign-in, `LuminousApp` may backfill the local locale from Lucent
   `profile.locale` when the value maps to `zh-CN`, `en`, or `system`.
- Notification type l10n includes `oauth_login`（登录提醒）and `identity_linked`（绑定提醒）,
  added 2026-07-20 to match Lucent `UserNotificationType` enum.

## 2026-07-26 Medicine risk-check coverage summary

- Added `medicineRiskCheckCoverageSummaryManual` and `medicineRiskCheckCoverageSummaryUnavailable` to
  `lib/l10n/src/medicine_en.arb` and `medicine_zh.arb`.
- Coverage summary strings are now composed in the presentation layer via
  `medicineRiskCheckCoverageSummary(l10n, coverageIssues)` instead of hardcoded Chinese in the
  domain service.
- The medicine fragment owns these keys; they are merged into `app_zh.arb` / `app_en.arb` by
  `dart scripts/arb_tools.dart merge` and then into Dart code by `flutter gen-l10n`.

## 2026-08-13 Review Task 8 More sheet 与分享口径

- Added 9 `reportMore*` keys to `lib/l10n/src/report_zh.arb` / `report_en.arb`（More sheet 标题
  「更多/More」与就诊摘要、PDF 报告、打印/下载、历史报告四个入口的标题/副标题），所有权在
  report 分片；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`
  （生成文件为 gitignore 产物）。
- 分享口径修正（不暗示医生一定查看）：`reportExportClinicShareTitle` 与
  `reportClinicSummaryShare` 从「分享给医生 / Share with doctor」改为「分享摘要 / Share summary」；
  就诊摘要入口副标题用「就诊时按需使用 / Use as needed during your visit」。分享仍为用户显式
  动作，后端 API 与数据流不变。
- Legacy 兼容页（`/report/legacy`）沿用 `tabReport` 与旧 `reportExport*` 文案，保持 Report 口径。

## 2026-08-14 Task 8 字段级隐私与分享管理

- Added `reportClinicSummaryField*` keys to `lib/l10n/src/report_zh.arb` / `report_en.arb`：字段选择面板标题「包含的内容 / Include」、六个字段（事件概况/症状变化/用药槽位/饮水/睡眠/备注）与隐私提示「仅所选内容会出现在预览、PDF 与分享链接中 / Only selected content appears in the preview, PDF and shared link.」。
- Added `reportShare*` keys：创建前确认（标题、`reportShareConfirmExpiryHint(days)` 占位 int「链接自创建起 {days} 天内有效 / The link is valid for {days} days from creation」、链接持有者可查看提示）、创建后（已创建标题、到期时间、复制链接、链接已复制 toast、撤销分享）、撤销后（已撤销标题与失效说明）、失败文案、分享管理面板（标题、空态、加载失败、创建时间/到期时间/`reportShareAccessCount(count)` 占位 int/最近访问/暂无访问/已撤销徽章）。
- Added `reportMoreShareManagement*` keys：More sheet 第五入口「分享管理 / Share management」标题与副标题。
- 所有权在 report 分片；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 Reminder delivery channel in_app label

- Added `medicineReminderDeliveryChannelInApp`（zh: 应用内通知 / en: In-app）to
  `lib/l10n/src/medicine_en.arb` and `medicine_zh.arb`。
- `deliveryChannelLabel` 新增 `in_app` 分支映射到新键；`local/push/email/sms` 标签保留为
  真实通道展示位（`in_app` 之前落入 `_ => value` 原样显示英文）。
- 所有权在 medicine 分片；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进
  `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 Medicine detail page (F-14) labels

- Added `medicineDetail*` keys to `lib/l10n/src/medicine_zh.arb` / `medicine_en.arb`：
  页面标题、加载失败标题/描述、未知数据源、无说明书内容空态、CN 头部元信息四标签
  （批准文号/生产企业/规格/商品名）、CN 说明书十二个分区标题、DrugBank 二十个分区标题，
  以及「查看我的用药风险检查」风险入口。
- 所有权在 medicine 分片（`medicine*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 Medicine adherence detail copy (F-5 P1)

- Changed `medicineAdherenceDetail` in `lib/l10n/src/medicine_zh.arb` / `medicine_en.arb` to the
  due-doses semantics：zh「今日已到期剂次中已确认占比」/ en「Share of today's due doses confirmed」，
  替换旧的「近期按时服药占比 / On-time doses over recent period」。
- 所有权在 medicine 分片（`medicine*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 Medicine dose check-in undo (F-3)

- Added `medicineDoseUndoAction`（zh: 撤销 / en: Undo）与 `medicineDoseUndoneToast`
  （zh: 已撤销本次打卡 / en: Dose check-in undone）to `lib/l10n/src/medicine_zh.arb` /
  `medicine_en.arb`。
- Home page dose check-in success toast now carries a「撤销 / Undo」action
  (`Toast.showWithAction`)；undo 反向 `mark(status: planned)` 成功后 toast 显示
  `medicineDoseUndoneToast`。
- 所有权在 medicine 分片（`medicine*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 F-19 处方导入占位清理（删除 medicineQuickActionPrescription* 3 键）

- 删除 `medicineQuickActionPrescriptionTitle` / `medicineQuickActionPrescriptionSubtitle` /
  `medicineQuickActionPrescriptionToast` 共 3 键（zh/en 各一份，medicine 分片）。
- 对应删除 `MedicineCopyKey.quickActionPrescriptionTitle` / `quickActionPrescriptionSubtitle`
  枚举值与 `medicineCopy` 映射分支、`_mobileScanQuickActions` 死数据条目（生产仓库与测试 mock）。
- 处方 OCR 识别保留为未来能力、不排期；「手动添加药物」意图由快捷操作区「添加药品」入口 +
  搜索/扫码「加入药箱」覆盖，不再显示处方导入占位入口。
- 经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`
  （生成文件为 gitignore 产物）。

## 2026-08-16 F-3 扫码结果出口 scan 键

- Added `scanBarcodeResultTitle`（zh: 扫码结果 / en: Scan result）、`scanViewInstructionsAction`
  （zh: 查看说明书 / en: View instructions）、`scanViewReminderAction`（zh: 查看提醒详情 /
  en: View reminder details）to `lib/l10n/src/medicine_zh.arb` / `medicine_en.arb`。
- 扫码结果 sheet（`barcode_scanner.dart`）使用这三键：主/次按钮（加入药箱复用
  `medicineSearchAddToBoxAction`、「已添加」复用 `medicineSearchAlreadyAddedLabel`）。
- 所有权在 medicine 分片（`scan*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 Search add pre-check unavailable toast (F-9)

- Added `medicineSearchPrecheckUnavailableToast`（zh: 暂无法即时检查该药品，加入后可在风险检查中查看 /
  en: Could not pre-check this medicine right now; you can review it in risk check after adding it.）to
  `lib/l10n/src/medicine_zh.arb` / `medicine_en.arb`。
- Search page「加入药箱」即时预检失败时展示该 toast（不阻塞添加，也不输出安全判断），随后仍走
  带「去设提醒」action 的成功 toast；既有 `medicineSearchPrecheck*` 文案（标题「添加前风险检查」等）
  保持不变——预检范围现在真实包含待加药品，语义成立。
- 所有权在 medicine 分片（`medicine*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 F-6 识别结果弹窗 scan 键（去假置信度）

- Added `scanResultVerifyHintAi`（zh: AI 识别结果，需核对药品名、批准文号和规格。 / en: AI
  recognition result. Verify the medicine name, approval number, and specification.）and
  `scanResultVerifyHintOcr`（zh: 本地 OCR 识别结果，请核对药品名与批准文号。 / en: Local OCR
  recognition result. Verify the medicine name and approval number.）to
  `lib/l10n/src/medicine_zh.arb` / `medicine_en.arb`。
- Deleted `scanResultConfidenceLabel`（含 `@scanResultConfidenceLabel` 占位符块）、
  `scanResultConfidenceExplanation`、`scanConfirmDetailAction`（zh/en 各一份，medicine 分片）——
  AI 识别路径不再构造假置信度，弹窗不再展示置信度百分比与解释、按钮改为「加入药箱」。
- `MedicineRecognizeDialog` 使用 `scanResultVerifyHint*`（top 卡片核对提示，按识别方法区分）、
  `medicineSearchAddToBoxAction` / `medicineSearchAlreadyAddedLabel`（主按钮与已加入态，复用搜索
  页键）、`scanViewReminderAction` / `scanViewInstructionsAction`（F-3 已加，本次复用）。
- 所有权在 medicine 分片（`scan*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 F-10 扫码/拍照入口上浮（复用既有 quick action 键，未新增）

- Medicine 页快捷操作区新增「扫描条形码」与「拍照识别药品」两项，复用既有
  `medicineQuickActionBarcodeTitle` / `medicineQuickActionBarcodeSubtitle` /
  `medicineQuickActionCameraTitle` / `medicineQuickActionCameraSubtitle` 四键
  （zh/en 各一份，medicine 分片，`lib/l10n/src/medicine_zh.arb` / `medicine_en.arb`），
  未新增 l10n 键。
- 所有权在 medicine 分片（`medicine*` 前缀）；这些键原由 barcode_scanner 页头与
  `MedicineCopyKey.quickAction*` 映射（lucent_workspace 桌面快捷动作数据）消费，
  现增加 Medicine 主页快捷操作区一个消费方。经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-16 F-11 桌面预览面板去造假（删除 medicineSearchPreviewClinical / medicineSearchPreviewSafety）

- 删除 `medicineSearchPreviewClinical` / `medicineSearchPreviewSafety` 两键
  （zh/en 各一份，medicine 分片，`lib/l10n/src/medicine_zh.arb` / `medicine_en.arb`）：
  桌面 `PreviewPanel` 不再把「规格 / 厂商」subtitle 当临床提示展示、不再渲染恒空
  安全清单，两键已无任何引用（`medicineSearchPreviewTitle` / `medicineSearchPreviewEmpty` 保留）。
- 所有权在 medicine 分片（`medicine*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-17 F-8 + F-16 数据层 degraded 标记文案

- 新增 `todayMetricDegraded`（zh: 暂不可用 / en: Temporarily unavailable）到 `lib/l10n/src/today_zh.arb` / `today_en.arb`。
- `buildOverviewItems` 在水、用药、睡眠指标的上游数据源失败时，将值渲染为该键；`_CompactSummaryMetric` 对 `isDegraded` 使用 destructive 颜色 + w500 字重，与未记录的 muted 样式区分。
- 所有权在 today 分片（`today*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 F-1 skip_dose 失败 toast 文案

- 新增 `todaySuggestionSkipDoseError`（zh: 跳过本次用药失败，请稍后再试 / en: Failed to skip this dose, please try again later）到 `lib/l10n/src/today_zh.arb` / `today_en.arb`。
- `suggestion_primary_card.dart` 的 `_skipDose` catch 分支改用该键，避免复用反馈失败的 `todaySuggestionFeedbackError`。
- 所有权在 today 分片（`today*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。

## 2026-08-17 F-10 健康观察关联选项加载失败重试提示

- 新增 `todayHealthEventOptionsLoadFailed`（zh: 加载失败，可重试 / en: Failed to load options, please try again）到 `lib/l10n/src/today_zh.arb` / `today_en.arb`。
- 新增 `todayHealthEventOptionsRetryAction`（zh: 重试 / en: Retry）到 `lib/l10n/src/today_zh.arb` / `today_en.arb`；`StartEventSheet` 重试按钮改用该独立键，不再复用 `todaySuggestionAiExplainRetry`。
- `StartEventSheet` 在当前用药或触发症状选项预读失败时，于对应选项区显示错误文案与 ghost `xs`“重试”按钮。
- 所有权在 today 分片（`today*` 前缀）；经 `dart scripts/arb_tools.dart merge` +
  `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。


## 2026-08-17 F-6 + F-7 Today AI 摘要物化状态文案

- 新增以下键到 `lib/l10n/src/today_zh.arb` / `today_en.arb`：
  - `todayAnalysisEmptyTitle` / `todayAnalysisEmptyBody`：`empty` 物化状态下的空态标题与说明。
  - `todayAnalysisPendingHint`：服务端正在物化时的提示。
  - `todayAnalysisStaleHint`：物化结果已过期、正在重新物化时的提示。
  - `todayAnalysisFailedHint`：物化失败时的提示。
  - `todayAnalysisRefreshAction`：物化提示条与空态的刷新操作文案。
- 所有权在 today 分片（`today*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。


## 2026-08-17 F-3 AI 解释规则兜底标签

- 新增 `todaySuggestionRuleBasedLabel`（zh: 基于规则 / en: Rule-based）到 `lib/l10n/src/today_zh.arb` / `today_en.arb`。
- `SuggestionAiExplainButton` 在 `aiGenerated == false` 时直接展示后端返回的 fallback 解释内容，并用该键替换原有的「AI」标签，不再自动重试。
- 所有权在 today 分片（`today*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 F-7 来源条组件键

- 新增 14 个 `assistantSource*` 键到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`：
  - `assistantSourceExpandAction`（查看详情 / View details）与 `assistantSourceCollapseAction`（收起 / Collapse）：来源条折叠行展开/收起动作语义标签。
  - `assistantSourceCoverageLabel`（覆盖 / Coverage）、`assistantSourceConfidenceLabel`（置信 / Confidence）、`assistantSourceAmbiguitiesLabel`（不确定项 / Ambiguities）、`assistantSourceSourceLabel`（来源 / Source）、`assistantSourceGeneratedAtLabel`（生成时间 / Generated at）：展开卡内容行标签。
  - `assistantSourceCoverageComplete`（完整 / Complete）、`assistantSourceCoveragePartial`（部分 / Partial）、`assistantSourceCoverageEmpty`（无数据 / No data）：覆盖状态三态本地化。
  - `assistantSourceConfidenceHigh`（高 / High）、`assistantSourceConfidenceMedium`（中 / Medium）、`assistantSourceConfidenceLow`（低 / Low）：置信三档本地化。
  - `assistantSourceNoDetailsNote`（该消息的工具详情暂不可用 / Tool details are unavailable for this message）：该工具无 toolDetails 条目时的占位文案。
- 来源条折叠行标题复用既有 `assistantUsedToolsLabel`（参考来源 / Sources used），未新增键。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 F-13 + F-15 AI 回答免责与来源级信任分层键

- 新增 7 个 `assistant*` 键到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`：
  - `assistantDisclaimerText`（zh: AI 回答仅供健康参考，不构成医疗诊断或用药建议；用药调整请咨询医生或药师。/ en: AI responses are for health reference only…）：助手消息免责条与欢迎面板免责区的固定免责文案。
  - `assistantSourceBadgeLeaflet`（说明书 / Leaflet）、`assistantSourceBadgeDrugbank`（DrugBank / DrugBank）、`assistantSourceBadgeMedicalQa`（医疗问答 / Medical Q&A）：来源条折叠行知识工具信任层级徽标。
  - `assistantSourceLowTrustHint`（低可信教育参考 / Low-trust educational reference）：medicalQa 工具出现时折叠行下方的固定低可信提示。
  - `assistantDisclaimerShowAction`（展开免责说明 / View disclaimer）与 `assistantDisclaimerCollapseAction`（收起免责说明 / Collapse disclaimer）：欢迎面板免责区展开/收起语义标签。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

- 修改 `lib/l10n/src/today_zh.arb` / `today_en.arb` 中的 `todayGreetingAfternoonWaterShort`：占位符由 `count`（次）改为 `gap`（int，ml），中文文案改为「下午好，饮水还差 {gap} ml」，英文文案改为 "Good afternoon, {gap} ml of water to go"。
- 新增 `todayGreetingAfternoonWaterUnknown`（zh: 下午好，今天还没记饮水 / en: Good afternoon, no water logged today）。
- `greetingSubtitle` 的 afternoon 分支改为基于 `water.observedMetric.state`：
  - `observed`：按 `targetMl - observedMl` 计算 ml 缺口，缺口 > 0 使用 `todayGreetingAfternoonWaterShort(gap)`，缺口 ≤ 0 使用 `todayGreetingAfternoonWaterDone`。
  - `unknown` 或无法确认的状态：使用 `todayGreetingAfternoonWaterUnknown`。
- 所有权在 today 分片（`today*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 F-9 跨会话记忆提示键

- 新增 `assistantMemoryHintTitle`（zh: 已开启跨会话记忆 / en: Cross-conversation memory is on）与 `assistantMemoryHintDescription`（zh: 你的对话会被提炼为要点，用于延续后续对话；可在设置中关闭。/ en: Your chats may be distilled into points used in later conversations. You can turn this off in settings.）到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`。
- `AssistantWelcomePanel` 在 `showMemoryHint: true` 时于免责区上方渲染记忆提示块（`SemanticIcons.statusInfo` + 两行小字，样式与免责区一致）。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 F-11/F-16 过期提案重新生成动作键

- 新增 `assistantProposalRegenerateAction`（zh: 重新生成 / en: Regenerate）到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`。
- `AssistantProposalCard` 在提案过期时于按钮行新增 ghost「重新生成」按钮，onPress 复用产生该提案的用户消息重走流式生成管线（`AssistantController.regenerateExpiredProposal`）。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 F-2 会话重命名与删除键

- 新增 7 个 `assistantConversation*`/`assistantClearingConversation*` 键到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`：
  - `assistantConversationRenameDialogTitle`（重命名会话 / Rename conversation）：重命名对话框标题。
  - `assistantConversationRenameHint`（输入新标题 / Enter a new title）：重命名输入框占位提示。
  - `assistantConversationDeleteConfirmTitle`（删除会话？/ Delete conversation?）与 `assistantConversationDeleteConfirmDescription`（删除后不可恢复。/ This cannot be undone.）：删除二次确认对话框标题与描述。
  - `assistantConversationDeletedToast`（会话已删除 / Conversation deleted）：删除成功 toast。
  - `assistantClearingConversationLabel`（归档中… / Archiving…）：当前会话归档时抽屉行 suffix 的 loading 标签（替换「当前」）。
  - `assistantConversationTapToName`（点击补名 / Tap to name）：空标题会话的补名入口文案。
- 对话框确认/取消复用既有 `commonConfirm` / `commonCancel`；「重命名」「删除」菜单项复用既有 `assistantConversationRenameAction` / `assistantConversationDeleteAction`，未新增重复键。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 T8 设置页 AI 隐私说明与上下文开关 toast 键

- 新增 5 个 `settings*` 键到 `lib/l10n/src/settings_zh.arb` / `settings_en.arb`：
  - `settingsAiContextChangeNextTurnToast`（上下文开关将在下次对话生效 / Context changes take effect from the next conversation）：AI 设置页上下文开关切换成功后的 toast。
  - `settingsAiPrivacySectionTitle`（AI 隐私 / AI Privacy）：设置页上下文开关组之后的 AI 隐私小节标题。
  - `settingsAiPrivacyMemoryNote`（开启记忆后，此前对话中提炼的要点会在后续对话中提供给 AI。/ When memory is on, key points distilled from your past chats may be provided to the AI in later conversations.）：记忆开启时的数据使用说明。
  - `settingsAiPrivacyContextNote`（勾选的数据来源（健康档案、日常记录、睡眠记录、当前用药）会在对话时提供给 AI。/ Selected sources (health profile, daily records, sleep records, current medicines) are provided to the AI during conversations.）：上下文开关勾选来源的数据使用说明。
  - `settingsAiPrivacyHistoricalNote`（关闭开关不会删除历史数据，只会停止后续使用。/ Turning a switch off never deletes historical data; it only stops future use.）：关闭开关不回退删除历史数据的说明。
- 所有权在 settings 分片（`settings*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 T9a Markdown 链接确认键

- 新增 3 个 `assistantMarkdownLink*` 键到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`：
  - `assistantMarkdownLinkConfirmTitle`（打开外部链接？/ Open external link?）：AI 消息气泡中 Markdown 链接点击后的确认对话框标题。
  - `assistantMarkdownLinkConfirmDescription`（该链接将离开应用打开。/ This link opens outside the app.）：确认对话框说明。
  - `assistantMarkdownLinkOpenAction`（打开 / Open）：确认对话框「打开」按钮；取消复用 `commonCancel`。
- F-4 链接契约：链接默认不自动跳转，先弹确认对话框，确认后经 `ExternalUrlLauncher` 打开（仅放行 http/https；链接域白名单规则未定，暂不做硬校验）。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。

## 2026-08-17 T9c 旧回答灰态 / 能力详情面板 / F-14 数据截至键

- 新增 18 个 `assistant*` 键到 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`：
  - `assistantReplacedLabel`（已替换 / Replaced）：F-5b 重新生成后被替换旧回答右上角小标签。
  - `assistantCapabilitiesAction`（能力详情 / Capabilities）：F-10 能力详情面板标题与页面入口 tooltip。
  - `assistantCapabilitiesSummaryTitle`（能力摘要 / Capability summary）：面板顶部能力摘要小节标题。
  - `assistantCapabilitiesToolsTitle`（工具 / Tools）：面板工具清单小节标题（计数 N / M 为纯数字拼接，不占位符）。
  - `assistantCapabilitiesRagLabel`（RAG 检索 / RAG retrieval）：摘要行第三项标签（AI 对话 / 持久化记忆复用 `assistantSettingsEnableTitle` / `assistantSettingsMemoryTitle`）。
  - `assistantCapabilitiesEnabledValue`（已启用 / Enabled）与 `assistantCapabilitiesDisabledValue`（已关闭 / Disabled）：摘要行开关值。
  - `assistantToolEnabledLabel`（可用 / Available）：能力面板中 enabled 工具的状态文案。
  - `assistantToolDisabledGeneric`（已停用 / Disabled）：disabled 但无具体原因时的兜底文案。
  - `assistantToolDisabledChat`（对话功能未启用 / Chat is disabled）、`assistantToolDisabledContext`（未开放所需健康上下文 / Required context not granted）、`assistantToolDisabledModel`（服务端模型未配置 / Model not configured）、`assistantToolDisabledNotImplemented`（尚未实现 / Not implemented yet）：后端 `AssistantToolDisabledReason` 四值（chat_disabled / context_disabled / model_not_configured / not_implemented）的用户话术；未知值显示原文不硬造。
  - `assistantToolSearchCnMedicineProducts`（中文药品检索 / Chinese medicine product search）、`assistantToolCnMedicineDetail`（中文药品详情 / Chinese medicine product detail）、`assistantToolDrugbankDetail`（DrugBank 详情 / DrugBank detail）：补全 `localizeToolName` 此前缺失的 3 个工具名。
  - `assistantSourceDataAsOfLabel`（数据截至 / Data as of）：来源条展开卡 F-14「数据截至」行标签。
  - `assistantSourceVersionLabel`（版本 / Version）：confidenceNote 缺失时 sourceVersion 兜底文本「版本 <v>」的标签。
- 所有权在 assistant 分片（`assistant*` 前缀）；经 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 合并进 `app_*.arb`（生成文件为 gitignore 产物）。
- 顶部 `Last updated` 已同步记录本次新增。
