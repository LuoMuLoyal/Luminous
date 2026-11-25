# lib/features/generative — 生成式 UI

agent 按用户的文字指示**现场拼装**展示性界面。与 `features/customizer` 同构但
方向相反：customizer 是**用户**从预置组件里挑，generative 是 **agent** 从
catalog 里拼。

协议：**A2UI 1.0**（`a2ui_flutter ^0.5.0` + `a2ui_core ^0.9.0`）。
计划原文：`plans/2026-11-25-a2ui-1.0.md`。

## 职责与边界

- 管：一次生成 / 一次交互回合的输入与产物、生成态的四态迁移、结果的本地读写、
  `generative.<surface>` 组件的注册与渲染入口。
- 不管：**怎么渲染**（`lib/core/composition/a2ui/` 的 `GenerativeTransport` /
  `GenerativeSurfaceRenderer`）、**catalog 怎么构造**
  （`lib/app/composition/generative/`）、生成内容本身（agent 的事）。

## 组件词汇表：全量开放

A2UI 1.0 起**没有受限词汇表、没有内容准入规则**。`basicCatalog()` 的全部组件都
可渲染：

| 类别 | 组件 |
| --- | --- |
| 布局 | `Row` / `Column` / `List` / `Card` / `Tabs` / `Modal` / `Divider` |
| 内容 | `Text` / `Image` / `Icon` / `Video` / `AudioPlayer` |
| 输入 | `Button` / `TextField` / `CheckBox` / `ChoicePicker` / `Slider` / `DateTimeInput` |

外加三个本仓的领域组件（`metric_card` / `trend_chart` / `finding`）。它们从
Riverpod 取真值，**不是因为不许 agent 看数字**，而是因为这些数据本来就在客户端
——旧的「AI 编造健康数值」红线随 1.0 迁移一并撤销。

结构合法性由 `a2ui_core` 的消息校验负责：组件 schema 不符、引用不存在、重复 id
都会被处理器拒绝并通过 `lastErrors` 暴露，好的组件照常渲染（A2UI 渐进构建语义）。

## 交互：渲染端 → agent

v1.0 引入了**双向通道**，这是本 feature 相对 A7b 的最大变化：

```text
用户点 Button / 填 TextField / 拖 Slider
  -> 组件把动作写进 dataModel，并发出一条上行动作
  -> GenerativeTransport.outbound（action / callAgentFunction / error）
  -> GenerativeSurfaceNotifier._runTurn
  -> POST /layouts/:surface/turn { messages, document, capabilities }
  -> SSE 四帧（chunk / result / error / done）
  -> 覆盖同一 surface
```

三条容易写错的：

1. **回合串行化**。服务端无状态，每次带的是「当前文档」；并发两回合会各用同一份
   旧文档生成，结果互相覆盖。`_turnInFlight` 挡住第二条。
2. **`result` 是完整序列，不是增量**。`commit` 覆盖而不是追加——追加会让交互
   回合不断叠旧组件。
3. **dataModel 必须一起存**。否则冷启动重放出正确的界面、但输入框全空。

## 消息契约

端点：`POST /layouts/:surface/generate` 与 `/turn`（Lucent `layouts` 模块），SSE
四帧。`data/datasources/generation_remote.dart` 是本仓唯一知道帧名的地方
（`GenerativeSseEvents`）。

**词汇表由客户端下发**：请求体带 `capabilities`
（`GenerativeTransport.capabilitiesDocument()`，含完整 catalog 文档）。服务端不再
维护第二份组件清单，提示词由它生成。

**`chunk` 不是 LLM 文本流**。它的 `data` 是一条服务端已解析好的 A2UI 消息对象，
直接交给 `MessageProcessor`——不需要增量解析器。

两条失败的到达路径不同，别混：

| 何时 | 形态 | 处理 |
| --- | --- | --- |
| 开流**前**（空 prompt / `tab` / 超长） | 普通 HTTP 400/422 | `DioException` → `LucentErrorMapper` |
| 开流**后**（模型输出被拒、LLM 未配置、熔断） | `event: error` + 完整 Problem Details | `mapSseStreamError` |

`chunk` 只作渐进反馈，**`result` 才是权威序列**：落盘与重放都用后者。没有
`result` 就结束的流视为失败，否则页面会停在骨架上面永远转圈。

## 三态渲染

**没有生成结果时返回 `null`**，页面上不占位置，默认布局因此干净。

| 状态 | 渲染 |
| --- | --- |
| `GenerationIdle` | 不渲染（`SizedBox.shrink`） |
| `GenerationInFlight` | 骨架（`SkeletonShimmer`） |
| `GenerationReady` | 渲染该 surface |
| `GenerationFailed` | 有上一份结果就继续渲染它，没有则回到 Idle |

失败**不是**第四种渲染结论：用户看到的应该是「还是原来的样子」，不是一块错误占位。

## 分层要点

| 层 | 内容 |
| --- | --- |
| `domain/` | `generation.dart`（四态、文档值类型、`GenerationRequest` / `GenerationTurn`）、`repositories/generation.dart`（仓储接口 + 事件类型）、`services/item_catalog.dart`（领域组件的 type 名与 enum 取值） |
| `application/` | `generation_session.dart`（生命周期编排），无 `Ref` / `BuildContext` |
| `data/` | `datasources/generation_remote.dart`（SSE 消费，两个端点）、`datasources/generation_cache.dart`（`KvStore`）、`repositories/cached_generation.dart`（远端 + 本地收口） |
| `presentation/` | `components/catalog.dart`（注册组件 + 挂入口）、`providers/surface_state.dart`（transport / catalog / 语言）、`providers/generation.dart`（生成态 + 回合 + 重放）、`widgets/generative_surface.dart`（三态渲染）、`widgets/compose_entry.dart`（区块外壳） |

`domain/` 不能 import 别的 feature 的 domain（`domain_purity`），所以可引用的维度
由 `item_catalog.dart` 的 `generativeMetricKinds` **声明**；不手抄第二份。

## 存储

键 `a2ui.<surface>.document`，内容是 `{messages, dataModel?}`。

**没有兼容路径**：旧键 `genui.<surface>.surface` 存的是 v0.9 消息，这套代码重放
不了，也就不该读到它。编排页的 `genui.<surface>.spec`（用户起的标题）与生成结果
无关，键不动。

## 实验性功能：默认关闭，需用户显式启用

开关在 settings → advanced 的实验开关页（`genUiEnabled`）；开启后才在编排页出现
入口。

| 位置 | 受开关控制的事 |
| --- | --- |
| `app/composition/components/registry.dart` | `buildComponentRegistry` 是否注册 `generative.<surface>` |
| 同上 | `buildSurfaceCatalog` 是否把这些 id 追加进各 surface 的 `owned` |
| `isComposableSurface` | 判定依据是同一个 `generativeSurfaces` 清单 |

**两件事必须一起做**：编排页的候选面板只列 `SurfaceDefinition.owned` 里的 id。
只注册组件而不进 `owned`，组件能用却永远不出现在面板里。测试
`test/core/composition/genui_flag_test.dart` 把这两条一起断言。

**两个 override 都必须是 `overrideWith` 而不是 `overrideWithValue`**：回调在
provider 读取时求值并 `watch(genUiEnabledProvider)`，所以用户一开开关就立即生效。

## 语言

界面框架文案（入口、面板、失败提示、空态）走 ARB 分片 `lib/l10n/src/generative_*.arb`。

basic catalog 的**格式**语言来自 `generativeCatalogLocaleProvider`（读
`localeControllerProvider`）：它决定数字、日期与 `formatString` 的输出。不能吃
默认的 `en-US`。

生成**内容**的语言不归客户端管：服务端按 `Accept-Language` 决定并写进提示词。
`GenerationFailed.error` 是诊断信息，失败提示用固定文案，不把 error 上屏。

## 组件 id

`generative.<surface>`，每个 surface 一个。

这是 `contract_test` 里「首段不得是 surface 名」规则的**唯一显式例外**。例外在
`test/core/composition/contract_test.dart` 的 `isSurfaceScopedGenerativeId` 里明写，
并有一条测试断言它必须指向真实存在的 surface。

## 当前阶段

A7a / A7b 已落地。本次迁移到 A2UI 1.0：换包、全量组件、双向交互、去掉准入规则。
服务端侧（Lucent `layouts` 的 v1.0 产出与 `/turn` 端点）记在
`Lucent/plans/2026-11-25-a2ui-1.0.md`。