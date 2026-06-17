# Lucent OpenAPI Client

Last updated: 2026-06-17

This file records the supported Flutter client workflow. API shape comes from Lucent controller/DTO code plus generated `../Lucent/docs/openapi.json`, not from prose.

## Files

- Generated OpenAPI source from the `Luminous` repo root: `../Lucent/docs/openapi.json`
- Generated Dart package: `packages/lucent_openapi/`
- Network wrapper: `lib/core/network/lucent_dio_client.dart`
- Public Flutter API exports: `lib/core/network/lucent_api.dart`
- Regeneration wrapper: `tool/regenerate_lucent_openapi.dart`

## Current Generated Baseline

- Last known Lucent export: 54 paths / 162 schemas.
- Generated package includes auth/account, user-scoped health context, daily records, AI daily-record candidate parsing, medicine search/detail, current medicines, dose logs, environment snapshot, schedule-only medicine reminders with optional date windows, read-only reminder delivery history, user settings, AI chat capability discovery, report dashboard, Today AI analysis, range-based report AI summary (`last_7_days` / `last_30_days`), public support resources/app info, data export request status plus explicit create-request DTOs/enums, and the new Today/Report AI stream response DTOs.
- Current user-scoped business data uses `/api/v1/user/*`; account profile/security actions stay under `/api/v1/account/*`.

## Usage Rules

- Business and presentation code use `LucentDioClient` or feature repositories, not generated internals directly.
- Generated DTOs stay in data-layer response mapping.
- For writes where nullable clearing matters, use local domain write inputs or raw Dio JSON maps instead of generated write DTOs.
- Medicine reminder create/update writes use a local write input plus raw Dio JSON so `daysOfWeek: null`, `startDate`, and `endDate` are sent with the intended nullable behavior; generated reminder DTOs remain the read-side mapper.
- Reminder delivery history is read through the feature data source and maps generated/raw response fields into local UI rows. The generated `ReminderDeliveriesApi` exists, but presentation/domain code should still depend on the feature repository boundary.
- Today AI analysis, Report AI summary, and AI chat streaming all use manual Dio + SSE parsing in `lib/core/network/lucent_sse.dart`, not generated OpenAPI transport methods. Generated DTOs still remain the contract source for capability/result payload shapes.
- `Accept-Language` is injected by the network layer.
- Authorization is injected when an access token exists.
- `401002` triggers refresh and retry.
- Dio errors are unwrapped through `LucentErrorMapper`.
- Use `LucentDioClient.medicinesHeaders(bypassCache: true)` for one-off medicine reads that must bypass Lucent read cache.
- If the generator drops a top-level API export or `LucentOpenapi` getter while the underlying `src/api/*.dart` file still exists, fix that in the generated package and in `tool/regenerate_lucent_openapi.dart` so the next regeneration stays stable.
- If the generator emits broken enum defaults for generated request models, patch the wrapper instead of hand-fixing generated files. The current wrapper now normalizes both constructor enum defaults in `*.dart` and enum decode fallback values in `*.g.dart` for `CreateDataExportRequestDto`.
- If a Swagger enum array causes the Dart generator chain to emit invalid `unknownEnumValue` code for `List<Enum>`, prefer expressing that field as `List<String>` in the generated contract and keep the allowed values in description/examples. The current AI chat `requiredContextSources` field uses this compatibility rule.

## Regenerate

From `Luminous`:

```bash
dart run tool/regenerate_lucent_openapi.dart
```

The wrapper exports Lucent OpenAPI, regenerates the Dart client, disables generated Markdown doc stubs and generated package test stubs, restores the generated package constraints, patches broken enum defaults before serializer build, rebuilds serializers, patches post-build enum decode fallback bugs plus known nullable-map generator output, restores missing generated API exports/getters when the generator drops them, formats generated model files, analyzes the generated package, and refreshes root Flutter dependencies.

Do not run ad-hoc `npx @openapitools/openapi-generator-cli generate` or manual `build_runner` steps for normal work.

After regeneration, run:

```bash
git -C Luminous diff --check
flutter analyze
flutter test
```

Generated OpenAPI client paths are covered by `.gitattributes` whitespace rules, so `git diff --check` will not block on generated trailing spaces there.

## Noise Boundary

- `packages/lucent_openapi/` stays committed because it is a local path dependency used by the app.
- Generated Dart client code under `lib/` stays tracked.
- Generated Markdown docs under `packages/lucent_openapi/doc/` and generated package stub tests under `packages/lucent_openapi/test/` are now intentionally disabled and cleaned by the wrapper because they add large diff noise without participating in app runtime or verification.
- Current known example: `AppApi` may still be generated under `src/api/app_api.dart` while the generator forgets to export it from `lib/lucent_openapi.dart` and `lib/src/api.dart`. The wrapper now repairs that gap automatically.
