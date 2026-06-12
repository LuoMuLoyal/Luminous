# Luminous Next Plan

Last updated: 2026-06-12

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

Use the Product_Vision-converged five-tab mobile UI as the baseline, then move into real daily health loops without presenting mock or deferred features as real capability.

## Completed

- **Record form maintenance** (2026-06-10): aligned quick-action visibility with create capability, removed static mock timeline fallback from Lucent repository, promoted `note` to a first-class `RecordEntryType` with its own mapping/filter/timeline, locked down active create kinds (water, meal, symptom, note), and added regression tests. All 165 tests pass; `flutter analyze` clean.
- **Mine and Settings contracts** (2026-06-11): Lucent now exposes user settings, support resources/app info, and data export request status; Luminous wires Mine campus resources and Settings privacy/export/help/about/reminder summaries to real contracts or local state. User-scoped business APIs now live under `/api/v1/user/*`; the old `me` namespace has been removed.
- **Report Phase 2 closeout** (2026-06-12): Lucent now exposes `/api/v1/user/reports/dashboard`; Luminous uses the real report contract, keeps explicit sleep `insufficient_data`, aligns signed-out behavior with other protected tabs, adds mobile pull-to-refresh, and trims generated OpenAPI doc/test noise from the regeneration workflow.
- **Today AI analysis** (2026-06-12): Lucent now exposes `POST /api/v1/user/today-analysis/generate`; Luminous replaces the static Today AI placeholder with a manual authenticated generate flow, respects the existing AI-summary setting, and covers the card with split page/widget/provider tests. Lucent fallback/prompt copy now follows request language for `zh-CN` and `en`.

## Immediate Work Order

1. **AI architecture follow-up**
   - Decide the backend execution boundary for the next AI slice:
     - keep bounded linear flows for manual Today / weekly / monthly summaries
     - or introduce a tool-capable orchestrator only for workflows that truly need branching, retrieval, or multi-step tool use
   - Do not refactor the shipped Today manual path into a generic agent runtime unless the next slice actually needs tool selection or multi-step control flow.
   - Before broader AI work, remove remaining hardcoded backend AI copy outside Today and define one shared locale-aware prompt/copy pattern.

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
   - Because `integration_test/` now lives in nested feature folders, always run those tests with an explicit file path and explicit device id. Plain `flutter test integration_test` is ambiguous when desktop/web targets are also available.
   - Expected run timing:
     - before merging any change that touches auth/session restore
     - before merging any Lucent or Luminous change that touches `/api/v1/user/daily-records*`
     - before merging changes to the full-stack E2E helper or generated auth/record client surface
     - before cutting a mobile test build that claims Record CRUD is stable

3. **Review-confirmed backlog / TODO**
   - Scope alignment around sleep remains unfinished:
     - Today still shows a placeholder sleep vital row.
     - Record still exposes sleep in placeholder-only quick-action/filter paths.
     - Settings still stores a local sleep reminder preference even though no real sleep contract exists.
   - Frontend coverage gaps still worth filling:
     - `UserSettingsController` toggle flows
     - `DataExportController` request/refresh flow
     - `ReportRemoteDataSource` request path
     - health-context write HTTP-layer tests beyond payload serialization
   - Placeholder copy cleanup is still pending:
     - user-visible `mock data` error text in ARB
     - fake medicine-name placeholder strings such as `Metformin XR` / `Atorvastatin calcium` / `Omeprazole capsules`
   - Lucent hardening still remains:
     - remove code-level fallback JWT/admin secrets and move dev defaults to env templates only
     - align `testing-support` password hashing with the shared `ARGON2_OPTIONS`

4. **AI follow-up order after Today**
   - Continue in this order after the manual Today path is stable:
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
