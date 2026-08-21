# 错误处理重构计划：fpdart、LucentFailure 与 Problem Details 硬切

Created: 2026-08-17
Updated: 2026-08-18
Status: blocked until the 2026-08-16 feature-plan gate is complete

> 权威决策见 [`ADR-0008`](../docs/02-reference/adr/0008-result-type-and-error-handling.md) 和
> [Lucent ADR-0012](../../Lucent/docs/01-reference/adr/0012-error-contract-and-result-boundary.md)。
> 本计划是一次集中式硬切，不是长期新旧规则并存的迁移项目。

## 一、最终决策

引入 `fpdart: ^1.2.0`，只使用 `Either` 和 `TaskEither`。项目公共失败类型命名为 `LucentFailure`：

```dart
typedef AppEither<T> = Either<LucentFailure, T>;
typedef AppTaskEither<T> = TaskEither<LucentFailure, T>;
```

- repository 的预期可恢复失败统一返回 `AppTaskEither<T>`。
- datasource 保持 `Future` / `Stream`，负责传输和流语义。
- provider 调用 `.run()` 并将 Left 映射到 `AsyncValue` 或明确的 action state。
- widget 不导入 fpdart，不处理网络 try-catch。
- `LucentFailure` 不代表编程错误、协议不变量、取消或 SSE 断流；这些保持显式异常/流错误。
- Problem Details 是 HTTP 错误契约，fpdart 只负责客户端内部的可恢复失败控制流。

Lucent 后端选择 `neverthrow`；不使用 `@backendkit-labs/result`、`@sapphire/result` 或 `antithrow`。
两端共享 RFC 9457 Problem Details 契约，不强求共享 Result 库。

## 二、启动门禁

在以下条件全部满足前，本计划不启动 Result/API 错误契约迁移：

1. `plans/` 下 2026-08-16 的十份功能改造计划全部完成；
2. 每份计划的实现、测试、迁移日志和文档检查均完成；
3. 按仓库规则删除已完成计划文件，并更新 `plans/README.md` 的完成状态；
4. 0.1.0 发布验证不再有阻断项；
5. Luminous 与 Lucent 的 Problem Details 迁移顺序、OpenAPI 变更和回滚点已确认。

门禁满足后冻结新功能，开启一次集中迁移窗口。门禁期间只允许修复阻断发布的问题，不在新旧错误规范之间继续添加代码。

## 三、问题基线（2026-08-18 前必须重跑）

旧快照中的数量只用于历史参考。启动时重新盘点：

- 所有 `catch (_)`, 空 catch 和默认值 fallback；
- 所有直接 `throw`、`rethrow` 及协议不变量异常；
- 所有 `runGuarded`、自建 `Result<T>` 和 repository `Future<T>`；
- 所有 `requestId` / `statusCode` 读取；
- 所有 provider/widget 网络 try-catch。

每个命中项必须归类为：可恢复失败、明确降级、编程/协议错误、取消/SSE，不能用正则统计代替判断。

## 四、执行阶段

### 阶段 0：契约准备

- 在 `core/errors/` 建立 `LucentFailure` 与 fpdart 类型别名。
- 增加 RFC 9457 Problem Details 解析：`type`、`title`、`detail`、稳定字符串 `code`、`errors`、`retryable`、`retryAfter`、`traceId`。
- 移除 `requestId` 和服务端 `statusCode` 作为当前契约字段；`networkErrorCode` 仅保留客户端内部。
- 为 HTTP status、Content-Type、Retry-After、幂等性和错误映射建立契约测试。
- 这一阶段与 Lucent 的 API 契约变更分开提交，但按跨仓发布顺序协同完成。

### 阶段 1：health_context + today

按 `domain interface → implementation → provider → mock → tests` 的顺序，把预期可恢复读写操作改为 `AppTaskEither<T>`。provider 为每个 Left 分支写测试；协议不变量不映射为 `LucentFailure`。

### 阶段 2：record + assistant + medicine

继续按 feature 原子迁移。assistant 的 SSE/取消语义保留 `Stream`，不强行包成 `TaskEither`。datasource 保持传输职责，转换在 repository 边界完成。

### 阶段 3：其余 repository 与 UI 编排

迁移 health_event、report、search、scan、notification 和 auth 中经 inventory 判定为可恢复的边界。将网络编排从 widget 移入 provider/controller；保留的本地 UI try-catch 必须有原因、日志和测试。

同时处理 8-18 审查中的 `detail!`、`AppLocalizations.of(context)!`、regenerate 错误边界和会话重命名回滚。

### 阶段 4：删除旧规则

仅当全部 repository 已完成迁移并通过全量测试时：

- 删除旧 `Result<T>`、`Success`、`Failure`；
- 删除 `runGuarded` 和 feature-local action runner；
- 删除旧 error-envelope fallback；
- 删除 `requestId` 读取和旧 `AppError` 公共类型名；
- 删除无日志、无说明的静默 catch；
- 更新 ADR、迁移日志和当前状态文档；
- 删除本计划文件。

## 五、硬规则

### 允许返回 Left

网络不可用、认证/授权业务失败、服务端 Problem Details、可恢复解析失败和明确的业务冲突。

### 必须保持 throw/stream error

编程错误、协议不变量、生成客户端结构不匹配、取消、SSE 断流和无法分类的基础设施故障。

### 允许 catch 的条件

必须有明确恢复或降级结果、结构化日志、必要的 OTel event/metric，以及证明用户可见结果的测试。禁止 `catch (_) {}`、无说明的默认空列表/null 和仅为“让流程继续”而吞错。

## 六、跨仓发布顺序

1. Luminous 先具备 Problem Details 解析、HTTP status 重试判定和 `LucentFailure`。
2. Lucent 切换成功资源响应、Problem Details filter、OpenAPI 和 SSE error event。
3. Luminous 导出并同步生成客户端，删除旧错误 envelope fallback。
4. 两端完成 repository/provider Result 硬切。
5. 删除旧类型、旧 helper、旧错误码和旧文档，并运行全量门禁。

## 七、验收标准

- 所有 2xx JSON 响应符合 endpoint 的资源 schema；`204` 响应无 body。
- 所有普通 4xx/5xx JSON 响应是 `application/problem+json`，不含 `statusCode`、`requestId`、堆栈或内部敏感数据。
- 客户端只根据 HTTP status、稳定业务 code、请求幂等性、Retry-After 和明确 retryable 处理重试。
- 每个迁移 repository/provider 都有成功、Left、降级和异常边界测试。
- OTel 能关联未预期错误和明确降级；traceId 不参与业务分支。
- `flutter analyze`、`flutter test`、Lucent typecheck、contract/e2e tests 和双仓文档检查全部通过。
- 旧 Result、runGuarded、AppError、错误 envelope fallback 不再有生产引用。

## 八、不做的事

- 不使用 fpdart 2.0 pre-release。
- 不在 widget 层引入 fpdart。
- 不引入 fpdart 的 Option/Reader/State 等无关类型。
- 不把 API Problem Details 迁移描述成 fpdart 自动完成的工作。
- 不承诺 Result 能在语言层面阻止调用方忽略返回值；用 repository contract、测试和 CI 门禁治理。
- 不把所有 throw 都消除；只消除没有边界、分类和观测的业务 throw。
