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
    → Repository (domain)
      → LucentDioClient (core/network)
        → Dio HTTP client
          → Lucent REST API
```

- `lib/core/network/lucent_dio_client.dart`: Configured Dio instance with auth interceptors, base
  URL, timeout.
- `lib/core/network/lucent_session_store.dart`: Token storage (secure storage on mobile, fallback on
  desktop/web).
- `lib/core/network/lucent_api.dart`: Convenience accessors for the generated API client.

### Generated API Client

`generated/lucent_api/` is auto-generated from `../Lucent/docs/openapi.json` via
`openapi_retrofit_generator` (Retrofit + json_serializable). Regenerate with:

```bash
cd generated/lucent_api && dart run build_runner build
```

This script normalizes generated pubspec constraints and fixes broken nullable `*.g.dart` entries.
Do not use ad-hoc `npx` / `build_runner` commands.

### Repository Pattern

Feature modules access data through repository interfaces, with separate implementations for real
API and mock/demo:

```
lib/features/<feature>/data/repositories/
├── <feature>_repository.dart          # Abstract interface
├── lucent_<feature>_repository.dart   # Real API implementation
└── mock_<feature>_repository.dart     # Demo-only (kDebugMode gated)
```

---

