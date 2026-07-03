# State Management (Riverpod)

本文件是 [[architecture]] 拆分后的子文档。

相关子文档：
- [[routing]]
- [[data-layer]]

## 2. State Management (Riverpod)

Luminous uses `flutter_riverpod` for all state management. The pattern follows a unidirectional data
flow:

```
Repository (data access)
    ↓
Provider / AsyncNotifier (state holder)
    ↓
Widget (via ref.watch / ref.listen)
    ↓
User action → ref.read(provider.notifier).method()
    ↓
Repository ← Provider ← (cycle)
```

### Key Conventions

- **`StateNotifier` / `AsyncNotifier`**: For mutable state that changes over time (form state, list
  filters, pagination).
- **`Provider`**: For derived/computed values and dependency injection of services.
- **`FutureProvider` / `StreamProvider`**: For async data that loads once or streams.
- **`ref.watch`** in build methods for reactive UI.
- **`ref.listen`** for side effects (toast, navigation) on state changes.
- **`ref.read`** in callbacks for one-shot actions.

### Why Riverpod

See [ADR-0001: Riverpod State Management](adr/0001-riverpod-state-management.md).

---

