# Luminous Next Plan

Last updated: 2026-06-13

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

Sleep structured field delivery is complete. Keep AI work deferred for now and spend the next slot on non-AI cleanup, verification, or product-surface work.

## Immediate Work Order

1. **Sleep contract + persistence MVP** ✅ DONE
   - Execution plan reference:
     - `Luminous/plans/2026-06-13-sleep-contract-slice.md`
   - Completed:
     - Lucent `DailyRecordKind.sleep` enum + payload field on DTOs
     - Lucent today-analysis reads real sleep data from payload
     - Lucent reports compute real sleep metrics from persisted data
     - Luminous Record create/detail/edit/timeline/filter wiring for sleep
     - Luminous Today sleep summary reads real duration from payload
     - Luminous Report sleep trend uses real backend data
     - Sleep payload supports: startAt, endAt, durationMinutes, quality, deepMinutes, lightMinutes, remMinutes

2. **Sleep structured fields — frontend delivery** ✅ DONE
   - Completed:
     - Removed the old sleep value/unit form path and replaced it with bedtime, wake time, quality, and stage-duration inputs
     - `record_create.dart` and `record_edit.dart` now write/read the full structured payload
     - `record_detail.dart` now renders time range, duration, quality, and sleep-stage rows
     - sleep timeline rows now derive a compact duration label from payload even when `value/unit` are intentionally null
     - identical bedtime and wake time are rejected instead of being interpreted as a 24-hour sleep
     - offline/full-stack sleep integration lanes now drive keyed pickers directly without extra `dart-define` setup

3. **Local full-stack lane usage rule**
   - Keep the current Record lane out of GitHub Actions for now.
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
   - Because `integration_test/` now lives in nested feature folders, always run those tests with an explicit file path and explicit device id. Plain `flutter test integration_test` is ambiguous when desktop/web targets are also available.
   - Expected run timing:
     - before merging any change that touches auth/session restore
     - before merging any Lucent or Luminous change that touches Today or Report protected root-tab loading
     - before merging any Lucent or Luminous change that touches `/api/v1/user/daily-records*`
     - before merging changes to the full-stack E2E helper or generated auth/record client surface
     - before cutting a mobile test build that claims Record CRUD is stable

4. **AI follow-up order — STILL DEFERRED**
   - Sleep structured fields are verified locally.
   - Resume AI only when we explicitly switch back to AI work.
   - Continue in this order:
     - monthly AI summary
     - natural language to candidate records
     - screenshot to candidate structured input
   - Do not jump to scheduled proactive AI pushes before the manual Today path, report aggregate layer, and sleep contract are all stable and bounded.

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
