# Luminous Next Plan

Last updated: 2026-06-15

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

The frozen mobile MVP path is now real: `record -> summarize -> bounded medicine safety check -> export`. The next phase should stop treating every remaining idea as an MVP task and instead split work into three tracks: stable demo/validation discipline, report/export productization, and explicit post-MVP surface decisions like Web or broader medicine coverage.

## Immediate Work Order

1. **Solidify the MVP handoff and demo discipline**
   - Priority order:
     - keep campus/help resource completeness, map discovery, and agent-assisted support lookup out of the frozen MVP promise
     - keep repo-safe daily checks plus the local full-stack gate as the standard pre-demo and pre-merge routine for the frozen path
     - turn any remaining half-real UI states into explicit boundary wording instead of relying on oral explanation
   - Success signal:
     - the mobile MVP can be demoed end to end by someone other than the implementer without ad-hoc caveats

2. **Productize report/export beyond the current MVP floor**
   - Priority order:
     - decide whether `monthly` / `print` stay as request-based export actions only or need true downloadable file lifecycle, preview state, and share semantics
     - if PDF is kept as the main artifact, tighten pagination, header/footer consistency, and export status wording
     - keep privacy, share, and doctor-facing summary boundaries explicit instead of implying a full collaboration workflow
   - Success signal:
     - report/export moves from “MVP proof it works” to a stable user-facing feature boundary with clear file behavior

3. **Decide the next real surface, don’t drift into side quests**
   - Priority order:
     - choose whether the next meaningful surface is authenticated Web report preview, stronger medicine knowledge depth, or support/discovery capability
     - if Web becomes real, treat it as its own slice instead of letting `Luminous-site` drift from marketing page to accidental product shell
     - if medicine depth becomes next, keep it to reviewed rule expansion or normalization groundwork, not broad speculative AI
   - Success signal:
     - the next milestone is one explicit product slice, not a grab bag of polish and experiments

4. **Local full-stack lane usage rule**
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

5. **Keep AI work in maintenance mode**
   - Today and Report AI cards now stream partial summary text and finish with the same structured payload as the one-shot flow.
   - Only revisit this slice when:
     - stream stability regresses
     - safety policy misses a case
     - UX breaks on slow networks or cancelled requests
   - Do not expand this into broad “AI everywhere” work before missing non-AI MVP capability gaps are closed.

6. **Keep NLP intake and Mine support in polish-only mode**
   - Mine campus/support rows already open contract-backed actions when Lucent provides a usable target; rows without target remain visible but disabled.
   - Do not pull campus/help resource completeness or dynamic nearby-care discovery back into MVP unless the product promise changes.
   - Record NLP candidate save already has explicit failed-item retry inside the sheet.
   - Revisit these two slices only if MVP testing shows users still get stuck, for example around clearer failure causes or support-resource action-type expansion.

7. **Do not turn Web into a stealth product requirement unless we mean it**
   - `Luminous-site` is currently a competition/marketing homepage, not a signed-in report preview surface.
   - If Web stays presentation-only, protect that boundary and do not smuggle product work into it.
   - If real authenticated Web report preview is chosen as the next slice, open a dedicated plan for it.

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
- Medicine safety now keeps the same explicit reviewed boundary across risk-check page, workspace cards, and add-before-save precheck, including visible unknown-state handling for pregnancy, lactation, pediatric, geriatric, and fully unchecked medicines.
- The mobile MVP promise is now frozen around the current real path instead of leaving medicine safety as an open completion blocker.

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
