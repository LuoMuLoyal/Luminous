# Luminous Next Plan

Last updated: 2026-06-12

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

Use the Product_Vision-converged five-tab mobile UI as the baseline, then move into real daily health loops without presenting mock or deferred features as real capability.

## Completed

- **Record form maintenance** (2026-06-10): aligned quick-action visibility with create capability, removed static mock timeline fallback from Lucent repository, promoted `note` to a first-class `RecordEntryType` with its own mapping/filter/timeline, locked down active create kinds (water, meal, symptom, note), and added regression tests. All 165 tests pass; `flutter analyze` clean.
- **Mine and Settings contracts** (2026-06-11): Lucent now exposes user settings, support resources/app info, and data export request status; Luminous wires Mine campus resources and Settings privacy/export/help/about/reminder summaries to real contracts or local state. User-scoped business APIs now live under `/api/v1/user/*`; the old `me` namespace has been removed.

## Immediate Work Order

1. **Report Phase 2 stabilization**
   - Active plan: `../plans/2026-06-12-report-contracts.md`.
   - Phase 1 contract wiring is in place on both Lucent and Luminous, the frontend hardcoded report chrome cleanup is done, and repository-level DTO-to-domain regression coverage is now in place for sleep `insufficient_data`, AI summary mode, and export action mapping.
   - Next focus:
     - decide whether report signed-out state should stay as a full-page gate or align with the protected-tab placeholder pattern used elsewhere
     - trim low-value generated OpenAPI doc/test noise only if it can be done without breaking the local path-package workflow
   - Sleep remains deferred as a later contract slice, but Report must keep explicit missing-data handling instead of faking values.

2. **Local full-stack lane usage rule**
   - Keep the current Record lane out of GitHub Actions for now.
   - Owner command for manual verification:
     - backend shell:
       `cd Lucent`
       `pnpm dev:stack:up`
       `pnpm db:migrate:test`
       `pnpm start:test:dev`
     - frontend shell:
       `cd Luminous`
       `flutter test integration_test/fullstack_record_lane_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`
   - Expected run timing:
     - before merging any change that touches auth/session restore
     - before merging any Lucent or Luminous change that touches `/api/v1/user/daily-records*`
     - before merging changes to the full-stack E2E helper or generated auth/record client surface
     - before cutting a mobile test build that claims Record CRUD is stable

3. **AI follow-up order after Report**
   - After Report contracts are stable, continue in this order:
     - Today AI analysis
     - weekly/monthly AI summary
     - natural language to candidate records
     - screenshot to candidate structured input
   - Do not jump to scheduled proactive AI pushes before the manual Today path and report aggregate layer are stable and bounded.

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- After the five-tab UI stabilizes, run a focused truncation pass for English and Chinese button labels, pills, and compact rows across Today, Record, Medicine, Report, and Mine.
- Sleep entry shapes.
- Lightweight mood record shapes.
- Environment signals for contextual Today/Mine use.
- Medicine scan/OCR/photo/barcode/prescription action shapes.

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

- Workspace path `Lucent/docs/public/reminder-contract.md`: reminder boundary.
- Workspace path `Lucent/docs/public/environment-contract.md`: environment snapshot boundary.
- Workspace path `Lucent/docs/public/data-sources.md`: medicine data-source/import strategy.
