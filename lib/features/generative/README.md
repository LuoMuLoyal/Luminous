# lib/features/generative — 生成式 UI

agent 按用户的文字指示**现场拼装**展示性界面（A2UI / `genui`）。与
`features/customizer` 同构但方向相反：customizer 是**用户**从预置组件里挑，
generative 是 **agent** 从受限词汇表里拼。

计划原文：`plans/2026-10-31-a2ui-generative.md`（组件化计划的 A7）。

## 职责与边界

- 管：一次生成的输入与产物、准入规则（`catalog_policy`）、生成态的四态迁移、
  生成结果的本地读写、`generative.<surface>` 组件的注册与渲染入口。
- 不管：**怎么渲染**（`lib/core/composition/genui/` 的 `GenerativeTransport` /
  `GenerativeSurfaceRenderer`）、**catalog item 怎么构造**
  （`lib/app/composition/generative/`）、生成内容本身（agent 的事；A7b 接后端）。

## 安全边界（本 feature 存在的理由）

agent 能决定「展示什么、怎么排、什么形式」，**不能决定数值是多少**：

| 风险 | 落点 |
| --- | --- |
| AI 编造健康数值 | `domain/services/catalog_policy.dart`：领域 item 只接受引用键，任何数值属性一律拒绝 |
| AI 生成可写动作 | `core/composition/genui/catalog.dart` 的白名单**不含** `Button` / `TextField` / 表单 |
| AI 改写医学结论 | `finding` item 只有 `findingId`，没有任何文案属性进白名单 |

`findingId` 是后端 `ReviewFinding.id`——稳定规则标识（`hydration_low` /
`medication_stable` / `sleep_insufficient`），由 Lucent `dashboard-presenter.ts`
的 `FINDING_IDS` 产生，跨请求跨语言不变。客户端词表见
`domain/services/item_catalog.dart` 的 `generativeFindingIds`。

两点容易写错：**不能拿 `kind` 当 id**（四值枚举，多条规则共用一个 kind，无法
唯一标识）；**`DataScope` 必须声明 finding 条目**（`findingPolicy` 要求引用值
存在于 scope，少了这一组任何合法 `finding` 都会被判违规，整次生成失败——这是
A7a 遗留的真 bug，已随本次修掉）。

三条都有测试：`test/generative/catalog_policy_test.dart`（规则）与
`test/generative/generative_surface_test.dart`（渲染层确实拿不到 `Button`）。

## 三态渲染

计划 §7 的结论：**没有生成结果时返回 `null`**，页面上不占位置，默认布局因此干净；
首次生成之后才出现。

| 状态 | 渲染 |
| --- | --- |
| `GenerationIdle` | 不渲染（`SizedBox.shrink`，尺寸为 0） |
| `GenerationInFlight` | 骨架（`SkeletonShimmer`） |
| `GenerationReady` | 重放 A2UI 消息序列 |
| `GenerationFailed` | 有上一份结果就继续渲染它，没有则回到 Idle |

失败**不是**第四种渲染结论：用户看到的应该是「还是原来的样子」，不是一块错误占位。

## 分层要点

| 层 | 内容 |
| --- | --- |
| `domain/` | `generation.dart`（`GenerationState` 四态、文档值类型、`GenerationRequest`）、`repositories/generation.dart`（仓储接口 + `GenerationStreamEvent`）、`catalog_policy.dart`（纯规则）、`item_catalog.dart`（首批 item 的 type 名与政策） |
| `application/` | `generation_session.dart`（生命周期编排 + 「恢复默认」结论），无 `Ref` / `BuildContext` |
| `data/` | `datasources/generation_remote.dart`（SSE 消费）、`datasources/generation_cache.dart`（`KvStore`，键 `genui.<surface>.surface`）、`repositories/cached_generation.dart`（远端生成 + 本地缓存的收口） |
| `presentation/` | `components/catalog.dart`（注册 `generative.<surface>` 并挂入口）、`providers/surface_state.dart`（transport / catalog / DataScope）、`providers/generation.dart`（生成态 notifier + 重放 + 动作）、`widgets/generative_surface.dart`（三态渲染）、`widgets/compose_entry.dart`（触发入口） |

`domain/` 不能 import 别的 feature 的 domain（`domain_purity`），所以可引用维度由
`item_catalog.dart` 的 `generativeMetricKinds` **声明**，`DataScope` 由它生成；不手抄
第二份。

## 实验性功能：默认关闭，需用户显式启用

生成式 UI 是**实验性功能**，默认关闭。开关在 settings → advanced → 实验开关页
（`genUiEnabled`）；开启后才在编排页出现入口。

| 位置 | 受开关控制的事 |
| --- | --- |
| `app/composition/components/registry.dart` | `buildComponentRegistry` 是否注册 `generative.<surface>` |
| 同上 | `buildSurfaceCatalog` 是否把这些 id 追加进各 surface 的 `owned` |
| `isComposableSurface` | 判定依据是同一个 `generativeSurfaces` 清单 |

**两件事必须一起做**：编排页的候选面板只列 `SurfaceDefinition.owned` 里的 id
（`customizer/presentation/widgets/palette.dart`）。只注册组件而不进 `owned`，
组件能用却永远不出现在面板里——用户看不到也就够不到。测试
`test/core/composition/genui_flag_test.dart` 把这两条一起断言。

**两个 override 都必须是 `overrideWith` 而不是 `overrideWithValue`**：回调在
provider 读取时求值并 `watch(genUiEnabledProvider)`，所以用户一开开关就立即生效；
写死成值则整个进程只有启动那一刻的判断，用户必须重启 app。开关关闭时组件根本
不注册，已存布局即使提到它，`ComponentHost` 也按「未知 id」跳过——这是组件系统
对任何未注册 id 的既有降级行为，不需要额外分支。

## 接后端生成端点（A7b）

端点：`POST /layouts/:surface/generate`（Lucent `layouts` 模块），SSE 四帧。
`data/datasources/generation_remote.dart` 是本仓唯一知道这些帧名的地方
（`GenerativeSseEvents`）。事件名收成常量而不是写在 `switch` 里：它们是跨仓契约，
漏改一处的后果是「事件被静默跳过」——用户看到的是永远转圈。

**`chunk` 不是 LLM 文本流**。它的 `data` 是一条服务端已解析好的 A2UI 消息对象，所以
喂给 `GenerativeTransport.feedMessageJson`（或 `feedJsonLine`），**不是** `feedChunk`
——后者是给未解析文本做增量解析的，形状对不上。

两条失败的到达路径不同，别混：

| 何时 | 形态 | 处理 |
| --- | --- | --- |
| 开流**前**（空 prompt / `tab_chrome` / 超长） | 普通 HTTP 400/422 | `DioException` → `LucentErrorMapper` |
| 开流**后**（模型输出被拒、LLM 未配置、熔断） | `event: error` + 完整 Problem Details | `mapSseStreamError` |

`chunk` 只作渐进反馈，**`result` 才是权威序列**：落盘与重放都用后者。没有 `result`
就结束的流视为失败，否则页面会停在骨架上面永远转圈。

**谁会重放**：`providers/generation.dart` 的 notifier。渲染层靠
`transport.contextFor(surfaceId)` 取上下文，消息没喂进引擎就永远是 `null`，于是有
结果也不渲染。所以「落地结果」与「喂给引擎」成对发生，缓存恢复时同理。

## 文案与语言

界面框架文案（入口、面板、失败提示、空态）走 ARB 分片 `lib/l10n/src/generative_*.arb`。

生成**内容**的语言不归客户端管：它由服务端按 `Accept-Language` 决定并写进提示词，
客户端只负责把值透传。`finding` 的医学结论文案来自后端原文，不翻译。
`GenerationFailed.error` 是诊断信息（Problem Details 明确写着 not for UI copy），
所以失败提示用固定文案，不把 error 上屏。

## 组件 id

`generative.<surface>`，每个 surface 一个（计划 §7 第 2 问）。

这是 `contract_test` 里「首段不得是 surface 名」规则的**唯一显式例外**：生成结果按
surface 存（`genui.<surface>.surface`），渲染引擎也按 surface 一份（
`generativeTransportProvider(surface)`）。一个全局可挂任意 surface 的组件会让「这块
结果属于哪个页面」变成运行期才知道的事。例外在
`test/core/composition/contract_test.dart` 的 `isSurfaceScopedGenerativeId` 里明写，
并有一条测试断言它必须指向真实存在的 surface。

## 当前阶段

A7a（catalog + 渲染链路）与 A7b（接后端生成端点）均已落地：
`generativeStateProvider` 是 `NotifierProvider`，由 `GenerationSession` 驱动，
渲染层不变。冷启动从 `KvStore` 恢复并重放；用户通过 `compose_entry.dart` 输入一句
指示触发生成。A7c（`chat.assistant` 组件）另行实施。
