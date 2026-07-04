# Luminous Copilot Instructions

You are working in `Luminous`, a Flutter client in the Lumos workspace.

## Stack

- Flutter 3.44.0 / Dart 3.12.0
- Riverpod, not GetX
- GoRouter, not ad-hoc `Navigator.push(MaterialPageRoute(...))`
- Forui-first UI
- Lucent-backed APIs through `packages/lucent_openapi/`

## Read First

- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `docs/02-reference/AI_Development_Workflow.md`

## Repo Rules

- Match the existing file style. Prefer small, direct changes.
- Reuse existing helpers and repositories before adding new abstractions.
- Keep feature code inside `lib/features/{feature}/`.
- Keep shared runtime/design/router code under `lib/core/` and `lib/app/`.
- Do not hand-edit generated files:
  - `lib/l10n/app_localizations*.dart`
  - `packages/lucent_openapi/**`
- Do not switch state management patterns away from Riverpod.

## UI Rules

- Prefer Forui primitives over new wrapper components.
- Prefer `FLucideIcons` over `Icons.*` when a reasonable icon exists.
- Preserve current routing and vertical-slice boundaries.

## AI-Specific Boundary

- Existing shipping AI features are Lucent-backed.
- `lib/core/ai/` is only for local runtime seams and future experiments.
- Do not reroute `assistant` or `report` production flows to a new model SDK
  unless the task explicitly requires that architecture change.

## Verification

Run the smallest relevant checks first, then broader checks when touching shared
runtime behavior:

- `flutter test`
- `flutter analyze`
- `dart run tool/run_daily_checks.dart`

## Docs

When behavior, workflow, runtime, or UI changes, update the matching docs under
`docs/00-current/`, `docs/02-reference/`, and
`docs/03-logs/migration-log/YYYY-MM-DD.md`.
