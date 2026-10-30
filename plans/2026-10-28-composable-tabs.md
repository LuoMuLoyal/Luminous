---
status: active
owner: frontend
updated: 2026-10-30
---

# 全 Tab 组件化：可组合组件库、变体、用户编排、跨 Tab 挂载、生成式 UI

Created: 2026-10-28（2026-10-29 按 L3 目标重写：组件 id 改按域命名、注册表改为「全局目录 + 表面挂载」、
阶段顺序改为「先可组合 → 再变体 → 再编排 → 再跨 Tab」）

> **目标级别：L3。** 每个 tab 是一个**可组合表面**：用户决定挂哪些组件、什么顺序、多大尺寸、
> 组件内部选项；同一组件可以挂到多个表面（今日页挂用药风险、用药页挂血糖趋势）；
> 底部 tab 的图标/名称/顺序可配；每个 tab 额外提供一个生成式 UI 组件与轻量 AI 会话组件。
>
> **不做 L4**（整应用任意嵌套组合）。理由见 §0.3：那是 Notion 级文档模型，成本与本计划的
> 收益不成比例，且对医疗产品的可预期性是负面的。
>
> **三处架构判定（2026-10-29 修订）**：
>
> 1. **布局与 tab 配置的权威在后端**，本地只做缓存与离线队列——多设备一致，且不依赖卸载重装。
>    与既有 cache-first 架构同构，不新增机制（§2.7）。
> 2. **Forui 优先**：编排 UI、tab 配置页、生成式容器一律用 Forui 原语（`FButton`/`FSwitch`/
>    `FDialog`/`FSidebar`/`FCard`），不引入 Material 组件，也不为 Forui 已有控件再包一层薄壳（§6）。
> 3. **组件层零新增 UI 框架依赖**：只加两个布局/拖拽包（§1），其余全部用现有
>    riverpod + freezed + hive_ce + forui + genui。

- 范围：`Luminous`（Flutter 客户端）+ `Lucent`（**3 组**新端点：`/ui/layouts` 读写、`month-overview`、`generate-layout` SSE）
- 分 8 个阶段（A0–A7），**每个阶段可单独发布**，不允许跨阶段混提交

## 0. 需求原文（逐条，作为验收清单）

以下为产品侧原始表述，不改写、不加解释，用于逐条验收：

1. 每个 tab 都做成**可组合**形式；做出**更多组件、更多变体**供用户选择**显示什么、怎么排列**。
2. **每个组件有可自定义项**：今日总结里从 {饮水, 睡眠, 步数, 症状变化} **任选三个**。
3. **变体**：今日总结可切换成**单维度趋势图**；记录页两种风格——现有风格 / **大日历**（每格显示当日单维度记录）。
4. **用药**：多加组件；后端已有若干**药物检查端点前端尚未调用**；用户可自建「用药安全工作台」（风险检查放首屏）。
5. **回顾页**：单维度、多维度组件都做；可做**横屏**；把旧 report 页面改进后**并入组件库**。
6. **我的页**：多加组件；**横向快捷操作条**，显示哪些操作来自**快捷操作库**（组件库同构思路）。
7. **首屏 vs 整页**、**顺序**都可配（用户举的例子：糖尿病用户把血糖单位趋势图放第一位）。
8. **生成式 UI**：每个 tab 的组件库加一个生成式组件；告诉用户「本页能拿到哪些数据」，用户输入想看什么（例：「把这个组件设成每日饮水变化」），Agent 以**事件驱动或手动刷新**把结果反馈给用户。
9. **轻量 AI 聊天组件**，可放在今日页。
10. **底部 tab** 的**图标、名称、顺序全可改**（例：今日→「总结」，与用药互换到第三位；用药→「用药安全工作台」）。
11. 整体可扩展性类比 **DSH 的插件系统**：自由度与可扩展性都要高。

### 0.1 「今天叫什么名字」类需求的性质

第 10 条把 tab 名称交给用户，与 l10n 铁律冲突。处理方式已在 §4.4 给出：
用户输入的字符串属于**数据**（与 `nickname` 同性质），不是 UI 文案，不进 ARB；
这是 `docs/reference/localization.md` 需要显式记录的例外。

### 0.2 能力分级

| 级别 | 能力 | 本计划 |
| --- | --- | --- |
| L0 | 布局写死在代码里 | 现状 |
| L1 | 单表面：从目录选组件、显隐、排序、持久化 | A2 |
| L2 | L1 + 尺寸档 + 组件内强类型选项/变体 | A3 |
| **L3** | **同一组件可挂到多个表面**（跨 tab 复用） | **A4（本计划落点）** |
| L4 | 整应用任意嵌套/自建组件（Notion 块模型） | 不做 |

### 0.3 为什么不做 L4

Notion 官方对块模型的成本描述（[The data model behind Notion's flexibility](https://www.notion.com/blog/data-model-behind-notion)）：
每个块需要 `id / type / properties / content[](子块 id) / parent`，父指针用于权限与移动，
再加渲染树、事务队列、实时同步、版本历史、原生端 LRU 缓存与本地库。
这是**围绕文档模型重建整个产品**，不是「给 tab 加个编排器」。

对医疗健康产品还有一层反向成本：用户可以把风险提示移出首屏并忘记它，
而「默认布局好不好用」的解释责任在应用侧。L3 已经能覆盖「我的安全，我要看血糖」这类诉求，
L4 多出来的自由度对产品是负担。

## 0.4 同类产品实测（同行怎么做的）

| 产品 | 机制 | 对本文档的用处 | 来源 |
| --- | --- | --- | --- |
| **Grafana** | 仪表盘 = `{schemaVersion, panels[]}`；面板 = `{type,id,gridPos{x,y,w,h},配置}` | 与我们 `SurfaceLayout{schemaVersion, placements[]}` 同构；`schemaVersion` 用于迁移，是对的 | [Grafana JSON model](https://grafana.com/docs/grafana/latest/visualizations/dashboards/build-dashboards/view-dashboard-json-model/) |
| **AWS Cloudscape** | 可配置仪表盘模式：board + 组件面板 + 拖拽增删/改尺寸；12 列网格按视口降到 1 列 | 两条硬要求直接采用：「保留用户配置」与「移动时保持尺寸与内容状态」 | [Configurable dashboard](https://cloudscape.design/patterns/general/service-dashboard/configurable-dashboard/index.html.md) |
| **Bearable**（症状追踪） | 首页底部「Customise Homepage」：每段左侧开关、右侧拖拽排序；段内可自定义追踪项并排序 | 这是 L1 + L2 在健康类产品里的最接近先例 | [Bearable 配置说明](https://bearable.app/support/howto/configure-and-enter-data-into-bearable/) |
| **Vunda**（Shopify→App） | 底部 tab：改名（≤20 字符）、选图标、显隐、排序、角标；**2–5 个可见**，Android 导航栏最多 5 个 | tab chrome 可配的完整先例；同时给出我们的硬约束（见下） | [Customize the bottom-tab menu](https://www.vunda.app/help/customize-bottom-tabs) |
| **Notion** | 块模型 | L4 的成本参照 | 同上 |

### 0.4.1 由 Vunda 直接推到我们的两条硬约束

1. **tab 数量不可增加**：Material 导航栏最多 5 个目的地，我们已是 5 个。
   因此「加一个血糖 tab」不可行 —— 只能**隐藏一个换一个**，或把血糖做成组件挂到现有 tab。
   这从侧面证明 L3（跨 tab 挂载）是本计划不可省的一半。
2. **tab 名称长度必须截断**：Vunda 对自由文本的限值是 20 字符，我们更窄（5 等分 + 单行 label），
   取**中文 8 / 拉丁 12**，见 §4.4。

### 0.5 组件化的立场：原生组件化

**组件就是开发者写的原生 Flutter Widget。**「组件化」在本仓指三件事：
页面构成的单位被抽出来、单位之间可以独立增减、单位能被其它表面复用。

AI-native 只是类比（把稳定单位抽出来，让上层按同一套规则组合），不是把 AI 塞进渲染路径。
组合者是用户（A2/A3）、跨表面挂载（A4）、生成式 UI（A7）——三者都只产出
`ComponentPlacement` / A2UI 消息，**不参与组件定义与渲染**。

四条判据，每阶段验收都要重跑：

1. **组件是原生 Widget，配置强类型。** builder 签名收 descriptor 声明的配置类型；
   `rawConfig` 的 `Map<String,Object?>` 只存在于**持久化边界**，进 builder 前必须经 descriptor
   解码成强类型；解码失败按未知 id 处理，不做类型擦除后的 downcast。
2. **组件不自带页面装配。** 构造函数不接收页面级回调（`onRetry`/`onGoXxx`/数据切片）；
   数据由组件自己 `ref.watch` provider，导航自己取 `GoRouter`。
3. **`pages/` 里不再出现 `final sections = <Widget>[...]`。** 页面 = 决定 surface 是哪张 + `ComponentHost` 一行。
4. **新增组件不需要改任何 `pages/` 文件。** 每个阶段结束重跑。

### 0.5.1 仓里已有的三个「不完整的组件目录」（收拢对象）

| 位置 | 已有雏形 | 为什么不够 |
| --- | --- | --- |
| `lib/features/medicine/presentation/pages/detail_sections.dart` | `MedicineDetailSections` 元数据表 + `MedicineDetailSection{tier,title,body,count}` | 只服务药品详情一页 |
| `lib/features/review/domain/entities/review.dart` | `ReviewSections` / `ReviewSection` / `ReviewSectionReasonCodes` 的 available/unknown 语义 | 语义正确但绑死在 review 域模型 |
| `lib/features/record/presentation/pages/quick_entry_reorder.dart` + `recordQuickEntryCustomOrder` | 已跑通的「有序 id + `ReorderableListView` + KV」链路 | 只服务快速记录面板 |

`lib/core/composition/` 就是这三处的通用化；`ReviewSection.unknown + reasonCode` 提升为
组件层的**降级态契约**（见 §2.5）。

## 1. 依赖决策

原则：**能用依赖解决的都引入依赖**，但只在它替代一批自研代码时才引入；已有依赖能覆盖的不重复引入。

### 1.1 本阶段要新增的

| 包 | 版本 | 用在哪 | 传递依赖 |
| --- | --- | --- | --- |
| `flutter_reorderable_grid_view` | `^5.7.0` | A3 起的编排编辑器网格模式：拖拽重排带位移动画，满足 Cloudscape「移动时保持尺寸与内容状态」 | 零（只依赖 Flutter） |

**`flutter_layout_grid` 已实测放弃**（原计划用它在 A3 承担三档跨列，依赖已移除）：

1. 它的自动放置无法可靠放置跨列项。最小复现：3 列网格里两个 `columnSpan: 2`
   的子项就抛 `GridPlacement.columnEnd cannot exceed column count` —— 游标逐列
   +1 前进，宽项从最后一列起算时算出 `columnEnd > columns`。`[3, 2]` 不报，
   `[2, 2]` 必报。手动指定 `columnStart` 也不行，会与库的游标不同步。
2. 它把子项放进内部 shrink-wrapping viewport，任何查询固有尺寸的后代都抛
   `RenderShrinkWrappingViewport does not support returning intrinsic dimensions`。
   Forui 的 `FBadge` 内部就是 `IntrinsicWidth`，含徽章的卡片无法放进网格。

跨列改用 `Row` + `Expanded(flex: span)`（`lib/core/composition/responsive/`）：
列数固定、按 span 分配，语义足够，且没有上述两类问题。

选 `flutter_reorderable_grid_view` 而非 `reorderable_grid_view`：后者最后发布 2023-11（`2.2.8`），
前者 2026-05 仍在更新，SDK 约束 `>=3.3.1` 与当前 Flutter 匹配。

**引入时机**：两个包都在 **A3** 进 `pubspec.yaml`，不在 A0。A0–A2 用内置 `ReorderableListView`
（`quick_entry_reorder.dart` 已在用）即可，先加包只会让锁文件多两个用不到的东西。

### 1.2 已有依赖直接覆盖，不重复引入

| 能力 | 现成依赖 |
| --- | --- |
| 列表拖拽排序 | Flutter 内置 `ReorderableListView` |
| 布局模型序列化 / 契约版本 | `freezed ^4.0.1` + `json_annotation ^4.12.0` + `json_serializable ^6.14.1` |
| 远端读写与错误映射 | 生成客户端 `generated/lucent_api` + `core/network/contract/` 的 `LucentFailure` 映射 |
| 本地缓存 / 待同步队列 | drift（`pending_sync_queue` + `SyncWorker`）+ `hive_ce ^2.22.0` |
| 状态与派生 | `flutter_riverpod ^3.4.3` + `riverpod_annotation ^4.0.7` |
| UI 原语 | `forui ^0.27.5`（**Forui 优先**，见 §6） |
| 生成式 UI | `genui ^0.10.4`（见 §1.3） |
| 图标选择 | 既有 `showAppIconPicker` + `LucideIconBridge`（2030 图标双向映射） |
| 测试替身 | `mocktail ^1.0.5` |

### 1.3 genui 的既有决策与代价

`genui ^0.10.4`（pub.dev，verified publisher `labs.flutter.dev`，BSD-3-Clause）已引入。

求解过程中撞到并解决的真冲突：`genui → json_schema_builder → email_validator ^3.0.0`
与本仓 `email_validator ^2.1.17` 不兼容，已升到 `^3.0.0`；影响面仅
`lib/core/forms/validators.dart:24` 一处，`EmailValidator.validate()` 签名不变。

引入的连带包共 20 个（`a2ui_core`/`genai_primitives`/`json_schema_builder`/`preact_signals`/
`decimal`/`rational`/`audioplayers`(+7)/`video_player`(+5)）。

**已知代价，接受并记录**：

- 13 个音视频包本仓用不到，是 `genui` 核心目录的连带依赖。会增大包体，
  iOS/Android 需确认无额外权限声明。A7 会从 catalog 剔除 `AudioPlayer`/`Video`，
  但**包本身仍在**——依赖图不用它，运行时即不初始化。
- `genui` 自带 `DataModel`（`preact_signals` 驱动），与本仓 Riverpod **并存但分层**：
  GenUI 内部状态只活在生成的 surface 里，**不允许**向 `DataModel` 同步业务数据；
  业务数据一律从 Riverpod provider 取值，由领域 `CatalogItem` 的 `widgetBuilder` 读取。
- `genui` 目前 0.x，API 可能破坏性变更。**所有 `genui` 引用只允许出现在
  `lib/core/composition/genui/` 一个目录内**。

### 1.4 明确不引入的

| 包 | 不引入的原因 |
| --- | --- |
| `json_dynamic_widget` | pub.dev 元数据 `isDiscontinued: true`（已停维护）。且它是 server-driven UI 引擎（自带 JSON 词汇表 / 表达式 / 主题），与「原生 Widget + 强类型 config」判据直接冲突；迁移现有 section 等于重写 UI |
| `reorderable_grid_view` | 版本停滞（2023-11 后无发布），见 §1.1 |
| `staggered_grid_view` | pub.dev 上当前 `0.0.1` 是另一个包（名字被占）；正主是 `flutter_staggered_grid_view`，而我们不需要瀑布流 |
| 第二套状态管理 / JSON 框架 | `riverpod` + `freezed` 已覆盖 |
| 面板→画布拖拽专用库 | 移动端用「点按添加」；真需要拖拽时用内置 `Draggable`/`DragTarget` |
| Material 组件库（隐式） | Forui 优先（§6），不因为某个拖拽包附带 Material 示例就引入 Material 依赖 |

## 2. 目标架构：`lib/core/composition/`

```text
lib/core/composition/
  id.dart            ComponentId（`<domain>.<view>`，永不改名）
  size.dart          ComponentSize { compact, regular, wide }
  descriptor.dart    ComponentDescriptor<C>：id / title(l10n) / sizes / defaultConfig /
                     encode/decode(C ⇄ Map) / build(context, C)
  registry.dart      ComponentRegistry：全局 id → descriptor（open registry，可注册/撤销）
  surface.dart       SurfaceCatalog：surface → {available: List<ComponentId>, generative: ComponentId?}
  layout.dart        SurfaceLayout { schemaVersion, version, placements[] } + ComponentPlacement
  layout/
    cache.dart       本地缓存（drift `ui_layouts` 表，cache-first）
    remote.dart      `GET/PUT /ui/layouts/:surface`（生成客户端，错误走 LucentFailure）
    sync.dart        乐观写入 + `pending_sync_queue`（entityType `ui_layout`/`tab_chrome`）
    store.dart       SurfaceLayoutStore：读缓存立即返回 → 后台拉远端 → 差异则更新
  chrome.dart        TabChromeConfig { tabId, customLabel?, iconName?, orderIndex, visible }
  host.dart          ComponentHost：按 placement 顺序取 builder + 统一间距 + 未知 id 容错
  data_scope.dart    DataScope：每个 surface 可访问数据的类型化声明（A7 提示词来源）
  catalog/           各 feature 的目录装配清单（只写 id，不写 builder）
  customizer/        编排 UI（A2，Forui 原语）
  genui/             genui 适配层，唯一允许 import genui 的地方（A7）
  tab_chrome/        tab 配置与图标选择（A6，Forui 原语）
```

### 2.1 三个互相独立的维度（这是与旧版本最关键的差别）

旧版把「组件属于哪个 tab」写进组件 id，导致跨 tab 复用不可能。本版拆成三个正交概念：

| 维度 | 类型 | 回答的问题 | 谁写 |
| --- | --- | --- | --- |
| **目录** | `ComponentRegistry`（全局） | 系统里存在哪些组件 | 开发者注册 |
| **挂载** | `SurfaceCatalog`（每 surface） | 这张表**能挂**哪些组件 | 开发者声明 |
| **布局** | `SurfaceLayout`（每 surface，用户态） | 用户**实际挂了**哪些、什么顺序/尺寸/配置 | 用户 |

三者关系是 `挂载 ⊆ 目录`、`布局 ⊆ 挂载`。**组件 id 里不含 surface**，
所以 `dose.risk_overview` 既能出现在用药页，也能被用户加到今日页首屏（§0 第 7 条的场景）。

### 2.2 核心类型（要点，不是最终签名）

```dart
/// 稳定标识，`<domain>.<view>`，例如：
///   summary.metrics        今日总结（可配 3 个指标 / 可切成单维趋势）
///   water.trend            饮水趋势（单维）
///   dose.risk_overview     用药风险总览（安全首卡）
///   dose.mechanism_paths   代谢通路
///   calendar.month         月历（每格当日单维记录）
///   review.metric_grid     多维度指标网格
/// 一旦发布永不重命名；下架用 catalog 移除 + 用户布局按未知 id 跳过。
final class ComponentId { /* 校验格式 + wireValue */ }

enum ComponentSize { compact, regular, wide }

/// 用户态的一条挂载记录。rawConfig 只在持久化边界存在，
/// 进 builder 前由 descriptor.decode 变成强类型 C。
final class ComponentPlacement {
  final ComponentId id;
  final ComponentSize size;
  final Map<String, Object?> rawConfig;
  final bool visible;
}

/// 每 surface 一份；读不到 / schemaVersion 不认识 → 整体回退默认布局，不猜。
final class SurfaceLayout {
  final int schemaVersion;
  final List<ComponentPlacement> placements;
}
```

**配置用 sealed 类型，不用自由 map。** 以 `summary.metrics` 为例：

```dart
sealed class SummaryConfig {}
final class SummaryCompact extends SummaryConfig { final (MetricKind, MetricKind, MetricKind) metrics; }
final class SummaryTrendSingle extends SummaryConfig { final MetricKind metric; final Range range; }
```

「任选三个指标」因此是 `SummaryCompact` 的三个字段，选错在编译期报错；
持久化存 `{kind: 'compact', metrics: [...]}`，`decode` 失败即按未知组件跳过。

### 2.3 注册表是开放的（对应「像插件系统」的诉求）

```dart
abstract interface class ComponentRegistry {
  void register<C>(ComponentDescriptor<C> descriptor);
  void unregister(ComponentId id);          // 只影响新布局，用户已存布局按未知 id 跳过
  ComponentDescriptor? find(ComponentId id);
}

abstract interface class SurfaceCatalog {
  void mount(SurfaceId surface, List<ComponentId> ids);   // 声明「这张表能挂什么」
  List<ComponentDescriptor> available(SurfaceId surface);
}
```

`catalog/` 下只写「哪个 feature 提供哪些 id」，**builder 实现留在 feature 自己的
`presentation/components/` 目录**，避免 `core/` import feature presentation（分层门禁要求）。

### 2.4 间距不变量

间距由 `ComponentHost` 统一施加（组件之间一个 gap，末尾不加），**不由组件自己 Padding**。
`mobile_dashboard.dart:36-41` 那条「空槽位不占间距」的注释在这一层被结构性消除。
同一组件挂在不同表面时，间距逻辑不跟页面走。

### 2.5 跨阶段的四条公共契约

- **降级态由宿主统一处理。** review 的 `unknown + reasonCode` 提升为组件层公共形态：
  组件可报告「此刻不可用 + 原因码」，由 `ComponentHost` 决定留白还是降级卡。
  **不得渲染成「无风险 / 无异常」**（与「图查询 200+status」是同一件事）。
- **组件标题走 ARB**，不从 spec 读字符串（tab 自由文本是唯一例外，见 §4.4）。
- **组件 id 是唯一身份**：测试键、持久化键、未知 id 容错、下架全绑 id，不绑位置。
- **`core/composition/` 不 import 任何 feature 的 presentation 层。**

### 2.6 L3 的架构前置条件（A0 必须先定）

组件能挂到别的表面，就要能取到别的 feature 的数据。这要求：

1. `presentation` 允许 import **别的 feature 的 `presentation/providers/`**（读模型接缝）；
2. 组件自身不接收页面注入的数据，自己 `ref.watch`（§0.5 判据 2 已要求）。

**这不是新增豁免，而是让门禁对齐仓库已有的成文规则。** `AGENTS.md`
「Cross-Feature Import Rules」第 2 条早已写明：presentation 不得 import 别的 feature 的
presentation，应改用领域实体、共享快照 hub 或 DataChangeBus；而 `layered_import` 规则
本身就有两处显式豁免——**任何 `.../presentation/providers/...` 接缝**与
`features/shell/presentation/` 外壳基础设施。

也就是说 `AGENTS.md` 与 `layered_import` 是自洽的，**不吻合的是 `clean_layers` 的
`cross_feature_import`**：它把 providers 接缝也判成违规（当前 51 条里 19 条正是
`presentation/providers/`、9 条是 shell 外壳）。A0 要做的就是把 `clean_layers` 的口径
按这两处既有豁免对齐，其余（跨 feature `data/`、跨 feature 普通 `pages`/`widgets` 深引用）
继续禁止。禁止用逐文件白名单——只能是规则口径本身按接缝修正。

### 2.7 布局与 tab 配置的持久化（后端权威 + 本地缓存优先）

**权威在后端**：多设备一致、换机不丢、卸载重装不丢。本地只做缓存与离线队列，
与既有 cache-first（ADR-0006）同构，不新增机制。

#### 契约（`Lucent` 新增，A2 需要）

```text
GET  /ui/layouts
  → 200 { surfaces: { <surface>: LayoutDoc } }

PUT  /ui/layouts/:surface
  body: { ifVersion: int?, doc: LayoutDoc }
  → 200 LayoutDoc
  → 409 { current: LayoutDoc }        // 版本冲突，客户端以服务端为准并提示

LayoutDoc = { version: int, schemaVersion: int, payload: <客户端自定义 JSON> }
```

- `surface` 取值：`today` / `record` / `medicine` / `review` / `mine` / `tab_chrome`。
  **tab 配置与页面布局共用资源**，只是 payload 结构不同（少一套端点）
- 服务端**不解释** `payload`，只校验 `schemaVersion` 在支持区间、`version` 单调递增；
  语义解析全在客户端——契约演进时后端不需要跟着改
- 错误遵循 RFC 9457 Problem Details（ADR-0012），客户端经 `core/network/contract/` 映射成
  `LucentFailure`

#### 读路径（cache-first）

1. 读 drift 缓存表 `ui_layouts(surface PK, payload, version, schemaVersion, cachedAt)`
   —— 命中即渲染，**不阻塞首帧**
2. 后台 `GET /ui/layouts`，`version` 与缓存不同则写回缓存并 invalidate provider
3. 未命中（首次安装）→ 用**代码内默认布局**渲染首帧，同时拉远端；
   远端也没有（新账号）→ 把默认布局 `PUT` 上去

这与 `daily_record_summaries` 的缓存模式一致；表结构随 A2 的 migration 一起加。

#### 写路径（乐观写入 + 待同步队列）

1. 用户在编辑器里确认 → **立即写本地缓存并刷新 UI**（不等待网络）
2. 同一份变更入 `pending_sync_queue`：`entityType = 'ui_layout'`（或 `'tab_chrome'`），
   `operation = 'upsert'`，`payload = { surface, ifVersion, doc }`
3. `SyncWorker` 重放 → 成功则更新缓存里的 `version`；失败按既有指数退避重试
   （`backoffForRetryCount`），`permanent` 才提示用户
4. 离线期间任意次编辑只在队列里保留**最后一次**（同 `entityType + entityId` 合并），
   不排队 20 条

`SyncHandler` 在 `lib/app/sync_handlers.dart` 注册（现有 4 个注册器旁新增一个）。

#### 冲突与边界

| 场景 | 处理 |
| --- | --- |
| 两台设备同时改同一 surface | `PUT` 带 `ifVersion`；409 → 拉服务端最新、覆写本地缓存、提示「另一台设备刚更新过」 |
| 未登录 | 只写本地缓存，**不入队列**；登录后：本地有未同步改动 → `PUT` 覆盖；否则拉取 |
| 客户端 `schemaVersion` 高于服务端支持 | 服务端 409/422 → 客户端整体回退默认布局并上报（不猜） |
| 服务端 `payload` 解不开 | 回退默认布局，保留原始 payload 供诊断，不上报用户可见错误 |
| 新组件 id 出现在旧客户端 | `ComponentHost` 跳过未知 id（§2.5），布局其余部分照常渲染 |

## 3. 阶段排期

顺序原则（本条为 2026-10-29 修订，与旧版不同）：
**先把现有组件全部变成可组合 → 再做变体/尺寸 → 再做用户编排 → 再补新组件与 AI。**

### 进度（2026-10-30）

| 表面 | 组件数 | 默认布局 | 测试 | 备注 |
| --- | --- | --- | --- | --- |
| today | 8 | 与原顺序一致 | `test/today` 全绿 | P0 打样面 |
| record | 4 | 与原顺序一致 | `test/record` 513 全绿 | 区块原为内联 widget，已提为独立组件 |
| medicine | 4 | 与原顺序一致 | `test/medicine` 407 / 1 失败 | 余 1 条打卡撤销用例（见下） |
| mine | 7 | 与原顺序一致 | `test/mine` 104 全绿 | 桌面双栏保留手写，section 已自取 |
| review | 20（含 legacy 5） | 主路径 14 项与原顺序一致 | `test/review` 296 / 9 失败 | legacy 5 进 available、不进默认布局 |

门禁：`--clean-layers` 25 条（全部为跨 feature 的 `presentation` 深引用，非本轮引入）。
`flutter analyze` 全仓库无问题。

**A2 / A4 已在模拟器上实测通过**（2026-10-30）：从 Today 点标题进编排页 → `＋` 打开面板
→ 加入 Record 的 `calendar.strip`、Mine 的 `archive.summary` → 面板实时消失、列表末尾
出现 → `✓` 保存后写入 `layout.today` 的 KV 持久化数据。

**已知未完成项**（不计入验收通过）：

- medicine：`home dose check-in undo reverts to planned`。打卡会 emit `doseLogs` →
  页面重建 → `Toast.showWithAction` 的 context 失效，点撤销时 `context.mounted` 为 false。
  这是组件化引入的真实回归（改造前的 Column 版本同样失败），不是布局问题。
- review：`review_golden_test` / `review_semantics_test` 仍在用已删除的构造参数（编译失败）；
  `page_test` 的 history 筛选用例、`review_view_test` 的冷启动用例未通。
- A1 的两条验收（五个 tab 的 golden 兜底、「未挂载 id 即渲染」用例）尚未补齐。

### 兼容性约定（本轮确立即长期有效）

1. **`ComponentHost` 不 watch 数据 provider**，页面必须自己 watch surface 状态。
   原因：组件的 `build` 在 host 的 build 内被调用，组件为 `null` 时没有 element 挂载，
   provider 变化无人监听。页面级 `ref.watch(surfaceStateProvider)` 是必需的，不是冗余。
2. **`ComponentHost` 与 `ComponentHostSliver` 不能互换**：外壳是 `CustomScrollView` 的
   用 sliver 版；外壳是 `ListView` / `SingleChildScrollView` 的用 box 版。用错会触发
   `RenderSliverList` 被当作 box 子节点，或 `RenderViewport` 收到非 sliver 而断言。
3. **页面级 `PageStateSwitch` 的刷新/降级提示是 `Stack` 覆盖层**，不参与内容高度。
   组件化的页面外壳常是 `Column + Expanded`，提示条若作为兄弟节点会让外壳拿到无界高度。
4. **跨 tab 后组件仍 `ref.watch` 原属 feature 的 provider**：provider 全局、不绑 surface，
   两个 surface 挂同一组件只发一次请求；挂到非所属 feature 的表面时组件自己触发首次请求，
   无需新增机制。组件不自持状态、不直接发请求。

### A1 现有组件全量登记（零视觉变化）

- medicine / review / record / mine 四个 tab 的现有 section **逐个登记进全局 registry**，
  声明各自 surface 的 `available` 清单与默认布局
- 只登记、不改组件：本轮不改任何 section widget 的内部实现
- `ComponentZone` 概念不存在——首屏由「默认布局的前 N 项」表达，不需要类型化分区
- 验收：五个 tab 的默认布局渲染结果与改动前一致（golden 兜底）；
  每个 tab 至少一条「新增一个未挂载 id 到 surface 后即渲染」的用例
- 估：8–10 天

### A2 编排 UI：显隐 + 顺序

**已完成**（`lib/features/customizer/`）：

- 形态：**每 tab 一个编排页 + 跨 tab 面板**。用户从某个 tab 点标题进入，心智是
  「我在改这一页」；跨 tab 由右侧面板提供。
- **入口 = 标题**：`core/widgets/common/control/surface_title_button.dart`
  （`SurfaceTitleButton` / `SurfaceTitleEntry`）把标题做成带编辑图标的按钮，点一下进入
  当前 surface 的编排页。五个 tab 的移动端顶栏和 `DesktopTabShell.titleSurface` 都用它。
  路由能力经 `core/composition` 的 `surfaceCustomizerOpenerProvider` 注入，五个 tab 与
  `core/` 都不 import customizer。
- 路由 `/customize/:surface`：一个路由服务五个 surface，桌面侧面板、窄屏滑入页。
- **布局真正生效**：`application/layout_store.dart` 的 `surfaceLayoutsProvider` /
  `commit()` / `storedSurfaceLayoutProvider`；组合根覆盖
  `core/composition/surface.dart` 的 `surfaceLayoutProvider`，用户布局优先、缺省用
  `defaultLayout`，坏数据整体回退默认。`commitDraft` 由「完成」调用，「取消」丢弃草稿。
- `domain/`：`LayoutDraft`（各 surface 草稿 + 未挂载池）、`LayoutEdit`（move/toggle/
  remove/add/resize 的 sealed 动作）、`draft_rules`（纯规则，非法编辑返回原草稿）。
- `application/`：`StartDraft`（读布局生成草稿，读取失败回退默认）、`commitDraft`、
  `EditSession`（会话生命周期）。
- `data/`：KV 缓存（`layout.<surface>`）+ cache-first + 乐观写的 `CachedLayoutRepository`。
- 跨 tab 面板按来源 tab 分组列出**所有可挂但未挂**的组件，点按或长按拖入即加入。
- 允许**全隐**：`visible` 与「从列表移除」是两件事；移除进未挂载池，可再加回。
- 顶部操作：`✕ 取消`（丢弃草稿退出）、`＋ 添加组件`（窄屏才有）、`恢复默认`、`✓ 完成`。
- 窄屏的面板是**可拖高的底部 sheet**（220dp–0.9 屏），宽屏则是常驻右栏。

**两条踩过的坑（都是静默失败，务必保留）**：

1. `_add` 曾经只在「本页移除过的组件池」里查，首次加入的组件直接返回原草稿——
   表现为「点了没反应」，无报错。现在池里没有就按目录新建 placement。
2. 面板**必须自己 `ref.watch` 草稿**，不能接收调用方传入的快照。窄屏面板长在
   `showModalBottomSheet` 的 builder 里，那个 builder 不在页面重建范围内：传快照
   进来时组件确实加进了草稿，面板却按旧数据渲染，条目仍留在列表里——同样是
   「点了没反应」，但数据层其实已经成功。

**依赖**：`flutter_reorderable_grid_view: ^5.7.0`。

**未完成**：

- Lucent `GET/PUT /ui/layouts` 不存在，`LayoutRemote` 是占位实现（fetchAll 返回空）。
  布局只存本地，不同步跨设备、不入 `pending_sync_queue`。
- 跨 surface **移动**（`LayoutEdit.move` 的 from≠to 分支）还没有 UI 入口：目前只能
  「在本页移除 → 在另一页加入」，不能一次拖动完成。
- 显隐/顺序只有列表形态，网格 + 尺寸档是 A3。

### A3 尺寸档 + 组件内选项/变体

**响应式三档已完成**（2026-10-30，`lib/core/composition/responsive/`）：

- `ComponentLayout` {mobile 1 列 / tablet 2 列 / desktop 3 列}，阈值沿用既有
  `Breakpoints`（960 / 1200），不引入新数字。
- `spanOf(ComponentSize)`：`compact` 恒 1 列；`regular` 在 2 列下占满、3 列下占 2；
  `wide` 占满；一律 clamp 到列数。
- `layoutGridRows` 按「从左到右填、放不下换行」分组，`ResponsiveGrid` 每行是
  `Row` + `Expanded(flex: span)`，行尾用 `Spacer` 占掉未使用的列（半宽卡片因此
  不会被拉成通栏）。
- `ComponentHostGrid` / `ComponentHostGridSliver`：单列时退回纵向列表，不付网格代价。
- 桌面端随之退出「手写双栏」：`desktop_dashboard.dart` 改渲染与移动端同一份
  `SurfaceId.today` 布局。顺带修掉一个既有遗漏——旧桌面双栏从不渲染
  `health_event.active`，`_refreshAll` 里「只在移动端刷新」的判断因此是错的。
- 不用 `flutter_layout_grid`（理由见 §1.1）；也不用 `IntrinsicHeight` 强制行等高：
  业务卡片可能内部带滚动视图，查固有高度会抛
  `RenderShrinkWrappingViewport does not support returning intrinsic dimensions`。
  行内改为 `CrossAxisAlignment.start`，各卡片保持自然高度。
- 编排页有尺寸选择器（三档 chip，选中实心、未选中描边），只在组件支持的档位
  多于一个时出现。
- 验收：`test/core/composition/responsive/layout_geometry_test.dart` 按**真实几何**
  断言 1/2/3 列下的宽度与换行，含未支持档位回退、未知 id 跳过、空布局。

**未完成**：

- 组件选项按 sealed 类型落地，先做需求里点名的两个：
  - `summary.metrics`：`SummaryCompact{3 个 MetricKind}` / `SummaryTrendSingle{metric, range}`
  - `record` 两种风格：默认布局预设 `classic` / `calendar`（两个预设，不做两套页面代码）
- 横屏/宽屏不是独立页面：由 `wide` 尺寸 + 同一组件的宽屏布局承担（需求第 5 条）
- `flutter_reorderable_grid_view` 的网格模式拖拽（编排页目前仍是列表形态）
- 每个新选项的 golden

### A4 跨表面挂载（L3 的开关）

**已完成**（2026-10-30）：

- `SurfaceCatalog` 把「所有权」与「挂载许可」拆成两件事：
  - `ownedBy(surface)`（原 `availableOf`）：这个 surface 自己 feature 提供的组件，
    只决定默认顺序与面板分组，**不是**权限表；
  - `mountableOn(surface, id)`：挂载许可。**任何已注册组件都能挂到任何页面**，
    只排除不存在的 surface 与 `tabChrome`。
- `SurfaceDefinition.available` 字段同步改名 `owned`，避免继续被当成权限表读。
- 跨 tab 面板按来源 tab 分组列出全部候选，用户可以把 Record / Review / Mine 的组件
  加到 Today（已在模拟器上实测 `calendar.strip`、`archive.summary`）。
- 组件被多个 surface 复用时仍是**同一份 descriptor、同一个 builder**，没有复制代码。

**未完成**：

- 默认布局尚未按需求第 4、10 条调整（用药页首屏 = 风险检查首卡）。
- 跨 surface 一次性移动（一次拖动从 A 页搬到 B 页）仍需两次操作。

- 验收：`water.trend` 同时挂在 today 与 record 两个 surface 的用例；
  同一 id 在两处共享同一个 provider 订阅（不重复请求）
- 估：5–7 天

### A5 各 tab 补组件（需求第 1–6 条）

#### A5-1 用药：接通 10 个未调用端点

以下 operationId **已在生成的 Dart 客户端里、前端一行没调**：

```text
listMechanismPaths  listSharedTargets  listCascadePaths  listSubstituteCandidates
listShortestRoutes  listDrugActions    listEnzymeDuels   listTargetDrugs
listTransportRoutes getMedicationOverview
```

（`getSafetyTips` / `getSequences` / `getDetail` / `runRiskCheck` / `getRiskCheck` 已在用。）

- medicine 数据层新增 `relations_remote.dart` + `medication_overview_remote.dart`，
  走既有 cache-first 模式
- 新增组件：`dose.medication_overview` / `dose.mechanism_paths` / `dose.shared_targets` /
  `dose.cascade_paths` / `dose.substitutes` / `dose.shortest_routes` / `dose.enzyme_duels` /
  `dose.drug_actions` / `dose.target_drugs` / `dose.transport_routes`
- 「用药安全工作台」= 该 surface 的默认布局（风险首卡 + overview + 机制/靶点）
- 图查询失败是 `200 + status`，必须渲染「暂时无法给出机理分析」，**不得渲染成「无风险」**
- 估：10–14 天

#### A5-2 回顾：单维 / 多维 / legacy 并入

后端 `GET /reports/dashboard` 已返回 `metrics`/`trends`/`findings`/`patterns`（含 `sparkline`），无需新端点。

- 单维：`review.trend_single`；多维：`review.metric_grid`、`review.trend_multi`
- legacy 页面（`legacy_dashboard_compat.dart` + `views/legacy/` + `sections/legacy/`）
  改进后拆成组件并入目录，随后删除 `/review/legacy` 路由
- 估：10–14 天

#### A5-3 记录：大日历（含后端新端点）

- `RecordCalendarDay.markers` 已是 `List<SemanticColor>`，但 `staticMonthDays()`
  只给当天塞一个 marker —— 现在是装饰不是数据
- `GET /daily-records` 无区间查询，渲染一个月 = 30 请求，不可接受

`Lucent` 新增：

```text
GET /daily-records/month-overview?month=YYYY-MM&kind=<可选>
→ 200 [{ date: 'YYYY-MM-DD', kind, count, hasAlert }]
```

- 组件 `calendar.month`：每格显示当日单维度记录（需求第 3 条）
- 验收：单请求渲染整月（断言 HTTP 调用 1 次）；空月份不崩
- 估：10–14 天（含后端）

#### A5-4 我的：快捷操作库

- 横向快捷操作条 `quick_action.strip`：操作项来自**快捷操作库**
  （复用 record 的 `QuickEntryPreferences.customOrder` 形态，独立键 `mineQuickActionOrder`）；
  可选操作 = 已在别处实现的动作，不新造动作
- 估：5–7 天

### A6 底部 tab 全可配（图标 / 名称 / 顺序）

> 需求第 10 条：图标、名称、顺序全部可自定义。这是 shell + router 的结构改造。

- `ShellTab` 从 enum 降级为**数据**：`ShellTabDescriptor { ShellTabId id, String? customLabel, IconData icon }`；
  `ShellTabId` 保留 enum（tab **身份**不变，只是展示可配），`ShellTabConfig` 持久化到
  `chrome.tab.<id>`（登记进 `pref_keys.dart`）
- **不能新增 tab**：Material 导航栏上限 5 个，当前正好 5 个（§0.4.1）。只支持改名/换图标/换顺序/隐藏，
  且可见数保持 ≥3
- 名称约束：中文 8 / 拉丁 12 字符，超出截断 + 实时计数；空串/纯空白回退 ARB 默认；
  禁 RTL/LTR 覆盖字符与零宽字符（`\u202A-\u202E`、`\u200B-\u200F`）；提供「恢复默认」
- 顺序：`ShellTabId` 映射到 branch index，**顺序变化不改路由 path**（深链稳定）。
  现有 `test/shell/tab_test.dart` 断言 `ShellTab.values` 顺序与 label，按「默认无自定义」路径保留，
  新增「自定义后」独立用例
- **持久化复用 §2.7 同一资源**：`surface = 'tab_chrome'`，`LayoutDoc.payload` 存
  `[{tabId, customLabel?, iconName, orderIndex, visible}]`；离线走 `pending_sync_queue`
- 估：8–10 天

### A7 生成式 UI + 轻量 AI 会话

> 需求第 8、9 条。genui 作为**渲染引擎**接入，不是组件定义者。

**每个 tab 的组件库里多一个生成式组件**（`generative.<surface>`），行为：

1. 组件首屏告诉用户「这张表能拿到哪些数据」（来自 §2 的 `data_scope.dart` 类型化声明）
2. 用户输入想看什么（例：「把这个组件设成每日的饮水变化」）
3. Agent 输出 A2UI 组件树；`SurfaceController` 解析、`Surface` 渲染
4. **事件驱动 + 手动刷新两条路都要**：`surfaceUpdates` 流自动替换；用户可手动重新生成
5. 生成结果（A2UI 消息序列）持久化到 `KvStore`（键 `genui.<surface>.surface`），冷启动重放，
   不重复烧 LLM

`Lucent` 新增：

```text
POST /ui/generate-layout
  body: { surface, dataScope, catalogSchema, prompt, currentLayout? }
  → SSE：A2UI message chunks（createSurface / updateComponents / updateDataModel）
  解析失败则本次生成失败，UI 保留上一份 surface
```

必须 SSE：`A2uiTransportAdapter` 按 chunk 流设计，一次性返回会失去渐进渲染。

**与组件化的边界（不许混）**：

- A2UI 树的节点只能落在 `LuminousCatalog` 已注册的 `CatalogItem` 上；**不允许**通过 A2UI
  定义「新组件」再保存复用 —— 生成结果是一次性布局产物，不是组件类型来源
- 领域 `CatalogItem` 的 `widgetBuilder` 内部**直接复用 §2 registry 里的同一份组件**，
  不重新实现。同一个组件在「用户排的布局」和「AI 排的布局」里是同一份代码

**安全边界：catalog 白名单**。`genui` 内部即按 catalog 校验，未知组件走 `FallbackWidget`。

- **保留** `CoreCatalogItems` 的纯展示项：`Text`/`Column`/`Row`/`Card`/`Divider`/`List`/`Image`/`Icon`
- **剔除**：`AudioPlayer`/`Video`（音视频权限，医疗数据场景无正当用途）、
  `TextField`/`Slider`/`CheckBox`/`DateTimeInput`（用户输入走既有表单）、
  `Modal`/`Tabs`（导航归 GoRouter）、`Button`（**去掉一切可写动作**）
- **新增领域项**：`LuminousMetricCard` / `LuminousTrendChart` / `LuminousMetricGrid` /
  `LuminousCalendarHeatmap` / `LuminousFinding`（后端 findings 只读呈现，**文案字段透传后端，
  AI 不能改写**）
- **数据注入方式**：领域 item 的 `dataSchema` **不接受数据值本身**，只接受**引用键**
  （如 `{kind:'water', range:'7d'}`）；`widgetBuilder` 内部从 Riverpod provider 取真值。
  AI 因此只能选「展示哪个维度、什么区间、什么形式」，**无法凭空捏造数值**

**轻量 AI 会话组件**（需求第 9 条）：抽 `features/assistant/presentation` 里的会话控制器 +
SSE 流 + proposal 卡片，做成 `assistant.chat` 组件，可挂到 today 首屏；
写动作一律走既有 proposal 门控，不提供绕过门控的直达写。

- 估：A7 拆两次提交：A7a 每个 tab 的生成式组件 + 后端端点；A7b `assistant.chat` 组件
- 合计：12–16 天

## 4. 依赖关系

```text
A1 ──→ A2 ──→ A3 ──→ A4 ──┬─→ A5-1 ─┐
                          ├─→ A5-2 ─┤
                          ├─→ A5-3 ─┼─→ A7
                          └─→ A5-4 ─┘
A6（与 A1–A5 无耦合，但要独占时间窗：动 shell + router）
```

- A5 各子项在 A4 之后彼此独立，可按人分工
- A6 与 A5 无代码耦合，但动 `shell/` + `router.dart` + `app.dart`，**与任何阶段的文件冲突面都大**
- A7 依赖 A4（要能挂到多表面）与 A5-2/A5-3（趋势与日历组件是 A2UI 的主要词汇）

## 5. 风险与红线

| 风险 | 应对 |
| --- | --- |
| 用户把页面排乱后无法恢复 | 每编辑页都有「恢复默认」；`SurfaceLayout` 读不到/版本不认识即整体回退默认 |
| 默认布局不好用，用户被迫配置 | 每个 surface 的默认布局独立可用；编辑器不提供「全空」状态 |
| 配置入口过深 | 入口只长在 tab 页自身 |
| **组件 id 按域命名后改不动** | id 一经发布永不改名；下架走 catalog 移除（用户布局按未知 id 跳过），不删 descriptor |
| **同一组件挂多表面导致重复请求** | 组件从 provider 取数，provider 本身是单例；A4 验收含「两处挂载只发一次请求」 |
| **L3 撞分层门禁** | A0 先把 `cross_feature_import` 口径改为「允许 providers 接缝」，并在 `AGENTS.md` 同步 |
| 用户隐藏全部风险提示 | 编辑器限制：风险类组件（`dose.risk_*`）不可全部隐藏，至少保留一个（安全红线） |
| tab 改名后文档/引导图对不上 | 接受（自由文本的必然代价）；`docs/reference/localization.md` 记录该例外 |
| tab 换序导致测试与深链错乱 | 测试键绑 tab 身份不绑位置；深链绑路由 path；参数化测试覆盖排列 |
| `genui` 0.x 破坏性升级 | 全部引用封闭在 `lib/core/composition/genui/` |
| 新增 13 个音视频包 | 记录在案；发布前核对包体积与权限声明；catalog 已剔除 |
| **AI 生成布局夹带医学结论/可写动作** | catalog 不含 `Button`/表单控件；领域 item 只收引用键；系统提示词禁诊断与用药建议；对抗性用例 |
| 生成结果丢失 / 每次冷启动重烧 LLM | A2UI 消息序列持久化 + 冷启动重放 |
| 大日历 30 个请求 | 必须先用 `month-overview` 端点 |
| **多设备并发改布局互相覆盖** | `PUT` 带 `ifVersion`；409 以服务端为准并提示；客户端不做自动合并 |
| **离线编辑丢失** | 变更先落本地缓存 + `pending_sync_queue`（同 entity 合并为最后一条），联网由 `SyncWorker` 重放 |
| **服务端成了布局演进的瓶颈** | 服务端不解释 payload，只校验 `schemaVersion` 区间与 `version` 单调；语义全在客户端 |

## 6. 执行注意

- l10n 铁律：改 `lib/l10n/src/` 片段 → `dart scripts/l10n/arb_tools.dart merge` → `flutter gen-l10n`，
  **不碰 `app_*.arb`**
- 每个组件新增用户可见文案走对应 feature 的 ARB 片段；**组件标题也走 ARB**
  （唯一例外：A6 的 tab 自由文本）
- **Forui 优先**：组件层与编排 UI 一律用 Forui 原语（`FButton`/`FSwitch`/`FDialog`/`FSidebar`/
  `FCard`/`FPopover`）；**不引入 Material 组件**，也不为 Forui 已有控件再包一层只预设样式的薄壳
  （`docs/reference/design-system.md`）。第三方包（`flutter_reorderable_grid_view`）
  只提供手势，视觉一律取 Forui tokens
  （`context.theme.style.borderRadius.*`、`context.theme.typography.*`）与 `SemanticColor`
- 每个阶段结束追加 `docs/logs/migration-log/YYYY-MM-DD.md`（只追加不覆盖）
- 契约变更后：`Lucent` 跑 `pnpm export:openapi`，`Luminous` 跑
  `dart run scripts/contract/bootstrap.dart`
- 窄命令迭代（`flutter analyze` + 单个测试文件），收尾跑
  `dart run scripts/workflows/daily.dart`
- **§0.5 四条判据是每个阶段的验收项**，不是 A0 的一次性任务。尤其「新增组件不需要改任何
  `pages/` 文件」——做不到说明组件化没成立，要停下来修装配层
- 完成项从本文件**直接删除**，不留 `✅` / `DONE` 标记
