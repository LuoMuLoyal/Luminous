# 错误处理重构计划：引入 fpdart 显式化可恢复错误

Created: 2026-08-17
Updated: 2026-08-17（改为引入 fpdart；本次修订移除“编译期强制处理”错误表述）

> 评估结论：**引入 fpdart**，但不将它描述为“编译期强制处理错误”。`Either` / `TaskEither`
> 能让可恢复失败出现在仓库的公开类型中，避免调用方把失败值当作成功值使用；调用方仍可忽略
> 返回值或折叠为默认值。实施靠明确的 repository contract、迁移测试和代码审查约束，而非
> 不存在的语言级强制力。

## 一、现状调研

### 1.1 错误处理统计

| 指标 | 数量 | 说明 |
|------|------|------|
| `catch` 块总数 | 196 | 2026-08-17 快照；仅 `lib/**/*.dart`，排除 `*.freezed.dart` / `*.g.dart` |
| `catch(_)` | 13 | 需要逐项判定为有意降级还是未记录地吞错，不能直接全删 |
| `throw` | 86 | 同一快照范围；包含协议解析和不变量失败，不等同于缺陷 |
| `runGuarded` 生产调用 | 13 | 现有调用者必须有独立迁移策略 |
| 自建 `Result<T>` | 少量使用 | 现状不足以证明任何容器可以自动约束调用方 |

### 1.2 问题根因分析

**根因：可恢复失败没有一致的公开边界。**

Dart 的 `try-catch` 和所有结果容器都允许调用方放弃处理；问题是仓库接口多以
`Future<T>` 暴露失败，而调用方无法从签名得知应转换为 `AsyncValue.error`、展示降级 UI，
还是中止操作。迁移后仅把**预期、可恢复的业务/网络/解析失败**表达为
`TaskEither<AppError, T>`；编程错误、协议不变量和取消语义仍按原样抛出或 `rethrow`。

### 1.3 四类问题模式

**P1: 静默 catch (_)** — 12 处，错误被完全吞掉

```
// dashboard_view.dart:327
} catch (_) {
  return (options: const <HealthEventAssociationOption>[], hasError: true);
}
```

**P2: 风格不一致** — 同一 feature 的不同方法用 4 种不同错误处理方式

**P3: repository 边界隐藏可恢复失败** — `Future<T>` 签名不声明失败值，调用方无从得知

**P4: 结果类型没有统一的边界和迁移策略** — 不论自建或第三方容器，都不会自动阻止忽略结果

## 二、方案对比

### 2.1 候选方案概览

| 维度 | fpdart | multiple_result | dartz | 自建 Result |
|------|--------|-----------------|-------|------------|
| 版本 | 1.2.0 (stable) | 5.3.0 | 0.10.1 | — |
| 维护状态 | 活跃 (9 个月前) | 活跃 (5 个月前) | ❌ 停滞 (4 年前) | ✅ 自己维护 |
| Flutter Favorite | ✅ | ❌ | ❌ | — |
| pub points | 150/160 | 160/160 | — | — |
| 周下载量 | ~263k | ~36.3k | — | — |
| AI 训练数据 | ✅ 丰富 | ⚠️ 较少 | ✅ 丰富(旧) | ❌ 无 |
| 核心类型 | `Either`/`TaskEither`/`Option`/`Task` | `Result`/`AsyncResult` | `Either`/`TaskEither` | `Result` |
| 类型边界 | ✅ 成功值不能被误当作 `T` 使用 | ✅ 成功值不能被误当作 `T` 使用 | ✅ 同 fpdart | ✅ 同样可建模 |
| Riverpod 集成 | 有官方示例 | 无 | 无 | 无 |
| 文档质量 | ✅ 丰富(博客+教程+API) | ✅ README 详细 | ❌ 缺乏 | ❌ 仅代码注释 |

### 2.2 fpdart 的类型边界

fpdart 的核心价值是让 repository 的可恢复失败成为返回类型的一部分：

```dart
// repository 公开 TaskEither，而不是 Future<Either<...>>。
TaskEither<AppError, List<Medicine>> fetchMedicines() =>
    TaskEither.tryCatch(
      () async => await dio.get('/medicines'),
      (error, stackTrace) => LucentErrorMapper.toAppError(error),
    ).flatMap((response) =>
      Either.tryCatch(
        () => _parse(response),
        (e, s) => AppError(message: '解析失败', cause: e),
      ).toTaskEither(),
    );

// 调用方若要得到 List<Medicine>，必须选择失败策略。
final result = await fetchMedicines().run();
// 一种策略：显式转换为 AsyncValue。
result.match(
  (error) => state = AsyncError(error, StackTrace.current),
  (medicines) => state = AsyncData(medicines),
);

// 不能把 Either 直接当作成功值使用。
// final List<Medicine> list = result; // 编译不通过
```

这不是对“忽略返回值”或 `getOrElse` 的语言级禁止。计划不承诺这种强制力；每个迁移的
provider 必须通过测试证明它将 Left 映射为既有的 `AsyncValue.error`、操作错误状态或明确的
降级行为。

**对比 try-catch：**

```dart
// try-catch 方式：不写 catch 编译也通过 ← 这就是问题
Future<List<Medicine>> fetchMedicines() async {
  final response = await dio.get('/medicines'); // 可能 throw
  return _parse(response); // 可能 throw
  // 没有 catch → 调用方如果也没 catch → 运行时崩溃
}
```

### 2.3 fpdart 与 Riverpod 的集成方案

初版评估认为 fpdart 与 `AsyncValue` 有理念冲突——这个判断**过于绝对**。
实际集成模式是清晰的：

**原则：repository interface 是边界，返回 `TaskEither`；datasource 保持 `Future` / `Stream`
并允许传输异常；provider 在 `.run()` 后把 Left 映射到既有 UI 状态。**

```dart
// data/repository 层 — 返回 TaskEither
class MedicineRepository {
  TaskEither<AppError, List<Medicine>> fetchMedicines() =>
      TaskEither.tryCatch(
        () async {
          final response = await dio.get('/medicines');
          return _parse(response);
        },
        (error, st) => LucentErrorMapper.toAppError(error),
      );
}

// presentation/provider 层 — 转 AsyncValue
class MedicineNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    final result = await ref.read(medicineRepositoryProvider).fetchMedicines().run();
    return result.match(
      (error) => throw error,  // AsyncValue 接住 throw → AsyncError
      (medicines) => medicines,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await ref.read(medicineRepositoryProvider).fetchMedicines().run();
    state = result.match(
      (error) => AsyncError(error, StackTrace.current),
      AsyncData.new,
    );
  }
}
```

**关键点**：provider 层的 `throw error` 不是"又回到了 try-catch"——它是把
`AppError`（已经结构化的错误，有 kind/code/statusCode）交给 `AsyncValue` 的 error
state。这与之前“裸 throw DioException”不同。`TaskEither.tryCatch` 只覆盖该 repository
边界包裹的操作；不能宣称所有异常都被捕获，协议不变量和编程错误必须保留其原有失败语义。

### 2.4 为什么不选 multiple_result

`multiple_result` (5.3.0) 也是一个好包，pub points 满分 160/160，但：

1. **无 `TaskEither` 等价物**：`AsyncResult<S, E>` 是 `Future<Result>` 的 extension type，
   不提供 `flatMap`/`tryCatch` 等函数式组合能力
2. **迁移目标需要惰性组合**：本计划需要在 repository 边界用 `tryCatch` / `flatMap` 组合
   多个可恢复操作，fpdart 更直接。

### 2.5 评估结论

**引入 fpdart 1.2.0**。理由：

1. **显式 contract**：调用者无法把 `Either` 误用为成功值；失败策略在 provider 中可见
2. **生态成熟度**：稳定版本、文档和组合 API 能减少项目自维护容器的成本
3. **`TaskEither.tryCatch`**：一行代码替代 try-catch → Result.success/failure 样板
4. **`flatMap` 链式组合**：多个可失败操作串联，中间不需要嵌套 try-catch
5. **Riverpod 集成可行**：data 层 `TaskEither`，provider 层 `.run()` + `match` → `AsyncValue`
6. **稳定版本**：1.2.0 发布 9 个月，API 稳定（2.0 是 pre-release，不使用）

## 三、架构设计

### 3.1 分层原则

```
┌─────────────────────────────────────────────────────────────┐
│  Presentation 层 (widgets / pages)                          │
│  只管渲染 AsyncValue<T> 的 data/loading/error              │
│  不写 try-catch，不 import fpdart                           │
└───────────────────────────▲───────────────────────────────┘
                            │ AsyncValue<T>
┌───────────────────────────┴───────────────────────────────┐
│  Provider 层 (notifiers / providers)                       │
│  调用 data 层获取 TaskEither<AppError, T>                  │
│  .run() → Either → .match() → AsyncData / AsyncError      │
│  简单操作可用 runGuarded 快捷封装                           │
└───────────────────────────▲───────────────────────────────┘
                            │ TaskEither<AppError, T>
┌───────────────────────────┴───────────────────────────────┐
│  Domain repository interface / implementation              │
│  预期可恢复失败返回 TaskEither<AppError, T>                  │
│  datasource 仍返回 Future/Stream，传输异常在 repository 映射 │
│  协议不变量、编程错误和取消语义不被伪装成 AppError            │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 AppError 与 fpdart 的关系

**保留 `AppError` 作为 `Either` 的 Left 类型**：

```dart
// fpdart 的 Either<L, R> 中 L = AppError
typedef AppEither<T> = Either<AppError, T>;
typedef AppTaskEither<T> = TaskEither<AppError, T>;
```

迁移期间不复用 `Result` 名称：现有 `core/errors/result.dart` 保持旧 API，避免与新的
`Either` 别名发生导入歧义。只有全部 `runGuarded` 调用者迁移后，才单独决定是否删除旧类型。

`AppError` 携带 Lucent API 特有的 `code`/`statusCode`/`requestId`/`traceId`/`networkErrorCode`，
这些是领域知识，fpdart 的 `Either` 不提供。两者是互补关系：
- **fpdart** 提供容器类型和组合操作（`flatMap`/`map`/`tryCatch`）
- **`AppError`** 提供领域错误语义（`kind`/`code`/`networkErrorCode`）

### 3.3 典型代码模式

#### Repository 层

```dart
class HealthContextRepository {
  /// 之前：try-catch + throw
  /// 之后：TaskEither.tryCatch + flatMap
  TaskEither<AppError, HealthContext> fetchContext() =>
      TaskEither.tryCatch(
        () async => await dio.get('/health-context'),
        (error, st) => LucentErrorMapper.toAppError(error),
      ).flatMap((response) =>
        Either.tryCatch(
          () => HealthContext.fromJson(response.data),
          (e, s) => AppError(message: '健康上下文解析失败', cause: e),
        ).toTaskEither(),
      );
}
```

#### Provider 层

```dart
class HealthContextNotifier extends AsyncNotifier<HealthContext> {
  @override
  Future<HealthContext> build() async {
    return await ref
        .read(healthContextRepositoryProvider)
        .fetchContext()
        .run()
        .then((either) => either.getOrElse(
          (error) => throw error,  // AsyncValue 接住 → AsyncError
        ));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await ref
        .read(healthContextRepositoryProvider)
        .fetchContext()
        .run();
    state = result.match(
      (error) => AsyncError(error, StackTrace.current),
      AsyncData.new,
    );
  }
}
```

#### 多步组合（替代嵌套 try-catch）

```dart
/// 之前：3 层嵌套 try-catch
/// 之后：flatMap 链
TaskEither<AppError, SyncResult> syncHealthData() =>
    fetchContext().flatMap((ctx) =>
      fetchRecords(ctx).flatMap((records) =>
        uploadRecords(records).map((result) =>
          SyncResult(ctx: ctx, count: records.length, result: result),
        ),
      ),
    );
```

### 3.4 `runGuarded` 的过渡策略

```dart
// 新 repository 直接暴露 AppTaskEither；不要在阶段 0 改变 runGuarded 的返回类型。
// 现有 13 个调用者继续使用 Result/Success/Failure，待各调用者完成迁移后再作一次
// 原子删除或替换，避免依赖安装阶段破坏全库编译。
```

## 四、执行阶段

### 阶段 0：建立边界与迁移清单（0.5d）

- [ ] `pubspec.yaml` 添加 `fpdart: ^1.2.0`
- [ ] `flutter pub get`
- [ ] 在 `core/errors/` 新建 `task_either.dart`：
  ```dart
  import 'package:fpdart/fpdart.dart';
  import 'package:luminous/core/errors/error.dart';

  /// repository 可恢复失败的统一类型别名。
  /// Left = AppError（领域错误），Right = T（成功值）。
  typedef AppEither<T> = Either<AppError, T>;
  typedef AppTaskEither<T> = TaskEither<AppError, T>;
  ```
- [ ] 记录 inventory：每个 repository 方法标出“预期可恢复失败”或“协议/编程不变量”；
      只迁移前者。datasource 不作为 `TaskEither` 边界。
- [ ] 保持 `core/errors/result.dart` 与 `run_guarded.dart` 不变；列出 13 个生产调用者，
      为最后的兼容层清理建立明确顺序。
- [ ] 在 `docs/02-reference/adr/0008-result-type-and-error-handling.md` 记录新旧类型并存期、
      repository 边界与允许抛出的异常类别。

### 阶段 1：迁移 health_context + today repository（2d）

选择这两个 feature 优先迁移，因为它们 catch 密度最高（10+7=17 处）。

- [ ] 先修改各 feature 的 **domain repository interface**，再修改 `lucent.dart` 实现、provider、
      mock 和该 feature 的测试；一个 feature 在同一提交内保持编译通过。
- [ ] `health_context`：仅将 inventory 标记为可恢复的读写操作改为 `AppTaskEither<T>`；
      provider 显式 `.run()` + `.match()` 映射到 `AsyncValue`。
- [ ] `today`：先修改 `TodayRepository` contract，再迁移 `LucentTodayRepository` 及其 provider/mock；
      不把 `StateError` 等数据不变量伪装成 `AppError`。
- [ ] 对每个被改动的 `catch(_)` 写明用户可见的降级结果，并同时记录原始异常；有意的本地解析
      降级保留，并添加解释性注释和测试。
- [ ] `flutter test` 全过

### 阶段 2：迁移 record + assistant + medicine（3d）

- [ ] 按“domain interface → implementation → provider/controller → mock → tests”的原子顺序迁移
      record、assistant、medicine；`assistant` 的 SSE/取消语义保留 `Stream`，不强行包成 `TaskEither`。
- [ ] `medicine` 的 datasource 保持传输职责，转换发生在 repository 边界。
- [ ] `flutter test` 全过

### 阶段 3：迁移剩余 repository + 消除 presentation 层 try-catch（2d）

- [ ] 按 inventory 迁移 `health_event`、`report`、`search`、`scan`、`notification` 的 repository。
- [ ] `auth` 先确认会话失效、OAuth 取消和验证码业务失败各自的语义，再决定 interface 边界；
      不将 datasource 全量改为 `TaskEither`。
- [ ] 将 widget 中的请求编排移动至 provider/controller；保留只处理本地 UI 行为的 try-catch，
      并为每个保留点说明原因。
  - `dashboard_view.dart`（2 处 catch(_)）
  - `suggestion_primary_card.dart`（2 处 catch）
  - `report/page.dart`（2 处 catch(_)）
  - `record/detail.dart`（1 处 catch(_)）
  - `health_event/sheets/*`（3 处 catch(_)）
- [ ] `flutter analyze` + `flutter test` 全过

### 阶段 4：兼容层清理、文档与验证（1d）

- [ ] 仅在 13 个 `runGuarded` 调用者均迁移、旧 `Result` 无生产引用后，删除旧类型与 helper；
      这是独立的原子提交，不与 repository 大迁移混做。
- [ ] 为每个迁移 feature 覆盖：transport 失败映射为 `AppError`、provider 的 Left 分支、
      有意降级的日志/用户结果。不要以“2–3 个通用测试”替代 feature 回归。
- [ ] 更新 ADR、`docs/03-logs/migration-log/2026-08-17.md`，并在影响运行时行为时更新对应
      `docs/00-current/` 子文档。

## 五、验收标准

| 项 | 标准 | 验证方式 |
|----|------|---------|
| 可恢复失败边界 | inventory 中每个 repository 方法均为 `AppTaskEither<T>`，或有明确的非迁移理由 | 审核 inventory 与 domain interface |
| 未记录吞错 | inventory 范围内没有无日志、无说明的 `catch(_)` | `rg -n --glob '*.dart' --glob '!**/*.freezed.dart' --glob '!**/*.g.dart' 'catch\\s*\\(\\s*_\\s*\\)' lib`，逐项比对 allowlist |
| 异常语义 | 协议不变量、编程错误、取消及有意降级均不被误映射为 `AppError` | feature 单测 + code review |
| provider 转换 | 每个迁移 provider 有 Left → `AsyncValue.error` / 操作错误状态的测试 | 相应 feature 测试 |
| flutter analyze | 零 warning | CI |
| flutter test | 全过 | CI |
| 新增 fpdart 依赖 | `fpdart: ^1.2.0` | pubspec.yaml |

## 六、不做的事

- **不用 fpdart 2.0.0-dev.x**。2.0 是 pre-release 且方向涉及 Effect 重写，API 可能 break。锁 `^1.2.0`。
- **不在 presentation/widgets 层引入 fpdart**。widget 只消费 `AsyncValue`。
- **不引入 fpdart 的 `Option`/`Reader`/`State` 等类型**。只用 `Either` 和 `TaskEither`。
- **不引入 `fast_immutable_collections`**。fpdart README 建议配合使用，但 Luminous 已有 `freezed` 和原生 List/Map，不额外引入。
- **不消除 `rethrow`**。有意的 rethrow 是合法模式（如 legal/repository 的 404→fallback + rethrow 非 404）。
- **不改 Lucent 后端**。纯客户端错误处理规范化。
- **不承诺语言级强制处理**。如未来确实需要禁止忽略结果，另立任务评估 analyzer/lint
  规则；本计划不以 fpdart 包替代该治理决策。

## 七、风险与回退

- **风险 1：fpdart 1.x API 在升级到 2.0 时 break**。
  - 缓解：锁 `^1.2.0`，2.0 稳定后再评估升级。
  - 如果 2.0 永远 pre-release（README 暗示因 Dart 语言限制可能长期 pre-release），1.2.0 的 API 就足够稳定。

- **风险 2：`TaskEither` 与 `AsyncValue` 转换样板代码**。
  - 缓解：在 `core/errors/` 提供窄的 `toAsyncValue()` extension，且保留明确 stack trace。
  - ```dart
    extension TaskEitherX<T> on TaskEither<AppError, T> {
      Future<AsyncValue<T>> toAsyncValue() async {
        final either = await run();
        return either.match(
          (error) => AsyncError(error, StackTrace.current),
          AsyncData.new,
        );
      }
    }
    ```

- **风险 3：边界扩大导致大范围签名变更**。
  - 缓解：按 feature 原子迁移，先改 domain interface，并在每个 feature 的 mock/provider/test
    同一提交内闭环；不要以 data implementation 单独改签名。

- **回退策略**：每个 feature 保持独立提交；如集成不可接受，回退该 feature 的 domain contract、
  implementation、provider、mock 与测试，而不是假定 API 契约未变化。

## 八、与现有计划的关系

- 本计划与 [`2026-08-16-assistant-remediation-plan.md`](2026-08-16-assistant-remediation-plan.md)
  正交——后者关注 assistant feature 的信任缺口，本计划关注全库错误处理规范化。
- 建议在 assistant-remediation P0 之后执行本计划，避免 rework。
- 与 [`2026-08-17-flowui-migration-plan.md`](2026-08-17-flowui-migration-plan.md) 无冲突
  （FlowUI 迁移不涉及错误处理层）。
- 不涉及 Lucent 后端改动，无需在 `Lucent/plans` 下落地文档。
