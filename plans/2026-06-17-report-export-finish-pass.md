# Report Export Finish Pass

Last updated: 2026-06-17

## Goal

Finish the remaining low-risk report/export productization work in Luminous without reopening backend contracts or adding new export features.

This plan is intentionally for the remaining simple work only. Lucent PDF productization has already advanced beyond the original baseline and should not be re-scoped here.

## Scope

Do:

- unify final export status wording between Report and Mine
- make expired or missing download links explicit
- refresh latest export status before trying to open an old download URL
- run one real-environment export acceptance pass for:
  - `hospital + pdf + last_7_days`
  - `monthly + pdf + last_30_days`
  - `print + pdf + last_7_days`
- update frontend docs so export is described as a finished real slice with known boundaries

Do not:

- add docx
- add export history
- add share links
- add async worker queueing
- redesign Lucent export DTOs
- reopen web or desktop scope

## Assumptions

- Lucent export APIs are already stable enough for this finish pass.
- The remaining work is mostly UI wording, state consistency, and acceptance verification.
- If a real-environment export fails, treat that as a bug to document and route back, not as a reason to widen scope.

## Files Most Likely To Change

- `lib/features/report/presentation/pages/report_page.dart`
- `lib/features/report/presentation/widgets/report_sections.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/providers/data_export_controller.dart`
- `lib/l10n/app_zh.arb`
- `lib/l10n/app_en.arb`
- `test/report/report_page_test.dart`
- `test/settings/data_export_controller_test.dart`
- `test/settings/settings_page_test.dart`
- `docs/Current_State.md`
- `docs/Next_Plan.md`
- `docs/TODO.md`
- `docs/migration-log/2026-06-17.md`

## Execution Steps

1. Status model check
   - Confirm Report and Mine still use the same `DataExportUiStatus`
   - Confirm `completed-but-no-link` stays distinct from normal completed

2. Open-before-refresh fix
   - Before opening a previously shown export link, refresh latest export status once
   - If latest status is completed but no link is returned, show the bounded “link missing/expired” wording

3. Final wording pass
   - Remove any leftover wording that sounds like export is still fake or placeholder
   - Keep wording short and operational, not explanatory

4. Real acceptance pass
   - Run all three real export kinds in an environment with working COS
   - Verify:
     - request submitted
     - processing/completed transition
     - file opens
     - re-open path after link refresh still behaves correctly

5. Docs closeout
   - Update `Current_State.md` to describe export as a finished real slice
   - Remove export from “rough real slice” positioning in `Next_Plan.md`
   - Keep only true deferred items in `TODO.md`

## Validation

- `flutter test test/report/report_page_test.dart`
- `flutter test test/settings/data_export_controller_test.dart`
- `flutter test test/settings/settings_page_test.dart`
- `flutter analyze`

Real-environment acceptance:

- one signed-in mobile/manual run covering all three export kinds

## Done Signal

- Report and Mine no longer feel like two different export systems
- old download links do not fail silently
- docs stop treating export as the next weak real slice
- remaining export backlog is clearly optional, not MVP-critical
