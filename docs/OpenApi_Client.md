# Lucent OpenAPI Client

Last updated: 2026-06-11

This file records the supported Flutter client workflow. API shape comes from Lucent controller/DTO code plus generated `../Lucent/docs/openapi.json`, not from prose.

## Files

- Generated OpenAPI source from the `Luminous` repo root: `../Lucent/docs/openapi.json`
- Generated Dart package: `packages/lucent_openapi/`
- Network wrapper: `lib/core/network/lucent_dio_client.dart`
- Public Flutter API exports: `lib/core/network/lucent_api.dart`
- Regeneration wrapper: `tool/regenerate_lucent_openapi.dart`

## Current Generated Baseline

- Last known Lucent export: 44 paths / 123 schemas.
- Generated package includes auth/account, user-scoped health context, daily records, medicine search/detail, current medicines, dose logs, environment snapshot, schedule-only medicine reminders with optional date windows, read-only reminder delivery history, user settings, public support resources/app info, and data export request status.
- Current user-scoped business data uses `/api/v1/user/*`; account profile/security actions stay under `/api/v1/account/*`.

## Usage Rules

- Business and presentation code use `LucentDioClient` or feature repositories, not generated internals directly.
- Generated DTOs stay in data-layer response mapping.
- For writes where nullable clearing matters, use local domain write inputs or raw Dio JSON maps instead of generated write DTOs.
- Medicine reminder create/update writes use a local write input plus raw Dio JSON so `daysOfWeek: null`, `startDate`, and `endDate` are sent with the intended nullable behavior; generated reminder DTOs remain the read-side mapper.
- Reminder delivery history is read through the feature data source and maps generated/raw response fields into local UI rows. The generated `ReminderDeliveriesApi` exists, but presentation/domain code should still depend on the feature repository boundary.
- `Accept-Language` is injected by the network layer.
- Authorization is injected when an access token exists.
- `401002` triggers refresh and retry.
- Dio errors are unwrapped through `LucentErrorMapper`.
- Use `LucentDioClient.medicinesHeaders(bypassCache: true)` for one-off medicine reads that must bypass Lucent read cache.

## Regenerate

From `Luminous`:

```bash
dart run tool/regenerate_lucent_openapi.dart
```

The wrapper exports Lucent OpenAPI, regenerates the Dart client, restores the generated package constraints, rebuilds serializers, patches known nullable-map generator output, formats generated model files, fixes generated API Dart lines that would fail `git diff --check`, analyzes the generated package, and refreshes root Flutter dependencies.

Do not run ad-hoc `npx @openapitools/openapi-generator-cli generate` or manual `build_runner` steps for normal work.

After regeneration, run:

```bash
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
flutter analyze
flutter test
```

If generated API Dart whitespace issues recur, fix the wrapper normalization instead of hand-editing generated output file by file.
