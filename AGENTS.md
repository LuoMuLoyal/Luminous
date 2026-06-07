# AGENTS.md - Luminous

## Stack

- Flutter
- Riverpod, not GetX
- GoRouter, not `Navigator.push(MaterialPageRoute(...))`
- Backend: Lucent

## Commands

```bash
flutter pub get
flutter analyze
flutter test
```

Regenerate Lucent client:

```bash
dart run tool/regenerate_lucent_openapi.dart
```

## Guardrails

- New code goes under `lib/features/`, `lib/core/`, or `lib/shared/`.
- Do not add code to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`, `lib/components/`.
- API contract: Lucent controller/DTO code plus generated `../Lucent/docs/openapi.json`.
- Network code belongs in `lib/core/network/`.
- Do not regenerate `packages/lucent_openapi` with ad-hoc `npx` / `build_runner` commands. Always use `dart run tool/regenerate_lucent_openapi.dart` so generated pubspec constraints and broken nullable `*.g.dart` map entries are normalized automatically.
- User-visible text goes through ARB + `flutter gen-l10n`.
- Token storage prefers secure storage, with desktop/web fallback.
- For lightweight frontend feedback, use shared `lib/core/feedback/app_toast.dart`; do not introduce page-local `SnackBar` prompts for routine click hints.
- All page-level error states must use `AppStateErrorView` (from `lib/core/widgets/app_state_views.dart`) instead of hand-written error views. This ensures centered, scrollable layout with consistent icon/tone/action patterns.
- All page loading states must use shimmer skeleton screens (`Shimmer.fromColors` from `shimmer` package) instead of `CircularProgressIndicator` or plain colored blocks. Reuse `AppStateSkeletonView` when the loading view is not nested inside another scrollable, or define a local `Column` + `_SkeletonBlock` when it is.
- When refining app UI, prefer flatter surfaces over nested boxes, and align high-level layout/metrics with the approved concept images instead of adding explanatory placeholder copy.
- Do not add explanatory, narrative, onboarding, or marketing-style copy to normal app pages by default. Keep user-visible text limited to necessary titles, labels, values, statuses, and actions.
- Child pages reached from settings, mine, or other in-app navigation should default to a standard app header: left back arrow and centered title. Avoid hero-style headers or extra descriptive paragraphs unless the task explicitly requires them.

## Docs

- Read `docs/README.md` before editing docs.
- Frontend code changed: append the entry to today's `docs/migration-log/YYYY-MM-DD.md`; keep `docs/MigrationLog.md` as the index only.
- Network / OpenAPI / auth client changed: update `docs/OpenApi_Client.md`.
- Visible text or l10n flow changed: update `docs/Localization.md`.
- UI/page state or project state changed: update `docs/Current_State.md`.
- Next work changed: update `docs/Next_Plan.md`.
- Recurring mistakes or rules changed: update `docs/Project_Guardrails.md`.
