---
status: active
owner: frontend
updated: 2026-08-31
---

# State Management (Riverpod)

本文件是 [[architecture]] 拆分后的子文档。

相关子文档：
- [[routing]]
- [[data-layer]]

## State Management (Riverpod)

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

ADR-0003 引入了 `riverpod_generator`。项目中有两种声明风格，各有适用场景：

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

// 只读异步数据（默认 autoDispose）。repository 边界为
// `TaskEither<LucentFailure, T>`：`run()` 后 fold，Left 抛出让 Riverpod
// 投影为 AsyncValue.error（widget 只消费 provider state）。
@riverpod
Future<MyData> myData(Ref ref) async {
  final result = await ref.watch(myRepositoryProvider).fetch().run();
  return result.fold((failure) => throw failure, (data) => data);
}

// keepAlive 异步数据（跨页面共享、dashboard 级别）
@Riverpod(keepAlive: true)
Future<MyDashboard> myDashboard(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(myRepositoryProvider)
          .fetchDashboard()
          .run();
      return result.fold((failure) => throw failure, (dashboard) => dashboard);
    },
    signedOutFallback: () => ref.watch(myRepositoryProvider).signedOutDashboard,
  );
}

// family 参数化
@riverpod
Future<MyDetail> myDetail(Ref ref, String id) async {
  final result = await ref.watch(myRepositoryProvider).findOne(id).run();
  return result.fold((failure) => throw failure, (detail) => detail);
}
```

**规则**：
- 所有新的 `Provider<T>` / `FutureProvider<T>` / `FutureProvider.family` 声明必须使用 `@riverpod`
  或 `@Riverpod(keepAlive: true)` 注解。
- 默认 `autoDispose`；需要跨页面保持状态时使用 `@Riverpod(keepAlive: true)`。
- 文件需添加 `part 'my_file.g.dart';` 和 `import 'package:riverpod_annotation/riverpod_annotation.dart';`。
- repository 失败统一按 `run()` + fold 消费（Left 抛出 → `AsyncValue.error`）；widget 不导入
  fpdart、不解析 `DioException`/Problem Details（见 [[data-layer#Repository Failure Boundary]] 与
  ADR-0005）。

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
loading flags, expand/collapse toggles). This does not conflict with Riverpod as the single source of
truth for shared/business state.

**Boundary rule**: `setState` / `useState` is acceptable when **all** of the following hold:

1. The state is **local to a single widget subtree** — it is not read or mutated by any other widget,
   provider, or feature module.
2. The state is **ephemeral** — losing it on dispose/rebuild is acceptable. It is not data that needs
   to survive navigation, app restart, or configuration changes.
3. The state has **no business semantics** — it controls presentation concerns (animation progress,
   scroll position, temporary loading flags, expand/collapse toggles, text-field focus) rather than
   domain data.

**Allowed examples** (no review action needed):

- `AnimationController` progress in a page that animates between states.
- A local `bool _loading` flag set during a one-shot async action whose result is surfaced via a
  toast/snackbar rather than stored in a Riverpod provider.
- `ScrollController` / `TabController` held by a `StatefulWidget`.
- Expand/collapse toggles for accordion sections.
- Text field focus and keyboard-visible state.

**Disallowed examples** (must use Riverpod instead):

- Form data that will be submitted to a repository.
- Filter/sort criteria that affect a list shown across multiple pages.
- Auth session state, user preferences, or health context.
- Any state that another feature module needs to read or invalidate.

> **Note for reviewers**: When auditing for `StatefulWidget` / `setState` usage, do not flag patterns
> matching the "Allowed examples" above. The AGENTS.md rule "State is Riverpod, not GetX" refers to
> **shared/business state management**, not to ephemeral widget-local presentation state.

### Application Layer Pattern

When page widgets grow too large, business orchestration logic is extracted into the
`application/` layer. This keeps presentation thin (build + route + trigger use case) and
makes orchestration reusable and testable.

#### Function-style use cases

Single operations that coordinate repository calls, DataChangeBus emission, and UI feedback:

```dart
// application/usecases/change_record_date.dart
Future<void> changeRecordDate({
  required Ref ref,
  required BuildContext context,
  required String recordId,
  required DateTime newDate,
}) async {
  // repository 调用（TaskEither）→ fold/重抛 → emit data change → toast feedback
}
```

#### Class-style orchestrators

Multi-step flows that need stateful sequencing:

```dart
// application/orchestrators/nlp_flow.dart
class NlpFlow {
  NlpFlow({required this.repository, required this.emitDataChange});
  // ...execute() orchestrates NLP candidate extraction → review → save
}
```

The application layer may import other features' **domain** layer for cross-feature
orchestration. See [[architecture#Cross-Feature Import Boundaries]].

### Cross-Feature Data Refresh (Invalidation Bus)

Feature modules are isolated: a feature must **never** import another feature's presentation-layer
provider to call `ref.invalidate()` on it after a data mutation. That creates presentation→presentation
coupling and circular dependency risks.

Instead, cross-feature refresh is mediated by a lightweight **invalidation bus** in
`lib/core/providers/data_change_bus.dart`:

- `DataChangeBus` — a keepAlive `Notifier` holding a `Map<String, int>` version counter.
- `DataChangeTopic` — constants for the 7 domain topics: `dailyRecords`, `healthContext`,
  `currentMedicines`, `doseLogs`, `medicineReminders`, `healthEvents`, `userSettings`.
- `dataChangeVersionProvider(topic)` — a family provider; watch it inside a dashboard/workspace
  provider to trigger an automatic rebuild when the topic's version increments.

**Emitting** (after a write that affects other features):

```dart
ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
```

**Watching** (inside a provider that should refresh on cross-feature changes):

```dart
@Riverpod(keepAlive: true)
Future<TodayDashboard> todayDashboard(Ref ref) async {
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.currentMedicines));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.doseLogs));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.medicineReminders));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.userSettings));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthEvents));
  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref.watch(todayRepositoryProvider).fetchDashboard().run();
      return result.fold((failure) => throw failure, (dashboard) => dashboard);
    },
  );
}
```

| Topic | Emitted by | Watched by |
|---|---|---|
| `dailyRecords` | record (create/update/delete/NLP), health_data sync | recordDashboard, todayDashboard, reviewCurrent, reviewDashboard |
| `healthContext` | mine (profile/allergy/condition edits), settings (preference sync) | healthContextSnapshot |
| `currentMedicines` | mine (current medicine add/remove), search (add to current medicines) | medicineWorkspace, todayDashboard, healthContextSnapshot |
| `doseLogs` | medicine (mark dose) | medicineWorkspace, todayDashboard, reviewCurrent |
| `medicineReminders` | medicine (reminder create/update/delete) | medicineWorkspace, todayDashboard |
| `healthEvents` | health_event (create/end/outcome confirm/check-in 落库成功后) | reviewCurrent, reviewHistory, todayDashboard |
| `userSettings` | settings (water target, AI toggles) | todayDashboard |

> **Note**: `ref.invalidate()` is still appropriate for **same-feature** retry/refresh (e.g. an error
> state's retry button invalidating its own feature's providers) and for **app-level** lifecycle
> events (e.g. `bootstrap.dart` invalidating `healthContextSnapshotProvider` on auth state changes).
> The bus only replaces **cross-feature write-path** invalidation.

### Shared Read-Only Snapshot Hub

`healthContextSnapshotProvider` (`lib/features/health_context/data/providers/health_context.dart`) is
the single shared read-only entry point for the user's health context across features. Multiple
features read from it instead of each independently fetching their own copy:

- `today/data/repositories/lucent.dart` — builds the Today dashboard from the snapshot.
- `medicine/presentation/providers/risk_check.dart` — risk check reads allergies/conditions.
- `medicine/presentation/providers/reminders.dart` — reminder prefill reads current medicines.
- `mine/presentation/pages/{allergy,condition,current_medicine,profile}_edit.dart` — edit forms
  prefill from the snapshot.
- `mine/data/repositories/lucent.dart` — Mine dashboard reads the snapshot.

This provider is `keepAlive` and `authGuarded`. It watches `DataChangeTopic.healthContext` and
`DataChangeTopic.currentMedicines` on the invalidation bus, so it auto-refreshes when any feature
mutates those data domains — consumers simply `ref.watch` / `ref.read` it and always get fresh data.

**Consuming the snapshot hub** (read-only, from any feature):

```dart
// Async read (one-shot, e.g. inside a repository method)
final snapshot = await ref.read(healthContextSnapshotProvider.future);

// Reactive watch (inside a build method)
final snapshot = ref.watch(healthContextSnapshotProvider);
snapshot.whenData((data) => ...);
```

> Do **not** create a second health-context fetch provider in another feature. Always read through
> `healthContextSnapshotProvider` so the cache and invalidation bus stay coherent.

### Why Riverpod

See [ADR-0001: Riverpod State Management](adr/0001-riverpod-state-management.md) and
[ADR-0003: riverpod_generator 与 Auth-Guarded Provider 工厂](adr/0003-riverpod-generator-and-auth-guard.md).

---

