# Lumos Project Guardrails

Last updated: 2026-06-08

This replaces the long historical error audit as the current quick-read checklist.

## Documentation

- Do not duplicate the same fact across docs. Product decisions go in `Product_Vision.md`; current facts in `Current_State.md`; next work in `Next_Plan.md`; history in `MigrationLog.md`.
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
- The mobile MVP bottom navigation is frozen as `today / record / medicine / report / mine`. Do not add or revive a generic More tab; route low-frequency utilities through Mine, contextual Today actions, or defer them.

## CI/CD And Generated Files

- Lucent deploy currently uses app image `latest`; there is no automatic image rollback.
- Do not edit generated Prisma client manually.
- Do not manually normalize generated OpenAPI client Markdown just to make diffs pretty.
- After OpenAPI regeneration, run whitespace checks excluding generated output where documented.

## Verification

- Backend focused change: `pnpm lint:check`, `pnpm build`, relevant tests, `pnpm export:openapi` if API changed.
- Frontend focused change: `flutter analyze`, relevant tests or `flutter test`.
- Cross-contract change: run both backend OpenAPI export and Luminous client regeneration.
