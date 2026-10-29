---
status: active
owner: frontend
updated: 2026-10-29
---

# 全 Tab 组件化：组件库、变体、用户自定义布局、生成式 UI

Created: 2026-10-28

> 状态：**未开工**（依赖已就位：`genui ^0.10.4`）。
>
> 定位：把 today / record / medicine / review / mine 五个 tab 从「每一页一段手写装配」
> 改成「每个 tab 一份组件目录 + 用户自选的组件列表 + 持久化布局」。用户决定**显示哪些
> 组件、什么顺序、哪个变体、每个组件的选项**；底部 tab 自身的**图标、名称、顺序全部可配**
> （名称接受自由文本）；每个 tab 的组件库额外提供一个**生成式 UI 组件**，
> 由 AI **真正生成布局**（A2UI 组件树），不走「受限 spec」的降级路线。
>
> **组件化本身的立场是「原生组件化」（§0.5）**：组件是开发者写的原生 Flutter Widget，
> 装配层只做「按声明取 builder + 统一间距 + 未知 id 容错」，不引入第二套 DSL，
> 也不让 codegen 介入组件定义。AI-native 只是类比——说明「组件是页面构成的稳定单位」
> 这件事值得先做，不是要把 AI 塞进渲染路径。

**架构立场：原生组件化（§0.5）。** 组件定义与渲染方式不变；新增组件与变体（P1/P3/P4/P5）、
装配层（P0）、用户组合（P2/P6）、生成式渲染（P7）、AI 会话画布（P8）都属于组件化，
只是各作用在组件生命周期的不同层。

- 范围：`Luminous`（Flutter 客户端）为主 + `Lucent`（3 个新端点的契约）
- 分 9 个阶段，**每个阶段都能单独发布**，不允许跨阶段混提交

## 0. 为什么要动架构（代码事实，不是判断）

四处现状都指向同一个结论：**页面结构被写死在代码里，用户无法参与**。

| 位置 | 现状 | 为什么撑不住 |
| --- | --- | --- |
| `lib/features/today/presentation/widgets/views/mobile_dashboard.dart:50-102` | 硬编码 `final sections = <Widget>[...]`，用 `SizedBox.shrink()` 占位保持索引稳定 | 注释明写「渲染空的槽位不能占间距」这一不变量；用户一排序即失效 |
| `lib/features/review/presentation/widgets/views/review_view.dart:38-67` | 构造函数 20+ 个参数，全是 `onXxx` 回调 + 数据切片 | 再加两个组件就是 30 个参数；组件间无法独立增删 |
| `lib/features/mine/presentation/widgets/views/dashboard_view.dart` | `MineStatusAlertsSection` / `MineArchiveSection` / `MineAiPrivacySection` … 顺序写死 | 与 today 完全不同的装配写法，各页各写一套 |
| `lib/features/shell/presentation/page.dart:105` + `tab.dart:5-10` | `ShellTab` 是 enum，`for (final tab in ShellTab.values)` 直接渲染 | enum 顺序即 tab 顺序，图标/名称是 enum 常量，无一可配 |

另外两处**已有的、可复用的**先例，说明「持久化偏好 + 重排 UI」这条链在本仓已经跑通：

- `lib/features/record/data/datasources/quick_entry_preferences.dart` —— 13 个 KV 键，
  其中 `recordQuickEntryCustomOrder` 就是一份有序 id 列表；`reset()` 逐键清理。
- `lib/features/record/presentation/pages/quick_entry_reorder.dart` —— 用内置
  `ReorderableListView` 完成拖拽重排并写回偏好。

**结论：不发明新机制，把这套既有形态提升成跨 tab 的通用层。**

## 0.5 组件化的立场：原生组件化

**组件就是开发者写的原生 Flutter Widget。**「组件化」在这个仓里指三件事：
页面构成的单位被抽出来、单位之间可以独立增减、单位能被其它页面复用。
它**不**指引入一套新的 UI 描述语言，也不指把组件定义交给 codegen 或 AI。

AI-native 是这类架构的**类比**，不是本计划的目标：AI-native 把「agent 能调用的动作」
抽成稳定单位，让上层（可以是人、可以是 agent）按同一套规则组合，而不用改页面自身的代码。
本仓抽出来的是 Widget，组合者是用户（P2）与生成式 UI（P7）——两者都只产出
`ComponentSpec` / A2UI 消息，**不参与组件的定义与渲染**。

据此立四条判据，每一条都能在代码里验证，且作为每个阶段的验收项：

1. **组件是原生 Widget，配置强类型。** 组件描述符的 builder 签名是
   `Widget Function(BuildContext, ComponentDescriptor 声明的配置)`，配置在编译期检查。
   禁止 `Map<String, Object?> options` 这类弱类型入口（§2 的 `ComponentSpec.options`
   只承载**持久化**的 JSON，进入 builder 前必须先经 descriptor 的强类型解码；
   解码失败按未知 id 处理，不做类型擦除后的 downcast）。
2. **组件不自带页面装配。** 组件的构造函数不得接收页面级回调（`onRetry` / `onGoXxx` /
   数据切片）。数据由组件自己的 `ConsumerWidget` 从 provider 取；需要跨页跳转时取
   `GoRouter`，不接受由页面注入的 `onTap`。
3. **`pages/` 里不再出现 `final sections = <Widget>[...]`。** 页面的职责收敛为
   「决定本页 surface 是什么」+ `ComponentHost(placements: ...)` 一行。
4. **新增组件不需要改任何 `pages/` 文件。** 这是本计划整体的验收标准，
   在 P0 之后每个阶段结束都要重新跑一遍。

### 0.5.1 现状：仓里已经有三个「不完整的组件目录」

这三处都能在代码里核实，说明组件化不是从零发明，而是把已有雏形收拢：

| 位置 | 已有的雏形 | 为什么不够 |
| --- | --- | --- |
| `lib/features/medicine/presentation/pages/detail_sections.dart:18` + `:389` | `MedicineDetailSections` 元数据表 + `MedicineDetailSection{tier, title, body, count}` | 只服务药品详情一个页面；`body` 是 `DetailSectionBody` 子类族，换页面就得重写一套子类 |
| `lib/features/review/domain/entities/review.dart:66-115` | `ReviewSections` / `ReviewSection` / `ReviewSectionReasonCodes` 的 available/unknown 语义 | 只服务 review；语义正确但绑死在域模型上，不能跨 tab 复用 |
| `lib/features/record/presentation/pages/quick_entry_reorder.dart` + `recordQuickEntryCustomOrder` 键 | 已经跑通的「有序 id 列表 + `ReorderableListView` 重排 + KV 持久化」链路 | 只服务快速记录面板，没有提到 tab 页级别 |

**§2 的 `lib/core/composition/` 就是这三处的通用化。** 这三份既有形态在本计划中的归宿：

- `detail_sections.dart` 的元数据表 → P0 之后由 medicine 的组件目录吸收，
  `DetailSectionBody` 子类族保留为组件内部实现细节（不进 `core/`）；
- `ReviewSection` 的 available/unknown → §2 `ComponentDescriptor` 的**降级态契约**
  （见 0.5.2），从 review 域模型提升为组件层公共语义；
- quick entry 的重排 + 持久化 → P2 `customizer/` 与 `TabLayoutStore` 的直接先例。

### 0.5.2 组件层的公共契约（跨阶段不变量）

以下四条对所有阶段的组件都成立，写在这里避免每个阶段各自发明：

- **降级态由宿主统一处理，不由组件各写各的。** review 的 `ReviewSectionState.unknown` +
  `reasonCode` 语义提升为组件层公共形态：组件可以报告「本组件此刻不可用 + 原因码」，
  `ComponentHost` 决定是留白还是渲染降级卡。**不得渲染成「无风险 / 无异常」**——
  这条与 P1 的图查询 `200 + status` 降级是同一件事，只是作用面从 medicine 扩到了全局。
- **用户可见文案一律走 ARB，组件标题也是。** 组件描述符的标题取 `AppLocalizations`，
  不从 spec 里读字符串（用户自由文本仅在 P6 的 tab 名称一处例外，见 P6-1）。
- **组件 id 是在 `ComponentHost` 里的唯一身份**：测试键、持久化键、未知 id 容错、
  下架（`visible: false`）全都绑 id，不绑位置。
- **`core/composition/` 不 import 任何 feature 的 presentation 层。** 组件注册在每个
  feature 自己的目录里（如 `lib/features/today/presentation/components/`），
  `catalog.dart` 只做装配清单，不持有 builder 实现。

## 1. 依赖决策（已落地）

`genui ^0.10.4`（pub.dev，verified publisher `labs.flutter.dev`，BSD-3-Clause）已引入。

求解过程中撞到并解决的真冲突：

- `genui` → `json_schema_builder ^0.1.3` → `email_validator ^3.0.0`，与本仓
  `email_validator ^2.1.17` 不兼容 → 已升到 `^3.0.0`。
  影响面仅 `lib/core/forms/validators.dart:24` 一处调用，`EmailValidator.validate()`
  签名不变；3.0.0 的唯一行为变更是「单字母 TLD 不再允许」，符合预期。

引入的连带包（共 20 个）：`a2ui_core`、`genai_primitives`、`json_schema_builder`、
`preact_signals`、`decimal`、`rational`、`audioplayers`(+7)、`video_player`(+5)。

**已知代价，接受并记录**：

- 13 个音视频包（`audioplayers*` / `video_player*`）本仓用不到，是 `genui` 核心目录
  `CoreCatalogItems` 的连带依赖。会增大包体，iOS/Android 需确认无额外权限声明。
  P7 会从 catalog 里剔除 `AudioPlayer` / `Video` 两项（见 P7.2），但**包本身仍在**——
  依赖图不去用它，运行时即不初始化。
- `genui` 自带 `DataModel`（`preact_signals` 驱动），与本仓 Riverpod **并存但分层**：
  GenUI 内部状态只活在生成的 surface 里，**不允许**向 `DataModel` 同步业务数据；
  业务数据一律从 Riverpod provider 取值，由领域 `CatalogItem` 的 `widgetBuilder` 读取。
- `genui` 目前 0.x（0.10.4），API 可能破坏性变更。**所有 `genui` 引用只允许出现在
  `lib/core/composition/genui/` 一个目录内**，外部只依赖本仓自己的
  `ComponentSpec` 与 `ComponentHost`，升级时改动面可控。

不新增其它依赖：拖拽排序用内置 `ReorderableListView`（`quick_entry_reorder.dart`
已在用）；布局持久化用现有 `KvStore`；spec 序列化用现有 freezed codegen；
tab 图标选择用既有 `showAppIconPicker` + `LucideIconBridge`（2030 图标双向映射）。

## 2. 目标架构：`lib/core/composition/`

新增一层**薄**的组装层。现有 section widget **全部原样保留**，registry 只是适配器。

```text
lib/core/composition/
  spec.dart              ComponentId / ComponentSpec / ComponentVariant / ComponentZone
  registry.dart          ComponentRegistry：tab → List<ComponentDescriptor>
  descriptor.dart        ComponentDescriptor：id / 默认变体 / 选项 schema / builder
  layout.dart            TabLayout：{ schemaVersion, List<ComponentSpec> } + 编解码
  store.dart             TabLayoutStore（KvStore 落盘，按 tab 分键）
  host.dart              ComponentHost：渲染 spec 列表 + 未知 id 容错 + 间距不变量
  data_scope.dart        DataScope：每个 tab 可访问数据的类型化声明（P7 的提示词来源）
  catalog.dart           每个 tab 的目录装配（P0 只装 today）
  customizer/            自定义 UI（P2）
  genui/                 genui 适配层，唯一允许 import genui 的地方（P7）
    catalog.dart         LuminousCatalog：AI 可用的领域组件词汇表
    controller.dart      SurfaceController 的 Riverpod 封装 + 持久化重放
    catalog_item/        各 CatalogItem 的 schema + widgetBuilder
```

核心类型（要点，不是最终签名）：

- `ComponentId` —— 稳定字符串，命名 `<tab>.<component>`，如 `today.summary`、
  `medicine.medication_overview`、`review.trend_single`。**一旦发布永不重命名**，
  改名即等于用户布局丢失。
- `ComponentSpec` —— `{ ComponentId id, String? variant, Map<String, Object?> options, ComponentZone zone, bool visible }`，freezed。
- `ComponentZone { hero, body }` —— `hero` = 首屏（滚动前可见），`body` = 首屏之下。
  这是用户说的「首屏显示什么 / 整页显示什么」的类型化表达。
- `TabLayout` —— `{ int schemaVersion, List<ComponentSpec> components }`。
  `schemaVersion` 用于将来破坏性迁移；**读不到/版本不认识时整体回退默认布局，不猜**。
- `ComponentHost` —— 按 spec 顺序取 builder 渲染；**未知 `ComponentId` 跳过并上报**，
  绝不抛异常（后端新增组件 id 时旧客户端必须能活）。

**间距不变量**（`mobile_dashboard.dart:36-41` 那条注释的通用化）：
间距由 `ComponentHost` 统一施加（组件之间一个 gap，末尾不加），
**由 host 决定，不由组件自己 Padding**。这样任何组件返回 `SizedBox.shrink()`
都不会留下空洞——原注释记录的问题在这一层被结构性消除，而不是靠每个 section 自觉。

## 3. 阶段排期

顺序原则：**先做「用户看不出变化」的重构，再做用户可见的组件，最后做 AI 与导航**。
每阶段结束即 `flutter analyze` + 相关测试 + 追加迁移日志。

### P0 组件骨架 + Today 接入（纯重构，零视觉变化）

- 落 §2 的 `lib/core/composition/` 全套骨架
- `catalog.dart` 只装 today 的 7 个既有 section：preview banner、greeting、
  primary suggestion、secondary suggestions、summary、health event、observation、
  quick actions
- `mobile_dashboard.dart` 的 `final sections = <Widget>[...]` 换成
  `ComponentHost(specs: defaultTodayLayout)`；`SizedBox.shrink()` 占位**全部删除**
- 默认布局 = 现有顺序，**像素级不变**
- **P0 是「原生组件化」的基准阶段，§0.5 四条判据逐条在此落地并测试**：
  1. descriptor 的 builder 收强类型配置（today 的 greeting / summary 各带自己的
     config 类型，先落最小形态，P2 再加变体字段）
  2. 被接入的 7 个 section 逐个去掉页面注入的回调：`onSignIn` / `onRefresh` /
     `dashboard` 这类参数改为组件自己 `ref.watch` 对应 provider、自己取 `GoRouter`。
     **这一步会改 today 的现有 widget 测试**（不再注入回调），是本阶段真正的成本所在，
     不是套一层 host
  3. `mobile_dashboard.dart` 只剩「顶栏 + 刷新指示器 + `ComponentHost`」
  4. 新增一个探索性空 id 到 registry，断言不碰 `pages/` 即可渲染出来（验证性用例，
     落地后删除）
- 验收：`test/features/today/` 现有测试全绿（含因去掉回调参数而做的装配调整）；
  新增 `host_test.dart` 覆盖「未知 id 跳过」「空组件不留间距」「顺序即渲染顺序」；
  新增 `composition_contract_test.dart` 断言判据 1/2/3（配置类型、无回调参数、
  页面无 `<Widget>[` 列表字面量）
- 估：3–5 天（若 today 的回调解耦超预期，允许 P0 拆成 P0a 骨架 + P0b 回调解耦两次提交）

### P1 用药页组件化 + 接通 10 个未调用端点

**这是全计划性价比最高的一步，零后端工作。**

核查结论：以下 operationId **已在生成的 Dart 客户端里，前端一行没调**：

```text
listMechanismPaths  listSharedTargets  listCascadePaths  listSubstituteCandidates
listShortestRoutes  listDrugActions    listEnzymeDuels   listTargetDrugs
listTransportRoutes getMedicationOverview
```

（`getSafetyTips` / `getSequences` / `getDetail` / `runRiskCheck` / `getRiskCheck` 已在用。）

- medicine 数据层新增 `relations_remote.dart` + `medication_overview_remote.dart`，
  走既有 cache-first 模式（读缓存 → 命中即返回 + 节流后台刷新；未命中拉网络写回）
- 新增组件（每个都进 medicine 目录）：
  - `medicine.medication_overview` —— 同成分重复 / 药理交汇（在说「我实际在吃什么组合」）
  - `medicine.mechanism_paths` —— 代谢通路（INHIBITS/INDUCES × SUBSTRATE_OF）
  - `medicine.shared_targets` —— 共同靶点
  - `medicine.cascade_paths` —— 四跳级联
  - `medicine.substitutes` —— 替代候选
  - `medicine.shortest_routes` —— 两药最短路径
  - `medicine.enzyme_duels` —— 酶竞争
  - `medicine.drug_actions` / `medicine.target_drugs` / `medicine.transport_routes`
- **「用药安全工作台」默认布局** = 风险检查首卡 + medication overview + 机制/靶点，
  即用户说的「把那几个用药风险检查的组件弄到首屏自己做一个用药安全工作台」
- 图查询失败是 `200 + status`（后端既有约定），组件必须渲染成「暂时无法给出机理分析」，
  **不得渲染成「无风险」**
- 验收：每个新组件至少 1 个 widget 测试（含 status 降级分支）+ 缓存写回测试
- 估：8–12 天

### P2 通用自定义 UI（显隐 / 顺序 / 变体 / 首屏分区）

- `customizer/`：每个 tab 一个编辑页，`ReorderableListView` 拖拽 + 显隐开关 +
  变体选择；**入口长在 tab 页自身的「编辑」按钮上，不做「设置 → 首页编辑」深层菜单**
- `TabLayoutStore` 落盘：键 `tabLayout.<tab>`，值即 `TabLayout` JSON。
  **键名进 `lib/core/config/pref_keys.dart`**（仓库约定 `domain.subfield.field`），
  不散落在组件层里手写字符串
- 变体机制：`ComponentDescriptor.variants`，每个变体声明自己的 options schema；
  today.summary 先落地用户明确要的那个：
  - 变体 `compact`：从 {饮水, 睡眠, 步数, 症状变化} 中**选 3 个**展示
  - 变体 `trend_single`：单维度趋势图（依赖 P3 的趋势组件抽象，可先置灰）
- **变体的落地形态受 §0.5 判据 1 约束**：变体选择结果写进 `ComponentSpec.variant`，
  进入 builder 之前必须由 descriptor 解码成**强类型选项**（如
  `sealed class SummaryVariant { Compact(left/mid/right: MetricKind) | TrendSingle(kind, range) }`），
  builder 签名收 `SummaryVariant`，不收 `Map`。
  「选 3 个指标」因此是 `Compact` 的三个字段，而不是一个自由形态的 map——
  这样填错在编译期报错，P7 的 AI 也无法构造出 schema 之外的选项组合
- 一条硬约束：**默认布局必须是好用的**。用户从不进编辑页也必须拿到完整体验；
  编辑器不给空状态（不允许把组件删到一个不剩）
- 验收：布局持久化往返测试（含 schemaVersion 不匹配回退默认）；widget 测试覆盖
  「编辑后重建仍保持顺序」
- 估：8–10 天

### P3 回顾页组件库（单维 / 多维 / 横屏 / legacy 并入）

后端 `GET /reports/dashboard` **已经**返回 `metrics` / `trends` / `findings` /
`patterns`（含 `sparkline`），无需新端点。

- 单维组件：`review.trend_single`（维度 = 饮水/睡眠/用药，range = 7d/30d/custom）
- 多维组件：`review.metric_grid`、`review.trend_multi`
- 横屏变体：同一组件新增 `variant: wide`（宽屏两列），**不做独立横屏页面**
- 把 `lib/features/review/presentation/pages/legacy_dashboard_compat.dart` +
  `widgets/views/legacy/` + `sections/legacy/` 改进后**拆成组件并入目录**，
  然后删除 legacy 路由 `/review/legacy`
- 验收：legacy 路由删除后无测试引用残留；新增横屏变体 golden 测试
- 估：10–14 天

### P4 记录页大日历（含后端新端点）

**最被低估的一步。** 用户要「每个格子显示当日单维度记录状态」，但：

- `RecordCalendarDay.markers`（`lib/features/record/domain/entities/dashboard.dart`）
  已是 `List<SemanticColor>`，但 `staticMonthDays()`
  （`lib/features/record/data/utils/record_static_data.dart:21`）**只给当天塞一个 marker**
  —— 它现在是装饰，不是数据
- `GET /daily-records` 的 query 是 `date`（必填）/`kind`/`page`/`pageSize`，
  **没有区间查询**。渲染一个月 = 30 个请求，不可接受
- 本地 Drift `daily_record_summaries` 表只缓存用户翻过的日期

`Lucent` 新增（契约变更，需 `pnpm export:openapi` + 客户端重生成）：

```text
GET /daily-records/month-overview?month=YYYY-MM&kind=<可选>
→ 200 [{ date: 'YYYY-MM-DD', kind, count, hasAlert }]
  单请求返回整月，kind 省略时返回全部 kind 的分组计数
```

- 新增组件 `record.calendar_heatmap`（大日历变体）+ `record.calendar_plain`（现有风格）
- 记录页两种风格 = 同一 tab 的两个默认布局预设（`classic` / `calendar`），
  **不做两套页面代码**
- 验收：单请求渲染整月（断言 HTTP 调用次数为 1）；空月份不崩
- 估：10–14 天（含后端）

### P5 我的页组件库 + 快捷操作库

- 把现有 `MineStatusAlertsSection` / `MineArchiveSection` / `MineAiPrivacySection` /
  `MineNotificationsReminderSection` / `MineAccountSecuritySection` 全部组件化
- 横向快捷操作条 `mine.quick_actions`：操作项来自**快捷操作库**
  （复用 record 的 `QuickEntryPreferences.customOrder` 形态，但独立的
  `mineQuickActionOrder` 键）；可选操作 = 已在别处实现的动作，不新造动作
- 验收：操作库增删后首页条同步；默认顺序 = 现有顺序
- 估：5–7 天

### P6 底部 tab 全可配置（图标 / 文本 / 顺序，均自由）

> 需求已裁定：**图标、名称、顺序三者全部可自定义，名称接受自由文本。**
> 本阶段因此不是「顺带加个设置」，而是 shell + router 的结构改造，排期按此计价。

#### P6-1 名称自由文本

- `ShellTab` 从 enum 降级为**数据**：`ShellTabDescriptor { ShellTabId id, String? customLabel,
  IconData icon }`；`ShellTabId` 是保留 enum（tab 身份不变，只是展示可配）
- 展示文案解析顺序：`customLabel`（用户输入，trim 后空则视为未设置）→
  ARB 默认（`l10n.tabToday` 等）
- **l10n 规则的显式例外**：本仓「用户可见文案必须走 ARB」这条铁律对
  **用户自己输入的字符串**不适用——与 `nickname`、`currentMedicineName`
  这类既有用户内容同性质（它们也不进 ARB，因为它们是数据不是 UI 文案）。
  `docs/reference/localization.md` 必须补这一段，**否则后来的人会把它当违规改回去**。
- 自由文本的具体约束（这些不是反对，是必须做的边界）：
  - 长度上限 **8 个字符**（中文）/ **12**（拉丁），超出截断 + 编辑页实时计数。
    底部 tab 栏是 5 等分的极窄槽位，`FBottomNavigationBar` 的 label 单行渲染，
    长文本会挤压图标或溢出（`tool/luminous_lints` 的 `non_shrinking_row_child`
    规则针对的正是这类问题）
  - 空串 / 纯空白 → 回退 ARB 默认，不允许无标签 tab
  - **不可包含 RTL/LTR 覆盖字符与零宽字符**（`\u202A-\u202E`、`\u200B-\u200F`），
    否则会把相邻 tab 的排版一起带偏
  - 编辑页给「恢复默认」按钮
- 现有测试影响已核查：`test/shell/tab_test.dart` 断言 `ShellTab.values` 顺序、
  `tab.label(l10n)` 等于 ARB 值、`testKey` 值；`test/shell/shell_page_test.dart:106-115`
  断言五个 label 文本各出现一次。这些断言在 P6 落地时**按「默认无自定义」路径保留**，
  新增「自定义后标签变化」的独立用例，不削弱既有覆盖。

#### P6-2 图标自由选择

已经有现成设施，**不新造**：

- `showAppIconPicker`（`lib/core/widgets/common/dialog/icon_picker_sheet.dart`）
  已是可复用的图标选择 sheet，支持 `currentIcon` 与自定义 `categories`
- `LucideIconBridge`（`lib/core/design/tokens/lucide_icon_bridge.dart`）已提供
  **2030 个** Lucide 图标的 `resolve(kebab-name)` / `nameOf(icon)` 双向映射

- **持久化形式：存 kebab-case 名称字符串，不存 `codePoint`**。
  `IconData.codePoint` 随 forui_lucide 版本升级会漂移，存名称才能在升级后仍然解析；
  且 `LucideIconBridge.nameOf/resolve` 就是为此设计的。
- 解析失败（用户选的图标在新版本被移除）回退到该 tab 的默认图标，
  **不崩、不留空图标**
- 默认值仍是 `SemanticIcons.tab*`（`tab.dart:6-10`）
- 图标选择默认全量 2030 个可用（用户要求「自由」）；编辑页提供
  「导航类精选」分类作为快捷入口，但不作为限制

#### P6-3 顺序自由调整

- 现状：`StatefulShellRoute` 的 5 个 branch 在 `lib/app/router.dart:267-321`
  按位置硬编码；`branch.dart:19` 的 `indexForTab` 直接取 `tab.index`；
  `branch.dart:15` 的 `isVisible` 依赖 `index < ShellTab.values.length`
- 改法：**branch 位置固定（编译期 5 个），展示顺序与 `goBranch` 索引做显式映射**
  - `ShellBranch` 继续按位置管身份（今日/记录/用药/回顾/我的位置不动）
  - 新增 `List<ShellTabId> displayOrder`，`FBottomNavigationBar.index` 用
    **展示位置**，`onChange` 经 `displayOrder[index].branchIndex` 转到真实 branch
  - `FSidebar`（桌面）走同一份 `displayOrder`
- `ShellTabBranchContainer`（`tab_branch_container.dart`）的切页动画依赖
  `currentIndex` 比较，改为比较 **branch 身份**而非展示位置
- 深链不受影响：路由 path 与 branch 绑定，与展示顺序无关

- 验收：
  - 改顺序后 `shell-tab-*` 测试键仍稳定（key 绑身份不绑位置）
  - 五种排列下点击每个 tab 都进对的 branch（参数化测试，至少覆盖
    「今日↔用药互换」这个用户明确提到的场景）
  - 深链 `go(/review)` 后高亮的是回顾 tab **而不是第 4 个位置**
  - 桌面 sidebar 与移动底栏顺序一致
  - 自定义名称/图标重启后保持；恢复默认后完全回到初始
- 估：10–14 天（含上述测试返工）

#### P6-4 持久化

键 `shellTabConfig`，值 `{ schemaVersion, List<ShellTabConfigEntry> }`，
`ShellTabConfigEntry { ShellTabId id, String? customLabel, String? iconName }`，
顺序即数组顺序。与 P2 的 `TabLayoutStore` 共用同一套 KV 形态，
**读不到或版本不认识时整体回退默认**（与布局保持一致口径）。

### P7 生成式 UI：AI 真正生成布局（genui 全量接入）

> 需求已裁定：**生成布局，充分发挥 genui。** 原「只生成受限 spec」的保守方案作废。
>
> 这不是妥协版本，是把 genui 当**渲染引擎**用：AI 输出 A2UI 组件树，`SurfaceController`
> 解析、`Surface` 渲染。用户说「把这个组件设置成每日的饮水变化」，AI 可以自己决定用
> 折线还是柱状、标题怎么写、要不要配一行统计——这才是生成式 UI 的意义。

**唯一允许 import genui 的目录：`lib/core/composition/genui/`。**
理由：`genui` 仍是 0.10.4（0.x），API 会破坏性变更；封闭单目录让升级改动面可控。
这是工程隔离，不是功能限制。

#### 7.0 与「原生组件化」的边界（§0.5 的推论）

genui 是**渲染引擎**，不是组件的定义者。两条不能混：

- A2UI 树里的节点只能落在 `LuminousCatalog` 已注册的 `CatalogItem` 上；
  **不允许**通过 A2UI 定义一个「新组件」再保存下来复用——生成结果是一次性的布局产物，
  不是组件类型的来源。
- 领域 `CatalogItem` 的 `widgetBuilder` 内部直接复用 §2 `ComponentRegistry` 里的组件
  Widget，不重新实现一遍。**同一个组件在「用户排的布局」和「AI 排的布局」里是同一份代码**，
  差别只在谁决定放哪儿。这条是 P7 与 P0–P5 之间唯一需要的桥，也是防止两套组件库分叉的保证。
- 生成式组件（`{tab}.generative`）本身也是一个普通组件：它只负责「把 surface 渲染出来」，
  不接管整个页面的布局。

#### 7.1 genui 的实际形态（已读源码，不是猜的）

| 概念 | 事实 | 对我们的意义 |
| --- | --- | --- |
| `Catalog(items, functions, systemPromptFragments)` | AI 可用的**词汇表**；`systemPromptFragments` 会拼进系统提示词 | 这是**唯一**的安全边界 |
| `CatalogItem(name, dataSchema, widgetBuilder)` | 每项 = 一个 AI 可调用的组件；schema 用 `json_schema_builder` 的 `S(...)` 定义 | 我们自己写组件，AI 只能从中挑 |
| `SurfaceController(catalogs)` | 管理 surface 生命周期，`surfaceUpdates` 是 `Stream<SurfaceUpdate>` | 与 Riverpod 的桥接点在这里 |
| `Surface(surfaceContext)` | 渲染一棵生成的组件树，`defaultBuilder` 处理无定义 | 放进 `ComponentHost` 当普通 widget 用 |
| `FallbackWidget(error, onRetry, isLoading)` | 官方错误/加载态 | 直接用它，不手写 |
| `DataModel`（`preact_signals`） | genui 内部状态存储，widget 绑定到数据路径 | **只读注入，不双向同步** |

#### 7.2 安全边界：从「校验 spec」变成「catalog 白名单」

生成布局后，AI 的输出不再是我们能逐字段校验的扁平 spec，而是一棵组件树。
**约束点在 catalog：AI 只能使用我们注册的 `CatalogItem`，不允许出现 catalog 之外的
组件名**——`SurfaceController` 内部即按 catalog 校验，未知组件走 `FallbackWidget`。

因此本仓必须注册的 catalog 是**领域组件**，不是 genui 自带的 `CoreCatalogItems`：

- **保留** `CoreCatalogItems` 中的纯展示项（`Text` / `Column` / `Row` / `Card` /
  `Divider` / `List` / `Image` / `Icon`）——布局骨架需要它们
- **剔除** 与本产品无关或有害的项：`AudioPlayer` / `Video`（音视频权限，
  且医疗数据场景无正当用途）、`TextField` / `Slider` / `CheckBox` / `DateTimeInput`
  （用户输入一律走既有表单，不经过 AI）、`Modal` / `Tabs`（导航归 GoRouter）、
  `Button`（**去掉一切可写动作**）
- **新增领域项**（本仓 `CatalogItem`）：
  - `LuminousMetricCard` —— 单维指标卡（值/单位/状态/delta），schema 只收
    `{ kind, value, unit, status, delta?, sparkline? }`
  - `LuminousTrendChart` —— 趋势折线/柱状，收 `{ kind, range, values, unit }`
  - `LuminousMetricGrid` —— 多维小卡网格
  - `LuminousCalendarHeatmap` —— 月历热力（P4 产出）
  - `LuminousFinding` —— 后端 findings 的只读呈现，**文案字段直接透传后端**，
    AI 不能改写
- **数据注入方式**：领域 catalog item 的 `dataSchema` **不接受数据值本身**，
  只接受**引用键**（如 `{ kind: 'water', range: '7d' }`）；`widgetBuilder` 内部从
  **Riverpod provider** 取真实数据。这样 AI 无法凭空捏造数值——它只能选
  「展示哪个维度、什么区间、什么形式」。这是本方案的关键设计：
  **AI 编排布局与表现形式，数据的真值永远来自 provider。**

`DataModel` 只用于 genui 自己的 UI 状态（展开/选中），**业务数据一律不写入**。

#### 7.3 落地

- `lib/core/composition/genui/catalog.dart` —— `LuminousCatalog`（上面那套 item 集合）
- `lib/core/composition/genui/controller.dart` —— `SurfaceController` 的 Riverpod 封装，
  `surfaceUpdates` → `StreamProvider`；**单例存活**，避免每次重建丢失 surface
- `lib/core/composition/genui/catalog_item/` —— 各 `CatalogItem` 的 schema + builder。
  **builder 只做「schema 键 → 强类型 config」的解码，然后转调 §2 registry 里的组件**；
  `catalog_item/` 下不出现任何布局代码、样式代码或数据请求代码
  （这是 §0.5 判据 1 在 P7 的落地形态，也是保证 genui 升级时改动面可控的实质手段）
- `{tab}.generative` 组件 —— 每 tab 一个，作为 `ComponentHost` 的普通组件；
  内部渲染 `Surface(surfaceContext: ...)`，无定义时用 `FallbackWidget`
- **事件驱动 + 手动刷新两条路都要**：AI 生成的新 surface 经 `surfaceUpdates` 流
  自动替换；用户也可在组件上手动「重新生成」
- 生成结果**持久化**：把最后一次的 A2UI 消息序列存 `KvStore`
  （键 `genui.<tab>.surface`，同样登记进 `pref_keys.dart`），重启后重放到
  `SurfaceController`，不必重新请求——否则每次冷启动都要烧一次 LLM 调用
- **降级口径与 §0.5.2 一致**：surface 渲染失败 → `FallbackWidget` + 保留上一份；
  **绝不留白屏，也绝不把「数据缺失」渲染成「无风险」**

`Lucent` 新增：

```text
POST /ui/generate-layout
  body: { tab, dataScope, catalogSchema, prompt, currentLayout? }
  → SSE 流：A2UI message chunks（createSurface / updateComponents / updateDataModel）
  LLM 输出经 a2ui_core 解析；解析失败则本次生成失败，UI 保留上一份 surface
```

- **必须 SSE**：genui 的 `A2uiTransportAdapter` 就是按 chunk 流设计的，
  一次性返回会失去渐进渲染，且大布局响应容易超时
- `catalogSchema` 由客户端从 `LuminousCatalog` 生成（`Catalog.fullSchema`），
  随请求上行 —— 后端不硬编码组件词汇表，**新增组件只改客户端**

#### 7.4 红线（保留，但不阻碍生成布局）

- 生成内容**不得含未经审核的医学结论文案**。落地手段：领域 `CatalogItem` 的文案
  区域只接受**引用键**而非自由文本；`CoreCatalogItems` 的 `Text` 允许自由文本，
  但**仅限标题/说明类**，系统提示词中明确禁止生成诊断/用药建议。
  P7 验收必须包含「诱导生成医疗建议」的对抗性用例。
- AI 生成的**可写动作一律不存在**（catalog 无 `Button`）——写操作只能走既有页面表单
  与 proposal 确认门。
- surface 渲染失败 → `FallbackWidget` + 保留上一份，**绝不白屏**。

- 验收：
  - catalog 包含项与排除项的断言测试（防止后续有人把 `Button` 加回来）
  - 完整链路测试（mock SSE 后端）：prompt → A2UI chunks → surface 渲染 → 截图/golden
  - 冷启动重放持久化 surface 不重新请求
  - 对抗性用例：诱导生成医疗建议 / 诱导生成可写按钮 → 均被挡住
  - 未知 `ComponentId` 不崩（genui 层天然满足，但仍要断言）
- 估：15–20 天（含后端 SSE 与对抗性测试；比原方案多 5–8 天，因为是真布局生成）

### P8 轻量 AI 聊天组件

**不新造能力**：`lib/features/assistant/` 已有 SSE 多轮对话 + proposal 确认门控，
`plans/2026-09-02-agentic-proactive-evolution.md` 的 **P1-1「assistant 能力组件化」
尚未开工**——本阶段就是它的落地，两者合并执行，不再单独立项。

- 抽出可复用会话组件（`assistant.chat`），today 首屏可挂
- 写动作仍走既有 proposal 确认门，不提供绕过门控的直达写
- 验收：today 内嵌对话能与独立页会话共存；proposal 门控行为不变
- 估：5–7 天（承接既有计划，不重复计价）

## 4. 依赖关系

```text
P0 ──┬─→ P1
     ├─→ P2 ──┬─→ P3
     │        ├─→ P4（另需 Lucent month-overview 端点）
     │        ├─→ P5
     │        └─→ P6（另需 shell/router 改造）
     └─→ P7（另需 Lucent generate-layout SSE 端点）
P1, P2 ──→ P8（复用 assistant）
```

可并行：P3 / P4 / P5 在 P2 之后彼此独立，可按人分工写不同目录。
P6 与 P3/P4/P5 无耦合，理论上可并行——但它动 `shell/` + `router.dart` +
`app.dart` 装配，**与任何其它阶段的文件冲突面都大**，建议独占一个时间窗做。

不可跨越：P7 必须等 P2（`ComponentHost` 要能承载一个 surface 组件）
与 P4（`LuminousCalendarHeatmap` 依赖月概览数据）。

**原生组件化视角**（§0.5）：P0 是唯一集中落判据 1–3 的阶段；此后每个阶段
（含 P1 新增的 10 个 medicine 组件、P3/P4/P5 的每批组件、P7 的每个 `CatalogItem`）
都必须重新跑一遍 §0.5 的四条判据，**新增组件不改任何 `pages/` 文件是硬验收项**。

## 5. 风险与红线

| 风险 | 应对 |
| --- | --- |
| 用户配置把页面搞乱后无法恢复 | 每个编辑页都有「恢复默认」；`TabLayout` / `shellTabConfig` 读不到或不认识即整体回退默认 |
| 默认布局不好用，用户被迫配置 | 每个 tab 的默认布局必须独立可用；编辑器不提供「全空」状态 |
| 配置入口过深，用户找不到 | 入口只长在 tab 页自身，不做「设置 → 首页编辑」 |
| `genui` 0.x 破坏性升级 | 全部 genui 引用封闭在 `lib/core/composition/genui/` |
| 新增 13 个音视频包 | 记录在案；发布前核对安装包体积与权限声明；catalog 已剔除音视频项 |
| **AI 生成布局夹带医学结论/可写动作** | catalog **不含** `Button` / 表单控件；领域 item 文案只收引用键；系统提示词禁止诊断与用药建议；P7 必须有对抗性用例 |
| **AI 生成布局后数据失真** | 领域 `CatalogItem` 的 schema 只收**维度/区间/形式**这类引用键，真值由 `widgetBuilder` 从 provider 读；AI 无法凭空造数值 |
| 生成结果丢失 / 每次冷启动重烧 LLM | A2UI 消息序列持久化到 `KvStore`，冷启动重放 |
| 组件 id 重命名导致用户布局丢失 | id 一经发布永不改名；下架组件走 `visible: false` 而非删除 |
| 后端新增组件让旧客户端崩 | `ComponentHost` 跳过未知 id；genui 侧走 `FallbackWidget` |
| **tab 自由文本溢出/被恶意字符带偏排版** | 长度上限（中文 8 / 拉丁 12）、禁 RTL/零宽字符、空串回退默认 |
| tab 改名后文档/引导图对不上 | 接受（这是自由文本的必然代价）；`docs/reference/localization.md` 记录该例外 |
| tab 换序导致测试与深链错乱 | 测试键绑 tab 身份不绑位置；深链绑路由 path；参数化测试覆盖五种排列 |
| 大日历 30 个请求 | 必须先用 P4 的月概览端点，不接受逐日请求 |
| **组件层退化成第二套 UI DSL / 弱类型 options** | §0.5 判据 1/2 作为每阶段验收项；`options` 只在持久化边界存在，进 builder 前必须解码成强类型 config，解码失败按未知 id 处理 |
| **组件库里出现两个同构实现（用户布局一套、AI 布局一套）** | P7.0：`CatalogItem` builder 必须转调 §2 registry 的组件，禁止在 `genui/catalog_item/` 里重写渲染 |
| **组件带页面回调，导致无法跨 tab 复用** | §0.5 判据 2：组件不进 `onXxx` 参数，数据取 provider、导航取 `GoRouter` |
| **页面级 `<Widget>[` 列表悄悄长回来** | §0.5 判据 3 由 `composition_contract_test.dart` 守（P0 建立，此后每阶段保留） |

## 6. 执行注意

- l10n 铁律：改 `lib/l10n/src/` 片段 → `dart scripts/l10n/arb_tools.dart merge`
  → `flutter gen-l10n`，**不碰 `app_*.arb`**
- 每个组件新增用户可见文案，走对应 feature 的 ARB 片段；**组件标题也走 ARB**，
  不从 spec / options 里读字符串（唯一例外是 P6-1 的 tab 自由文本）
- 每个阶段结束追加 `docs/logs/migration-log/YYYY-MM-DD.md`（只追加不覆盖）
- 契约变更后：`Lucent` 跑 `pnpm export:openapi`，`Luminous` 跑
  `dart run scripts/contract/bootstrap.dart`
- 窄命令迭代（`flutter analyze` + 单个测试文件），收尾跑
  `dart run scripts/workflows/daily.dart`
- **§0.5 四条判据是每个阶段的验收项**，不是 P0 的一次性任务。特别是
  「新增组件不需要改任何 `pages/` 文件」——做不到说明组件化没成立，
  要停下来修装配层，而不是在页面里再补一个 `if`
- 完成项从本文件**直接删除**，不留 `✅` / `DONE` 标记
