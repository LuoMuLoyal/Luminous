# ADR-0008: Result 类型与统一错误处理

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

当前错误处理依赖 try-catch 传播，存在三个系统性问题：

### 1. try-catch 模式遍布 UI 层

几乎每个 widget 的回调都重复相同的错误处理骨架：

```dart
// 这个模式在 report/page.dart、assistant/page.dart、auth/ 多处重复出现
try {
  await ref.read(xxxProvider.notifier).doSomething();
} catch (error) {
  ref.read(talkerProvider).error('XxxPage.handle: failed: $error');
  if (!context.mounted) return;
  final message = LucentErrorMapper.fromObject(error).message;
  await AppToast.show(context, message);
}
```

搜索结果中至少 12 处 widget 回调遵循这个完全相同的模式。

### 2. `runAuthAction` 被限制在 auth 模块

`auth/presentation/providers/shared/auth_action_runner.dart` 已有统一错误处理 helper：

```dart
Future<AuthActionResult<T>> runAuthAction<T>({
  required Ref ref,
  required String tag,
  required Future<T> Function() action,
}) async {
  try {
    return (value: await action(), error: null);
  } catch (e) {
    ref.read(talkerProvider).error('$tag: failed: $e');
    return (value: null, error: LucentErrorMapper.fromObject(e).message);
  }
}
```

但它只在 auth feature 内使用。其他 feature 没有类似抽象，各自手写 try-catch。

### 3. Repository 直接抛异常，调用方必须 try-catch

Repository 方法签名是 `Future<T>` 而非 `Future<Result<T, E>>`。调用方无法从签名判断
可能抛出哪些异常，错误类型信息在传递中丢失：

- `LucentApiException` 的 `code`、`statusCode`、`requestId` 在 UI 层只取了 `message`
- 不同错误类型（网络超时 vs auth 失败 vs 业务逻辑错误）无法在调用方做差异化处理
- Provider 层必须用 try-catch 包裹 repository 调用，增加嵌套

## Decision

### 8.1 引入轻量 `Result` 类型

不自引入 `fpdart`，在 `lib/core/errors/` 下定义项目自己的 `Result` 类型（~40 行）：

```dart
sealed class Result<T> {
  const Result();
  factory Result.success(T value) = Success<T>;
  factory Result.failure(AppError error) = Failure<T>;

  /// 模式匹配
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  });
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onSuccess(value);
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onFailure(error);
}

/// 统一应用错误类型，保留原始异常信息。
class AppError {
  const AppError({
    required this.message,
    this.kind = AppErrorKind.unknown,
    this.code,
    this.statusCode,
    this.requestId,
    this.cause,
  });

  final String message;
  final AppErrorKind kind;     // network / auth / server / business / unknown
  final int? code;             // Lucent envelope code
  final int? statusCode;       // HTTP status
  final String? requestId;     // X-Request-Id response header
  final String? traceId;       // traceresponse header / traceparent
  final Object? cause;         // 原始异常
}
```

### 8.2 Repository 层返回 `Result`

Repository 方法签名改为 `Future<Result<T>>`。异常在 repository 边界被捕获并转换：

```dart
@override
Future<Result<ReportDashboard>> fetchDashboard(query) async {
  try {
    final dto = await dataSource.fetch(query);
    return Result.success(mapper.toEntity(dto));
  } on DioException catch (e) {
    return Result.failure(LucentErrorMapper.toAppError(e));
  } catch (e) {
    return Result.failure(AppError(message: '未知错误', cause: e));
  }
}
```

**注意**：网络层的 `AuthInterceptor`（ADR-0007 已实现）内部的 401 refresh 逻辑仍然抛
异常（它需要在拦截器层面工作），不使用 Result。`ErrorInterceptor`（ADR-0007）已在
拦截器链末端将 `DioException` 映射为 `LucentApiException`，`LucentErrorMapper.toAppError()`
在此映射基础上进一步转换为 `AppError`。Result 只在 repository → provider → UI 边界使用。

### 8.3 泛化 `runGuarded` helper

将 `runAuthAction` 泛化为全局 `runGuarded`，放在 `lib/core/errors/`：

```dart
Future<Result<T>> runGuarded<T>({
  required Ref ref,
  required String tag,
  required Future<T> Function() action,
}) async {
  try {
    return Result.success(await action());
  } catch (e) {
    ref.read(talkerProvider).error('$tag: failed: $e');
    return Result.failure(LucentErrorMapper.toAppError(e));
  }
}
```

### 8.4 UI 层错误展示统一化

在 `LuminousApp` 中注册全局 `ref.listen`，监听 provider 错误状态变化，自动展示 toast：

```dart
// 在页面级别
ref.listen<AsyncValue<void>>(someActionProvider, (previous, next) {
  next.whenOrNull(
    error: (error, _) {
      if (error is AppError) {
        AppToast.show(context, error.message);
      }
    },
  );
});
```

页面级回调中的 try-catch 减少为只处理需要差异化 UI 的错误（如导航、表单内联错误）。

## Options Considered

### 保持 try-catch + LucentErrorMapper（现状）

- Pros: 零迁移成本，已有 `runAuthAction` 在 auth 模块工作良好
- Cons: 12+ 处重复 try-catch 骨架，错误类型信息在传递中丢失，Repository 签名不表达失败可能

### 引入 `fpdart` 的 `Either` / `TaskEither`

- Pros: 成熟库，丰富的函数式 API（`map`、`flatMap`、`traverse` 等）
- Cons: 引入函数式编程范式，团队学习成本高，`Either<Left, Right>` 的左右约定对 Dart 开发者不直观

### 自实现轻量 `Result`（本方案）

- Pros: ~40 行代码，无外部依赖，API 直观（`Success` / `Failure`），与 Dart 3 的 sealed
  class / pattern matching 天然契合
- Cons: 需自行维护，功能不如 `fpdart` 丰富

### 使用 `AsyncValue` 作为错误载体（不引入 Result）

- Pros: Riverpod 原生支持，零新概念
- Cons: `AsyncValue` 是 provider 级别的状态容器，不适合表示一次性 action 的结果（如"导出报告"
  是一个 action 而非持续状态）；错误信息仍需从 `AsyncValue.error` 中提取

## Consequences

- 新增 `lib/core/errors/result.dart` + `lib/core/errors/app_error.dart` + `lib/core/errors/run_guarded.dart`。
- `LucentErrorMapper` 增加 `toAppError(Object) → AppError` 方法，保留 `fromObject` 向后兼容。
- Repository 方法签名从 `Future<T>` 改为 `Future<Result<T>>`，存量方法在触碰时迁移。
- Provider 层从 try-catch 改为 `result.fold(...)`，可基于 `AppErrorKind` 做差异化处理：
  - `network` → 展示"网络错误"toast + 重试按钮
  - `auth` → 触发 session expired 流程
  - `business` → 展示后端返回的业务错误消息
  - `unknown` → 展示通用错误消息 + 上报 talker
- `runAuthAction` 标记 `@Deprecated`，新代码使用 `runGuarded`。
- UI 层 try-catch 显著减少；需要差异化 UI 的场景仍可在 widget 内 try-catch。
- Mock repository 也需要返回 `Result`，但 mock 基本只返回 `Success`，迁移成本低。
- `AppError` 保留 `cause` 字段用于 talker 上报，不丢失原始异常栈。
