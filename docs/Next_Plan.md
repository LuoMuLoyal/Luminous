# Luminous Next Plan

Last updated: 2026-06-15

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

Today/Report AI summary streaming is in place for MVP, export and reminder scope have now been narrowed to match the real shipped boundary, and Medicine already shares a more explicit risk-check boundary across the main page and add-before-save precheck. Campus/help resource completeness and offline-care discovery are no longer on the MVP critical path. The next focus should move from feature expansion to MVP closeout: remaining Medicine safety hardening, deterministic validation, and demo readiness.

## Immediate Work Order

1. **Finish the next Medicine safety-hardening pass**
   - Priority order:
     - keep the current shared coverage-summary / unknown-state behavior stable across all Medicine safety entry points
     - decide whether any remaining near-term hardening is still needed before red-flag work, such as a small reviewed interaction expansion or tighter cross-source duplicate handling
     - keep uncertainty explicit instead of adding fake confidence
   - Success signal:
     - the product can demonstrate stable “new medicine -> reviewed warning or explicit unknown” paths without hand-waving around the coverage boundary

2. **Run MVP closeout validation and freeze the promise**
   - Priority order:
     - keep campus/help resource completeness, map discovery, and agent-assisted support lookup out of the current MVP promise
     - run repo-safe daily checks plus the local full-stack gate against the frozen MVP path
     - turn any remaining half-real UI states into explicit boundary wording instead of relying on oral explanation
   - Success signal:
     - the mobile MVP can be demoed end to end without relying on post-MVP support-discovery work or ad-hoc caveats

3. **Local full-stack lane usage rule**
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

4. **Keep AI work in maintenance mode**
   - Today and Report AI cards now stream partial summary text and finish with the same structured payload as the one-shot flow.
   - Only revisit this slice when:
     - stream stability regresses
     - safety policy misses a case
     - UX breaks on slow networks or cancelled requests
   - Do not expand this into broad “AI everywhere” work before missing non-AI MVP capability gaps are closed.

5. **Keep NLP intake and Mine support in polish-only mode**
   - Mine campus/support rows already open contract-backed actions when Lucent provides a usable target; rows without target remain visible but disabled.
   - Do not pull campus/help resource completeness or dynamic nearby-care discovery back into MVP unless the product promise changes.
   - Record NLP candidate save already has explicit failed-item retry inside the sheet.
   - Revisit these two slices only if MVP testing shows users still get stuck, for example around clearer failure causes or support-resource action-type expansion.

6. **Do not turn Web into a stealth MVP requirement unless we mean it**
   - `Luminous-site` is currently a competition/marketing homepage, not a signed-in report preview surface.
   - If MVP stays mobile-first for delivery and demo, keep Web scoped to presentation.
   - If real authenticated Web report preview becomes an MVP promise, treat it as a separate planned slice instead of a side quest.

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- After the five-tab UI stabilizes, run a focused truncation pass for English and Chinese button labels, pills, and compact rows across Today, Record, Medicine, Report, and Mine.
- Agent-assisted support discovery and map-backed nearby-care lookup.
- Lightweight mood record shapes.
- Environment signals for contextual Today/Mine use.
- Medicine scan/OCR/photo/barcode/prescription action shapes.
- Local-only sleep reminder preferences beyond simple placeholder labeling.
- Real authenticated Web report preview beyond the competition site.

Pregnancy/lactation/special-group medication safety remains active only inside Medicine safety boundaries.

## Recently Closed

- Export promise is intentionally narrowed to the real `hospital + pdf + last_7_days` flow.
- `monthly` / `print` stay visible but inactive instead of pretending to be shipped.
- Reminder UI now treats local scheduling as the real MVP path and stops reading worker history / push / SMS as if they already exist.

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
