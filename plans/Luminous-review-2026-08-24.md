已回查: True

# Luminous 增量代码审查报告

**审查日期**: 2026-08-24
**审查范围**: `5edf883e^..HEAD`（refactor 分支，约 30 个 commits，276 个文件）
**时间窗口**: 2026-08-23 09:22 ~ 20:42
**最新 5 个 commit**:
- `d09e6809` refactor(client): 同步 ProblemDetails OpenAPI 引用
- `94f71e89` docs(todo): 清理错误迁移已完成待办
- `abd0a28f` docs(error): 收口错误迁移文档与临时计划清理
- `504a1ac9` docs(todo): 记录 SSE 迁移审查遗留项
- `301171b3` refactor(error): 统一 Luminous SSE failure 消费

---

## 变更概览

本轮是一次 **Repository/TaskEither 边界迁移**：将此前未迁移的数据源和仓库层全面改为返回 `TaskEither<LucentFailure, T>`，并通过 `LucentErrorMapper.fromObject` 统一处理错误边界。主要变更：

1. **Repository 边界迁移**：`mine`、`today`、`report`、`medicine`、`record`、`assistant`、`scan`、`auth` 等模块的数据源和仓库全部改为 `TaskEither` 返回。
2. **SSE 错误收口**：`sse.dart` 和 `map_utils.dart` 的异常类型从 `LucentApiException` 统一改为 `FormatException` 或 `LucentFailure`。
3. **网络拦截器升级**：`auth_interceptor.dart` 使用 `isTokenExpired` 替代固定的非刷新码集合；`retry_interceptor.dart` 新增 `_withMappedFailure` 在决策前映射 Problem Details。
4. **旧错误体系清理**：`core/errors/error.dart`（`AppError`、`AppErrorKind`）及 `core/errors/result.dart` 被完全移除；`error_mapper.dart` 中的 `toAppError` 和 `_toAppErrorKind` 被删除。
5. **OpenAPI 客户端同步**：所有 API 类新增 `problem_details_dto.dart` 导入，配合 Problem Details 响应解析。

---

## 逐条审查意见

### 🔴 严重 — 必须修复

#### R-1: `_withMappedFailure` 丢失 `message` 上下文

`lib/core/network/interceptors/retry_interceptor.dart:113`

```dart
return DioException(
  requestOptions: err.requestOptions,
  response: err.response,
  type: err.type,
  error: failure,
  stackTrace: err.stackTrace,
);
```

**后果**: 新建的 `DioException` 未复制 `message` 字段（原始错误描述），导致重试决策日志和下游异常展示丢失人类可读的错误说明。`DioException` 的 `message` 字段为 `String?`，不传递会显示 `null`。

**建议**: 在构造函数中添加 `message: err.message`。

**回查验证：** ✅ 真实存在。`_withMappedFailure` 方法中构造 `DioException` 时确实未传递 `message: err.message`。

---

#### R-2: `auth.dart` 内部 `throw value` 反模式

`lib/features/auth/data/datasources/auth.dart:404`（当前 `HEAD` 版本）

```dart
final user = switch (await fetchAccount().run()) {
  Left(:final value) => throw value,
  Right(:final value) => value,
};
```

**后果**: 在 `TaskEither.tryCatch` 内部通过 `throw` 短路 `Either` 左值。虽然外层 `tryCatch` 的 `(error, stackTrace) => LucentErrorMapper.fromObject(error)` 会捕获并透传 `LucentFailure`，但如果未来修改 mapper 不再透传（例如改为强制 unknown），此处会直接崩。将 `TaskEither` 内部逻辑用 `throw` 驱动是对 monad 语义的误用。

**建议**: 使用 `flatMap` 或 `chain` 组合 `TaskEither`，而非在内部 throw。正确的写法是 `fetchAccount().flatMap((account) => ...)` 或提前 `bind`。

**回查验证：** ✅ 真实存在。第404行 `Left(:final value) => throw value` 在 `TaskEither.tryCatch` 回调中确实用 throw 驱动控制流。

---

### 🟡 警告 — 建议修复

#### W-1: `quick_entry_undo.dart` 裸 throw StateError（2 处）

`lib/features/record/application/usecases/quick_entry_undo.dart:94`
```dart
throw StateError('Dose log delete undo is not configured.');
```

`lib/features/record/application/usecases/quick_entry_undo.dart:101`
```dart
throw StateError('Dose log status restore undo is not configured.');
```

**后果**: Usecase 层直接抛出 `StateError`，没有通过 `TaskEither` 或统一错误类型封装。虽然当前在 `fast_entry_dialog.dart` 和 `quick_entry_executor.dart` 的 `try/catch` 中被捕获并显示固定翻译消息，但类型为 `StateError` 的异常无法被统一错误处理器正确分类，且这两处是配置缺失（开发/部署问题），不应在运行时暴露给用户。

**建议**: 改为 `LucentFailure.business(code: 'UNDO_NOT_CONFIGURED')` 或通过构造函数前置校验（`assert` / `required` 参数），避免运行时抛异常。

**回查验证：** ✅ 真实存在。第94行和第101行两处 `StateError` 裸throw均存在。

---

#### W-2: `auth_interceptor.dart` `_doRefresh` 异常捕获范围过宽

`lib/core/network/interceptors/auth_interceptor.dart:289` 附近

```dart
catch (e, st) {
  appTalker.error(...);
  return const _RefreshTransientFailure();
}
```

**后果**: 同上一轮（2026-08-23）W-3 警告，此处 `catch` 未限定类型（应为 `on Exception catch` 或 `on DioException catch`）。如果 `Dio` 内部发生 `AssertionError` 或 `TypeError`（编程错误），会被误归类为 `_RefreshTransientFailure`，导致刷新重试而非暴露 bug。

**建议**: 限定为 `on DioException catch`；真正的编程错误应穿透到全局异常处理器。

**回查验证：** ✅ 真实存在。第289行确为裸 `catch (e, st)`，未限定异常类型。

---

#### W-3: `dose_log_remote.dart` 中文 StateError 消息未翻译

`lib/features/medicine/data/datasources/dose_log_remote.dart:45`
```dart
throw StateError('用药记录列表格式异常');
```

**后果**: 中文技术消息会随 `StateError` 穿透到 `LucentErrorMapper.fromObject`，被归类为 `LucentFailureKind.unknown`，消息原文直接暴露给 UI 层。在英文环境下用户看到中文乱码。

**建议**: 使用机器可读的错误 code（如 `LucentFailure.business(code: 'DOSE_LOG_INVALID_FORMAT')`），UI 层根据 code 查表翻译。

**回查验证：** ✅ 真实存在。第45行 `throw StateError('用药记录列表格式异常')` 中文消息未翻译。

---

#### W-4: `_requireBody` 中文错误消息同样问题

`lib/features/auth/data/datasources/auth.dart:55`
```dart
throw LucentFailure.network(
  message: 'API 返回空响应体（$operation）',
  networkErrorCode: NetworkErrorCode.emptyResponse,
);
```

**后果**: `LucentFailure.network` 的 `message` 字段存储中文技术描述。虽然 `LucentFailure` 是正确类型，但 `message` 被用于 Sentry 日志和可能的 UI fallback，中英文混合会导致监控和用户体验不一致。

**建议**: `message` 存英文或机器标识，`code` / `networkErrorCode` 用于 UI 翻译映射。

**回查验证：** ✅ 真实存在。第55行 `message: 'API 返回空响应体（$operation）'` 中文消息。

---

### 🟢 建议 — 本轮不单独报告

- 无新增严重影响可读性的问题。

---

## 前一天问题修复验证

前一天（2026-08-23）报告了 4 条 🔴 严重问题（R-1 ~ R-4）和 3 条 🟡 警告（W-1 ~ W-3）：

### 🔴 修复状态

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| R-1 | 数据层裸 throw StateError（6 处） | 部分修复 | `sessions.dart`、`scan.dart`、`record.dart` 已包装为 `TaskEither.tryCatch` + `LucentErrorMapper.fromObject`。但 `StateError` 本体未消除，仅被边界捕获。`quick_entry_undo.dart` 新增 2 处未包装。 |
| R-2 | Provider 层裸 throw StateError（4 处） | 未修复 | `conversation.dart` 第 408、700、774 行仍保留 `StateError`。这些在 Provider 层直接 throw，会被 `AsyncValue.error` 捕获。 |
| R-3 | LucentApiException 未迁移（5 处） | 已修复 | `map_utils.dart:43` 的 `LucentApiException` 已改为 `FormatException`；`medicine_detail_remote.dart` 已改为 `LucentFailure.network`；`dose_log_remote.dart` 的 LucentApiException 已清理。 |
| R-4 | Today 数据源新增 StateError（2 处） | 已修复 | `ai_remote.dart` 的 StateError 已改为 `LucentFailure.network`。 |

### 🟡 修复状态

| 编号 | 问题 | 状态 | 说明 |
|------|------|------|------|
| W-1 | 错误体系迁移不彻底 | 已修复 | `LucentApiException` 生产点已基本清理，仅剩 `conversation.dart` 的防御性兼容代码（文档已说明为遗留兼容）。 |
| W-2 | 注释与实际行为不符 | 未涉及 | 本轮未修改 `dose_log_remote.dart` 的 `_requireData` 注释。 |
| W-3 | catch 未限定异常类型 | 未修复 | `auth_interceptor.dart` 的 `_doRefresh` 仍使用裸 `catch`。 |

---

## 新发现问题

本轮新发现 2 条 🔴 严重问题、4 条 🟡 警告（回查后全部确认真实存在）：

| 编号 | 级别 | 问题 | 文件数 | 处数 | 回查状态 |
|------|------|------|--------|------|----------|
| R-1 | 🔴 | `_withMappedFailure` 丢失 `message` | 1 | 1 | ✅ 真实存在 |
| R-2 | 🔴 | `throw value` 反模式 | 1 | 1 | ✅ 真实存在 |
| W-1 | 🟡 | `quick_entry_undo` StateError | 1 | 2 | ✅ 真实存在 |
| W-2 | 🟡 | `_doRefresh` 捕获范围过宽 | 1 | 1 | ✅ 真实存在 |
| W-3 | 🟡 | `dose_log_remote` 中文消息 | 1 | 1 | ✅ 真实存在 |
| W-4 | 🟡 | `_requireBody` 中文消息 | 1 | 1 | ✅ 真实存在 |

---

## 重复造轮子检查

| 重复项 | 位置 A | 位置 B | 结论 |
|--------|--------|--------|------|
| `TaskEither.tryCatch` + `LucentErrorMapper.fromObject` 模式在 15+ 个 repository 中重复 | 各 feature repository | — | ⚠️ 模式重复但属于架构一致性的合理重复，不构成造轮子。若未来抽象为 `lucentTryCatch` helper 可减少样板。 |

---

## 维护隐患

1. **`throw value` 反模式扩散风险**: `auth.dart` 的 `Left(:final value) => throw value` 是一个危险的先例。如果其他开发者模仿此写法但忘记外层 `tryCatch`，异常会直接逃逸。建议在团队文档中明确禁止在 `TaskEither` 内部使用 `throw` 驱动控制流。

2. **中文错误消息残留**: 虽然本轮迁移了大部分异常类型，但 `message` 字段中仍大量使用中文技术描述（`API 返回空响应体`、`用药记录列表格式异常`）。这些消息会被 Sentry 收录，也会被英文用户看到。建议在 CI 中添加检测：禁止 `LucentFailure.*(message:` 中包含中文字符。

3. **`conversation.dart` 的 `LucentApiException` 防御代码**: 第 366、371 行保留了 `LucentApiException` 的 `is` 检查和分类逻辑。注释说明是"遗留兼容"，但如果后续确认网络层已全部迁移，应设定清理 deadline，避免永远背负。

4. **`retry_interceptor` 的 `_withMappedFailure` 设计隐患**: 该方法在决策路径上临时构造 `DioException`，但缺少 `message` 字段。如果后续 Dio 升级调整了构造函数必填参数，此处可能编译失败。建议添加字段完整性注释或使用 `DioException.copyWith`（如果 Dio 支持）。

---

## 总结

本轮 Repository/TaskEither 迁移整体方向正确，执行质量较高：
- ✅ 旧 `AppError`/`AppErrorKind`/`Result` 体系被完全移除
- ✅ `LucentApiException` 的生产点已基本清理（仅剩遗留兼容）
- ✅ 所有新增/修改的 Repository 方法一致使用 `TaskEither<LucentFailure, T>`
- ✅ `auth_interceptor` 的刷新决策从固定码表改为 `isTokenExpired`，更精确
- ✅ `retry_interceptor` 能识别 Problem Details 中的 `retryable` 字段

但以下问题需要关注：
- ❌ **2 处 🔴 严重**: `_withMappedFailure` 丢失 `message`、`throw value` 反模式
- ⚠️ **4 处 🟡 警告**: `_doRefresh` 捕获过宽、`quick_entry_undo` StateError、中文消息残留
- ⚠️ `conversation.dart` Provider 层的 3 处 `StateError` 仍未处理（上轮遗留）

**建议优先处理顺序**: R-1（补 `message`）→ R-2（改 `flatMap`）→ W-2（限定 catch 类型）→ W-1（配置校验前置）。

**回查时间**: 2026-08-24 03:07 (Asia/Shanghai)
**报告生成时间**: 2026-08-24 00:55 (Asia/Shanghai)
