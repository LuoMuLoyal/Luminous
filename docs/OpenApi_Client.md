# Lucent OpenAPI Client

Last updated: 2026-06-05

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
- Account profile/security calls use generated `AccountApi` through `LucentDioClient.accountApi`. Luminous uses `/account` for account data and actions; Lucent `/auth/me*` routes are removed. Health-context `/me/...` routes remain a separate health resource, not account compatibility endpoints.
- `ChangeEmailDto` follows Lucent contract: `newEmail` + `code`
- `RegisterDto` follows Lucent contract: `email` + `password` + register-scene `code`; successful registration returns a verified email.
- `AuthUser` stores `emailVerifiedAt` and derives `emailVerified` locally. Account detail responses also map `hasPassword`, `lastLoginAt`, and linked OAuth identities into the auth session user. Linked identities carry Lucent identity IDs so account settings can call `DELETE /api/v1/account/identities/{identityId}` through `AccountApi`.
- Re-generated on 2026-06-05 after Lucent added account identity unlinking. Lucent export currently reports **31 paths / 83 schemas**. The generated `AccountApi` now includes `accountControllerUnlinkIdentityV1`, and `AccountIdentityDto` includes `id`.
- WeChat OAuth login uses generated `OAuthAuthorizeDto`, `OAuthAuthorizeDataDto`, `OAuthAuthorizeResponseDto`, `OAuthCallbackDto`, and `OAuthCodeCallbackDto` through `AuthRemoteDataSource`. Android/iOS uses `fluwx` to obtain a native SDK auth code, then calls Lucent's WeChat mobile callback endpoint. Desktop login passes a loopback `callbackUri` to Lucent so the browser callback can redirect back to the app and verifies the returned `state` before exchanging the code. Web login passes the current origin plus `/login/oauth/wechat`; Lucent accepts it only when that origin is trusted by backend CORS config. OAuth-only Lucent users may have `email: null`, so `AuthUser.email` is nullable and UI should fall back to nickname, ID, or signed-out copy where appropriate.
- Re-generated on 2026-06-05 after Lucent removed legacy `/auth/me*` routes and kept account profile/security actions under `AccountApi`. Lucent export currently reports **30 paths / 83 schemas**. The generated package includes `AccountApi`, `AccountDto`, `AccountIdentityDto`, `AccountResponseDto`, `AccountEmailDataDto`, `AccountEmailResponseDto`, and `UpdateAccountDto`; stale `MeResponseDto` / `UpdateMeDto` artifacts were deleted.
- Re-generated on 2026-06-05 after Lucent added the desktop WeChat Web OAuth callback URI contract. Lucent export currently reports **30 paths / 81 schemas**. The generated package now includes `OAuthAuthorizeDto`, `OAuthAuthorizeDataDto.callbackUri`, `OAuthAuthorizeResponseDto`, `OAuthCallbackDto`, and `OAuthCodeCallbackDto`.
- Re-generated from Lucent `openapi.json` on 2026-06-02 after the auth alignment pass. No business-layer SDK surface changes were required in `lib/core/network/`; regeneration is now expected to go through the repo wrapper instead of manual package repair.
- Re-generated again on 2026-06-02 after Lucent added `PATCH /api/v1/me/health-context/profile`; current app settings usage now consumes the supported `locale / timezone / unitSystem` preference write path, while theme mode and notification toggles remain local because Lucent does not expose write endpoints for them yet.
- Re-generated on 2026-06-03 after Lucent added full health-context write APIs (profile expansion, allergy/condition/current-medicine CRUD). The `health_context` feature remote data source now exposes all write methods through the generated `UserHealthContextApi`, and the repository interface + Lucent-backed implementation cover the complete read/write surface. Settings profile sync continues to use the same `PATCH /me/health-context/profile` path unchanged.
- Post-audit update on 2026-06-03: health-context domain and presentation code must not pass generated write DTOs directly. `lib/features/health_context/domain/entities/health_context_write_inputs.dart` owns the local write inputs/enums, and `HealthContextRemoteDataSource` serializes writes as raw Dio JSON maps so explicit `null` values still clear nullable Lucent fields. Generated DTOs remain acceptable in data-layer response mapping.
- Re-generated on 2026-06-04 after Lucent restored the health-context write surface on `dev` and added typed medicine dose-log response schemas. Lucent export currently reports **27 paths / 76 schemas**. The generated package now includes `DoseLogItemDto`, `DoseLogListDataDto`, `DoseLogListResponseDto`, and `DoseLogResponseDto`.
- Current stable regeneration entrypoint is `dart run tool/regenerate_lucent_openapi.dart`.
- The OpenAPI generator version is already pinned in `openapitools.json`; the recurring breakage is downstream in the Dart package output:
  - `openapi-generator-cli` rewrites `packages/lucent_openapi/pubspec.yaml` back to older constraints.
  - `json_serializable 6.14.0` currently emits invalid nullable map entries in generated `packages/lucent_openapi/lib/src/model/*.g.dart` for this package shape (`'field': ?instance.field`).
- `tool/regenerate_lucent_openapi.dart` is the supported fix path. It exports Lucent OpenAPI, regenerates the Dart client, restores the generated package constraints (`sdk 3.12`, `json_annotation 4.12.0`, `build_runner 2.15.0`, `json_serializable 6.14.0`), rebuilds serializers, patches the broken nullable map entries, formats the model files, analyzes the generated package, and refreshes root Flutter dependencies.
- After regeneration, always run `git -C Luminous diff --check`. The generator can emit Markdown tables with trailing whitespace even when the Dart package analyzes cleanly; clean generated Markdown whitespace before committing rather than skipping the check.

## Regenerate

```bash
dart run tool/regenerate_lucent_openapi.dart
```

Do not run ad-hoc `npx @openapitools/openapi-generator-cli generate` plus manual `build_runner` steps unless you are intentionally debugging the generator itself. The wrapper script is what keeps the generated package usable on the current Flutter/Dart toolchain.
