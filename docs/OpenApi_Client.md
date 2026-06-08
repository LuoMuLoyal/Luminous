# Lucent OpenAPI Client

Last updated: 2026-06-08

This file records the supported Flutter client workflow. API shape comes from Lucent controller/DTO code plus generated `../Lucent/docs/openapi.json`, not from prose.

## Files

- Generated OpenAPI source from the `Luminous` repo root: `../Lucent/docs/openapi.json`
- Generated Dart package: `packages/lucent_openapi/`
- Network wrapper: `lib/core/network/lucent_dio_client.dart`
- Public Flutter API exports: `lib/core/network/lucent_api.dart`
- Regeneration wrapper: `tool/regenerate_lucent_openapi.dart`

## Current Generated Baseline

- Last known Lucent export: 38 paths / 106 schemas.
- Generated package includes auth/account, health context, daily records, medicine search/detail, current medicines, dose logs, environment snapshot, and schedule-only medicine reminders.

## Usage Rules

- Business and presentation code use `LucentDioClient` or feature repositories, not generated internals directly.
- Generated DTOs stay in data-layer response mapping.
- For writes where nullable clearing matters, use local domain write inputs or raw Dio JSON maps instead of generated write DTOs.
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

The wrapper exports Lucent OpenAPI, regenerates the Dart client, restores the generated package constraints, rebuilds serializers, patches known nullable-map generator output, formats generated model files, analyzes the generated package, and refreshes root Flutter dependencies.

Do not run ad-hoc `npx @openapitools/openapi-generator-cli generate` or manual `build_runner` steps for normal work.

After regeneration, run:

```bash
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
flutter analyze
flutter test
```

Generated Markdown whitespace inside `packages/lucent_openapi/**` may remain generator output; do not normalize it just to make diffs prettier.
