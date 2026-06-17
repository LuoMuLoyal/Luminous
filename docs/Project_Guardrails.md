# Lumos Project Guardrails

Last updated: 2026-06-11

This replaces the long historical error audit as the current quick-read checklist.

## Documentation

- Do not duplicate the same fact across docs. Product decisions go in `Product_Vision.md`; current facts in `Current_State.md`; next work in `Next_Plan.md`; history in `MigrationLog.md`.
- Active multi-step execution plans belong in `../plans/`, not in `docs/` and not in the workspace root.
- Do not keep old execution plans in active docs after they are superseded. Move useful decisions into the owning doc and delete the plan.
- Do not use migration logs as current source of truth; they are historical records only.

## Contracts

- Do not hand-maintain API prose. Lucent controller/DTO code plus `Lucent/docs/openapi.json` is the contract.
- After Lucent API changes, run `pnpm export:openapi`, then regenerate Luminous with `dart run tool/regenerate_lucent_openapi.dart`.
- Do not run ad-hoc OpenAPI generator commands for normal work.
- Do not pass generated write DTOs into Flutter domain/presentation code when nullable clearing matters; use local write inputs or raw maps.
- For PATCH semantics, test omitted field, explicit `null`, and concrete value separately.

## Backend

- Do not use legacy Nest cache `store`; this repo expects `stores` / Keyv-backed Redis wiring.
- Do not assume cache TTL units; this repo treats cache-manager/Nest cache TTL as milliseconds.
- Do not convert DrugBank `full database.xml` to xlsx for routine import. Keep the scripted XML path.
- Do not write mutations that trust request DTO echo as final state; return persisted normalized data.
- Do not mutate sessions, identities, records, dose logs, or health context without scoping by current user.
- Do not add cloud credentials, SMTP passwords, OAuth secrets, or COS keys to source files.

## Frontend

- Do not add code to legacy folders: `lib/pages`, `lib/stores`, `lib/viewmodels`, `lib/components`.
- Do not use `Navigator.push(MaterialPageRoute(...))`; use GoRouter.
- Do not show full-page loading for pages with stable local chrome; use localized skeletons for backend-backed sections.
- Do not add page-local routine `SnackBar`; use shared feedback utilities.
- Do not add visible text without ARB/l10n.
- Do not let signed-out pages repeatedly call protected APIs; show stable signed-out state or route to login.
- Do not present mock/static/unsupported features as real capability.
- Do not leave user-visible copy that literally says `mock data` once a real or deferred boundary has been defined; use neutral placeholder wording instead.
- Do not let deferred capability drift into ambiguous half-active UI. If a future feature must stay visible before its contract exists, keep it clearly placeholder-only and keep docs in sync with that choice.
- For mobile UI refinement, "avoid nested boxes" means keep the necessary outer section panel and replace only inner cards with rows, dividers, pills, or controls. Do not flatten an entire section into loose dividers when the outer panel provides visual grouping.
- The mobile MVP bottom navigation is frozen as `today / record / medicine / report / mine`. Do not add or revive a generic More tab; route low-frequency utilities through Mine, contextual Today actions, or defer them.
- Do not hide shared business data under one page feature just because it was first used there. If the same provider/service is consumed by Mine, Medicine, and Settings, move it to a neutral feature boundary such as `features/support/` instead of leaving it nested under `settings`.
- Keep design-system primitives in `lib/core/design/`. Do not split responsive breakpoints or theme seed colors into parallel `core/constants` files when they are part of the same UI token system.

## CI/CD And Generated Files

- Lucent deploy currently uses app image `latest`; there is no automatic image rollback.
- Do not edit generated Prisma client manually.
- Do not manually normalize generated OpenAPI client Markdown just to make diffs pretty.
- Generated OpenAPI client whitespace warnings are handled via `.gitattributes`; do not add repo-specific cleanup steps just to strip generated trailing spaces.
- Do not describe the Android emulator + Lucent test-runtime lane as already covered by GitHub Actions. The current CI boundary is repo-safe Flutter checks only; full-stack E2E remains a local/manual gate through `tool/run_fullstack_checks.ps1`.

## Verification

- Backend focused change: `pnpm lint:check`, `pnpm build`, relevant tests, `pnpm export:openapi` if API changed.
- Frontend focused change: `flutter analyze`, relevant tests or `flutter test`.
- Cross-contract change: run both backend OpenAPI export and Luminous client regeneration.
- Prefer `powershell -ExecutionPolicy Bypass -File tool/run_daily_checks.ps1` for repo-safe frontend verification and `powershell -ExecutionPolicy Bypass -File tool/run_fullstack_checks.ps1` for the local emulator gate instead of retyping long command chains.
- Run emulator integration tests sequentially per device. Do not run multiple `flutter test integration_test/... -d emulator-5554` commands concurrently against the same emulator; they can race app install / VM service attachment and fail with device-level errors.
- Long-running emulator tests need an explicit timeout and investigation path. If a single scenario stalls for minutes, inspect the test wait condition and device logs instead of repeatedly waiting for the same timeout.
