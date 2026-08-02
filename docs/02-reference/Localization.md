---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-02
---

# Flutter Localization

Last updated: 2026-07-30 (OAuth Weibo + Google sign-in strings)

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
- Assistant strings use `assistant*` ARB keys directly. Do not reintroduce compatibility alias
   layers for assistant l10n.
- Report AI summary state copy such as generate/loading/error/disabled hints is owned by the Report
   ARB entries, not by repository/domain fallback strings.
- Report readiness state copy such as status badges, updated-at wording, locked-feature hints,
  keep-recording CTA labels, and score summary is owned by the Report ARB entries.
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
- Record detail page strings (`recordDetail*`, including water progress, copy summary, and
  adjacent-navigation labels) and record edit discard strings (`recordEditDiscard*`) are owned by
  the Record ARB entries. Water default customization strings (`recordQuickSettingsWaterCustom*`)
  are also Record-owned and used by both the quick-entry settings page and the long-press dialog.
- Record quick medication strings (`recordQuickMedication*`) are owned by the Record ARB entries,
  even when an action routes to Medicine search, because the prompt and selection dialog live on the
  Record page.
- Record quick sleep strings (`recordQuickSleep*`) are owned by the Record ARB entries because the
  start toast, multi-start selection, merge confirmation, and sleep in-progress badge live on the
  Record page.
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
  observation wording, and quick-action labels is owned by the Today ARB entries.
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
- Report root-page suggestion-history copy such as section title, empty state, lifecycle
  badges, and suggestion detail sheet labels (rule ID, trigger type, confidence, generated-at,
  feedback, expired-at) is owned by the Report ARB entries.
- Theme settings now own both mode strings (`system / light / dark`) and theme-family strings
  (`blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc`), plus the
  section labels used by the theme settings subpage and the general-settings summary.
- Assistant tool inventory strings are owned by the Assistant ARB entries, including medicine
   retrieval tools such as leaflet search, DrugBank entity resolution, DrugBank passage search, and
   medical-QA search.
- Assistant controls drawer strings such as the drawer title (`assistantControlsDrawerTitle`) and the
   disabled-by-user hint (`assistantConversationDisabledByUserHint`) are owned by the Assistant ARB
   entries. The hint text references the top-right settings entry point.
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
