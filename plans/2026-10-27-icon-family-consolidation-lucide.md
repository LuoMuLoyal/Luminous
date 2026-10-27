---
status: active
owner: frontend
updated: 2026-10-27
---

# 图标体系收敛：iconMind 退场，统一 Lucide

Created: 2026-10-27

> 状态：**P0 / P1 / 去重已完成**（见 `docs/logs/migration-log/2026-10-27.md`）；
> **P2 尺寸刻度收敛、P3 衬底清理、P4 混合族清理未开工**。

## 执行进度

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| P0 迁移 5 个语义位 | **已完成** | commit `adde9d416` |
| P1 删除 iconMind | **已完成** | commit `98698f816`（112 文件 / 34.1 KB + 注册表 + pubspec + barrel） |
| 去重（§4） | **已完成** | commit `1329ed0ff`；115 个语义名 → 115 个互异字形，跨族同形 0 组 |
| P2 尺寸刻度收敛 | 未开工 | `Icon(size: Spacing.*)` 63 处 + 刻度外字面量 |
| P3 衬底清理 | 未开工 | `SoftIcon` 44px 容器、23 处 `FAvatar` 托盘 |
| P4 混合图标族清理 | 未开工 | 剩余 5 个 `FPhosphorIcons`（已拆开同形冲突，仅剩族混合问题） |
| 防复发 lint 规则 | **按指示暂缓** | 用户明确要求先不做 lint 规则 |

### 去重实际口径（比 §4 更严）

用户明确要求：**严禁同一页面出现两个含义不同但图标相同的地方，不允许复用**。
因此原 §4 中「跨语境可复用、保留」的组**全部拆开**，换独立字形；并额外发现
**Lucide/Phosphor 跨族同形**（如 `circleCheck` vs `checkCircle`）也属重复，一并处理。
最终校验：全局唯一（含跨族归一化）+ 逐文件碰撞检测，两者均为 0。

- 范围：`Luminous`（Flutter 客户端）
- 目标：移除 iconMind 资产与 `SemanticIconSvg` 注册表，全部图标回到 Lucide 单一族；同时按大厂规范收敛尺寸刻度、清理既有重复语义。

## 0. 背景与结论

用户反馈「iconMind 图标大小不一致、每个图标都有衬底、效果不好」，并要求**弃用 iconMind，统一 Lucide**。
经实测，前两条判断成立，且根因已定位：

**（1）iconMind 资产内部几何纪律差，导致「同样 size 画出来不一样大」**

对 `assets/icon/iconmind/` 全部 111 个 SVG 计算墨迹包围盒（图形实际占用范围，而非 viewBox）：

| 图标 | 墨迹（24 框内） | 占框比 |
| --- | --- | --- |
| `power` | 8.46 × 7.06 | 35% |
| `idea-bulb` | 8.00 × 9.00 | 38% |
| `agent` | 8.46 × 9.06 | 38% |
| `tool-calling` | 12.00 × 16.00 | 67% |
| `vector-database` | 16.00 × 16.00 | 67% |
| `brain` | 19.00 × 16.00 | 79% |
| `llm` | 20.00 × 16.00 | 83% |

极差 **8.46 → 20.00，2.36 倍**。对照 Lucide（`forui_lucide` v0.26.0，upem=1000）实测 15 个在用的字形，墨迹 13.97–22.03，极差 **1.58 倍**。

直接后果：`capabilities_panel.dart` 三行摘要与工具行全部写 `size: 14`，实际墨迹分别为
`aiEntry` 11.7px、`aiMemory` 10.5px、`aiKnowledge` 9.3px、`aiToolCalling` 9.3px——**同一尺寸参数差 26%**。

`agent.svg` 另有定位缺陷：其路径只覆盖 y=2.94~12.00，**底部 12 个单位全空、图形顶在框上半部**；
而它正是 `assistant_greeting.dart` 里 `size: 40` 的 hero 图标，实际只画出 15.1px 墨迹。

**（2）「衬底」来自两个组件，与 iconMind 无关**

- `SoftIcon`（`lib/core/widgets/common/control/soft_icon.dart`）：默认 `size: 44.0` 圆角方块内装
  `IconSizeTokens.lg`（24px）字形，**字形仅占 55%**。用于 mine 的归档行、通知行、状态卡。
- `FAvatar` 被当图标托盘使用：23 处，容器取 `Spacing.xl4`(32)/`IconSizeTokens.xl3`(48)/`Spacing.xl2`(20) 等。

即：**只换图标族不会消除衬底**，衬底清理必须单列（见 §4）。

**（3）iconMind 资产本身规格是干净的**

111 个文件全部 `viewBox="0 0 24 24"` / `stroke-width="2"` / `fill="none"` / `stroke="currentColor"`，
无例外，可被 `flutter_svg` 正确染色，MIT 可商用。问题在**几何纪律与词表定位**（面向 AI 概念词汇，
`reranker`/`chunk-overlap`/`kv-cache` 之类占多数），不在许可或渲染。

### 为什么统一 Lucide 是对的

- 全 app 已是 Lucide 主导：`SemanticIcons` 122 个语义位中 **111 个是 `FLucideIcons`**、11 个是 `FPhosphorIcons`。
- 现有 iconMind 触点极小：**5 个语义位、6 个调用点、2 个文件**（见 §2）。
- 迁移后可删除整个 SVG 资产目录（34.1 KB / 112 文件）、`flutter_svg` 依赖（若 `oauth_panels.dart` 也无需保留）、
  以及一套并行注册表。

### 大厂规范依据（外部调研，供本计划取值）

来源：[Ant Design 图标规范](https://raw.githubusercontent.com/ant-design/ant-design/master/docs/spec/icon.zh-CN.md)、
[Clarity Design（阿里/Teambition）图标规范](https://clarity.design/documentation/iconography)、
[Material Icons 样式页](https://m1.material.io/style/icons.html)、
[IBM Carbon Icons](https://www.carbondesignsystem.com/building-blocks/foundations/icons/guidelines)、
[Atlassian RFC-81](https://community.developer.atlassian.com/t/rfc-81-upcoming-changes-to-iconography/87753)、
[Apple HIG SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)。
完整报告见 `icon-design-systems-research.md`（工作区根，非仓库文档）。

与本计划直接相关的条款：

| 规范 | 条款 |
| --- | --- |
| Ant Design | 「弯曲的线条会比竖直的线条看起来细，因此圆形的外边框会做 4px 微调」——**光学补偿是明文允许的**；图标应随文字缩放，「与 12pt 文字并排的图标为 12px、间距 8px」 |
| Clarity Design（阿里系） | S 16px 框 / 1px 描边 / 14px 安全区 / 12pt 文字；M 20px / 1.2px / 16px / 14pt；L 24px / 1.5px / 20px / 16pt。**单色，图标颜色=文字颜色，垂直居中** |
| Material | 系统图标 24dp、密集 20dp；**24dp 框内 20dp 活动区（四周 4dp 内边距）**；描边 2dp 固定；24dp 图标配 48dp 触控区 |
| Carbon | 16/20/24/32 四档，默认 16；「**Be sure icon size is consistent throughout your product**」「**Don't alter the icon-text size ratio**」；图标永远单色、对比度 ≥4.5:1；44px 触控区靠**内边距**达成 |
| Atlassian | 尺寸固定 12/16，**移除 size prop**，因为缩放「led to inconsistencies in sizes, stroke widths, and padding」；`spacing` 默认 `none` 且为推荐值 |
| Apple HIG | 符号与文字按 cap height 光学对齐；**负边距**做水平光学对齐 |

**关于「衬底」的诚实说明**：调研未能找到任何大厂文档里「禁止在图标后加装饰性容器」的明文原句
（m3.material.io / atlassian.design / fluent2.microsoft.design 均为 SPA 壳，抓不到正文）。
可确证的是一致的功能性取向：**裸字形是默认**（M3：「Standard icon buttons do not have a background or outline,
and have the lowest emphasis」），容器只在四种情形下成立——触控目标、状态承载面、刻意强调层级、固定列表/导航前导槽位。
Carbon 明确「icons themselves do not have interaction states, **only their backgrounds do**」。

## 1. 目标状态

1. `assets/icon/iconmind/` 及其 LICENSE 删除；`pubspec.yaml` 移除该 asset 声明。
2. `lib/core/design/tokens/semantic_icon_svg.dart` 删除；`SemanticIconSvg` 不再存在。
3. 原 5 个 iconMind 语义位改由 `SemanticIcons`（Lucide）承担，**且不与既有语义位重复**。
4. `SemanticIcons` 成为全 app 唯一图标入口；业务代码不直接引用 `FLucideIcons`（`icon_picker_sheet.dart` 除外，见 §5）。
5. 尺寸取值收敛到 `IconSizeTokens` 的离散档位；`Icon(size: Spacing.*)` 清零。
6. `SoftIcon` / `FAvatar` 的装饰性衬底按 §4 收敛。

## 2. 迁移映射（去重的核心）

现状：`SemanticIconSvg` 声明 34 个语义位，**实际只用到 5 个**（其余 29 个是死代码）。

| 现用（iconMind） | 调用点 | 现状冲突 | 迁移后 |
| --- | --- | --- | --- |
| `SemanticIconSvg.aiEntry` (`llm`) | `capabilities_panel.dart:100` | ⚠️ `SemanticIcons.aiEntry` **已存在** = `sparkles` | 删除 SVG 版，调用点改用 `SemanticIcons.aiEntry` |
| `SemanticIconSvg.aiGenerated` (`agent`) | `assistant_greeting.dart:33` | ⚠️ `SemanticIcons.aiGenerated` **已存在** = `bot` | 删除 SVG 版，调用点改用 `SemanticIcons.aiGenerated` |
| `SemanticIconSvg.aiMemory` (`memory`) | `capabilities_panel.dart:105` | 无 | 新增 `SemanticIcons.aiMemory = FLucideIcons.memoryStick` |
| `SemanticIconSvg.aiKnowledge` (`vector-database`) | `capabilities_panel.dart:110` | 无 | 新增 `SemanticIcons.aiKnowledge = FLucideIcons.database` |
| `SemanticIconSvg.aiToolCalling` (`tool-calling`) | `capabilities_panel.dart:235` | 无 | 新增 `SemanticIcons.aiToolCalling = FLucideIcons.wrench` |

**已核实**：`memory-stick` / `database` / `wrench` 三个 Lucide 名在 `LucideIconBridge` 中均存在，
且 `SemanticIcons` 当前**未**使用它们，新增不会引入新重复。

### 命名取舍说明

- `aiEntry` / `aiGenerated` 两个名字**两边都有**，是这次迁移最需要留意的重复点。规则是：
  **保留 `SemanticIcons` 的既有定义，删除 `SemanticIconSvg` 的同名位**，不新增、不改名。
- `aiMemory` / `aiKnowledge` / `aiToolCalling` 沿用原语义名，仅换实现源，调用点名字不变。
- **不要**为 iconMind 的 28 个未使用语义位建 Lucide 对应项——它们是死代码，随文件一起删除。

## 3. 执行步骤

### P0 — 迁移 5 个语义位（唯一有行为影响的一步）

- `lib/core/design/tokens/semantic_icons.dart`：在 AI 段落新增 `aiMemory` / `aiKnowledge` / `aiToolCalling` 三项。
- `lib/features/assistant/presentation/widgets/dialogs/capabilities_panel.dart`：
  3 处 `_SummaryRow(icon: ...)` 与 1 处工具行前缀改为 `Icon(SemanticIcons.xxx, size: ...)`。
  注意 `_SummaryRow.icon` 与工具行的类型：原为 `Widget`（SVG），改后可直接传 `IconData`，
  需同步调整参数类型与 `const` 性。
- `lib/features/assistant/presentation/widgets/sections/assistant_greeting.dart`：
  `SemanticIconSvg.aiGenerated(size: 40, color: colors.primary)` → `Icon(SemanticIcons.aiGenerated, size: 40, color: colors.primary)`。
- 验收：`assistant_greeting.dart` 的 hero 图标由「顶部锚定的 15.1px 墨迹」变为**居中且接近 40px 的 `bot` 字形**，
  这是本次最直观的视觉修复。

### P1 — 删除 iconMind

- 删除 `assets/icon/iconmind/`（含 `LICENSE`，112 文件 / 34.1 KB）。
- `pubspec.yaml:204` 移除 `- assets/icon/iconmind/`。
- 删除 `lib/core/design/tokens/semantic_icon_svg.dart`。
- 确认 `flutter_svg` 是否仍被需要：`lib/features/auth/presentation/widgets/shared/oauth_panels.dart` 仍在用
  `SvgPicture`，故 **`flutter_svg` 依赖保留**；但 `lib/oss_licenses.dart` 中若含 iconMind 条目需同步清理。
- 验收：`grep -rn "iconmind\|SemanticIconSvg" lib test assets pubspec.yaml` 零命中。

### P2 — 尺寸刻度收敛（去重的另一半）

现状问题：

- `Spacing.xl`（**间距** token，值 16）被当**图标尺寸**用了 **63 处**（`Icon(icon, size: Spacing.xl)`）。
  `Spacing` 与 `IconSizeTokens` 是两套独立刻度（16 vs 20、14 vs 16），混用导致同一位置换人写就是另一个尺寸。
- 刻度外字面量：`18`（21 处）、`14`（14 处）、`19`、`22`、`40`、`52` 等。
- `IconSizeTokens` 八档中 `xs` 全 app 仅用 1 次、`xl` 仅 1 次——刻度设计合理但基本未被执行。

动作：

1. 把 `Icon(size: Spacing.*)` 的 63 处改为 `IconSizeTokens.*`（`Spacing.xl`→`IconSizeTokens.md`，
   `Spacing.lg`→`IconSizeTokens.sm`，逐处按语义复核，不做无脑等值替换）。
2. 刻度外字面量收编：`18`→`sm`(16) 或 `md`(20)；`14`→`sm`；`19`/`22`→就近档位。
3. 在 `tool/luminous_lints` 增补一条规则 `no_spacing_as_icon_size`，禁止 `Icon(size: Spacing.*)`，
   否则会复发（该项目已有八条自定义规则的现成框架，默认 warn 观察模式）。
4. 尺寸档位维持 `IconSizeTokens` 现状（12/16/20/24/28/32/48/64），不新增档位；
   对齐 Clarity/Material 的取值习惯后，实际主力档位应落在 **16 / 20 / 24**。

### P3 — 衬底收敛

**注意：这一项与 iconMind 无关，不随 P0/P1 自动消失。**

- `SoftIcon`：默认 `size: 44` + 24px 字形 = 55% 填充率，是最典型的装饰性衬底。
  按 §大厂依据，容器只在「触控目标 / 状态面 / 强调层级 / 固定前导槽」成立。
  列表行（`archive_row.dart`、`notifications_reminders.dart`、`status_alerts.dart`）建议改裸图标；
  若要保留容器，把容器降到 32 并让字形占比 ≥70%。
- `FAvatar` 作图标托盘的 23 处：逐处判断是「头像」还是「图标托盘」，后者改裸图标或统一到
  `iconSize + 16` 的规则（24px 字形 → 40px 圆形容器，对齐 Material 的 40/24）。
- 验收：`mine` 的归档/通知/状态行不再出现 44px 圆角色块内嵌 24px 字形。

### P4 — 混合图标族清理（可选，独立评估）

`SemanticIcons` 中 11 个 `FPhosphorIcons` 与 111 个 `FLucideIcons` 混排，违反 Carbon「单一族」与
Ant Design「同风格细节/透视/描边一致」。其中 `statusInfoCircle = FPhosphorIcons.info` 与
`statusInfo = FLucideIcons.info` 是**同一语义的两个图标**，属既有重复，建议合并。

## 4. 既有重复清单（本计划一并处理）

`SemanticIcons` 内部已存在「不同语义名 → 同一 Lucide 图标」13 组，本次至少处理明确冗余的：

| Lucide 图标 | 重复的语义名 | 处置 |
| --- | --- | --- |
| `info` | `statusInfo`、`statusInfoCircle` | 合并（另见 P4 的跨族重复） |
| `lightbulb` | `aiTip`、`reportInsight` | 保留 `aiTip`；`reportInsight` 改用 `sparkles` 或独立图标 |
| `circleCheck` | `statusSuccess`、`reportReady` | 语义确实不同（状态 vs 报告就绪），**保留**，但需在注释中说明 |
| `ban` | `statusSkipped`、`doseSkipped` | 同上，保留 |
| `clock3` | `statusPending`、`dosePending` | 同上，保留 |
| `coffee` | `recordCaffeine`、`safetyCaffeine` | 同上，保留 |
| `zap` | `safetyAllergy`、`profileAllergy` | 同上，保留 |
| `pillBottle` | `tabMedicine`、`medicineBottle` | 同上，保留 |
| `calendarClock` | `dosePlanned`、`safetyTiming` | 同上，保留 |
| `fileQuestion` | `statusUnknown`、`reportInsufficient` | 同上，保留 |
| `heartPulse` | `safetyPregnancy`、`profileCondition` | 同上，保留 |
| `arrowDownToLine` | `actionExport`、`reportExport` | 同上，保留 |
| `briefcaseMedical` | `medicineKit`、`profileMedicine` | 同上，保留 |

判定原则：**同一图标承载不同语境（状态 vs 领域）是允许的**，真正要消除的是同一语境下的两个名字
（`statusInfo`/`statusInfoCircle`）。上表「保留」项需在 `semantic_icons.dart` 中以注释显式声明
「有意复用」，避免后续被当成缺陷反复「修复」。

## 5. 边界与不做的事

- **不动** `icon_picker_sheet.dart` 的 47 处 `FLucideIcons` 直引：它是用户可选图标的调色板，
  按设计就该直接枚举 Lucide，属合法例外（该文件返回 `IconData` 供用户选择）。
- **不动** 数据驱动的 `IconData` 映射（如 `SuggestionIconMapping`）：后端字符串/枚举 → 图标，
  形态必须保持 `IconData`。
- **不新增** iconMind 死代码的 Lucide 对应项（29 个未使用语义位随文件删除）。
- **不重构** `SoftIcon` 的调用方业务逻辑，只调容器尺寸与字形占比。
- **不引入**新图标依赖或新资产。

## 6. 验收

- `flutter analyze` 无新增问题。
- `flutter test` 全绿；assistant 相关 widget 测试若断言了 SVG 类型需同步更新。
- `grep -rn "iconmind\|SemanticIconSvg\|SvgPicture.asset" lib test` 零命中
  （`oauth_panels.dart` 的 `SvgPicture` 除外）。
- `Icon(size: Spacing.` 零命中。
- 真机/模拟器目视：assistant 欢迎区 hero 图标居中且尺寸正常；
  `capabilities_panel` 四行前缀图标**视觉等大**（这是本次修复的直接验收点）。
- 收尾跑 `dart run scripts/workflows/daily.dart`。

## 7. 文档同步

- `docs/reference/design-system.md`：删除 `SemanticIconSvg` 条目，改写「AI 语义图标用 iconMind SVG」的分工描述为
  「全部图标走 `SemanticIcons`（Lucide）」；补充尺寸档位与「禁止用 `Spacing` 当图标尺寸」的约定。
- `docs/explanation/iconmind-assistant-icons.md`：**归档到 `docs/archive/`**（该文档记录的是已废弃的技术选型，
  且含与现状相反的结论；不要直接删除，历史决策有价值）。
- `docs/logs/migration-log/2026-10-27.md`：追加本次变更条目。
- `plans/README.md`：本计划执行完毕后删除本文件，并在「已执行完毕、文件已删的计划」段追加记录。

## 8. 风险

| 风险 | 评估 |
| --- | --- |
| `aiEntry`/`aiGenerated` 同名重复导致误改 | 中。两边同名不同实现，必须删 SVG 侧、留 Lucide 侧；§2 已写明规则 |
| `_SummaryRow.icon` 类型从 `Widget` 改 `IconData` 波及调用点 | 低。仅 `capabilities_panel.dart` 一个文件 |
| P2 的 63 处机械替换误伤语义 | 中。要求逐处按语义复核，不做等值无脑替换；先窄范围验证再全量 |
| 衬底清理（P3）影响面最大 | 高。涉及 mine 三处 section 与 23 处 `FAvatar`；建议独立提交、独立验证 |
| `flutter_svg` 是否可移除 | 低。`oauth_panels.dart` 仍在用，**保留依赖** |
