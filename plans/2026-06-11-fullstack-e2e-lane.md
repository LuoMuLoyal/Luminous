# Full-Stack E2E Lane Plan

Last updated: 2026-06-11

## Goal

Establish the first real full-stack mobile E2E lane for Luminous:

- real Flutter app on emulator/device
- real Lucent backend
- real PostgreSQL-backed test data
- no fake repositories or offline bootstrapping for the chosen scenario

This plan exists to close the current gap between:

- device-level scenario tests under `integration_test/`
- Lucent backend e2e API tests under `Lucent/test/*.e2e-spec.ts`

The immediate target is not "more E2E files". The target is one trustworthy end-to-end path that proves Flutter and Lucent still work together after contract and UI changes.

## Decision

Use the existing Flutter `integration_test` stack as the first full-stack lane.

Do not introduce a new framework first.

Reason:

- current Luminous tests already have device boot, navigation keys, and scenario structure
- the main missing piece is real backend/data wiring, not another test runner
- adding Patrol or Maestro now would increase moving parts before we have a stable baseline lane

Re-evaluate Patrol only after the first real lane is working, if we need native/system coverage such as permissions, notifications, OAuth/WebView, app lifecycle, or OS settings handoff.

## Initial Slice

Start with one narrow vertical slice:

1. sign in with a dedicated test account
2. open Record
3. create one daily record
4. verify it appears in timeline/detail
5. edit or delete it
6. verify the mutation is reflected by the backend

Prefer Record first because:

- the user flow is already central to the product
- the UI exists and is actively maintained
- Lucent already has user-scoped `/api/v1/user/daily-records` contracts
- this slice exercises auth, repository wiring, mutation, reload, and date-scoped reads

## Non-Goals

- no broad framework migration
- no full replacement of existing fake/offline `integration_test` scenarios
- no Test Lab / cloud-device rollout in phase 1
- no report contracts or report UI work
- no attempt to cover every tab before one lane is stable

## Assumptions

- emulator/device testing stays Android-first for the first lane
- Lucent local test environment can run with reachable Postgres
- a deterministic test account and deterministic cleanup/reset path can be provided
- WeChat OAuth is not the first auth lane; use a simpler deterministic login path first

## Affected Areas

### Luminous

- `integration_test/`
- `lib/core/network/`
- auth/session bootstrapping used by integration tests
- any environment/config wiring needed to point Flutter to Lucent test backend
- docs:
  - `docs/Next_Plan.md`
  - `docs/Current_State.md` if the lane becomes a current fact
  - `docs/Project_Guardrails.md` if reusable test rules emerge
  - `docs/migration-log/YYYY-MM-DD.md`

### Lucent

- test data setup/reset support
- auth path used by the test account
- daily-records fixtures or reset endpoints/scripts
- docs if local test-environment commands or contracts change

## Milestones

### Phase 1 - Test Lane Contract

Define the minimum contract for a full-stack mobile lane:

- backend base URL and environment selection for integration tests
- dedicated test account strategy
- test data reset strategy
- scenario ownership boundary between Flutter and Lucent

Exit criteria:

- we can describe exactly how a Flutter integration test reaches a real Lucent instance
- we can recreate the same starting state repeatedly

### Phase 1 Status

Status: completed on 2026-06-11

#### Phase 1 Conclusions

1. Backend reachability
   - The first real lane is Android-emulator-first.
   - Do not use the current fallback `http://127.0.0.1:3000` for the emulator lane. Inside Android emulator, `127.0.0.1` points to the emulator itself, not the host Lucent process.
   - Run the lane with an explicit Dart define:
     - `--dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000`
   - Keep the base URL explicit in full-stack runs. Do not rely on implicit `.env` or platform-specific fallback behavior for this lane.

2. Auth strategy
   - The first lane uses password login against Lucent `POST /api/v1/auth/login`.
   - Do not use WeChat OAuth for the first full-stack lane. That would mix app-to-backend verification with external OAuth/browser/system behavior and make failures harder to localize.
   - Test credentials should be injected explicitly for the lane, not hidden in production app code.
   - Preferred config shape for Flutter full-stack runs:
     - `--dart-define=E2E_TEST_EMAIL=...`
     - `--dart-define=E2E_TEST_PASSWORD=...`

3. Test account strategy
   - Use one dedicated password-based test user owned by Lucent test support.
   - Do not depend on whatever account currently exists in a developer's local database.
   - The account must be recreated or repaired idempotently by Lucent-side test support in phase 2, so the Flutter lane always targets the same logical user.
   - The first lane should not create a brand-new random user from the Flutter UI. That adds verification-code and account-lifecycle noise before the core Record path is stable.

4. Reset strategy
   - Luminous should not reset PostgreSQL state directly and should not assume long-lived seeded records already exist.
   - Lucent should own deterministic test-state setup and cleanup.
   - Phase 2 should add the smallest test-only support that can:
     - ensure the dedicated test user exists
     - clear that user's daily records for one known test date
     - optionally seed one deterministic baseline record when the scenario needs it
   - Prefer explicit reset/seed actions over hidden global truncation. The Flutter lane should start from a known user/date scope, not from "empty whole database" assumptions.

5. Ownership boundary
   - Flutter full-stack tests own UI driving, waits, visible assertions, and high-level business outcome checks.
   - Lucent owns seed/reset helpers, deterministic test credentials, and backend data shape guarantees.
   - Do not reintroduce fake repositories or offline overrides into the real lane.
   - Do not make Flutter full-stack tests inspect the database directly. If backend state must be proven, prove it through authenticated API reads reflected in UI or through a narrow test support contract.

6. Scenario shape locked for the first lane
   - sign in with dedicated credentials
   - navigate to Record
   - create one daily record for one fixed known date
   - reopen/reload and verify the item appears in timeline/detail
   - edit or delete the same item
   - reload and verify the persisted mutation

#### Phase 1 Output

Phase 2 should now implement backend-side repeatability, not debate framework choice again.

### Phase 2 - Backend Test State Support

Add the smallest backend-side support needed for repeatability.

Preferred order:

1. reusable seeded test user
2. record cleanup/reset script or endpoint restricted to test environment
3. deterministic fixture for one known date range

Recommended concrete target:

- dedicated account identified by email, created or repaired idempotently
- one fixed date for the first Record lane
- one reset action that cleans only this user's record-slice data for that date or date range
- optional seed step only if the edit/delete path is cleaner than create-first

Guardrails:

- do not add broad production-facing test backdoors
- any reset endpoint must be test-only and environment-guarded
- prefer explicit seed/reset actions over hidden assumptions about DB state

Exit criteria:

- Record flow can start from a clean known state without manual DB fiddling

### Phase 2 Status

Status: completed on 2026-06-11

#### Phase 2 Conclusions

1. Backend support shape
   - Lucent now exposes a test-only preparation route:
     - `POST /api/v1/testing/fullstack-e2e/record-lane/prepare`
   - The module is loaded only when Lucent runs with `NODE_ENV=test`.
   - The route is intentionally absent from normal development and production runtime, so it does not become a broad production-facing backdoor.

2. Dedicated account handling
   - The preparation route accepts explicit test credentials from the lane runner.
   - Lucent repairs the target user idempotently:
     - normalize email
     - hash and replace password
     - force active status
     - ensure profile exists
     - clear existing sessions

3. Record reset scope
   - The preparation route clears only the target user's daily records for one target date.
   - Clearing is hard-delete for repeatability and includes record attachments for the same record ids.
   - This keeps reset scope narrow and avoids global database truncation assumptions.

4. Local runtime command
   - Lucent now has a dedicated local command for this lane:
     - `pnpm start:test:dev`
   - This is the runtime Flutter full-stack tests should target when they need the preparation route.

5. Verification status
   - Code-level verification passed:
     - `pnpm lint:check`
     - `pnpm build`
     - targeted unit test for the preparation service
   - End-to-end backend verification is still environment-dependent because the local Docker-backed test database was not available in this session.
   - A dedicated Lucent e2e spec was added for the route and should pass once the local test stack is up.

#### Phase 2 Output

Phase 3 should now wire Flutter integration tests to this preparation route and explicit test credentials.

### Phase 3 - Flutter Full-Stack Bootstrapping

Add a real-app integration test boot path alongside the existing fake/offline path.

Likely shape:

- keep current `pumpOfflineApp(...)` for fast scenario tests
- add a separate helper for real-backend boot, not a silent mode switch
- load backend URL and test credentials from explicit config

Guardrails:

- do not break the current fast fake-based integration suite
- keep "offline scenario tests" and "full-stack lane tests" clearly separated

Exit criteria:

- one integration test can launch the real app, talk to Lucent, and authenticate successfully

### Phase 3 Status

Status: completed on 2026-06-11

#### Phase 3 Conclusions

1. Full-stack helper boundary
   - Luminous now keeps fake/offline helpers and full-stack helpers separate.
   - Offline scenario tests continue to use `pumpOfflineApp(...)`.
   - Full-stack startup now uses a dedicated helper path that:
     - reads explicit Dart defines
     - calls Lucent prepare support before app boot
     - overrides session storage with an in-memory test store
     - launches the real app against the real backend

2. Explicit runtime config
   - The full-stack helper now expects:
     - `--dart-define=LUCENT_BASE_URL=...`
     - `--dart-define=E2E_TEST_EMAIL=...`
     - `--dart-define=E2E_TEST_PASSWORD=...`
   - It rejects `localhost` / `127.0.0.1` so Android emulator runs fail fast instead of silently pointing at the wrong host.

3. Auth flow stability
   - Login page now has stable keys for the real full-stack login path.
   - Full-stack boot uses a memory-backed session store, so auth state is not inherited from previous manual runs or secure-storage leftovers.

4. Verification result
   - A real-device integration smoke test now proves:
     - Lucent test runtime can be prepared
     - Luminous can launch against it
     - UI password login succeeds
     - authenticated session state updates in-app
   - Verified command:
     - `flutter test integration_test/fullstack_auth_smoke_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`

#### Phase 3 Output

Phase 4 should now build the first real Record CRUD lane on top of the new full-stack boot helper.

### Phase 4 - First Real Record Lane

Implement the first full-stack test file for the Record slice.

Minimum assertions:

- sign in succeeds
- create succeeds
- created item appears in UI after reload
- detail view shows persisted data
- delete or edit persists and reloads correctly

Exit criteria:

- a single command can run the lane on emulator and pass from a clean state

### Phase 4 Status

Status: completed on 2026-06-11

#### Phase 4 Conclusions

1. First real Record CRUD lane
   - Luminous now has `integration_test/fullstack_record_lane_test.dart`.
   - The lane covers:
     - prepare test state
     - sign in with real Lucent credentials
     - open Record for one fixed target date
     - create one note record
     - verify timeline/detail persistence
     - edit the note
     - delete the same note
     - reopen Record and verify the backend-backed item is gone

2. Full-stack UI stability fixes
   - Bottom-tab navigation for integration tests no longer depends on localized visible text.
   - Shell tabs now expose stable test keys, and the full-stack helper opens Record through keys instead of assuming Chinese labels.
   - Record delete confirmations now expose a stable confirm-action key, so emulator locale drift does not break the lane.

3. Real-backend contract bug found and fixed
   - The lane exposed a real client/backend mismatch in daily-record deletion:
     - Lucent `DELETE /api/v1/user/daily-records/:id` returns `successEnvelope(null)`
     - Luminous delete path was incorrectly reusing the response parser that expects a `DailyRecordItemDto`
   - Luminous now validates the delete success envelope directly instead of trying to parse a record body.
   - Without the real lane, this bug would not have been caught by the existing fake/offline tests.

4. Verification result
   - Verified on `emulator-5554` against Lucent test runtime with:
     - `flutter test integration_test/fullstack_record_lane_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`
   - Additional regression verification passed for:
     - `flutter test integration_test/fullstack_auth_smoke_test.dart -d emulator-5554 --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 --dart-define=E2E_TEST_EMAIL=fullstack-record-lane@example.com --dart-define=E2E_TEST_PASSWORD=RecordLane123 --dart-define=E2E_RECORD_DATE=2026-06-12`
     - `flutter test integration_test/record_mutation_e2e_test.dart -d emulator-5554`

#### Phase 4 Output

Phase 5 should now decide whether the first real lane remains local/manual for now or becomes part of a repeatable CI/device workflow.

### Phase 5 - CI/Execution Strategy

After the first lane is locally stable, decide how it runs outside local dev.

Options to evaluate after phase 4:

1. local/manual only at first
2. gated CI job with local emulator
3. Firebase Test Lab
4. later Patrol expansion for native/system coverage

Exit criteria:

- explicit decision recorded, even if the answer is "keep local-only for now"

## Verification Plan

### Required for the lane itself

- Lucent:
  - `pnpm lint:check`
  - `pnpm build`
  - relevant e2e or seed/reset verification
- Luminous:
  - `flutter analyze`
  - `flutter test`
  - targeted device run for the new full-stack lane

### Required behavior checks

- rerunning the test from a clean reset produces the same result
- auth/session state is not inherited from a previous manual app run
- timeline assertions read real backend state, not fake repository memory
- failure output identifies whether the issue is auth, backend reachability, seed/reset, or UI wait conditions

## Observable Outcomes

When this plan is complete, we should be able to say:

- Luminous has both fast fake-based device scenario tests and at least one real full-stack mobile E2E lane
- a contract rename or mutation regression can be caught by a real app-to-backend flow
- the team has a clear criterion for when Patrol or another framework is actually worth adding

## Risks

- flaky backend state if seed/reset is not deterministic
- auth instability if the first lane depends on OAuth instead of a simpler deterministic path
- accidental coupling of slow full-stack setup into the fast fake-based scenario suite
- emulator/device timing issues being mistaken for product regressions

## Follow-Up Decision Gate

Only consider introducing Patrol after phase 4 if one of these is true:

- we need reliable permission dialogs or notification assertions
- we need app background/foreground lifecycle coverage
- we need WebView/OAuth/system-level interactions that `integration_test` handles poorly

Only consider Maestro after phase 4 if one of these is true:

- non-Dart contributors need to author black-box mobile flows
- we want high-level smoke coverage that is intentionally separated from app-internal test helpers
