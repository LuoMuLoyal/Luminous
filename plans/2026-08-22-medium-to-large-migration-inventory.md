# Luminous 中小型到中大型过渡迁移盘点与执行计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 找出 Luminous 在功能和本地数据规模扩大后仍保留的早期客户端做法，并把它们迁移到可验证、可演进的客户端边界。

**Architecture:** 保留 Flutter 移动端、Riverpod、GoRouter、feature-first Clean Architecture 和 Drift cache-first 方向。重点收口 repository/Result、离线同步、跨 feature 依赖、构建配置和设计系统边界；不以重写所有页面或追求桌面/Web 功能对等为目标。

**Tech Stack:** Flutter 3.47.1、Dart 3.12、Riverpod 3、GoRouter 17、Dio、fpdart、Freezed、Drift、OpenAPI generated dart-dio client、Forui、Talker/Sentry、GitHub Actions。

---

## 一、审查结论

审查快照：2026-08-22。Luminous 已经有 feature-first 目录、domain repository、生成客户端、Drift 本地数据库、Pending Sync、Sentry 和文档覆盖门禁。当前最明显的规模化债务不是“没有架构”，而是同一架构正在以多种历史方式并存：错误处理仍在硬切、离线写队列仍是字符串注册表、边界规则主要靠文档、Forui 仍有兼容层、构建输入仍是扁平 `.env`，而核心页面/测试存在超大文件。

### 已有独立计划，不在本计划重复拆解

| 项目 | 当前状态 | 本计划处理方式 |
| --- | --- | --- |
| Forui 主迁移 | 2026-07 已完成主设计系统迁移，当前仍有 Material/Forui 兼容树 | 不重做主题；只做兼容层清点、分类、收口和禁止新增旧用法 |
| Drift 本地持久化 | 已有 6 张表、DAO、WAL、外键、cache-first 和 `SyncWorker`；ADR-0009 明确当前不引入 SQLCipher | 先完善同步协议和数据生命周期；SQLCipher 只在产品数据范围扩大或威胁模型变化时重新评估 |
| 产品闭环/功能改造计划 | 2026-08-16 十份计划的 0.1.0 前工作已收口，后续项仍按各自计划执行 | 本计划不把产品功能债务伪装成工程迁移 |
| 桌面/Web 路线 | 当前移动端首发，桌面/Web PC 扩展冻结，未来大屏另行调研 | 不把“中大型工程化”误解为现在启动 Next.js/Tauri 或 Flutter 功能对等 |

### 候选迁移总表

| 优先级 | 迁移项 | 当前证据 | 目标 | 依赖 |
| --- | --- | --- | --- | --- |
| P0/P1 | OpenAPI/client 跨仓发布门 | 客户端生成依赖 `Lucent/docs/openapi.json`，当前仍需本地顺序执行；CI 主要验证客户端自身 | 合同版本、breaking diff、生成漂移、双仓最小兼容测试自动化 | — |
| P1 | 离线同步从字符串队列迁移为版本化命令协议 | `PendingSyncDao` 保存 `entityType/operation/payload` 字符串；`SyncWorker` 用 `Map<String, SyncHandler>` 动态注册 | typed command、payload version、client operation id、幂等/冲突策略、可观测 dead-letter/replay | 后端幂等合同 |
| P1 | Feature/layer 依赖可执行门禁 | 文档规定 data→data、presentation→presentation 禁止，但没有独立架构检查；跨 feature import 很多 | 规则由脚本/CI 强制，允许的 domain/application 依赖有清单 | 目录规则、生成代码排除规则 |
| P1 | 构建环境配置分层 | `EnvKey`/`EnvReader` 已类型化，但 `.env` 同时承载本地地址、E2E 凭证、SDK 值和 Sentry；`String.fromEnvironment` 只在编译期读取 | public build config、local dev、E2E、release secret 注入分离；缺失/非法配置在构建前失败 | CI、脚本、Lucent contract |
| P1/P2 | Forui 兼容层收口 | 代码仍有大量 Material import 和 `Icons.*` 使用，文档明确处于兼容阶段 | 新代码只走 Forui/Lucide；保留的 Material 仅有登记理由和封装 seam | 现有 UI 回归测试 |
| P2 | Riverpod 状态管理统一 | `@riverpod` 生成 provider 与手写 `NotifierProvider`/`AsyncNotifierProvider` 混用 | 形成“何时生成、何时手写、生命周期、重试和 action state”的明确规则，按收益迁移 | provider 测试 |
| P2 | 超大页面/测试文件拆分 | `record/presentation/pages/detail.dart` 约 900 行，多个页面/测试 400–1500+ 行；TODO 已暂缓 | 按 feature/application/presentation seam 拆 deep module，不做无语义的按行切片 | 0.1.0 发布验证、行为快照 |
| P2 | 测试质量从“全量通过”迁移到分层质量门 | CI 已运行 `flutter test --coverage`，但没有按层的 coverage baseline/ratchet、架构门或合同矩阵 | 关键 domain/repository/provider/UI/集成路径各有门槛，覆盖率只做趋势而非虚假总指标 | API contract、架构检查 |
| 条件项 | 本地数据库加密 | ADR-0009 明确当前依赖应用沙箱，未引入 SQLCipher | 只有数据范围/威胁模型改变才启动独立安全计划 | 安全评估、平台验证 |

结论：Luminous 当前最应先做的是合同/同步两个公共边界；页面拆分、provider 统一和完整 Forui 收口应在发布验证完成后按触及范围推进。

## 二、执行计划

### Task 1: 将 OpenAPI/client 同步变成跨仓合同门

**Files:**

- Modify: `../Lucent/scripts/contract/export-openapi.ts`、`../Lucent/.github/workflows/lucent-ci.yml`
- Modify: `scripts/bootstrap_generated_sources.dart`、`scripts/verify_lucent_openapi_sync.dart`
- Modify: `.github/workflows/luminous-ci.yml`、`scripts/tooling_workflows.dart`
- Inspect/Update: `generated/lucent_api/`、`docs/00-current/Lucent_Contract_Snapshot.md`、`docs/02-reference/how-to/regenerate-api-client.md`
- Test: new contract version, breaking-change and generated-drift tests

- [ ] 在 Lucent 导出 OpenAPI 时生成可追踪的 contract version/commit metadata；客户端构建输入必须能报告自己消费的合同版本。
- [ ] 在 Lucent CI 检查 Problem Details、SSE error event、2xx resource schema、204 empty body、pagination/cursor 和 enum unknown fallback。
- [ ] 在 Luminous CI 使用固定合同产物执行 bootstrap、generated client build、`flutter analyze` 和最小 provider/repository contract tests；不要让 CI 隐式依赖开发者本机的 `../Lucent` 工作区。
- [ ] 增加 breaking-change diff：删除字段、收紧 required、枚举删除、状态码/Content-Type 变化和错误字段变化必须显式批准；新增 optional 字段默认兼容。
- [ ] 写清发布顺序和回滚：客户端先能解析新合同 → 后端发布 → 更新 generated client → 删除兼容代码；失败时客户端可回退到上一份合同。

**完成判据：** PR 能自动回答“此 API 改动是否破坏旧客户端”和“生成客户端是否来自当前合同”；不再靠本地手工顺序保证两仓同步。

### Task 2: 将 Pending Sync 迁移为版本化、幂等的离线命令协议

**Files:**

- Modify: `lib/core/database/tables/pending_sync_queue.dart`
- Modify: `lib/core/database/daos/pending_sync_dao.dart`
- Modify: `lib/core/database/sync/worker.dart`
- Modify: `lib/core/database/database.dart`
- Modify: `lib/core/database/models/pending_sync_error_details.dart`
- Modify: `lib/features/*/data/repositories/` that enqueue offline writes, starting with `record`, `medicine`, `health_data` and product events
- Modify: corresponding `lib/features/*/data/datasources/`
- Test: `test/core/database/dao_test.dart`、`test/core/database/dao_extended_test.dart`、`test/core/database/sync/worker_test.dart`、repository tests and full-stack lanes
- Contract: `../Lucent/docs/01-reference/contracts/` and idempotent write endpoints

- [ ] 把 `entityType/operation/payload` 转为稳定命令注册表：命令名、payload version、schema validator、target id、client operation id、createdAt、attempt 和安全重试策略都必须可追踪。
- [ ] 每个离线写命令定义成功、可重试失败、永久失败、冲突和不可重试失败；不要用 `Map<String, SyncHandler>` 缺失 handler 时静默跳过。
- [ ] 使用 client operation id 与后端幂等合同配对；同一命令重放不会重复创建记录、重复埋点或重复扣减状态。后端未提供幂等能力的操作不能直接加入离线队列。
- [ ] 增加命令 schema version 和数据库 migration；旧 payload 有明确迁移器或进入用户可见永久失败，不把 JSON 解析异常吞成 null。
- [ ] 将 dead-letter/永久失败详情、retry now、reset、replay 和队列年龄纳入统一 UI/日志/指标；记录 traceId、failure code 和 operation id，但不得存储 token 或完整敏感请求。
- [ ] 处理账号切换/登出：队列必须按用户或会话隔离，登出后不得把上一个用户的 pending write 发给下一个用户。
- [ ] 运行 DAO/repository tests、`flutter test integration_test` 中代表性离线/全栈 lane、`flutter analyze` 和合同同步检查。

**完成判据：** 离线写入的恢复、冲突、重复、版本升级和永久失败均有显式状态；网络恢复后不会因动态字符串 handler 或旧 payload 造成静默数据丢失。

### Task 3: 将 feature/layer 规则接入可执行架构门禁

**Files:**

- Create: `scripts/check_architecture_boundaries.dart`
- Create: `test/scripts/architecture_boundary_check_test.dart`
- Modify: `.github/workflows/luminous-ci.yml`、`scripts/tooling_workflows.dart`
- Update: `docs/02-reference/architecture.md`、`docs/02-reference/Project_Guardrails.md`、`docs/00-current/Project_Governance.md`
- Inspect: `lib/features/**/data/`、`domain/`、`application/`、`presentation/`

- [ ] 解析 import 的 package path，排除 `generated/`、`*.g.dart`、`*.freezed.dart` 和明确的 platform conditional export。
- [ ] 失败规则至少包括：feature data 不得导入另一个 feature data；feature presentation 不得导入另一个 feature presentation provider/widget；domain 不得依赖 Flutter/Dio/generated client。
- [ ] 允许 application → domain；跨 feature presentation 的 UI action 通过 route/use case/domain snapshot/DataChangeBus；允许项写在带理由的 allowlist，而不是在脚本中硬编码静默跳过。
- [ ] 为每个现有 allowlist 项写回归测试；新增违规必须在 CI 阻断，脚本输出完整文件和 import 行。
- [ ] 将该检查接入 `run_daily_checks.dart` 和 GitHub Actions，运行 `dart run scripts/check_architecture_boundaries.dart` 与现有 docs/analyze/test 门禁。

**完成判据：** 依赖方向从文档约定变成 CI 可执行规则；重构模块时能定位一个清晰 seam，而不是靠全局搜索避免循环依赖。

### Task 4: 分离构建配置、E2E 配置与敏感注入

**Files:**

- Modify: `lib/core/config/env_keys.dart`、`lib/core/config/env_reader.dart`
- Modify: `.env.example`、`README.md`、`scripts/run_fullstack_checks.dart`、`scripts/run_daily_checks.dart`、`scripts/tooling_workflows.dart`
- Modify: `.github/workflows/luminous-ci.yml`、`.github/workflows/luminous-cd.yml`
- Update: `README.md`、`docs/02-reference/how-to/run-tests.md`、`docs/02-reference/Project_Guardrails.md`
- Test: `test/core/config/`、script tests and CI dry-run validation

- [ ] 将变量分为 public runtime/build configuration、local developer configuration、E2E credentials、release secrets；E2E email/password 不再和普通 `.env` 示例混为一组。
- [ ] 保留 `--dart-define-from-file` 作为编译期入口，但为每个 profile 提供经过 schema 校验的输入生成器/检查器；Dart 代码只读取 `EnvKey`，不新增裸 `String.fromEnvironment`。
- [ ] 对 URL、布尔值、版本、平台 SDK 值做构建前校验；release 缺 `LUCENT_BASE_URL`/`SENTRY_DSN` 等必需变量时 CI 失败，而不是把空字符串打进包。
- [ ] 明确客户端构建中什么是公开值：API base URL、OAuth app id、Sentry DSN 的暴露限制；密码、refresh token 和后端 Secret 不允许进入 Flutter artifact。
- [ ] 验证 Android/iOS/Web/Desktop 的 profile 输入、E2E 脚本 fallback、CI secrets 和本地 `.env` 优先级；不要为了“嵌套配置”强行让 Flutter 运行时解析 YAML，除非另有平台配置需求。

**完成判据：** 开发、E2E、CI、release 的配置来源和泄露边界清晰；缺失/非法配置在构建或测试启动前失败，不在运行中静默回退到错误后端。

### Task 5: 收口 Forui/Material 兼容层和图标入口

**Files:**

- Modify: `lib/app/bootstrap.dart`、`lib/app/router.dart`、`lib/core/theme/theme.dart`
- Modify: `lib/core/widgets/`、`lib/core/feedback/`、`lib/core/design/`
- Modify: feature presentation files with direct `package:flutter/material.dart` or legacy `Icons.*`
- Update: `docs/02-reference/Design_System.md`、`docs/02-reference/Design_System_Components.md`、`docs/02-reference/Design_System_Migration.md`
- Test: affected widget tests, golden/semantics tests where available, architecture check for new legacy imports

- [ ] 先生成保留清单：root `MaterialApp.router`、ThemeData interoperability、第三方组件必需 Material、平台 API 和真正需要的 picker/dialog 分别标注原因；不要用正则把所有 Material 类型替换成 Forui。
- [ ] 将 app-owned surfaces 按 feature 批次迁移到 Forui primitives 和 `FLucideIcons`；共享 wrapper 只保留有深度的语义模块，不新增只预设一个 style 的薄 wrapper。
- [ ] 对每个批次保留交互、键盘、语义树、暗色/高对比、响应式布局和平台回退测试；迁移后删除旧 wrapper 或把它移入明确的 compatibility namespace。
- [ ] 在 CI 检查新生产文件不能新增未登记的 Material import/`Icons.*`；已有债务用 allowlist 逐步收缩，不为达到零匹配破坏 Flutter/Forui 互操作。
- [ ] 完成后同步 Design System 和迁移日志；不要把生成的 `app_localizations*.dart`、Freezed、API client 当作手工 UI 迁移对象。

**完成判据：** 新 UI 的设计 token、控件和图标来源单一；兼容项可解释、可测试，Forui 迁移不再依赖隐形旧 wrapper。

### Task 6: 统一 Riverpod provider 的职责和生命周期

**Files:**

- Update: `docs/02-reference/state-management.md`、ADR-0006 and relevant provider guidance
- Inspect/Modify: `lib/features/**/data/providers/`、`lib/features/**/presentation/providers/`、`lib/core/providers/`
- Test: affected provider/controller tests

- [ ] 建立选择规则：repository/data wiring 优先 `@riverpod` 生成；复杂表单、分页、并发 action、明确 keepAlive 语义可手写 Notifier；widget 不直接创建 data source。
- [ ] 为每个 provider 记录 owner、生命周期、invalidate/refresh 语义、retry policy、上一次成功值保留策略和 sign-out 清理策略。
- [ ] 先迁移重复度高、没有特殊命名/生命周期理由的 provider；不为了形式统一重写稳定复杂 provider，也不同时改变错误类型。
- [ ] 为生成 provider 与手写 provider 各保留一套测试模板，验证 loading/success/Left/exception/refresh/override/dispose。
- [ ] 运行 `dart run build_runner build --delete-conflicting-outputs`、`flutter analyze`、相关 `flutter test` 和 docs verify。

**完成判据：** provider 形式由职责和生命周期决定；调用方不需要知道 provider 是生成还是手写，公共接口保持小而稳定。

### Task 7: 按 seam 拆分超大页面、provider 和测试

**Files:**

- First batch: `lib/features/record/presentation/pages/detail.dart`
- Next batch: `lib/features/record/presentation/widgets/sections/quick_entry_panel.dart`、`lib/features/record/presentation/pages/edit.dart`
- Later batch: `lib/features/report/presentation/pages/page.dart`、`lib/features/settings/presentation/pages/page.dart`、`lib/features/assistant/presentation/providers/conversation.dart`
- Tests: matching `test/record/`、`test/report/`、`test/settings/`、`test/assistant/`
- Update: `docs/00-current/TODO.md`、`docs/02-reference/architecture.md`

- [ ] 先为每个文件画出状态 ownership、IO/use case、view model、sections、dialogs 和 navigation seam；不按固定行数机械切文件。
- [ ] 把远程/本地编排移到 application/provider，把纯映射/格式化移到 domain 或 feature-local pure service，页面只保留布局、事件触发和生命周期所需逻辑。
- [ ] 每次只拆一个 seam，先移动现有测试和 key，运行对应 widget/provider tests，再继续下一个 seam；禁止借拆文件顺便改 API 合同或 l10n 结构。
- [ ] 对拆出的 module 设小接口，检查是否有真正第二个 adapter；如果只是转发一层，不创建空 repository/helper。
- [ ] 完成一批后删除对应 TODO 行，把稳定目录事实写回架构文档；不在计划里留下“已完成”标记。

**完成判据：** 页面复杂度集中在少数 deep module；测试可通过页面/控制器/纯逻辑的小接口覆盖行为；拆分不增加 cross-feature import。

### Task 8: 建立分层测试质量门，而不是只追总覆盖率

**Files:**

- Modify: `.github/workflows/luminous-ci.yml`、`scripts/tooling_workflows.dart`
- Create: test/coverage baseline and ratchet helper under `scripts/`
- Update: `docs/02-reference/how-to/run-tests.md`、`docs/00-current/Project_Governance.md`
- Test: script tests and representative feature suites

- [ ] 先保存当前 coverage baseline，按 domain pure logic、repository/data、provider/application、widget/integration 分层，不凭空设一个总百分比。
- [ ] 对公共基础设施（网络错误映射、auth refresh、offline sync、OpenAPI decode、l10n merge、architecture script）设置阻断门；普通页面先采用不下降的 ratchet。
- [ ] 把 contract tests、offline sync tests、最小 full-stack lanes 和语义/可访问性测试列为发布表面；慢的 Android emulator lane 继续单独运行，不伪装成普通 unit gate。
- [ ] 上传 coverage 和测试分类结果到 CI artifact，失败时显示缺口所在模块；不为了过门禁排除真正生产代码或只增加无断言 smoke test。
- [ ] 运行 `flutter test --coverage`、`flutter analyze`、`dart format --set-exit-if-changed`、docs verify 和 contract sync。

**完成判据：** 质量门能阻止公共边界退化，同时允许发布前不为每个 UI 像素追求虚假的统一覆盖率。

## 三、推荐顺序与暂停条件

1. 先把 OpenAPI/client 合同门自动化，保证后续同步改造不会继续漂移。
2. 将 Pending Sync 命令协议化，并和 Lucent 的幂等写合同对齐。
3. 把 feature/layer 规则接入 CI，之后再进行 Forui/provider/大文件迁移。
4. 分离构建配置和 E2E/Release secret 注入。
5. 按实际触及页面推进 Forui 收口和大文件拆分。
6. 最后建立按层 coverage/质量 ratchet；SQLCipher 仅在威胁模型变化后启动独立安全计划。

暂停条件：如果某项需要改变产品表面、启动桌面/Web 新路线、引入新的后端合同、改变数据保留/隐私模型或引入平台级加密，先创建独立 ADR 和子计划；不要把高风险决定藏在机械迁移中。

## 四、明确不建议现在迁移

- 不把 Flutter feature-first 全量重写成另一套 Clean Architecture/Bloc/GetX。
- 不为了 provider 形式统一而把所有手写 Notifier 改成生成器；有命名、生命周期或复杂 action 理由的保留。
- 不把所有本地数据直接迁移到 SQLCipher；ADR-0009 的当前决策有效，先做威胁模型和平台可行性评估。
- 不把 Flutter `.env` 机械改成 YAML；Flutter 的 `--dart-define-from-file` 是编译期输入，配置格式迁移必须有工具链收益和安全边界。
- 不在 0.1.0 发布验证前启动桌面/Web 功能对等、Next.js/Tauri 或大范围页面重写。
- 不把生成 API、Freezed、l10n 产物当作手工维护源文件；源文件和生成边界必须保持现有规则。

## 五、验证总门

每个代码迁移子计划完成后至少运行：

```powershell
flutter analyze
flutter test
dart format --set-exit-if-changed lib/ test/ scripts/
dart run scripts/check_doc_coverage.dart --verify
dart run scripts/check_doc_links.dart
dart run scripts/verify_lucent_openapi_sync.dart
```

涉及 generated client、Drift schema、l10n、跨 feature 边界或 full-stack lane 时，再运行：

```powershell
dart run scripts/bootstrap_generated_sources.dart
dart run scripts/run_fullstack_checks.dart
flutter test integration_test
```

计划执行过程中只更新相关当前状态文档和当天 `docs/03-logs/migration-log/YYYY-MM-DD.md`；执行完的计划文件按 Luminous 规则删除，不在计划中留下完成标记。
