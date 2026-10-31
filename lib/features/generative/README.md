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
| `domain/` | `generation.dart`（`GenerationState` 四态、文档值类型）、`generation.dart`（仓储接口）、`catalog_policy.dart`（纯规则）、`item_catalog.dart`（首批 item 的 type 名与政策） |
| `application/` | `generation_session.dart`（生命周期编排 + 「恢复默认」结论），无 `Ref` / `BuildContext` |
| `data/` | `generation_cache.dart`（`KvStore`，键 `genui.<surface>.surface`）、`cached_generation.dart`（cache-first 仓储） |
| `presentation/` | `components/catalog.dart`（注册 `generative.<surface>`）、`providers/surface_state.dart`（生成态 / transport / catalog / DataScope）、`widgets/generative_surface.dart`（三态入口） |

`domain/` 不能 import 别的 feature 的 domain（`domain_purity`），所以可引用维度由
`item_catalog.dart` 的 `generativeMetricKinds` **声明**，`DataScope` 由它生成；不手抄
第二份。

## 组件 id

`generative.<surface>`，每个 surface 一个（计划 §7 第 2 问）。

这是 `contract_test` 里「首段不得是 surface 名」规则的**唯一显式例外**：生成结果按
surface 存（`genui.<surface>.surface`），渲染引擎也按 surface 一份（
`generativeTransportProvider(surface)`）。一个全局可挂任意 surface 的组件会让「这块
结果属于哪个页面」变成运行期才知道的事。例外在
`test/core/composition/contract_test.dart` 的 `isSurfaceScopedGenerativeId` 里明写，
并有一条测试断言它必须指向真实存在的 surface。

## 当前阶段

A7a（catalog + 渲染链路，不接 LLM）。`generativeStateProvider` 恒为 `GenerationIdle`：
还没有人生成，所以默认页面上什么都不出现。A7b 接后端生成端点时把它换成
`NotifierProvider`，由 `GenerationSession` 驱动，渲染层不变。
