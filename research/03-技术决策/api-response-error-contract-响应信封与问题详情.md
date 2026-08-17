---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-17
---

# Lucent API 响应信封、HTTP 状态与 Problem Details 调研

> 范围：回答 Lucent/Luminous 是否应保留 `{ code, message, data }`，以及如何让业务失败不被前端误当成成功并触发无效重试。资料仅采用 RFC、W3C、Google 和 Stripe 的一手资料，以及本仓库的当前契约与源码；本文不改动代码或计划。

## 结论

**保留 Lucent 的成功响应信封，但停止把它当作 HTTP 失败的替身。** 不建议为了“更像大厂”立即把全部成功响应改成裸资源；现有生成客户端、拦截器和全部 OpenAPI DTO 都依赖该形状，迁移收益不抵兼容成本。真正需要收紧的是失败契约和验证：

1. HTTP 状态码是请求是否成功、是否可按基础设施策略重试的权威信号。业务失败不能以 `200` 返回；`code != 0` 时 HTTP 必须为对应的 4xx/5xx。
2. 成功响应继续固定为 `{ "code": 0, "message": "", "data": ... }`。`code=0` 只表示 HTTP 已成功完成的业务操作，不承载“局部失败”或异步任务最终结果。
3. 非 SSE 的 HTTP 错误逐步改为 `application/problem+json`（RFC 9457），以 HTTP 状态 + 稳定业务 `code` 扩展字段表达；**不再套一层成功响应信封**。Lucent 的 Problem Details 不重复 body `status`，以避免第二个状态真相源。
4. `statusCode` 不进入 JSON 错误体；它与 HTTP 状态重复且会发生漂移。`requestId` 已由 Lucent ADR-0010 退役，客户端和契约中应删除；诊断只保留可选的 `traceId`。
5. 自动重试只看已定义的 HTTP 状态、方法幂等性、`Retry-After` 和（写操作）幂等键；绝不能因为“有 envelope”或 `code != 0` 盲目重试。

这套组合同时保留现有前端必需的成功 envelope 保护，并采用成熟 API 对失败的通行做法。Google 的 AIP-193 使用 HTTP 状态和结构化错误 status；Stripe 也以 HTTP 错误响应为外层、错误对象及业务错误码为内层。RFC 9457 则给出可互操作的标准错误媒体类型。

## 为什么现有信封不是错误本身

信封解决的是**响应体形状一致**的问题；HTTP 解决的是**传输/协议语义**的问题。两者可以共存，不能互相替代。

| 字段/层次 | 应回答的问题 | Lucent 推荐规则 |
|---|---|---|
| HTTP status | 请求在 HTTP 语义上是否成功；客户端/代理能否按通用规则处理 | 2xx 仅用于完成成功的请求；参数/业务/鉴权失败用 4xx，服务依赖或内部失败用 5xx。RFC 9110 将状态码定义为服务器对请求的响应结果；通用 HTTP 软件首先只看这里。 |
| `code` | 对产品代码有稳定意义的、可枚举的失败原因是什么 | 只在错误 Problem Details 的扩展字段中使用，例如 `AUTH_TOKEN_EXPIRED`、`VERIFICATION_CODE_COOLDOWN`；不可用来覆盖或违背 HTTP 状态。成功时固定为 `0`，以保留现有兼容性。 |
| `message` / `detail` | 给用户或开发者的可读解释 | 成功 envelope 的 `message` 继续为空；错误使用 Problem Details 的 `title`（稳定、短）与 `detail`（请求具体说明）。不得让客户端仅靠自由文本分支。 |
| `data` | 成功载荷 | 只在成功 envelope 中出现；错误不伪造 `data: null` 来冒充成功 schema。 |
| `traceId` | 支持与后端日志/追踪关联 | 可选诊断字段，不参与业务判断或重试。 |

RFC 9457 明确要求客户端以实际 HTTP 响应的状态为准，Problem Details 中的 `status` 只是咨询性副本；这正说明把一个 JSON `statusCode` 作为第二权威来源是不合适的。Lucent 应直接省略这个可选成员。[RFC 9457 §3.1.2](https://www.rfc-editor.org/rfc/rfc9457.html#section-3.1.2)；HTTP 状态语义见 [RFC 9110 §15](https://www.rfc-editor.org/rfc/rfc9110.html#section-15)。

## 成熟实践的共同点

### RFC 9457：标准化 HTTP 错误，不标准化成功体

RFC 9457 定义 `application/problem+json` 的错误对象，核心字段包括 `type`、`title`、可选的 `status`、`detail`、`instance`，并允许 API 加扩展成员。它不规定成功响应要不要 envelope，也明确它不替代既有领域错误格式。因此，“成功 envelope + Problem Details 错误”是完全兼容的组合。[RFC 9457 §3](https://www.rfc-editor.org/rfc/rfc9457.html#section-3) [§3.2](https://www.rfc-editor.org/rfc/rfc9457.html#section-3.2) [§4](https://www.rfc-editor.org/rfc/rfc9457.html#section-4)。

### Google：HTTP 状态与结构化错误代码一致，不以 200 表示错误

Google AIP-193 要求 API 返回结构化的 `google.rpc.Status` 错误；JSON 中的 `code` 是对应的 HTTP 状态码，并明确要求它与 HTTP status 一致。Google 还把机器可读的细节放入 `details`，而非让客户端解析 `message`。[AIP-193: Errors](https://google.aip.dev/193)。

这和 Lucent 的差异是：Google 的 `code` 是 HTTP code，而 Lucent 的 `400_002` / `401_002` 是更细粒度的业务码。Lucent 可以保留后者，但它应是**附加分类**，不能成为第二个 HTTP 状态。

### Stripe：HTTP 错误 + 稳定错误码 + 请求关联

Stripe 的错误处理文档把错误当作 HTTP API error，错误对象再给出 `type`、`code`、`message` 等细分信息；文档要求根据错误码决定处理，而不是解析文案。[Stripe Error handling](https://docs.stripe.com/error-handling) [Stripe error object](https://docs.stripe.com/api/errors/object)。其请求 ID 也是诊断用关联值，不改变成功/失败语义。[Stripe Request IDs](https://docs.stripe.com/api/request_ids)。

## 对 Lucent 的目标契约

### 1. 读取或写入成功

保持兼容形状，且只允许 `code: 0`：

```http
HTTP/1.1 201 Created
Content-Type: application/json

{"code":0,"message":"","data":{"id":"..."}}
```

所有 2xx JSON endpoint 都须在 OpenAPI 中将该 envelope 标为成功 schema；不能出现“控制器返回裸 DTO、运行时 interceptor 再补 envelope、OpenAPI 却还是裸 DTO”的双重契约。仓库在 2026-08-15 已发生过该类问题，当前全局 `ApiEnvelopeInterceptor` 及生成的 Dart client 都依赖这一点。

### 2. 业务、认证、验证和服务端失败

新的 HTTP 错误使用 Problem Details。`type` 是可文档化的稳定 URI，`code` 是稳定的机器码；不要把用户文案作为分支依据。

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/problem+json
traceresponse: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01

{
  "type": "https://api.lumos.example/problems/auth/token-expired",
  "title": "Authentication token expired",
  "detail": "Please refresh the session and retry.",
  "code": "AUTH_TOKEN_EXPIRED",
  "traceId": "4bf92f3577b34da6a3ce929d0e0e4736",
  "retryable": false
}
```

RFC 9457 的 `status` 在 Lucent 中省略，客户端必须信任 HTTP 状态。`traceId` 是可选 extension；若把 trace ID 暴露给终端用户，需确认它不包含用户信息或供应商敏感上下文。W3C 将 `trace-id` 定义为 trace context 的全局标识；它属于跨服务链路，而非单进程的 request ID。[W3C Trace Context §3.2.2.3](https://www.w3.org/TR/trace-context/#trace-id) [§8.1](https://www.w3.org/TR/trace-context/#uniqueness-of-trace-id)。

可以在一次兼容版本内让 Luminous 接受两种错误体：先解析 Problem Details，若 Content-Type 不是该类型则回退解析旧 `{code,message,data:null}`。完成客户端更新、OpenAPI 更新和服务端统一后删除旧错误 envelope。这是**后端 API 版本化改动**，须单独立项，不能混入 Luminous 的 `TaskEither` 重构。

### 3. SSE 是例外，必须显式建模

SSE 在 HTTP 200 建立流之后不能再改变 HTTP status；因此流内 `event: error` 需要自己携带失败语义。当前 Lucent 已使用 `{message, code?, statusCode?}`。应改为与 Problem Details 同语义的受限对象，例如：

```text
event: error
data: {"type":".../upstream-unavailable","title":"Upstream unavailable","code":"EXTERNAL_SERVICE_ERROR","retryable":true,"retryAfterSeconds":3}
```

这里可保留 `status` 作为事件字段，因为没有新的 HTTP 响应可读取，但字段名应为 `status` 而非 `statusCode`，并在 OpenAPI/SSE 文档中注明“仅表示流终止原因，不改变建立流时的 200”。普通 HTTP endpoint 不适用此例外。

## 字段取舍：回答当前的重复字段

| 当前字段 | 结论 | 原因 |
|---|---|---|
| `code` | 保留，但将数值 `400_002` 等逐步迁为可读稳定字符串，或至少在文档中维护一对一名称 | 它表达比 HTTP 更细的产品语义。不能用它取代 HTTP status，也不能允许它与 HTTP 类别矛盾。 |
| `statusCode` | 删除（SSE event 的 `status` 例外） | HTTP 已是权威；JSON 再放一个 `statusCode` 只会制造不一致。RFC 9457 的可选 `status` 也只是 advisory，因此普通 HTTP 的 Problem Details 同样省略它。 |
| `requestId` | 删除 | Lucent ADR-0010 已明确“彻底退役 requestId”；后端不再回写 `X-Request-Id`，Luminous 现有读取是过时兼容代码。 |
| `traceId` | 保留为可选诊断数据 | 与 Jaeger/OTel 追踪一致。当前 Lucent 从 `traceresponse` 头提取，后端日志已注入 `trace_id`。不用于业务逻辑。 |
| `networkErrorCode` | 仅客户端内部保留 | 它描述 DNS、超时、TLS、取消等“没有 Lucent HTTP 响应”的本地/传输失败，不能出现在 Lucent API contract。 |
| `retryable` | 建议新增到 Problem Details 和 SSE error event | 它补充业务判定，但不能绕过 HTTP 方法幂等性与 Retry-After。只有服务端明确知道语义时才设为 true。 |

## 防止“HTTP 200 业务失败 → 无效重试”的硬约束

造成无效重试的根因不是 envelope 本身，而是服务器与客户端把同一失败同时标为 HTTP 成功和业务失败。以下规则应写进 API contract 测试，不能只靠约定：

1. **一致性不变量**：任何 HTTP 2xx JSON 响应必须满足 `code == 0`；任何 `code != 0` 的普通 HTTP 响应必须是 4xx 或 5xx。批量接口的“部分成功”必须使用成功响应中的逐项结果，而不是把整个请求标成失败后给 200。
2. **错误媒体类型不变量**：任意 4xx/5xx JSON 响应的 `Content-Type` 必须为 `application/problem+json`，且 `code`、`type`、`title` 必填；普通 HTTP body 不得出现 `statusCode` 或 RFC 9457 的可选 `status`。
3. **重试不变量**：Luminous 的默认重试只允许 GET，且只对超时、连接失败、408、429、500、502、503、504 生效；429/503 优先遵守 `Retry-After`。非幂等写请求必须显式 opt-in 并带服务端验证的幂等键。现有 `RetryInterceptor` 已满足“默认只重试 GET”和该状态集合，需增加 `Retry-After` 解析及 Problem Details 的 `retryable:false` 否决。
4. **契约回归测试**：对每个代表性 endpoint 覆盖 success、validation、auth、conflict、not-found、internal error，断言 HTTP status、Content-Type、body schema、`code` 与 generated Dart client 的映射。再添加一个全局 e2e 断言：故意抛出 `BadRequestException` 不得返回 200。
5. **发布顺序**：先让 Luminous error mapper 能理解 Problem Details 并以 HTTP status 作重试判定；再在 Lucent 导出 OpenAPI、更新异常过滤器及测试；最后删除旧 error-envelope 回退。成功 envelope 不迁移。

`Retry-After` 的语义由 HTTP 定义（尤其适用于 429/503 等延迟重试场景）；客户端不应把业务错误默认视为暂时性失败。[RFC 9110 §10.2.3](https://www.rfc-editor.org/rfc/rfc9110.html#section-10.2.3) [§15.5.9](https://www.rfc-editor.org/rfc/rfc9110.html#section-15.5.9) [§15.6.4](https://www.rfc-editor.org/rfc/rfc9110.html#section-15.6.4)。

## 当前仓库事实与决策影响

- Lucent 的 `ApiEnvelopeInterceptor` 将所有普通成功返回包装成 `{code:0,message:'',data}`；`ApiExceptionFilter` 已在 4xx/5xx 使用同形 error envelope，但同时正确返回 HTTP error status。前端的 `LucentEnvelope.throwIfFailed()` 因而是第二道防线，不能是唯一失败判断。
- `ResultCode` 的数值前缀已和 HTTP 类别对齐，例如 `401_002` 是 token expired；这可以继续使用，但下一次 API major 时改为 `AUTH_TOKEN_EXPIRED` 这类字符串会更清晰，也避免把 HTTP status 编进业务码后又复制一遍。
- Lucent ADR-0010 和 `setup-app.ts` 已退役 `X-Request-Id`，改为响应 `traceresponse`；Luminous `error_mapper.dart` / `LucentApiException` 仍保留 `requestId` 读取，应在上述契约迁移中移除。
- Luminous 当前 `RetryInterceptor` 只对 GET 默认重试，并列举 408/429/5xx，是正确的安全底线；不要因为引入 `retryable` 而放开非幂等 POST 的自动重试。

## 不建议的方案

- **不建议** `HTTP 200 + {code:非零}`：代理、监控、通用 SDK、缓存与重试器会把它视为成功，正是此前排查困难的来源。
- **不建议** 同时维护 HTTP status、`statusCode`、带 HTTP 前缀的数值业务 code 三个可判定失败的真相源：只保留 HTTP status 为权威，业务 code 为细分原因。
- **不建议** 为了采用 RFC 9457 而马上移除成功 envelope：RFC 并不要求这样做，且会制造没有业务价值的大规模 generated-client 破坏。
- **不建议** 用 `message` / `detail` 决定登录刷新、UI 分支或重试：文案可本地化、修订，机器逻辑必须依赖 status、`code` 与明确的重试策略。

## 一手来源

- [RFC 9110: HTTP Semantics，§15 Status Codes](https://www.rfc-editor.org/rfc/rfc9110.html#section-15)
- [RFC 9457: Problem Details for HTTP APIs，§3 Problem Details](https://www.rfc-editor.org/rfc/rfc9457.html#section-3)
- [RFC 9457，§3.1.2 `status` is advisory](https://www.rfc-editor.org/rfc/rfc9457.html#section-3.1.2)
- [Google AIP-193: Errors](https://google.aip.dev/193)
- [Google `google.rpc.Status` protobuf source](https://github.com/googleapis/googleapis/blob/master/google/rpc/status.proto)
- [Kubernetes API conventions: Response Status kind](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#response-status-kind)
- [Stripe: Error handling](https://docs.stripe.com/error-handling)
- [Stripe: API error object](https://docs.stripe.com/api/errors/object)
- [Stripe: Request IDs](https://docs.stripe.com/api/request_ids)
- [W3C Trace Context](https://www.w3.org/TR/trace-context/)
- [Lucent ADR-0010：OTel tracing 与 requestId 退役](/D:/25080/Documents/VSCodeProject/Lumos/Lucent/docs/01-reference/adr/0010-otel-tracing.md)
