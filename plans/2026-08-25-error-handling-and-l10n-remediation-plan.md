# 错误处理收尾与 l10n 消息根治计划

Created: 2026-08-25
Status: active
审查来源: `plans/Luminous-review-2026-08-24.md`、`plans/Luminous-review-2026-08-25.md`
关联计划: `plans/2026-08-17-error-handling-reform-plan.md`（原硬切计划，阶段 4 未完成）

## 一、根本原因分析

### 1. 错误处理重构为何没有进行到底

原计划 `2026-08-17-error-handling-reform-plan.md` 的阶段 4（删除旧规则）要求"仅当全部
repository 已完成迁移并通过全量测试时"才删除旧类型。实际执行中：

- **Repository 边界迁移基本完成**：所有 feature repository 的公共方法已改为
  `TaskEither<LucentFailure, T>` 返回，旧 `AppError`/`AppErrorKind`/`Result` 已删除。
- **但 monad 内部仍用 throw 驱动控制流**：`auth.dart:404` 的 `Left(:final value) => throw value`
  是最典型的案例——`refreshSession` 在 `TaskEither.tryCatch` 内部调用 `fetchAccount().run()`，
  然后用 `throw` 短路 Left 值。这违背了 fpdart 的函数式语义，依赖外层 `tryCatch` 捕获来
  正确工作。同一模式扩散到了 `account.dart:47` 的 `_resolve<T>` 方法。
- **`StateError` 作为协议异常在生产代码中大量残留**：全仓库扫描发现 25+ 处
  `throw StateError(...)` 散落在 datasource、repository、provider 三个层级。原计划
  规定"协议不变量保持 throw"，但这些 `StateError` 的大部分属于可恢复失败
  （空响应体、列表格式异常、字段缺失），不属于协议不变量。
- **中文技术消息未与 l10n 体系对齐**：`LucentFailure.network(message: '...')` 和
  `StateError('...')` 中大量使用中文硬编码消息（20+ 处），这些消息会被
  `LucentErrorMapper.fromObject` 透传到 `failure.message`，最终暴露给英文用户和 Sentry。
  项目已有 `NetworkErrorCode` → `NetworkErrorL10n` 的完整映射机制，但 datasource 层
  绕过了它。
- **`LucentApiException` 旧类型未彻底清除**：`error_mapper.dart` 仍保留
  `_fromLegacyLocalException` 适配器，`conversation.dart` 仍有 2 处 `is LucentApiException`
  防御检查，`mobile_auth_client_fluwx.dart` 仍有 6 处 `throw LucentApiException`。
  `api_exception.dart` 的类注释仍写"新代码不得构造本类型"，但实际新代码（微信移动端）
  就在构造它。

### 2. l10n 问题的根本原因

项目 l10n 基础设施本身是正确的：
- `NetworkErrorCode` 枚举定义了所有网络错误分类。
- `NetworkErrorL10n.map(code, l10n)` 正确映射到 `network_zh.arb` / `network_en.arb`。
- `user_message.dart` 的 `userMessageFromError` 在 `networkErrorCode != null` 时走 l10n 映射。

**但断裂点在 datasource 层**：datasource 在遇到空响应体或格式异常时，直接构造
`LucentFailure.network(message: '中文消息')` 或 `throw StateError('中文消息')`，
没有使用 `NetworkErrorCode`。导致：
- `message` 字段携带中文，被 `failure.message` 透传。
- 当 `networkErrorCode` 存在时，`userMessageFromError` 会优先走 l10n 映射，
  `message` 被忽略——但 `StateError` 不携带 `networkErrorCode`，走
  `LucentFailure.unknown(message: ...)` 路径，中文 `message` 直接暴露。
- 英文用户看到中文错误消息。

### 3. 敏感操作密码对话框问题（8-25 审查新增）

Security PIN 被删除后新增的密码对话框使用了原生 `TextFormField` 而非项目统一的
`FTextFormField`，与整个应用的 Forui-first 设计方向不一致 [[memory:17849504329474592541]]。
此外缺少 widget 测试、`autofocus`、`textInputAction` 等基本 UX 配置。

---

## 二、问题清单与分类

### A. 错误处理 — 🔴 严重

| 编号 | 问题 | 文件 | 行 | 来源 |
|------|------|------|----|------|
| A-1 | `throw value` 反模式（TaskEither 内部 throw Left） | `auth/data/datasources/auth.dart` | 404 | 8-24 R-2 / 8-25 #3 |
| A-2 | `_resolve<T>` 中 `throw failure`（Provider 层 throw） | `auth/presentation/providers/account.dart` | 47 | 8-25 #2 |
| A-3 | `retry_interceptor` `_withMappedFailure` 丢失 `message` | `core/network/interceptors/retry_interceptor.dart` | 108-114 | 8-24 R-1 |
| A-4 | `auth_interceptor._doRefresh` 裸 catch 吞编程错误 | `core/network/interceptors/auth_interceptor.dart` | 289 | 8-24 W-2 |

### B. 中文消息残留 — 🟡 警告（l10n 根因）

| 编号 | 问题 | 文件 | 行 | 来源 |
|------|------|------|----|------|
| B-1 | `_requireBody` 中文 message | `auth/data/datasources/auth.dart` | 46 | 8-24 W-4 |
| B-2 | `dose_log_remote` 中文 StateError | `medicine/data/datasources/dose_log_remote.dart` | 41,145 | 8-24 W-3 |
| B-3 | `response_body.dart` 中文 StateError | `core/network/response_body.dart` | 8 | 新发现 |
| B-4 | `reminder_remote` 中文 StateError | `medicine/data/datasources/reminder_remote.dart` | 252,262 | 新发现 |
| B-5 | `dose_log_remote._requireData` 中文 message | `medicine/data/datasources/dose_log_remote.dart` | 130 | 新发现 |
| B-6 | `reminder_remote._requireData` 中文 message | `medicine/data/datasources/reminder_remote.dart` | 150,269 | 新发现 |
| B-7 | `safety_tips_remote` 中文 message | `medicine/data/datasources/safety_tips_remote.dart` | 24 | 新发现 |
| B-8 | `risk_check_remote` 中文 message | `medicine/data/datasources/risk_check_remote.dart` | 31,47,70 | 新发现 |
| B-9 | `medicine_detail_remote` 中文 message | `medicine/data/datasources/medicine_detail_remote.dart` | 37 | 新发现 |
| B-10 | 其他 repository `requireData` 中文 message | support/settings/legal/notification/health_event/report/record/assistant/search 共 10+ 处 | — | 新发现 |

### C. 裸 StateError 残留 — 🟡 警告

| 编号 | 问题 | 文件 | 行 | 来源 |
|------|------|------|----|------|
| C-1 | `quick_entry_undo` StateError（配置缺失） | `record/application/usecases/quick_entry_undo.dart` | 94,101 | 8-24 W-1 |
| C-2 | `conversation.dart` Provider 层 StateError | `assistant/presentation/providers/conversation.dart` | 408,700,774 | 8-24 R-2（遗留） |
| C-3 | `sessions.dart` StateError | `auth/data/repositories/sessions.dart` | 20,26 | 8-24 R-1（遗留） |
| C-4 | `record.dart` StateError | `record/data/datasources/record.dart` | 223,255 | 8-24 R-1（遗留） |
| C-5 | `scan.dart` StateError | `scan/data/repositories/scan.dart` | 97,108 | 8-24 R-1（遗留） |
| C-6 | `lucent_ai.dart` StateError（流结束无结果） | `today/data/repositories/lucent_ai.dart` | 61 | 新发现 |
| C-7 | `ai_summary.dart` StateError（流结束无结果） | `report/presentation/providers/ai_summary.dart` | 85 | 新发现 |
| C-8 | `health_event/lucent.dart` StateError（5 处） | `health_event/data/repositories/lucent.dart` | 176,229,249,267 | 新发现 |
| C-9 | `reminders.dart` StateError | `medicine/presentation/providers/reminders.dart` | 162 | 新发现 |
| C-10 | `reminder_notification_planner.dart` StateError | `medicine/domain/services/reminder_notification_planner.dart` | 213 | 新发现 |
| C-11 | `sleep_flow.dart` StateError | `record/presentation/quick_entry/sleep_flow.dart` | 185,189 | 新发现 |

### D. 旧类型残留 — 🟡 警告

| 编号 | 问题 | 文件 | 行 | 来源 |
|------|------|------|----|------|
| D-1 | `LucentApiException` 仍在微信移动端构造 | `auth/data/datasources/wechat/mobile_auth_client_fluwx.dart` | 27,40,47,66,80,87 | 8-24 维护隐患 |
| D-2 | `conversation.dart` 防御性 `is LucentApiException` 检查 | `assistant/presentation/providers/conversation.dart` | 366,371 | 8-24 维护隐患 |
| D-3 | `error_mapper.dart` 保留 `_fromLegacyLocalException` | `core/network/error_mapper.dart` | 20-21,29-30,89 | 8-24 维护隐患 |
| D-4 | `sentry_talker_observer.dart` 保留 `is LucentApiException` | `core/logger/sentry_talker_observer.dart` | 52,58 | 新发现 |

### E. 敏感操作对话框 — 🔴 严重 + 🟡 警告

| 编号 | 问题 | 文件 | 行 | 来源 |
|------|------|------|----|------|
| E-1 | 使用原生 `TextFormField` 而非 `FTextFormField` | `core/widgets/common/sensitive_action_password_dialog.dart` | 83 | 8-25 #1 |
| E-2 | 缺少 widget 测试 | `core/widgets/common/sensitive_action_password_dialog.dart` | — | 8-25 #4 |
| E-3 | 缺少 `autofocus` 和 `textInputAction` | `core/widgets/common/sensitive_action_password_dialog.dart` | 83-91 | 8-25 #9 |

### F. 其他 — 🟡 警告

| 编号 | 问题 | 文件 | 行 | 来源 |
|------|------|------|----|------|
| F-1 | 改邮箱页密码未 `trim()` | `auth/presentation/pages/change_email.dart` | 122 | 8-25 #6 |
| F-2 | 改邮箱页测试用 `EditableText` 索引 | `test/auth/change_email_page_test.dart` | 39,76-78 | 8-25 #5 |
| F-3 | `AUTH_ELEVATION_TOKEN_INVALID` 遗留分支 | `auth/presentation/pages/account_settings_helpers.dart` | 154-157 | 8-25 #7 |
| F-4 | `device_session.dart` 裸 throw FormatException | `auth/domain/entities/device_session.dart` | 20,28 | 8-25 #8 |

---

## 三、执行计划

### 阶段 1：TaskEither monad 语义修复（A-1 ~ A-4）

**目标**：消除 `TaskEither` 内部的 `throw` 反模式和拦截器中的信息丢失。

1. **A-1: `auth.dart:404` `refreshSession`**
   - 将 `fetchAccount().run()` + `switch throw` 改为 `fetchAccount().flatMap((user) => TaskEither.of(...))`
   - `refreshSession` 整体用 `TaskEither.tryCatch` → `flatMap` 链组合，不内部 throw。

2. **A-2: `account.dart:47` `_resolve<T>`**
   - 删除 `_resolve` 方法。
   - 将所有调用方从 `_resolve(repository.method(...))` 改为
     `repository.method(...).flatMap((value) => TaskEither.of(...))`，
     或在 `_run` 的 `action` 中使用 `task.run()` + `fold`/`match` 直接操作 `state`，
     不通过 throw 传递失败。
   - `_run` 的 catch 不再需要捕获 `LucentFailure`——Left 直接映射到 `state`。

3. **A-3: `retry_interceptor.dart:108-114`**
   - 在 `DioException` 构造中添加 `message: err.message`。

4. **A-4: `auth_interceptor.dart:289`**
   - 将 `catch (e, st)` 改为 `on Exception catch (e, st)`，
     让 `AssertionError` / `TypeError` 等编程错误穿透。

### 阶段 2：中文消息根治（B-1 ~ B-10）

**目标**：datasource/repository 层的 `LucentFailure` 和 `StateError` 不再携带
中文 `message`；所有面向用户的消息通过 `NetworkErrorCode` + l10n 映射。

**策略**：
- `LucentFailure.network(message: '中文')` → `LucentFailure.network(message: '', networkErrorCode: ...)`。
  `message` 改为英文机器标识或空字符串，UI 层通过 `NetworkErrorL10n.map` 映射。
- `throw StateError('中文')` → `throw LucentFailure.network(message: '', networkErrorCode: ...)`
  或改为协议异常（`throw FormatException('English message')`）。
- 公共 helper `requireData`（`response_body.dart`）的 `message` 改为英文，
  并确保所有调用方传递 `networkErrorCode: NetworkErrorCode.emptyResponse`。

**批量修改清单**：
1. `core/network/response_body.dart` — `requireData` 的 `StateError` 改为
   `LucentFailure.network`，message 改英文，确保 `networkErrorCode` 传入。
2. `auth/data/datasources/auth.dart` — `_requireBody` 的 message 改英文。
3. `medicine/data/datasources/dose_log_remote.dart` — 2 处 StateError + 1 处 message。
4. `medicine/data/datasources/reminder_remote.dart` — 2 处 StateError + 2 处 message。
5. `medicine/data/datasources/safety_tips_remote.dart` — 1 处 message。
6. `medicine/data/datasources/risk_check_remote.dart` — 3 处 message。
7. `medicine/data/datasources/medicine_detail_remote.dart` — 1 处 message。
8. 其余 10+ 处 `requireData` 调用方（support/settings/legal/notification/health_event/
   report/record/assistant/search）——将 `message: '中文'` 统一改英文或空串，
   确保都传递了 `networkErrorCode`。

### 阶段 3：StateError 分类处置（C-1 ~ C-11）

**目标**：区分"协议不变量 throw"（保留）和"可恢复失败 throw"（改为 `LucentFailure`）。

**判定标准**：
- ✅ 保留 `throw StateError` 的场景：编程前置条件校验（如 `sleep_flow` 时间顺序）、
  状态机不变量（如 `reminder_notification_planner` 未找到提醒）。
- ❌ 改为 `LucentFailure` 的场景：空响应体、列表格式异常、字段缺失——
  这些是网络/服务端问题，属于可恢复失败。

**逐项处置**：
1. C-1 `quick_entry_undo.dart` — 配置缺失改为构造函数 `required` 参数校验，
   或 `assert(deleteDoseLog != null)`。
2. C-2 `conversation.dart` 3 处 — 改为 `LucentFailure.business(code: 'NO_PERSISTED_CONVERSATION')` 等，
   不在 Provider 层 throw。
3. C-3 `sessions.dart` 2 处 — 改为 `LucentFailure.network(networkErrorCode: ...)`。
4. C-4 `record.dart` 2 处 — 空 body 改 `LucentFailure.network`；状态码异常改 `LucentFailure.server`。
5. C-5 `scan.dart` 2 处 — 改为 `LucentFailure.network`。
6. C-6 `lucent_ai.dart` — 流结束无结果改为 `LucentFailure.business(code: 'AI_EMPTY_RESULT')`。
7. C-7 `ai_summary.dart` — 同上。
8. C-8 `health_event/lucent.dart` 5 处 — 改为 `LucentFailure.network` / `LucentFailure.business`。
9. C-9 `reminders.dart` — 改为 `LucentFailure.business(code: 'MEDICINE_NOT_FOUND')`。
10. C-10 `reminder_notification_planner.dart` — 保留（协议不变量）。
11. C-11 `sleep_flow.dart` — 保留（前置条件校验）。

### 阶段 4：旧类型清除（D-1 ~ D-4）

**目标**：删除 `LucentApiException` 及其所有引用。

1. **D-1: 微信移动端** — `mobile_auth_client_fluwx.dart` 的 6 处
   `throw LucentApiException(...)` 改为 `throw LucentFailure.network(...)` 或
   `throw LucentFailure.business(code: 'WECHAT_SDK_ERROR')`。
   消息改英文，携带 `networkErrorCode`。
2. **D-2: conversation.dart** — 删除 `is LucentApiException` 防御检查（2 处）。
3. **D-3: error_mapper.dart** — 删除 `_fromLegacyLocalException` 方法和
   `LucentApiException` 的 2 个 `is` 检查分支。
4. **D-4: sentry_talker_observer.dart** — 删除 `is LucentApiException` 分支（2 处）。
5. **最终**：删除 `core/network/api_exception.dart` 文件。

### 阶段 5：敏感操作对话框修复（E-1 ~ E-3）

1. **E-1**: 将 `TextFormField` 替换为 `FTextFormField.password`，
   使用 `FTextFieldControl.managed(controller: controller)`。
2. **E-3**: 添加 `autofocus: true` 和 `textInputAction: TextInputAction.done`。
3. **E-2**: 新建 `test/core/widgets/sensitive_action_password_dialog_test.dart`，
   覆盖：空密码提交、取消返回 null、键盘提交、UI 渲染。

### 阶段 6：其他修复（F-1 ~ F-4）

1. **F-1**: `change_email.dart:122` 添加 `.trim()`：`password: passwordController.text.trim()`。
2. **F-2**: 为 `change_email.dart` 的表单字段添加 `Key`，测试改用 `find.byKey`。
3. **F-3**: 删除 `account_settings_helpers.dart:154-157` 的 `AUTH_ELEVATION_TOKEN_INVALID` 分支。
4. **F-4**: `device_session.dart` 的 `throw FormatException` 保留（协议不变量），
   但确保调用方在 `TaskEither.tryCatch` 边界内捕获。

---

## 四、不做的事

- 不消除所有 `throw`：编程错误、协议不变量、前置条件校验的 `throw` 是正确的。
- 不在 widget 层引入 fpdart。
- 不修改 `LucentFailure` 的结构——它已经正确设计，问题在调用方误用 `message`。
- 不修改 l10n 基础设施——`NetworkErrorCode` + `NetworkErrorL10n` 已经正确，
  问题在 datasource 层绕过了它。
- 不在敏感操作对话框中使用 Material 3 组件 [[memory:17849504329474592541]]。

## 五、验收标准

- `grep -r "throw StateError" lib/` 只返回前置条件校验和协议不变量（≤5 处）。
- `grep -rP "message:.*[\x{4e00}-\x{9fff}]" lib/` 返回 0 结果。
- `grep -r "LucentApiException" lib/` 返回 0 结果（文件删除）。
- `auth.dart` 的 `refreshSession` 不含 `throw value`。
- `account.dart` 的 `_resolve` 方法已删除。
- `retry_interceptor.dart` 的 `DioException` 构造包含 `message`。
- `auth_interceptor.dart` 的 `_doRefresh` 使用 `on Exception catch`。
- 敏感操作对话框使用 `FTextFormField`。
- `flutter analyze` 无新增 error/warning。
- `flutter test` 全量通过。
- 新增 widget 测试覆盖敏感操作对话框。

## 六、执行顺序

1. 阶段 3（StateError 分类）→ 阶段 2（中文消息）—— 可合并为一次提交。
2. 阶段 1（monad 语义修复）—— 独立提交，需要更新相关测试。
3. 阶段 4（旧类型清除）—— 独立提交。
4. 阶段 5（敏感操作对话框）—— 独立提交。
5. 阶段 6（其他修复）—— 可与阶段 5 合并。
6. 全量 `flutter analyze` + `flutter test`。
7. 更新迁移日志和文档。
