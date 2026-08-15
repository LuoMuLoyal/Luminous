---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-15
---

# Data Layer

本文件是 [[architecture]] 拆分后的子文档。

相关子文档：
- [[state-management]]
- [[routing]]

## 5. Data Layer

### Network Stack

```
Widget
  → Riverpod Provider
    → Repository (domain interface / data implementation)
      → lucentClientProvider (generated API client, core/network)
        → LucentDioClient (Dio config + interceptors)
          → Lucent REST API
```

- `lib/core/network/dio_client.dart`: `LucentDioClient` — configured Dio instance with auth/error/retry
  interceptors, base URL, timeout.
- `lib/core/network/session_store.dart`: `LucentSessionStore` — token storage (secure storage on
  mobile, fallback on desktop/web).
- `lib/core/network/api.dart`: Barrel export re-exporting the generated API client and all network
  layer files. Features use `ref.watch(lucentClientProvider).medicines` etc. to access typed API
  methods.
- `lib/core/network/error_mapper.dart`: `LucentErrorMapper.fromObject()` is the single source of
  truth for `DioException` → `LucentApiException` mapping (envelope parsing, fallback messages,
  network-error-code derivation, traceId binding). `lib/core/network/interceptors/error_interceptor.dart`
  delegates to it and only re-wraps the mapped exception into a rejected `DioException`, so the
  mapping logic is not duplicated between the interceptor and feature call sites.
  `LucentErrorMapper.toAppError()` now preserves `traceId` on the resulting `AppError` so the
  diagnostics panel in Mine sync failures can copy it.
- `lib/core/network/sse.dart`: `LucentSseClient` — direct `text/event-stream` consumer with
  optional reconnect and capped exponential backoff (1s, 2s, 4s, ... clamped to 60s) so raising
  `maxReconnects` later cannot produce unbounded delays.
- `lib/core/network/interceptors/auth_interceptor.dart`: guards the `onSessionExpired`
  callback (a throwing callback is logged and the original error still resolves) and logs
  token-refresh failures with endpoint/status before degrading to a session clear.

### Generated API Client

`generated/lucent_api/` is auto-generated from `../Lucent/docs/openapi.json` via
`@openapitools/openapi-generator-cli` (generator `dart-dio`, `serializationLibrary=json_serializable`,
`enumUnknownDefaultCase=true`). Regenerate with:

```bash
cd ../Lucent
pnpm export:openapi
cd ../Luminous
openapi-generator-cli generate -i ../Lucent/docs/openapi.json -g dart-dio -o generated/lucent_api -c openapi_gen_config.json
dart run scripts/bootstrap_generated_sources.dart
```

`bootstrap_generated_sources.dart` runs `flutter pub get`, `dart pub get` in the generated package,
`build_runner` for both the generated package and the root app, and `flutter gen-l10n`.
Do not use ad-hoc `npx` / `build_runner` commands.

The generated client includes `AppInfoDataDto` with `minClientVersion`, `latestVersion`,
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
   topic's version automatically rebuild. See [[state-management#Cross-Feature Data Refresh
   (Invalidation Bus)]].

2. **Shared Read-Only Snapshot Hub** — `healthContextSnapshotProvider`
   (`health_context/data/providers/health_context.dart`) is the single keepAlive, `authGuarded`
   entry point for the user's health context. Any feature needing allergies, conditions, or current
   medicines reads from this provider rather than fetching independently. It watches the
   invalidation bus for `healthContext` and `currentMedicines` topics, so consumers always get
   fresh data without manual refresh calls. See [[state-management#Shared Read-Only Snapshot Hub]].

### Offline / Cache-First Strategy

ADR-0009 introduced Drift-based local persistence. Repositories for `daily-records`,
`health-context`, and `dose-logs` follow a cache-first pattern:

- **Read**: serve from local cache immediately, trigger a throttled background refresh (30s) from
  the network, and backfill the cache.
- **Write**: optimistic local copy first, then remote confirm; on failure, enqueue to
  `pending_sync_queue` for replay via `SyncWorker` (connectivity listener + exponential backoff).
- **Failure details**: `PendingSyncDao.fetchPermanentlyFailed()` exposes the diagnostic fields kept
  in the queue (`entityType`, `entityId`, `operation`, retry counts, `lastError`, and
  `lastErrorDetails`) for the Mine sync-failure dialog. `lastErrorDetails` is a JSON-encoded
  `PendingSyncErrorDetails` object produced by `LucentErrorMapper.toAppError()`; it carries
  `message`, `code`, `statusCode`, `traceId`, `networkErrorCode`, and `kind` so the UI can show
  localized user-facing messages without parsing raw exception strings. `lastError` is kept for
  backwards compatibility and as the raw diagnostic fallback. `resetForRetry()` clears both error
  columns before a manual flush; the queued payload is never rendered or modified by the UI. Pending
  sync ids use a cryptographically random suffix (`Random.secure()`) so they remain unique across
  hot restarts and isolates. `markFailed()` increments `retryCount` atomically at the database level
  (`retryCount = retryCount + 1`) so concurrent callers cannot race on a read-then-write value;
  backoff is computed by the shared `backoffForRetryCount()` helper.
- **Cleanup**: `cacheCleanupProvider` trims expired cache rows at startup based on the user's
  `DataRetentionPeriod` setting.

---

