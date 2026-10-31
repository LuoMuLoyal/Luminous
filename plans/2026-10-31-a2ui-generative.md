---
status: active
owner: frontend
updated: 2026-10-31
---

# A2UI 生成式 UI：agent 按用户指示即时拼装展示性界面

Created: 2026-10-31（修订：领域 item 去掉重复的 `Luminous` 前缀；目录按
DDD-lite + Clean 四层组织）

> **落点**：组件化计划 `2026-10-28-composable-tabs.md` 的 A7，需求原文第 8、9 条。

## 0. 定位：两条不同的路

| | A2/A4 用户编排 | **A7 生成式 UI** |
| --- | --- | --- |
| 谁决定 | 用户拖拽/勾选 | **agent 按文字指示决定** |
| 单位 | 预置组件（`ComponentRegistry` 里的 38 个） | **展示原语**（Text / Card / Column / Row / Image / Icon / List / Divider） |
| 产物 | `SurfaceLayout`（id + size + config 清单） | **A2UI 消息序列**（一棵现拼的树） |
| 存哪 | `layout.<surface>` | `genui.<surface>.surface` |
| 复用代码 | 是——同一 id 同一 builder | **否**——每次生成都是新树 |

两者并存：用户可以让 agent 生成「每日饮水变化」的卡片，也可以把那类卡片在编排页里
换成自己排的。

## 1. 一句话方案

`genui`（`^0.10.4`，基于 `a2ui_core ^0.1.0`，A2UI **v0.9**）做渲染引擎；
我们提供**受限的展示性 catalog**，agent 只能在这个词汇表内拼装。
业务数据一律通过「引用键」注入——agent 决定「展示什么、怎么排」，
**不能编造数值、不能发起写操作**。

## 2. 调研结论

### 2.1 genui 渲染模型

| 维度 | 结论 |
| --- | --- |
| 协议 | A2UI v0.9：`createSurface` / `updateComponents` / `updateDataModel` / `deleteSurface`，消息带 `"version": "v0.9"` |
| 组件树 | 邻接表：`{id, component: {<Type>: {...}}}`，父子用 `children.explicitList` / `child` 引用。根节点约定 `id == "root"` |
| 渲染入口 | `SurfaceController` 消费消息 → `SurfaceWidget` 按 `SurfaceDefinition` 重建 |
| 数据绑定 | `updateDataModel` + 属性值 `{"path": "/x"}`；内部用 `preact_signals`（**不是 Riverpod**） |
| 传输 | `A2uiTransportAdapter.addChunk`（LLM 文本流，内部增量解析）/ `addMessage`（已解析消息） |
| catalog | `CatalogItem{name, dataSchema, widgetBuilder}`；schema 用 `json_schema_builder` 的 `Schema` |
| 版本状态 | `genui` 0.10.x / `a2ui_core` 0.1.x 均为 0.x，API 可能破坏性变更 |

### 2.2 可用的展示原语（`BasicCatalogItems`）

`Text`（markdown，`variant` h1–h5/caption/body）、`Card`、`Column`、`Row`、`List`、
`Divider`、`Icon`、`Image`、`ChoicePicker`、`FormatDuration`。

**剔除项**：

| 剔除 | 理由 |
| --- | --- |
| `Button` | 去掉一切可写动作 |
| `TextField` / `Slider` / `CheckBox` / `DateTimeInput` | 用户输入走既有表单 |
| `Modal` / `Tabs` | 导航归 GoRouter |
| `AudioPlayer` / `Video` | 无正当用途，且带音视频权限 |

### 2.3 与本仓架构的冲突

1. **状态双轨**：`genui` 用 `preact_signals` 驱动 DataModel，本仓是 Riverpod。
   DataModel 只放展示数据与引用键，业务数值不进。
2. **数据注入**：属性值只能是引用键（`{"kind":"water","range":"7d"}`），
   由领域 item 的 builder 内部从 Riverpod 取真值。
3. **分层门禁**：`genui` 引用封闭在一处；catalog 需要 feature 组件，
   而 `core/` 不能 import feature——沿用组合根注册模式。
4. **13 个音视频连带包**：catalog 剔除，包仍在依赖图（计划 §1.3 已接受）。

## 3. 目录结构（DDD-lite + Clean 四层）

### 3.1 命名：去掉 `Luminous` 前缀

现有组件 id 全部是 `<域>.<视图>`（`dose.safety_engine`、`calendar.strip`、
`overview.noteworthy`），类名也不带产品前缀（`ComponentHost` / `SurfaceCatalog` /
`ReviewHistorySection`）。catalog item 是本仓自有词汇，**不在跨包语境内活动**，
`Luminous` 前缀只是重复。

修订后：

| 原命名 | 修订后 | A2UI type |
| --- | --- | --- |
| `LuminousMetricCard` | `MetricCard` | `metric.metric_card` |
| `LuminousTrendChart` | `TrendChart` | `metric.trend_chart` |
| `LuminousFinding` | `Finding` | `review.finding` |

第三列是 `ComponentId` 形态（`<域>.<视图>`），登记进 `ComponentRegistry` 时用。

### 3.2 `lib/core/composition/genui/` — 跨 feature 的渲染引擎接缝

这一层属于**横切基础设施**（与 `core/composition` 现有部分同级），
职责是「怎么渲染」，不含具体业务词汇。

```text
lib/core/composition/genui/
  catalog.dart         GenerativeCatalog：白名单校验 + 查找；不含具体 item 定义
  data_scope.dart      DataScope：每个 surface 可访问数据的类型化声明（提示词来源）
  transport.dart       A2uiTransportAdapter 的 Riverpod 封装（消息流接入）
  surface.dart         渲染包装：SurfaceWidget + 错误降级
  store.dart           生成结果持久化（KvStore，键 genui.<surface>.surface）
```

**`core/` 只声明契约**：`GenerativeCatalog` 接受外部传入的 `List<CatalogItem>`，
自己不 import 任何 feature。

### 3.3 `lib/features/generative/` — 生成式 UI 的垂直切片

生成式 UI 是一个**独立 feature**（与 `features/customizer` 同构：
customizer 是用户编排，generative 是 agent 编排），按四层组织：

```text
lib/features/generative/
  domain/
    entities/
      generation.dart        GenerationPrompt / GenerationResult / GenerativeSurfaceDocument
    repositories/
      generation.dart        GenerationRepository 接口（TaskEither）
    services/
      catalog_policy.dart    纯规则：哪些 type 允许、引用键校验（无框架依赖）
  application/
    usecases/
      request_generation.dart    构造请求（含 DataScope + catalog 摘要 + prompt）
      apply_surface.dart         把 A2UI 消息序列应用到 surface 状态
    orchestrators/
      generation_session.dart    一次生成的完整生命周期（触发→流式→落盘→替换）
  data/
    datasources/
      generation_remote.dart     SSE 消费（复用既有 LucentSseClient）
      generation_cache.dart      消息序列的 KV 持久化
    repositories/
      cached_generation.dart     实现 domain 接口 + cache-first
  presentation/
    components/
      catalog.dart        注册 `generative.<surface>` 组件 + 领域 item 的 builder
    provider/
      surface_state.dart  生成态（idle / generating / ready / failed）
    widgets/
      generative_surface.dart   渲染 + 空态/生成中/失败
```

**要点**：

- `domain/` 纯 Dart：`GenerationResult` 是 A2UI 消息序列的值类型；`catalog_policy`
  是纯函数（给定 type 名与属性，判断是否放行）。
- `application/` 不出现 `Ref` / `BuildContext`。
- `data/` 只允许同 feature `domain/` + `core/network` / `core/storage` / `shared/`。
- `presentation/` 引用 `core/composition/genui/`（渲染引擎）是合法的——
  `allowedCoreForPresentation` 已含 `core/composition/`。

### 3.4 `lib/app/composition/generative/` — 组合根

需要同时看见「feature 组件」与「core 契约」的装配都在这里：

```text
lib/app/composition/generative/
  catalog.dart      装配 GenerativeCatalog：展示原语白名单 + 领域 item
  items/
    metric_card.dart       MetricCard item（builder 复用 review 指标卡）
    trend_chart.dart       TrendChart item（builder 复用 review 趋势图）
    finding.dart           Finding item（builder 复用 review findings，文案透传）
  generation_repository.dart   GenerationRepository 的装配（remote + cache）
```

领域 item 的 `widgetBuilder` 在这里拿 `WidgetRef`（经 `ProviderScope.containerOf`
或 builder 内的 context），从对应 feature 的 provider 取真值。

### 3.5 CatalogItem 没有直接落文件的特殊情况

`CatalogItem` 本身是 `genui` 类型，**不能出现在 feature 的 `domain/` 或
`application/`**（框架依赖）。所以：

- feature 的 `presentation/components/catalog.dart` 只负责**注册组件**
  （`ComponentRegistry`，本仓自有类型）；
- `CatalogItem` 的构造全部在 `lib/app/composition/generative/items/`。

## 4. 关键设计

### 4.1 catalog 分两层

**展示原语**：agent 用它们拼布局（`Text` 写标题说明、`Column`/`Row` 排版、
`Card` 分组、`Divider` 分隔）。用户说「把每日饮水做成三张并排小卡」，
agent 用 `Row` + 三张 `Card` + `Text` 就能做。

**领域 item**：agent 声明 `{'component': 'trend_chart', 'kind': 'water', 'range': '7d'}`，
渲染时从 Riverpod 取真值。

| item | schema | 底层组件 |
| --- | --- | --- |
| `metric_card` | `{kind, range}` | review 指标卡 |
| `trend_chart` | `{kind \| kinds[], range}` | review 趋势图 |
| `finding` | `{findingId}` | 后端 findings，**文案透传，AI 不能改写** |

`finding` 是安全边界的关键：医学结论文案必须原样呈现，agent 只能选展示哪一条。

### 4.2 为什么必须分两层

只有展示原语，agent 就得把数值写进 `Text`——那是「AI 编造健康数据」。
引用键正是为了堵这个：**agent 能决定展示什么、怎么排、什么形式，
不能决定数值是多少**。

### 4.3 生成结果持久化

存 **A2UI 消息序列**（`createSurface` + `updateComponents` + `updateDataModel`），
不存渲染树——序列是协议稳定表示，`genui` 升级后重放仍能重建。

冷启动重放，不重复烧 LLM。

### 4.4 两条触发路径

- **事件驱动**：`surfaceUpdates` 流自动替换；
- **手动刷新**：用户点「重新生成」并输入新指示。

### 4.5 `assistant.chat`（需求第 9 条）

抽 `features/assistant/presentation` 的会话控制器 + SSE 流 + proposal 卡片，
做成可挂载组件 `chat.assistant`。**写动作走既有 proposal 门控**。

## 5. 分阶段

### A7c：`chat.assistant` 组件

- 估：3–4 天

### 前置条件

- A4（跨表面挂载）已完成 ✅
- A5-2（趋势）/ A5-3（日历）未开始，但 A7c 不被阻塞：展示原语不依赖 A5。

## 6. 风险与红线

| 风险 | 应对 |
| --- | --- |
| **AI 编造健康数值** | 领域 item schema 只有引用键；`additionalProperties: false`；`catalog_policy` 纯规则校验；对抗性用例 |
| **AI 生成可写动作** | catalog 不含 `Button`/表单 |
| **AI 改写医学结论** | `finding` 文案透传后端；系统提示词禁诊断与用药建议 |
| `genui` 0.x 破坏性升级 | 引用封闭在 `core/composition/genui/` |
| 生成结果丢失 / 冷启动重烧 | 消息序列持久化 + 重放 |
| 音视频包增大包体 | 已记录；发布前核对 |
| 分层违规 | `CatalogItem` 构造只在 `app/composition/generative/` |

## 7. 待确认

1. **A7c 的 `chat.assistant` 挂载点**：是固定挂在 assistant 页，还是可按 surface
   分别挂载？
