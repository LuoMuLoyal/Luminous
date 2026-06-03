# Lucent OpenAPI Client

Last updated: 2026-06-03

## Files

- Generated package: `packages/lucent_openapi/`
- Wrapper: `lib/core/network/lucent_dio_client.dart`
- Export: `lib/core/network/lucent_api.dart`

## Behavior

- Generated from `../Lucent/docs/openapi.json` with `dart-dio`
- Business code uses `LucentDioClient`, not generated internals
- Token storage prefers secure storage, with platform fallback
- `Accept-Language` is injected by the network layer
- Authorization is injected when an access token exists; generated `secure` metadata is not trusted because the current generator emits empty lists
- `401002` triggers refresh and retry
- Dio errors are unwrapped through `LucentErrorMapper`
- Medicines API is now generated into `packages/lucent_openapi`; call sites should use `LucentDioClient.medicinesHeaders(bypassCache: true)` when a one-off medicines refresh must bypass Lucent read cache.
- `ChangeEmailDto` follows Lucent contract: `newEmail` + `code`
- `RegisterDto` follows Lucent contract: `email` + `password` + register-scene `code`; successful registration returns a verified email.
- Re-generated from Lucent `openapi.json` on 2026-06-02 after the auth alignment pass. No business-layer SDK surface changes were required in `lib/core/network/`; regeneration is now expected to go through the repo wrapper instead of manual package repair.
- Re-generated again on 2026-06-02 after Lucent added `PATCH /api/v1/me/health-context/profile`; current app settings usage now consumes the supported `locale / timezone / unitSystem` preference write path, while theme mode and notification toggles remain local because Lucent does not expose write endpoints for them yet.
- Re-generated on 2026-06-03 after Lucent added full health-context write APIs (profile expansion, allergy/condition/current-medicine CRUD). The `health_context` feature remote data source now exposes all write methods through the generated `UserHealthContextApi`, and the repository interface + Lucent-backed implementation cover the complete read/write surface. Settings profile sync continues to use the same `PATCH /me/health-context/profile` path unchanged.
- Post-audit update on 2026-06-03: health-context domain and presentation code must not pass generated write DTOs directly. `lib/features/health_context/domain/entities/health_context_write_inputs.dart` owns the local write inputs/enums, and `HealthContextRemoteDataSource` serializes writes as raw Dio JSON maps so explicit `null` values still clear nullable Lucent fields. Generated DTOs remain acceptable in data-layer response mapping.
- Current stable regeneration entrypoint is `dart run tool/regenerate_lucent_openapi.dart`.
- The OpenAPI generator version is already pinned in `openapitools.json`; the recurring breakage is downstream in the Dart package output:
  - `openapi-generator-cli` rewrites `packages/lucent_openapi/pubspec.yaml` back to older constraints.
  - `json_serializable 6.14.0` currently emits invalid nullable map entries in generated `packages/lucent_openapi/lib/src/model/*.g.dart` for this package shape (`'field': ?instance.field`).
- `tool/regenerate_lucent_openapi.dart` is the supported fix path. It exports Lucent OpenAPI, regenerates the Dart client, restores the generated package constraints (`sdk 3.12`, `json_annotation 4.12.0`, `build_runner 2.15.0`, `json_serializable 6.14.0`), rebuilds serializers, patches the broken nullable map entries, formats the model files, analyzes the generated package, and refreshes root Flutter dependencies.

## Regenerate

```bash
dart run tool/regenerate_lucent_openapi.dart
```

Do not run ad-hoc `npx @openapitools/openapi-generator-cli generate` plus manual `build_runner` steps unless you are intentionally debugging the generator itself. The wrapper script is what keeps the generated package usable on the current Flutter/Dart toolchain.
