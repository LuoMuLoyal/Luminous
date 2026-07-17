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

### Generated API Client

`generated/lucent_api/` is auto-generated from `../Lucent/docs/openapi.json` via
`openapi_retrofit_generator` (Retrofit + json_serializable). Regenerate with:

```bash
cd generated/lucent_api && dart run build_runner build
```

This script normalizes generated pubspec constraints and fixes broken nullable `*.g.dart` entries.
Do not use ad-hoc `npx` / `build_runner` commands.

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
- **Cleanup**: `cacheCleanupProvider` trims expired cache rows at startup based on the user's
  `DataRetentionPeriod` setting.

---

