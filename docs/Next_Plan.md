# Luminous Next Plan

Last updated: 2026-06-14

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

Natural-language record intake phase 1 is now usable enough for MVP continuation. Next focus should move back to missing core product features instead of spending another round on local polish.

## Immediate Work Order

1. **Close the biggest remaining fake surfaces**
   - Priority order:
     - wire Mine campus/support resource taps to real actions when `actionUrl` is usable
     - wire at least one Report export action to the existing Lucent data-export request flow
     - decide whether the Medicine risk-check entry can be connected to a real source-backed flow now; if not, narrow the visible promise so it stops reading like an implemented feature
   - Success signal:
     - at least one previously toast-only MVP-facing entry becomes real, or the UI/doc promise is explicitly narrowed

2. **Local full-stack lane usage rule**
   - Keep the current emulator + Lucent full-stack gate out of GitHub Actions for now.
   - Repo-safe daily entry:
     - `powershell -ExecutionPolicy Bypass -File tool/run_daily_checks.ps1`
   - Full-stack gate entry:
     - `powershell -ExecutionPolicy Bypass -File tool/run_fullstack_checks.ps1`
   - Owner command for manual verification:
     - backend shell:
       `cd Lucent`
       `pnpm dev:stack:up`
       `pnpm db:migrate:test`
       `pnpm start:test:dev`
     - frontend shell:
       `cd Luminous`
       `flutter test integration_test/record/fullstack_record_lane_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`
     - frontend shell:
       `flutter test integration_test/record/fullstack_sleep_lane_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`
     - frontend shell:
       `flutter test integration_test/app/fullstack_today_report_lane_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`
   - `tool/run_fullstack_checks.ps1` is the preferred local entry because it starts Lucent test runtime and runs the four emulator lanes sequentially with one shared define set.
   - Because `integration_test/` now lives in nested feature folders, always run those tests with an explicit file path and explicit device id. Plain `flutter test integration_test` is ambiguous when desktop/web targets are also available.
   - Expected run timing:
     - before merging any change that touches auth/session restore
     - before merging any Lucent or Luminous change that touches Today or Report protected root-tab loading
     - before merging any Lucent or Luminous change that touches `/api/v1/user/daily-records*`
     - before merging changes to the full-stack E2E helper or generated auth/record client surface
     - before cutting a mobile test build that claims Record CRUD is stable

3. **Natural-language record intake follow-up**
   - Phase 1 now exists on mobile Record:
     - FAB + AI input bar open one shared bottom sheet
     - text note -> Lucent candidate records
     - user can edit/select/remove candidates
     - save-selected writes confirmed records through existing daily-record create flow
   - Current stopping point:
     - per-kind edit polish is in place for water / meal / symptom / note / sleep
     - sheet has focused widget coverage for editable/selective save plus water unit switching
   - Remaining follow-up only when it blocks MVP usage:
     - explicit partial-failure surface beyond toast-only feedback
     - one real integration lane for NLP review/save if this flow starts regressing
   - Do not expand this into broad “AI everywhere” work before missing non-AI MVP capability gaps are closed.

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- After the five-tab UI stabilizes, run a focused truncation pass for English and Chinese button labels, pills, and compact rows across Today, Record, Medicine, Report, and Mine.
- Lightweight mood record shapes.
- Environment signals for contextual Today/Mine use.
- Medicine scan/OCR/photo/barcode/prescription action shapes.
- Local-only sleep reminder preferences beyond simple placeholder labeling.

Pregnancy/lactation/special-group medication safety remains active only inside Medicine safety boundaries.

## Do Not Start Yet

- Standalone More tab or generic utility hub.
- Women-health or period management.
- Sport recovery.
- Specialist health packs.
- Smart devices or family profiles.
- Skin recognition or report photo import.
- OCR/barcode/photo/prescription recognition UI or contracts.
- Real push delivery through FCM/APNs.
- Real SMS delivery.
- Backend reminder delivery workers.
- Paid or credentialed external services without explicit approval.
- Environment frontend wiring until the target Today/Mine job is explicit.

## Contract References

- `Lucent/docs/public/reminder-contract.md`: reminder boundary.
- `Lucent/docs/public/environment-contract.md`: environment snapshot boundary.
- `Lucent/docs/public/data-sources.md`: medicine data-source/import strategy.
