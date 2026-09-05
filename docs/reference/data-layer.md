---
status: active
owner: frontend
updated: 2026-08-31
---

# Data Layer

本文件是 [Architecture](architecture.md) 拆分后的子文档。

相关子文档：
- [State Management](state-management.md)
- [Routing](routing.md)

## Data Layer

### Network Stack

`core/network/` 按职责分两组：`client/`（HTTP 执行栈：Dio client、providers、session、SSE、base URL、重试、trace、interceptors）与 `contract/`（响应与错误合同：api_paths、response_body、problem_details、error_code、result_code、error_mapper）；根下仅留 barrel `api.dart` 与纯工具 `map_utils.dart`。

```
Widget
  → Riverpod Provider
    → Repository (domain interface / data implementation)
      → lucentClientProvider (generated API client, core/network)
        → LucentDioClient (Dio config + interceptors)
          → Lucent REST API
```

- `lib/core/network/client/dio_client.dart`: `LucentDioClient` — configured Dio instance with auth/error/retry
  interceptors, base URL, timeout.
- `lib/core/network/client/session_store.dart`: `LucentSessionStore` — token storage (secure storage on
  mobile, fallback on desktop/web).
- `lib/core/network/api.dart`: Barrel export re-exporting the generated API client and all network
  layer files. Features use `ref.watch(lucentClientProvider).medicines` etc. to access typed API
  methods.
- `lib/core/network/contract/error_mapper.dart`: `LucentErrorMapper.fromObject()` is the single source of
  truth for `DioException` → `LucentFailure` mapping. HTTP errors require
  `application/problem+json` and strict Problem Details parsing (missing body, wrong media type,
  and field-type mismatches stay `FormatException` — protocol invariants, never business
  `LucentFailure`); transport failures receive client-only network metadata and trace correlation.
  `lib/core/network/client/interceptors/error_interceptor.dart` delegates to it and re-wraps the mapped
  failure into a rejected `DioException`. The legacy `LucentApiException` compat branch is retained
  only for the WeChat mobile auth client's local SDK failures.
- `lib/core/network/client/sse.dart`: `LucentSseClient` — direct `text/event-stream` consumer with
  optional reconnect and capped exponential backoff (1s, 2s, 4s, ... clamped to 60s) so raising
  `maxReconnects` later cannot produce unbounded delays. An empty stream response surfaces as
  `LucentFailure.network(emptyStreamResponse)`.
- `lib/core/network/contract/response_body.dart`: `requireData(response, operation: 'apiName')` guards
  success responses — an empty/non-object body throws so the repository boundary maps it to
  `LucentFailure.network(emptyResponse)` instead of a bare `!` crash. The retired
  `{ code, message, data }` envelope is not interpreted anywhere.
- `lib/core/network/client/interceptors/auth_interceptor.dart`: token injection + 401 refresh + retry +
  session clear. Refresh outcomes are typed (`_RefreshOutcome`): the refresh token being rejected
  (Problem Details 401/403) is an auth failure that clears the session and notifies the auth layer,
  while network/timeout/5xx/empty-body failures are transient and keep the session. **Only
  `AUTH_TOKEN_EXPIRED` triggers a refresh** (positive allow-list); `AUTH_REQUIRED`,
  `AUTH_REFRESH_TOKEN_INVALID`, `AUTH_WRONG_PASSWORD`, and plain 401/403 never refresh — a plain
  401 clears the session, a 403 does not. Concurrent requests share a single refresh; a definitive
  refresh failure clears the session and passes the **original** `LucentFailure` back to the caller.
  The `onSessionExpired` callback is guarded (a throwing callback is logged and the original error
  still resolves).

### Generated API Client

`generated/lucent_api/` is auto-generated from `../Lucent/docs/reference/generated/openapi.json` via
`@openapitools/openapi-generator-cli` (generator `dart-dio`, `serializationLibrary=json_serializable`,
`enumUnknownDefaultCase=true`). Regenerate with:

```bash
cd ../Lucent
pnpm export:openapi
cd ../Luminous
openapi-generator-cli generate -i ../Lucent/docs/reference/generated/openapi.json -g dart-dio -o generated/lucent_api -c openapi_gen_config.json
dart run scripts/contract/bootstrap.dart
```

`scripts/contract/bootstrap.dart` runs `flutter pub get`, `dart pub get` in the generated package,
`build_runner` for both the generated package and the root app, and `flutter gen-l10n`.
Do not use ad-hoc `npx` / `build_runner` commands.

The generated client includes `AppInfoResponse` with `minClientVersion`, `latestVersion`,
`downloadUrl`, and `supportEmail` fields, consumed by the About page's "Check for Updates" feature
and the Help page's feedback email resolution.

### Repository Pattern

Feature modules access data through repository interfaces defined in `domain/repositories/`, with a
single Lucent (real API) implementation in `data/repositories/`. Mock repositories live only under
`test/helpers/mocks/` for unit/widget tests — production code always uses the Lucent implementation.

```
lib/features/<feature>/
├── domain/repositories/<feature>.dart      # Abstract interface (abstract interface class)
└── data/repositories/lucent.dart           # Lucent API implementation + provider
```

All repository providers are declared with `@riverpod` and access the API through the shared
`lucentClientProvider`. Repository implementations own DTO ↔ domain entity mapping so that
presentation/domain layers never see generated DTO types.

The `health_event` slice follows the same boundary: `HealthEventRepository` exposes domain
entities, `LucentHealthEventRepository` maps the generated `HealthEventsApi`, and
`activeHealthEventProvider` owns the keep-alive loading/data/error state plus explicit refresh.
An empty active response and HTTP 404 both mean “no active event”; other transport failures remain
errors so the UI can offer a retry path.

### Repository Failure Boundary

Every feature repository exposes expected, recoverable failures as
`TaskEither<LucentFailure, T>` (fpdart 1.x, [ADR-0005](adr/0005-result-type-and-error-handling.md))
— no project-local Result alias exists.

- **Datasources** keep `Future`/`Stream` transport responsibility and throw `DioException` (or
  `LucentFailure` for empty success bodies, precedent: `LucentFailure.network(emptyResponse)`).
- **Repositories** wrap datasource calls with
  `TaskEither.tryCatch(..., (error, stackTrace) => LucentErrorMapper.fromObject(error))`; protocol
  invariants (malformed generated payloads, non-Problem-Details error bodies) stay thrown
  `FormatException`/`StateError` and surface from `run()` — they are never disguised as Left.
- **Providers/controllers** call `run()` and fold: Left → `AsyncValue.error` or an explicit action
  state; Right → data. Widgets render provider state only — no fpdart, no `DioException`
  inspection, no code/status parsing.
- **Offline cache** (daily-records / health-context / dose-logs): cache writes that are required
  for request success map to Left; best-effort background refresh writes log and continue; write
  failures enqueue to the pending-sync queue **and** return Left (enqueue self-failures are logged
  and never mask the original network failure).
- **Retry** is decided only by `RetryPolicy` (HTTP status, network error type, `retryable`,
  `retryAfter`, idempotency) in the transport layer — features never add their own retry loops.
- **SSE**: `event: error` payloads are parsed as `SseProblemDetails` → `LucentFailure`; cancellation
  and disconnects keep Stream semantics (see [ADR-0005](adr/0005-result-type-and-error-handling.md)).

### Domain Interface Injection (Cross-Feature)

When a feature's repository needs data from another feature, it depends on the other feature's
**domain interface** — never on its data source concrete type. The provider assembly layer injects
the concrete implementation at wiring time.

Domain interfaces exposed for cross-feature consumption:

- `medicine/domain/repositories/dose_log.dart` — `DoseLogRepository` (implemented by
  `CachedDoseLogDataSource`). Consumed by `today/data/repositories/lucent.dart`.
- `medicine/domain/repositories/reminder.dart` — `ReminderRepository` (implemented by
  `MedicineReminderRemoteDataSource`). Consumed by `today/data/repositories/lucent.dart`.

```dart
// today/data/providers/today_suggestion.dart — provider assembly
@riverpod
TodayRepository todayRepository(Ref ref) {
  return LucentTodayRepository(
    dailyRecordRepository: ref.watch(dailyRecordRepositoryProvider),
    doseLogRepository: ref.watch(doseLogRepositoryProvider),       // domain interface
    medicineReminderRepository: ref.watch(medicineReminderRepositoryProvider), // domain interface
    // ...
  );
}
```

This ensures `today/data/` never imports `medicine/data/` — the dependency direction is
`today/data → medicine/domain` (interface) + `today/data/providers → medicine/data/providers`
(wiring), not `today/data → medicine/data` (implementation).

### Cross-Feature Data Access

Features must not directly import another feature's presentation-layer providers. Two mechanisms
keep features decoupled while sharing data:

1. **Invalidation Bus** (`lib/core/providers/data_change_bus.dart`) — a version-counter event bus for
   cross-feature write-path refresh. When a feature mutates shared data, it emits a topic
   (`DataChangeTopic.dailyRecords`, `healthContext`, etc.); dashboard providers that `ref.watch` the
   topic's version automatically rebuild. See [State Management](state-management.md#cross-feature-data-refresh-invalidation-bus).

2. **Shared Read-Only Snapshot Hub** — `healthContextSnapshotProvider`
   (`health_context/data/providers/health_context.dart`) is the single keepAlive, `authGuarded`
   entry point for the user's health context. Any feature needing allergies, conditions, or current
   medicines reads from this provider rather than fetching independently. It watches the
   invalidation bus for `healthContext` and `currentMedicines` topics, so consumers always get
   fresh data without manual refresh calls. See [State Management](state-management.md#shared-read-only-snapshot-hub).

### Offline / Cache-First Strategy

[ADR-0006](adr/0006-local-persistence-drift.md) introduced Drift-based local persistence.
Repositories for `daily-records`, `health-context`, and `dose-logs` follow a cache-first pattern:

- **Schema version**: currently `5`. v5 renames `report_dashboard_cache_entries` →
  `review_dashboard_cache_entries` (report→review migration). The rename is defensive:
  it queries `sqlite_master` to check if the old table name exists before issuing
  `ALTER TABLE ... RENAME TO ...`, so users who first installed at v4 after the
  `ReviewDashboardCacheEntries` class rename (d607145) — and therefore already have
  the `review_dashboard_cache_entries` SQL table name — skip the rename cleanly.
  Earlier versions: v1 initial schema, v2 adds `lastErrorDetails` to `PendingSyncItems`,
  v3 adds `ReviewCacheEntries`, v4 adds `ReviewDashboardCacheEntries`.

- **Read**: serve from local cache immediately, trigger a throttled background refresh (30s) from
  the network, and backfill the cache.
- **Write**: optimistic local copy first, then remote confirm; on failure, enqueue to
  `pending_sync_queue` for replay via `SyncWorker` (connectivity listener + exponential backoff).
- **Failure details**: `PendingSyncDao.fetchPermanentlyFailed()` exposes the diagnostic fields kept
  in the queue (`entityType`, `entityId`, `operation`, retry counts, `lastError`, and
  `lastErrorDetails`) for the Mine sync-failure dialog. `lastErrorDetails` is a JSON-encoded
  `PendingSyncErrorDetails` object produced by the sync worker via
  `PendingSyncErrorDetails.fromLucentFailure(...)`; it carries `message`, `code`, `statusCode`,
  `traceId`, `networkErrorCode`, and `kind` (`LucentFailureKind`) so the UI can show localized
  user-facing messages without parsing raw exception strings. The JSON decoder is backward
  compatible with rows persisted before the migration (legacy `AppErrorKind` names and numeric
  codes, including the `VALIDATION_FAILED` bridge for 400001/400002) and never throws on old rows.
  `lastError` is kept for backwards compatibility and as the raw diagnostic fallback.
  `resetForRetry()` clears both error columns before a manual flush; the queued payload is never
  rendered or modified by the UI. Pending sync ids use a cryptographically random suffix
  (`Random.secure()`) so they remain unique across hot restarts and isolates. `markFailed()`
  increments `retryCount` atomically at the database level (`retryCount = retryCount + 1`) so
  concurrent callers cannot race on a read-then-write value; backoff is computed by the shared
  `backoffForRetryCount()` helper.
- **Cleanup**: `cacheCleanupProvider` trims expired cache rows at startup based on the user's
  `DataRetentionPeriod` setting.

---
