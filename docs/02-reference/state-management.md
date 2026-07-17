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

### Provider 声明风格

ADR-0006 引入了 `riverpod_generator`。项目中有两种声明风格，各有适用场景：

#### 1. `@riverpod` 注解函数（首选）

用于**无状态 DI**、**只读异步数据**、**family 参数化查询**等场景。函数名直接推导 provider
名称（`myFunction` → `myFunctionProvider`），无需手写 provider 声明。

```dart
part 'my_file.g.dart';

// 纯 DI / 无状态服务
@riverpod
MyRepository myRepository(Ref ref) {
  return LucentMyRepository(api: ref.watch(lucentClientProvider).myApi);
}

// 只读异步数据（默认 autoDispose）
@riverpod
Future<MyData> myData(Ref ref) async {
  return ref.watch(myRepositoryProvider).fetch();
}

// keepAlive 异步数据（跨页面共享、dashboard 级别）
@Riverpod(keepAlive: true)
Future<MyDashboard> myDashboard(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(myRepositoryProvider).fetchDashboard(),
    signedOutFallback: () => ref.watch(myRepositoryProvider).signedOutDashboard,
  );
}

// family 参数化
@riverpod
Future<MyDetail> myDetail(Ref ref, String id) async {
  return ref.watch(myRepositoryProvider).findOne(id);
}
```

**规则**：
- 所有新的 `Provider<T>` / `FutureProvider<T>` / `FutureProvider.family` 声明必须使用 `@riverpod`
  或 `@Riverpod(keepAlive: true)` 注解。
- 默认 `autoDispose`；需要跨页面保持状态时使用 `@Riverpod(keepAlive: true)`。
- 文件需添加 `part 'my_file.g.dart';` 和 `import 'package:riverpod_annotation/riverpod_annotation.dart';`。

#### 2. 手写 `NotifierProvider` / `AsyncNotifierProvider`（Notifier 类）

用于**带 mutation 的有状态逻辑**（表单、分页、复杂交互状态）。riverpod_generator 的类注解
会从类名推导 provider 名称（`MyFormNotifier` → `myFormNotifierProvider`），但项目约定使用
`myFormProvider` 等简短名称，两者不匹配，因此 Notifier 类保持手写声明。

```dart
class MyFormNotifier extends Notifier<MyFormState> {
  @override
  MyFormState build() => const MyFormState();

  void updateField(String value) {
    state = state.copyWith(field: value);
  }
}

final myFormProvider =
    NotifierProvider<MyFormNotifier, MyFormState>(MyFormNotifier.new);
```

**规则**：
- `Notifier` / `AsyncNotifier` 类使用手写 `NotifierProvider` / `AsyncNotifierProvider` 声明。
- 类名保留 `Notifier` 或 `Controller` 后缀以区分职责。
- Provider 名称使用简短形式（`myFormProvider` 而非 `myFormNotifierProvider`）。
- 同一文件中可以混合 `@riverpod` 函数和手写 Notifier 类（例如 datasource 用注解、form
  notifier 用手写）。

### Provider 选型标准

| 场景 | 声明方式 | autoDispose | 示例 |
|------|---------|-------------|------|
| 纯 DI / 无状态服务 | `@riverpod` 函数 | 默认 autoDispose | `authApiProvider`、`myRepositoryProvider` |
| 只读异步数据（无 mutation） | `@riverpod` 返回 `Future<T>` | 默认 autoDispose | `legalDocumentsProvider`、`suggestionHistoryProvider` |
| 带 auth guard 的 dashboard | `@Riverpod(keepAlive: true)` | keepAlive | `todayDashboardProvider`、`mineDashboardProvider` |
| 跨 feature 共享的根级服务 | `@Riverpod(keepAlive: true)` | keepAlive | `lucentClientProvider`、`appDatabaseProvider` |
| family 参数化只读 | `@riverpod` 带 positional 参数 | 默认 autoDispose | `legalDocumentProvider(docType)`、`dailyRecordDetailProvider(id)` |
| 带 mutation 的同步状态 | 手写 `NotifierProvider` | keepAlive | `loginFormProvider`、`selectedRecordDateProvider` |
| 带 mutation 的异步状态 | 手写 `AsyncNotifierProvider` | keepAlive | `todaySuggestionProvider`、`notificationListControllerProvider` |
| ephemeral UI 状态 | `StatefulWidget` / `hooks` | N/A | 动画进度、局部 loading 标志 |

### Key Conventions

- **`Notifier` / `AsyncNotifier`**: For mutable state that changes over time (form state, list
  filters, pagination).
- **`@riverpod` 函数**: For derived/computed values, dependency injection, and read-only async data.
- **`ref.watch`** in build methods for reactive UI.
- **`ref.listen`** for side effects (toast, navigation) on state changes.
- **`ref.read`** in callbacks for one-shot actions.
- **`authGuarded`** helper (`core/providers/auth_guarded.dart`): Wraps `FutureProvider` fetch logic
  with auth session checks — session restoring → pending; signed out → `signedOutFallback`;
  authenticated → `fetch()`.

### Ephemeral UI State

`StatefulWidget` / `flutter_hooks` are allowed for ephemeral UI state (animation progress, local
loading flags, expand/collapse toggles). This does not conflict with Riverpod as the single source
of truth for shared/business state.

### Why Riverpod

See [ADR-0001: Riverpod State Management](adr/0001-riverpod-state-management.md) and
[ADR-0006: riverpod_generator 与 Auth-Guarded Provider 工厂](adr/0006-riverpod-generator-and-auth-guard.md).

---
