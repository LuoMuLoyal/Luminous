# ADR-0003: riverpod_generator 与 Auth-Guarded Provider 工厂

- **Status**: accepted
- **Date**: 2026-07-10
- **Deciders**: LuoMuLoyal

## Context

ADR-0001 确立了 Riverpod 作为唯一状态管理方案。经过两个月的快速迭代，provider 层暴露出三个结构性问题：

1. **Provider 声明样板过多**：每个 feature 重复 datasource → repository → provider 三层管道，`network_providers.dart` 中有 15+ 个完全同构的 API provider，每个只是 `ref.watch(lucentDioClientProvider).xxxApi` 的一行包装。
2. **Provider 类型选型不统一**：`FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一，缺乏明确的选型标准：何时用 `FutureProvider`、何时用 `AsyncNotifierProvider`、何时加 `autoDispose`、何时用 `family`。
3. **Auth session 检查散落**：多个数据 provider 重复相同的 auth guard 模式（session 检查 + 未登录 fallback），在 mine、report、today、health_context 等至少 5 处重复。

## Decision

### 1. 引入 `riverpod_generator`

使用 `@riverpod` 注解替代手写 provider 声明。所有新 provider 必须使用注解形式；存量 provider 在触碰时迁移。代码生成会自动推导 provider 名称、默认添加 `autoDispose`、支持 family 参数类型推断、生成类型安全的 `Ref` 子类。

### 2. 统一 Provider 选型标准

| 场景 | Provider 类型 | autoDispose | 示例 |
|------|-------------|-------------|------|
| 纯 DI / 无状态服务 | `@riverpod` | 默认 autoDispose | `authApiProvider`、`dioClientProvider` |
| 只读异步数据（无 mutation） | `@riverpod` 返回 `Future<T>` | 默认 autoDispose | `mineDashboardProvider` |
| 带 mutation 的异步状态 | `@Riverpod(keepAlive: true)` AsyncNotifier | keepAlive | `todaySuggestionProvider` |
| 跨 feature 共享的根级服务 | `@Riverpod(keepAlive: true)` | keepAlive | `dioClientProvider`、`sessionStoreProvider` |
| 参数化只读 | `@riverpod` 带 family 参数 | 默认 autoDispose | `dailyRecordDetailProvider(id)` |

### 3. 提取 `authGuarded` Provider 工厂

创建一个受 auth session 保护的 FutureProvider 工厂，消除 5+ 处重复的 auth guard 逻辑：

- session 正在恢复并**有 stored session**（离线优先，2026-09-10 修订）→ 调用 fetch，cache-first repository 立即返回本地缓存数据，同时 session restore 后台继续；缓存缺失走网络路径并经调用方 timeout/error 处理降级
- session 正在恢复但**无 stored session**（全新安装）→ 返回 pending future（不触发 error/loading）；restore 无 token 时极快 resolve 为 signed-out，仅一两个帧
- session 确认未登录 → 返回 signedOutFallback（如有）
- session 已登录 → 执行 fetch

各 feature 的数据 provider 改为通过 `authGuarded` 调用，repository 边界为 `TaskEither<LucentFailure, T>`（ADR-0005），fetch 内 `run()` + fold，Left 抛出让 Riverpod 投影为 `AsyncValue.error`。

> **2026-09-10 修订（冷启动骨架屏 → 离线优先）**：原实现中 restore 期间无条件返回 pending future，导致所有 tab 在冷启动时卡骨架屏最长 8 秒，即使本地 Drift 缓存已有数据。修订后 restore 期间按是否有 stored session 决定是否走 cache-first fetch——返回用户启动即显示本地缓存，同时后台刷新；全新安装无 token 则不触发无谓网络请求。`resolvePageViewState` 同步移除 restore 期间强制 loading 的分支，让有缓存数据的 provider 直接展示。`authGuarded` 由同步函数改为 async（throw 语义不变，但错误 settle 在微任务队列上，依赖同步 error 断言的测试需 await 后再检查）。stored-session 的读取失败（如测试环境 platform channel 不可用）静默视为"无 session"。

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| 保持手写 Provider 声明 | 零新依赖，无 codegen 步骤 | 样板持续增长，autoDispose 遗漏风险，无编译时 provider 名称检查 |
| **引入 `riverpod_generator`（本方案）** | 编译时安全，减少 ~30% provider 样板，自动 autoDispose，IDE 跳转支持更好 | 增加 `build_runner` 运行（项目已有 freezed/json_serializable 依赖，无额外基础设施成本） |
| 迁移到 Bloc | 事件/状态分离更明确 | 推翻 ADR-0001，全量重写，学习成本高，与 hooks_riverpod 集成断裂 |

## Consequences

- 新增 `riverpod_generator` + `riverpod_annotation` 到 `dev_dependencies`（`build_runner` 已存在）。
- `scripts/contract/bootstrap.dart` 需增加 riverpod codegen 步骤。
- 存量 provider 不强制一次性迁移；新代码必须使用注解形式，触碰旧文件时逐步迁移。
- `authGuarded` 工厂消除至少 5 处重复 auth guard 逻辑。
- 受保护的 dashboard provider 通过 `dataChangeVersionProvider` 监听跨 feature 数据变更，实现自动刷新。
- Provider 选型标准写入本文档作为 ADR 引用，不再在 TODO 中追踪。
