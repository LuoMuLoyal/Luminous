# Lucent OpenAPI Client

Last updated: 2026-07-28

This file records the supported Flutter client workflow. API shape comes from Lucent controller/DTO
code plus a freshly exported local `../Lucent/docs/openapi.json`, not from prose.

## Files

- Generated OpenAPI source from the `Luminous` repo root: local export `../Lucent/docs/openapi.json`
- Generated Dart package scaffold: `generated/lucent_api/`
- Network wrapper: `lib/core/network/dio_client.dart`
- Public Flutter API exports: `lib/core/network/api.dart`
- Contract drift verifier: `scripts/verify_lucent_openapi_sync.dart`

## Current Generated Baseline

- Last known Lucent export: 104 paths / 224 schemas.
- Generated package uses the official OpenAPI Generator `dart-dio` generator with `json_serializable`
  and `copy_with_extension`. All enums include `unknownDefaultOpenApi` fallback via
  `enumUnknownDefaultCase=true`.
- Generated package includes auth/account, user-scoped health context, daily records, AI daily-record
  candidate parsing, medicine search/detail, current medicines, dose logs, environment snapshot,
  schedule-only medicine reminders, read-only reminder delivery history, user settings, assistant
  capability/conversation, report dashboard, Today AI analysis, report AI summary, public support
  resources/app info, data export requests, notifications, legal documents, and assistant streaming
  REST DTOs, and medicine risk check (static + LLM) DTOs.
- Current user-scoped business data uses `/api/v1/user/*`; account profile/security actions stay
  under `/api/v1/account/*`.

## Usage Rules

- Business and presentation code use `LucentDioClient` or feature repositories, not generated
  internals directly.
- Generated DTOs stay in data-layer response mapping.
- Read-side contract drift must be fixed at the Lucent OpenAPI export first. Do not bypass an
  existing generated read API with handwritten Dio GET parsing unless
  `../Lucent/docs/openapi.json` has been freshly exported,
  `dart run scripts/bootstrap_generated_sources.dart` has been attempted, and the exported contract
  still lacks the required fields.
- For writes where nullable clearing matters, use local domain write inputs or raw Dio JSON maps
  instead of generated write DTOs.
- Medicine reminder create/update writes use a local write input plus raw Dio JSON so `daysOfWeek:
  null`, `startDate`, and `endDate` are sent with the intended nullable behavior; generated
  reminder DTOs remain the read-side mapper.
- Reminder delivery history is read through the feature data source and maps generated/raw response
  fields into local UI rows. The generated `ReminderDeliveriesApi` exists, but presentation/domain
  code should still depend on the feature repository boundary.
- Today AI analysis, Report AI summary, and assistant streaming all use manual Dio + SSE parsing in
  `lib/core/network/sse.dart`, not generated OpenAPI transport methods.
- `Accept-Language` is injected by the network layer.
- Authorization is injected when an access token exists.
- `401002` triggers refresh and retry.
- Dio errors are unwrapped through `LucentErrorMapper`.
- Use `LucentDioClient.medicinesHeaders(bypassCache: true)` for one-off medicine reads that must
  bypass Lucent read cache.

## Regenerate

From `Luminous`:

```bash
# 1. Make sure Lucent has exported the latest contract
cd ../Lucent
pnpm export:openapi

# 2. Generate the Dart client (requires @openapitools/openapi-generator-cli installed)
cd ../Luminous
openapi-generator-cli generate \
  -i ../Lucent/docs/openapi.json \
  -g dart-dio \
  -o generated/lucent_api \
  -c /path/to/openapi_gen_config.json
```

Example config (`openapi_gen_config.json`):

```json
{
  "pubName": "lucent_api",
  "serializationLibrary": "json_serializable",
  "pubDescription": "Generated Lucent API client (openapi_generator dart-dio)",
  "enumUnknownDefaultCase": true
}
```

After generating, restore the generated `pubspec.yaml` SDK and dependency constraints to the project
baseline, then run:

```bash
dart run scripts/bootstrap_generated_sources.dart
```

This runs `flutter pub get`, `dart pub get` in `generated/lucent_api`, `build_runner` for both the
generated package and the root app, and `flutter gen-l10n`.

After regeneration, run:

```bash
git -C Luminous diff --check
flutter analyze
flutter test
```

For CI-only contract-path verification without re-exporting from a sibling workspace layout, run:

```bash
dart run scripts/verify_lucent_openapi_sync.dart \
  --openapi /absolute/path/to/Lucent/docs/openapi.json
```

`verify_lucent_openapi_sync.dart` verifies that the target OpenAPI file is readable JSON and that
the generated client layout exists, so it can run safely before commit inside a dirty working tree.

## Noise Boundary

- `generated/lucent_api/lib/api/**` is tracked for contract review, but its nested `**/*.g.dart`
  stays local-only and ignored.
- `generated/lucent_api/pubspec.lock` stays local-only and ignored.
- Flutter generated sources in the main app (`*.g.dart`, `*.freezed.dart`,
  `lib/l10n/app_localizations*.dart`) are also local-only and ignored.
- CI and local validation now regenerate these artifacts before analyze/test via
  `dart run scripts/bootstrap_generated_sources.dart`.
- The `dart-dio` generator still produces Markdown doc stubs and package test stubs; these are
  tracked by the project baseline and regenerated alongside the rest of the package.
