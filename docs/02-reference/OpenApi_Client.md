# Lucent OpenAPI Client

Last updated: 2026-07-08

This file records the supported Flutter client workflow. API shape comes from Lucent controller/DTO
code plus a freshly exported local `../Lucent/docs/openapi.json`, not from prose.

## Files

- Generated OpenAPI source from the `Luminous` repo root: local export `../Lucent/docs/openapi.json`
- Generated Dart package scaffold: `generated/lucent_api/`
- Network wrapper: `lib/core/network/dio_client.dart`
- Public Flutter API exports: `lib/core/network/api.dart`
- Contract drift verifier: `tool/verify_lucent_openapi_sync.dart`

## Current Generated Baseline

- Last known Lucent export: 84 paths / 188 schemas.
- Generated package includes auth/account, user-scoped health context, daily records with persisted
   `occurredTime`, AI daily-record candidate parsing, medicine search/detail, current medicines,
   dose logs, environment snapshot, schedule-only medicine reminders with optional date windows,
   read-only reminder delivery history, user settings, assistant capability discovery plus
   recent-conversation list/open and latest-conversation restore/archive DTOs, report dashboard
   with `last_7_days`/`last_30_days`/`custom` range support, Today AI analysis, range-based report
   AI summary (`last_7_days` / `last_30_days` / `custom`), public support resources/app info, data
   export request status plus explicit create-request DTOs/enums, and the new Today/Report AI
   stream response DTOs.
- Current user-scoped business data uses `/api/v1/user/*`; account profile/security actions stay
   under `/api/v1/account/*`.

## Usage Rules

- Business and presentation code use `LucentDioClient` or feature repositories, not generated
   internals directly.
- Generated DTOs stay in data-layer response mapping.
- Read-side contract drift must be fixed at the Lucent OpenAPI export first. Do not bypass an
   existing generated read API with handwritten Dio GET parsing unless
   `../Lucent/docs/openapi.json` has been freshly exported,
   `dart run tool/bootstrap_generated_sources.dart` has been attempted, and the exported contract
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
   `lib/core/network/sse.dart`, not generated OpenAPI transport methods. Assistant
   capability/latest/clear plus recent-conversation list/open reads still use the generated REST
   methods, and generated DTOs remain the contract source for capability/result payload shapes.
   Assistant streamed `proposedActions` now also carry `target`, `constraints`, and `expiresAt`,
   while high-certainty read tool envelopes remain server-internal prompt context rather than
   public REST DTOs.
- `Accept-Language` is injected by the network layer.
- Authorization is injected when an access token exists.
- `401002` triggers refresh and retry.
- Dio errors are unwrapped through `LucentErrorMapper`.
- Use `LucentDioClient.medicinesHeaders(bypassCache: true)` for one-off medicine reads that must
   bypass Lucent read cache.
- The new generator (`openapi_retrofit_generator`) handles enum defaults and nullable map entries
   natively, so no post-generation patching is needed.

## Regenerate

From `Luminous`:

```bash
dart run tool/bootstrap_generated_sources.dart
```

Hosted CI can also point the workflow at an explicitly checked-out Lucent contract file:

```bash
dart run tool/verify_lucent_openapi_sync.dart --openapi /absolute/path/to/Lucent/docs/openapi.json
```

The generator (`openapi_retrofit_generator`) reads the OpenAPI spec, generates Retrofit API clients
and JSON-serializable models, then `build_runner` produces the `.g.dart` files. No post-generation
patching is needed — the new generator handles enum defaults and nullable maps correctly.

After regeneration, run:

```bash
git -C Luminous diff --check
flutter analyze
flutter test
```

For CI-only contract-path verification without re-exporting from a sibling workspace layout, run:

```bash
dart run tool/verify_lucent_openapi_sync.dart \
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
  `dart run tool/bootstrap_generated_sources.dart`.
- The new generator does not produce Markdown doc stubs or package test stubs, so there is no
  noise from those paths.
