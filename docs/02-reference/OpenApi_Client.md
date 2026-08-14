---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-13
---

# Lucent OpenAPI Client

Last updated: 2026-08-13

This file records the supported Flutter client workflow. API shape comes from Lucent controller/DTO
code plus a freshly exported local `../Lucent/docs/openapi.json`, not from prose.

## Files

- Generated OpenAPI source from the `Luminous` repo root: local export `../Lucent/docs/openapi.json`
- Generated Dart package scaffold: `generated/lucent_api/`
- Network wrapper: `lib/core/network/dio_client.dart`
- Public Flutter API exports: `lib/core/network/api.dart`
- Contract drift verifier: `scripts/verify_lucent_openapi_sync.dart`

## Current Generated Baseline

- Last known Lucent export: 117 paths / 272 schemas.
- Generated package uses the official OpenAPI Generator `dart-dio` generator with `json_serializable`
  and `copy_with_extension`. All enums include `unknownDefaultOpenApi` fallback via
  `enumUnknownDefaultCase=true`.
- Generated package includes auth/account, user-scoped health context, daily records, AI daily-record
  candidate parsing, medicine search/detail, current medicines, dose logs, environment snapshot,
  schedule-only medicine reminders, read-only reminder delivery history, user settings, assistant
  capability/conversation, report dashboard, event review (current / history / detail read model),
  Today AI analysis, report AI summary, public support resources/app info, data export requests,
  notifications, legal documents, and assistant streaming REST DTOs, and medicine risk check
  (static + LLM) DTOs.
- Event review endpoints live in the generated `ReportsApi`:
  `reportsControllerGetCurrentReviewV1` (no event → `EventReviewNullableResponseDto` with null
  `data`, not a 404), `reportsControllerListReviewsV1` (status/cursor/limit, opaque
  `startedAtISO|id` cursor), `reportsControllerGetEventReviewV1` (foreign/missing → 404). The 14
  generated `EventReview*Dto` models mirror Lucent's read-model shape; domain mapping preserves
  section state / reasonCode / coverage / sources instead of collapsing unknown values.
- `scripts/bootstrap_generated_sources.dart` regenerates the filtered client as two
  openapi-generator passes (TodayAnalysis and Reports) because the 7.x CLI accepts only a single
  `apis` value per run; outputs are merged into `generated/lucent_api/` and formatted.
- Current user-scoped business data uses `/api/v1/user/*`; account profile/security actions stay
  under `/api/v1/account/*`.
- Legacy user-device registration is no longer part of the Lucent contract. Push identity is
  maintained by the JPush SDK through the authenticated user's UUID alias, so the generated
  client and `LucentDioClient` intentionally expose no `UserDevicesApi` or device-registration DTOs.

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
- Today AI REST reads/generation/refresh use the generated OpenAPI transport and unwrap the
  `{ code, message, data }` envelope in the Today data source. Today AI streaming, Report AI
  summary, and assistant streaming continue to use manual Dio + SSE parsing in
  `lib/core/network/sse.dart`.
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

# 2. Run the repository-owned filtered generator and generated-source bootstrap
cd ../Luminous
dart run scripts/bootstrap_generated_sources.dart
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

The bootstrap uses OpenAPI Generator with a Today Analysis API/model filter, copies only the
contract slice and its required index/deserialize files into `generated/lucent_api`, then runs
`flutter pub get`, generated-package `dart pub get`, `build_runner` for both the generated package
and the root app, and `flutter gen-l10n`. This keeps the generated package on the repository Dart
SDK constraint and avoids unrelated full-client churn.

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

`verify_lucent_openapi_sync.dart` verifies that the target OpenAPI file is readable JSON, the
generated client layout exists, and the generated `TodayAnalysisApi` exposes the GET and refresh
operations.

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

## 2026-08-14 Clinic summary preview/share 信封绕行

- `POST /user/reports/clinic-summary/preview` 与 `/share` 的服务端响应是 `{code, message, data}` 信封，而生成的 `ReportsApi` 把 body 直接当裸 `ClinicSummaryDto` / `ClinicSummaryShareResponseDto` 反序列化（会抛 `CheckedFromJsonException`）。这两个端点因此不走生成客户端，改由 `LucentApiPaths.clinicSummaryPreview` / `clinicSummaryShare` + 原始 Dio 调用：解信封后再 `fromJson`（四个 section 键已随合同改可选，未选键反序列化为 null，不再占位补齐）。预览 PDF（POST 带 body）由 `downloadAndSharePdf` 的 `postBody` 参数承载字段选择。
- `GET /user/reports/clinic-summary/shared/{token}`（公开分享页）同型缺陷：Task 10 起同样走 raw Dio（`LucentApiPaths.clinicSummaryShared(token)` + `skipAuthorization: true`）解信封，不再使用生成客户端方法；与 preview 同一模式（占位补齐已随合同债收口删除）；相关 provider 测试以 scripted HttpClientAdapter 断言请求不带 Authorization 头。
