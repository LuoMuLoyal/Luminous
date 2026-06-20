# Record Fast Entry

## Goal

Complete lightweight fast-entry flows for each active Record quick-action type in
the Flutter client, following the user's requested cadence:

1. implement one record type
2. run the corresponding tests
3. fix regressions until those tests pass
4. commit the result
5. move to the next type

Target active types:

- water
- meal
- symptom
- note
- sleep

`mood` stays reserved only and does not become an active workflow in this slice.

## Verified Constraints

- Frontend repo: `Luminous`
- Feature structure must stay feature-first.
- Current backend contract only accepts `occurredAt` as `YYYY-MM-DD`.
  - Verified in `Lucent/src/modules/daily-records/dto/create-daily-record.dto.ts`
  - Verified in `Lucent/src/modules/daily-records/daily-records-mapper.service.ts`
- Therefore this slice can save against the selected date, but cannot truthfully
  persist a separate current-time field without a backend contract change.

## Non-Scope

- backend contract expansion for record time-of-day persistence
- RAG
- assistant scope expansion
- web product work
- medication quick entry as an active record create flow

## Likely Files

- `lib/features/record/presentation/record_page.dart`
- `lib/features/record/presentation/widgets/record_dashboard_view.dart`
- `lib/features/record/presentation/widgets/record_quick_entry_panel.dart`
- `lib/features/record/presentation/widgets/record_fast_entry_*.dart`
- `lib/features/record/presentation/pages/record_create.dart`
- `test/record/record_page_test.dart`
- `docs/Current_State.md`
- `docs/Next_Plan.md`
- `docs/migration-log/2026-06-20.md`

## Execution Order

1. water
2. meal
3. symptom
4. note
5. sleep

## Success Shape Per Type

- tapping the quick action opens a lightweight fast-entry surface first
- the common case saves from that surface without routing through the full form
- a `more` action still opens the existing full create page for the same kind
- signed-out behavior still shows the auth-required dialog instead of bypassing
  protected flow
- the matching record tests pass before commit

## Validation Per Type

- focused `flutter test` for the touched Record quick-entry scenarios
- expand or adjust tests when behavior changes
- fix failures before commit

## Done Signal

- all five active Record quick-action types use lightweight fast entry first
- each type was validated in sequence with relevant tests
- each type landed in its own git commit after tests passed
