---
status: active
owner: frontend
updated: 2026-11-01
---

# Luminous 桌面端视觉方向改造（参照 Lumine）

> 目标：把 Flutter 桌面端从「手机 App 放大到桌面上」改成真正的桌面工作台视觉。
> 参照对象 `Luminary/apps/lumine`（TanStack Start + shadcn/Tailwind SaaS 仪表盘）。
>
> 本计划的判断以**静态分析**为准：没有桌面端截图、无 golden，所有现状结论都标注了
> 文件与行号，可直接核对。
>
> **ADR-0008 前提（2026-11-01 已决策，见 §0）**：桌面端**继续发展**，手机端重构时
> 同步带上桌面端。ADR-0008 第 4 条「停止扩展」由本计划附带的 ADR 修订提案解除
> ——修订本身**待评审后才落地**（见 §0.2）。

---

## 〇、已决策事项（2026-11-01 定稿）

### 0.1 三项决定

| # | 决定 | 对计划的影响 |
| --- | --- | --- |
| **D1** | **桌面端继续发展**，不再是"停止扩展的保留代码" | 解除 §五 D3 阻塞；桌面端获得与手机端同等的视觉投入资格；P0–P4 全部可执行 |
| **D2** | **手机端重构时同步带上桌面端**，不另起一套桌面专属设计语言 | 桌面端与手机端**共用同一套 token 与设计语言**，只在布局与密度上分档。因此 §五 D4 关闭为「共用」：**不建独立 theme family**（省掉翻倍工作量），代价是每次 token 改动要两端分别回归 |
| **D3** | 视觉缺陷由**人工检查**，通过既有 `Luminous/tool/screenshots` 生成截图 | 本计划**不新建 golden 体系**，改为给现有截图生成器**增加桌面档位**（见 §四） |

### 0.2 ADR-0008 修订提案（待评审后落地，不在本计划内直接改 ADR）

> 状态：**提案**。评审通过后按此文本修改
> `docs/reference/adr/0008-desktop-independent-web-product-route.md`；
> 未通过则本计划的 D1/D2 失去 ADR 依据，回到 §五 重新裁决。

**提案改动 1 — Status 行**

```text
- **Status**: accepted (amended 2026-09-27: 客户端代码归属由 Lucent 改为 Luminary；
  后端合同仍由 Lucent 提供)
```
改为
```text
- **Status**: accepted (amended 2026-09-27: 客户端代码归属由 Lucent 改为 Luminary；
  后端合同仍由 Lucent 提供；**amended 2026-11-01: Flutter 桌面端恢复为在产平台
  目标，第 4/7 条被取代，见「2026-11-01 修订」**)
```

**提案改动 2 — 新增「2026-11-01 修订」小节**（置于 Decision 之后）

```markdown
### 2026-11-01 修订：Flutter 桌面端恢复为在产平台目标

原第 4 条「停止扩展现有 Flutter 桌面表面」与第 7 条「0.1.0 后启动独立的
Next.js + Tauri 桌面 MVP」**被取代**。修订理由：

1. **两套桌面客户端不成立**。原决定同时保留 Flutter Desktop 的现有代码、
   又新建 Luminary 内的 Next.js+Tauri 客户端，结果是同一批桌面用户被两个仓库、
   两套信息架构、两条发布链服务。维护成本翻倍，产品事实有两个来源。
2. **Flutter Desktop 已是可用资产**。侧边栏、桌面窗口 chrome、桌面 Tab Shell、
   主从分栏等桌面结构已落地在 `lib/features/shell/`，丢弃后重写等于把已付费的成本
   再付一次。
3. **手机端与桌面端共享业务语义**。Lucent 合同、认证会话、健康数据解释完全一致，
   差异只在布局与密度。共用一套 Flutter 代码能天然保证两端语义同步，而双栈会把
   这种一致性退化成需要人工对齐的检查项。

修订后的边界：

- **Flutter Desktop 恢复为在产平台目标**，可新增桌面专属的布局与交互，
  但仍与手机端共享同一套设计 token 与业务语义。
- **手机端重构必须同时覆盖桌面端**：不是"先手机后桌面补适配"，而是每个改动在
  设计阶段就声明两端的表现。
- **Luminary 内不再新建桌面客户端**。该仓库继续承担官网、文档站、个人站与
  Lumine；Lumine 是独立产品（药品知识工作台），不承担 Luminous 桌面端职责。
- **ADR-0008 第 1/2/3/5/6/8 条保持不变**：Lucent 仍是唯一 API 合同事实源；
  手机端边界不变；桌面改动不得阻塞手机端发布。
```

**提案改动 3 — Related 行追加**

```text
计划 `plans/2026-11-01-desktop-visual-direction.md`
```

### 0.3 评审通过后需要联动修改的文件

| 文件 | 改什么 |
| --- | --- |
| `plans/README.md` | 本计划条目里的「待 D3 决策」改为「进行中」；功能盘点改造计划段落的「桌面/Web 产品方向以已接受的 ADR-0008 为准」需补一句修订 |
| `docs/explanation/project-governance.md:36` | 目前按 ADR-0008 原口径引用，需同步修订后的边界 |
| `lib/features/shell/README.md` | 记录桌面端为在产目标的约束（桌面布局改动需同步手机端回归） |

---

## 一、现状盘点（证据）

### 1.1 四层结构问题

| # | 问题 | 证据 |
| --- | --- | --- |
| S1 | **侧边栏与内容区同色**，全屏层次只靠 1px 边框 | `lib/core/theme/family.dart:212-213` 把 `backgroundColor` 与 `sidebarBackgroundColor` 设为同一个值；`lib/features/shell/presentation/page.dart:146` 又用 `BoxDecoration(color: theme.colors.background)` 覆写一次 |
| S2 | **间距按手机密度、圆角按大屏**，两者不同尺度 | 间距 `layout_scale.dart` 桌面档 `pageHorizontalPadding = Spacing.xl2`(20)、`cardPadding = Spacing.xl`(16)；圆角 `family.dart` `cardStyle` 用 `borderRadius.lg`(14)；`spacing.dart` 注释自述标题间距「直接取自 borderRadius.lg（=14）」 |
| S3 | **桌面端无右侧结构**，详情只能 `context.push` 整页跳走 | `desktop_tab_shell.dart` 只有 `FHeader.nested` + 一个 `maxContentWidth` 居中列；全仓唯一的主从实现是设置页专用的 `SettingsMasterDetail`（`page.dart:100`） |
| S4 | **侧边栏无分组、无二级、无 hover 态** | `page.dart:151-157` 五个平铺 `FSidebarItem`；`touch: false` 主题下无鼠标悬停反馈 |
| S5 | **行高被全量拍平成 1.0** | `family.dart` `_flattenLineHeight` 对每个字号拍平；手机端为密度，桌面端长段落不可读 |
| S6 | **最小窗口 480×720 仍是手机长宽比** | `lib/app/window_manager_setup.dart` `setMinimumSize(const Size(480, 720))`；`Breakpoints.desktop = 1200` 但窗口可被拖到 480 |

### 1.2 目标形态（Lumine 的六条机制）

| 机制 | Lumine 做法 | 落到 Luminous |
| --- | --- | --- |
| 双层底 | `--sidebar` 比 `--background` 深一档，内容卡 `card` 再浅一档 | `SurfaceTokens` 增加 `sidebarBackground`，桌面分支三层亮度可分 |
| 画布内缩 | `SidebarInset` 桌面 `rounded-xl shadow-sm m-2` | 内容区成一整块浮起的纸，与侧边栏留缝 |
| 顶栏玻璃化 | `h-14 bg-background/60 backdrop-blur-md sticky` | `FHeader` 桌面分支 |
| 右侧色差分块 | `Infobar` 22rem、`bg-sidebar`、`rounded-tl-xl`、仅左上圆角 | `FResizable` + `FixedResizableRegion(22rem)`，右侧面板与画布反向咬合 |
| 间距与圆角同尺度 | `--radius: 1rem` 派生四档；卡内 `gap-6 py-6 px-6` | 桌面档 `24 > 20 > 16 > 14` 递减 |
| 标题只说一次 | `page-container.tsx` 明确默认不传 `pageTitle` | 桌面端去掉与侧边栏高亮重复的大标题 |

**不照搬**：Lumine `light-green` 主题的 `--primary` 是高饱和柠檬绿
`oklch(0.8871 0.2122 128.5)`，属装饰性色值。Luminous 是健康类产品，
沿用 Luminous 既有 `SemanticColor` 语义，只借机制不借色相。

---

## 二、依赖决策：依赖替代掉手写（含已有的手写）

### 2.0 原则与作用域（2026-11-01 澄清）

> **原则：凡能用依赖替代手写的，就用依赖替代手写。**
>
> **作用域包含两部分**：
> 1. **未来的手写**——新功能先找包，找不到再写；
> 2. **已有的手写**——仓库里现任的手写实现，只要某个包的成本更优，
>    **也纳入替换范围**。不是"新写的才遵守"，而是"手写本身就要被逐步清出"。
>
> **成本可接受是前提**，按四项合并裁定：包维护状态（是否活跃、是否 0.x、
> bus factor）、依赖面（传递依赖、是否触碰平台原生）、许可证、以及
> **替换工量 + 后续升级维护工量**。

为什么要把作用域扩大到已有手写：手写的成本不是写那一刻，而是**长期**——每个
手写件都要自己维护、自己修边界、自己测、自己教新人。仓库里已有**六类**自有重实现
（见 §2.3 清单），它们的存在本身就构成持续成本。只要包的总成本低于
"继续维护这份手写"，就应该换。

判定口径：

| 情形 | 结论 |
| --- | --- |
| 现依赖（Forui / Flutter SDK）已具备 | **直接用**，无需新增包 |
| 现依赖不具备，pub.dev 有成熟的单一职责包 | **引入并按 §2.0 四项评估** |
| **仓库里已有等价手写** | **默认纳入替换评估**；评估通过即替换（见 §2.3 清单） |
| 包很重 / 0.x 且单人维护 / 拖原生依赖 | 先评估；本计划内不引入，单独提依赖决策 |
| 生态里确实没有合适的包 | 才保留手写，且手写部分必须带测试与注释说明理由 |

### 2.1 本计划所需的九项能力

| 需求 | 现成方案 | 结论 |
| --- | --- | --- |
| 侧边栏分组标签 | `FSidebarGroup(label: …)` 已随 forui 0.27.5 提供（`forui/lib/src/widgets/sidebar/sidebar_group.dart`，含 `label` / `action` / `onActionHoverChange`） | **用现依赖，不手写** |
| 右侧可拖分栏 | `FResizable` + `FixedResizableRegion(extent:)` + `FlexResizableRegion`（`forui/lib/src/widgets/resizable/`），自带拖柄、min/max extent、键盘可达 | **用现依赖，不手写** |
| 侧边栏折叠到图标栏 | Forui `FSidebar` 既有能力，`page.dart` 已在用 | 只改宽度值 |
| 面板开合动画 | `DurationTokens.masterDetailSwitch = 220ms` 已有 | 复用（但承载它的 `AnimatedSize`+`TweenAnimationBuilder` 属待替换手写，见 §2.3-4） |
| 骨架 / 空态 / 错误态 | `AppStateSkeletonView` / `AppStateErrorView` 已有 | 只改桌面列数 |
| 图标 | `forui_lucide` 已在依赖中 | 不变 |
| 双层底色 | `SurfaceTokens` 已有结构 | 加一个方法 |
| 间距 / 圆角同尺度 | `Spacing` + `LayoutScale` 已有 | 改桌面档数值 |
| 玻璃顶栏 | `BackdropFilter` / `ClipRect` 是 Flutter SDK 内建 | 不引包（引包只是包一层 SDK 组件，成本不优于直接用） |

### 2.2 候选包评估（按新原则重估）

之前被否掉的候选按成本重新过一遍。仍不引入的，理由落在成本或冲突上。

| 包 | 评估 | 结论 |
| --- | --- | --- |
| `flutter_acrylic` | 只支持 Windows 10/11 亚克力材质，macOS/Linux/Web 无效果；要写平台分支，效果还只在单一平台可见 | 不引入；窗口材质非本计划必需 |
| `macos_ui` / `windows_ui` | 把界面拉向各平台原生控件风格，与 D2「两端共用一套设计语言」**直接冲突** | 不引入（与决定冲突，非成本问题） |
| `responsive_framework` / `sizer` | 本仓已有 `Breakpoints` + `LayoutScale` 并在 **64 处**调用 `ResponsiveContentFrame`；替换工量 + 迁移风险高于收益 | 不引入（**但见 §2.3-1：替代品是更好的布局包，不是这两个**） |
| `rubber` / `padded` 等布局糖 | 只是 `Padding` combinator 的语法糖，增加依赖面而不减少维护 | 不引入；单项收益过小 |
| `google_fonts` | 运行时从网络取字体，Tauri 桌面离线场景不可接受 | 不引入（与桌面离线前提冲突） |
| `blur` / `glass_kit` | 只是包装 SDK `BackdropFilter` | 不引入；SDK 已可直接用 |

### 2.3 已有手写的替换清单（本计划范围内）

这是 §2.0 第 2 部分要求的一方工作。逐项给出"现手写 → 替代品 → 处理"。

| # | 现手写 | 位置 / 规模 | 替代品 | 处理 |
| --- | --- | --- | --- | --- |
| **1** | 自维护响应式布局三件套（`LayoutScale` / `LayoutScaleResolver` / `ResponsiveContentFrame`） | `lib/core/design/layout/layout_scale.dart`、`core/widgets/layout/responsive_content_frame.dart`；**64 处调用点** | `flutter_adaptive_scaffold`（Flutter 官方维护的 adaptive 布局包，提供 breakpoint 驱动的 layout slot）**或** `sizer` | **评估替换**。判定要点：现实现有价值的是"按宽度解析 padding/maxWidth"这一层，`ResponsiveContentFrame` 只是 `ConstrainedBox`+`Center`。若包能覆盖且迁移面可控（64 处多为机械替换），则换；否则保留并在此写明理由。**本计划 P0/P3 会再改这些值，替换必须在 P0 之前定，否则会出现改了两次** |
| **2** | 手写表头吸顶 / 滚动联动（`sticky header`） | P4 需要，目前用 `CustomScrollView` + `SliverPersistentHeader` 手写 | `sticky_headers` / `flutter_sticky_header` | **P4 直接引入依赖**，不手写 sliver delegate |
| **3** | 手写滚动条样式 | 目前 0 处（`Scrollbar` 未使用），但 P4 要加 | Flutter SDK `ScrollbarTheme`（官方） | 用 SDK 主题配置，不写自定义 painter |
| **4** | 设置页主从详情的手写动画（`AnimatedSize` + `TweenAnimationBuilder` + `ValueKey` 手动重放） | `lib/features/settings/presentation/widgets/master_detail.dart`：注释明确记录了放弃 `AnimatedSwitcher` 的原因（默认 `Stack` 居中叠放导致抖动、双份文本对 a11y 可见），并手写"同步切换 + 仅入场淡入"来绕开 | `flutter_animate`（**已在依赖中**）或 `FAnimatedSwitcher` 一类 | **看 §2.3-5 一并处理**：P2 引入右侧面板后，这段手写的滑出/切换逻辑应由统一包接管，避免仓库里存在两套"面板切换动画"实现 |
| **5** | 侧边栏折叠的宽度过渡与图标位过渡 | `page.dart` 内依赖 Forui `FSidebar` 的实现细节 | Forui 自带 | 已由依赖覆盖，仅需给值 |
| **6** | 自定义 `CustomPaint`（评分环、扫码角标） | 4 处 `CustomPaint`，其中 2 个非本计划范围（扫码） | `fl_chart`（已在依赖）可覆盖评分环 | **不在本计划内**。列在此处是为了说明：并非所有手写都该换——扫码角标是产品特有视觉，没有包，这类保留并写明理由 |

> **§2.3 的执行顺序要求**：`#1` 必须在 **P0 之前**裁决。因为 P0 要改
> `SurfaceTokens` 与间距值，P3 要改 `LayoutScale` 桌面档——如果之后又决定换包，
> 等于同一批值改两遍。所以本计划的第一步不是 P0，而是**完成 §2.3-1 的评估**。

### 2.4 执行时发现缺能力怎么办

按原则一，**发现某处确实需要手写时，先暂停该步**，补一条候选依赖评估（按 §2.0
四项），评审通过后加包；评估结论是"没有合适的包"才手写，并在当日迁移日志里
记下评估过程与理由。

`forui ^0.27.5` 是 0.x，`FSidebarGroup` / `FResizable` 的 API 在 minor 版本间可能变。
升级 forui 时需重跑 P1 / P2 的 golden（见 §六）。

---

## 三、执行阶段

> **执行状态（2026-11-01）**：P-1、P0、P1、P3、P4 已完成并各自原子提交于
> `feat/desktop-visual` 分支。P2 未开工（等待 §五 D2'）。

**前置于所有阶段**：**P-1 手写替换裁决**（§2.3-1）。因为 P0 要改 `SurfaceTokens`
与间距值、P3 要改 `LayoutScale` 桌面档，若之后又决定换布局包，同一批值要改两遍。
所以第一步是先裁决现有响应式布局三件套的归属。

依赖顺序：**P-1 → P0 → P1 → P3 → P4 → P2**。P-1 是裁决（可能零代码），
P0–P3 只动 token 与 shell（不碰业务组件），风险低、见效快；P2 是结构改动。

**P-1 裁决结论**：**整体替换**。`LayoutScaleResolver.resolve` 的 if 分档链换成了
`fluid_adaptive` 的 `ResponsiveBreakpoints.standard.sizeClassFor(width).resolve<T>()`；
阈值统一到 M3 标准值 600 / 840 / 1200。`LayoutScale` 的四档取值表**保留**——
那是设计决策不是布局算法，包不提供也不该提供。`ResponsiveContentFrame` 暂留
（它只是 `ConstrainedBox` + `Center`，替换它不减少任何判断，留待 P2 与右侧面板一起看）。

### P-1 — 手写替换裁决（前置，可能零代码）

**目标**：决定 `LayoutScale` / `LayoutScaleResolver` / `ResponsiveContentFrame`
（`lib/core/design/layout/layout_scale.dart` + `core/widgets/layout/responsive_content_frame.dart`，
**64 处调用**）是保留还是被布局包替代。

按 §2.0 四项评估 `flutter_adaptive_scaffold`（Flutter 官方）与 `sizer`：

- 现实现实际提供什么：按宽度解析 `pageHorizontalPadding` / `cardPadding` /
  `maxContentWidth` 等**语义化 token**；`ResponsiveContentFrame` 只是
  `ConstrainedBox` + `Center` 的一层包装，**本身没有任何布局算法**。
- 因此关键判断是：包能替代的是**外层 frame**，替代不了**语义化 token 表**。
  若包的 breakpoint 抽象还能覆盖 token 表（如 slot 化布局），则整体替换；
  若不能，则至少把 `ResponsiveContentFrame` 替换成包提供的自适应槽位，
  `LayoutScale` 的 token 表作为本项目领域值保留（这不是"手写布局"，是设计值）。
- **裁决结果写进本文件**，再进 P0。

**验收**：给出明确结论（替换 / 部分替换 / 保留）+ 理由 + 迁移面；若替换，
列出 64 处调用的迁移方式（机械替换 or 逐处改造）。

### P0 — 双层底（先做，可单独验收）

**改动面**：`lib/core/design/layout/surface.dart`、`lib/core/theme/family.dart`、
`desktop_tab_shell.dart`。**不新增依赖**（叠加层用 SDK `Stack` + `ClipRRect`）。

1. `SurfaceTokens` 增加 `sidebarBackground(FColors)`：
   - 亮色：比 `scaffoldBackground`（`#FAFAFA`）深一档，取 `#F2F2F2`；
     保持与 `containerBorder`（`#F5F5F5`）的关系不颠倒。
   - 暗色：`Color.lerp(colors.background, colors.secondary, 0.75)`（现为 0.5，过浅）。
2. `family.dart:213` 的 `sidebarBackgroundColor` 改为指向新方法；删掉 `page.dart:146` 的覆写。
3. `DesktopTabShell` 外层由 `DecoratedBox` 平铺改为
   `ClipRRect(borderRadius: 14)` + 卡白底，与窗口边缘内缩 12、与侧边栏间距 6。

**验收（硬条件）**
- 1280×800 与 1920×1080 各截一张：侧边栏 / 画布 / 卡片必须能分出**三个**亮度层级。
- 把全局边框临时关掉后，层次依然成立（证明层次来自底色而不是线）。
- 亮 / 暗各验一遍（暗色下卡片必须比画布**更亮**，同 Lumine）。

### P1 — 侧边栏分组化

**改动面**：`page.dart` 的 `_DesktopSidebar`。**用 `FSidebarGroup`，不手写分组组件。**

1. 五个 tab 之上引入分组标签。**分组归属是信息架构决策**（见 §五 D1），
   未决前先用单组保持现状，把 `FSidebarGroup` 的结构先立起来。
2. 选中态与 hover：`bg-sidebar-accent` + `font-medium` + `200ms linear` 过渡。
3. 项高 32（`h-8`）、图标 16 固定、项间距 2；宽度 16rem，可折叠到 3rem。
4. 窗口宽度 < `Breakpoints.desktop`(1200) 时自动折叠为图标栏（`Breakpoints` 已有，接上即可）。

**验收**：鼠标悬停每一项有明确反馈；折叠/展开时宽度过渡无跳变；
`flutter test test/shell/` 不回归。

### P3 — 间距与圆角收敛到同一尺度

**改动面**：`layout_scale.dart`、`spacing.dart`（桌面档）、`family.dart`（行高分支）。

1. 桌面档：`pageHorizontalPadding` 20 → **24**，`cardPadding` 16 → **20**，
   形成 `24 > 20 > 16 > 14` 递减（现在 20/16/14 挤在一起，观感偏闷）。
2. **行高按平台分支**：`_flattenLineHeight` 保留手机 1.0；桌面分支 `body` 1.4–1.5、`sm` 1.3。
   这是本计划**影响面最大**的一处（所有文本高度变化），必须单独提交、单独回归。
3. 标题层级补 tracking：页面级 `text-2xl` + `semibold` + `tracking-tight`，
   段落描述 `sm` + `muted-foreground`，卡片标题 `semibold` 无 tracking。

**验收**：桌面端长段落（如报告正文）阅读行宽与行高符合可读区间；
`dart run scripts/workflows/daily.dart` 通过；无 golden 变化以外的意外 diffs。

### P4 — 顶栏与细节

1. `FHeader` 桌面分支：高 56、`bg-background/60` + `BackdropFilter`、
   `sticky`、底部 1px 分隔。
2. 滚动条统一：宽 10、thumb 用 border 色、`rounded-full`、hover 变 `muted-foreground`。
   几乎零成本，桌面手感一半来自这里。
3. 键盘焦点环与 Lumine 的 `focus-visible:ring-2` 对齐（用 Forui 默认 ring token，不手绘）。
4. 最小窗口 `480×720` → **960×640**（`Breakpoints.tablet` 起算桌面）。
   同时把「侧边栏出现」阈值 1200 与「右侧面板出现」阈值 960 **分开**，
   否则两侧一收就把内容挤成手机宽。

**验收**：滚动时内容从半透明顶栏下穿过，无撕裂；窗口拖到最小时布局不破。

### P2 — 桌面端右侧详情面板（结构性，等决策）

**改动面**：新增 `features/shell/presentation/desktop_detail_pane.dart`（或并入
`desktop_tab_shell.dart`），并替换若干 `context.push` 详情跳转。

1. 用 `FResizable`（`axis: Axis.horizontal`）组织「主内容 | 右侧面板」；
   右侧用 `FixedResizableRegion(extent: 22rem)`，带 min/max，可拖动可折叠。
2. 右侧视觉与左侧侧边栏**同色**（`SurfaceTokens.sidebarBackground`），仅左上圆角——
   形成左右对称的"夹心"，这是 Lumine 最有辨识度的一段。
3. 面板内部层级：标题 `title-lg semibold`；组标题 `sm semibold`；
   正文 `sm leading-relaxed muted-foreground`；组间 24、组内 12。
4. 开合动画**复用依赖，不手写**：仓库已有 `flutter_animate`（`pubspec.yaml` 已声明）
   与 Forui 的动画原语。**不要**再写一套 `AnimatedSize` + `TweenAnimationBuilder` +
   手动 `ValueKey` 重放——那正是 `master_detail.dart` 现在的手写形态（该文件注释记录了
   放弃 `AnimatedSwitcher` 的原因，值得保留为决策依据，但"绕开它"的替代实现应交由包）。
   落定时把 `master_detail.dart` 的切换动画一并迁到同一套，避免仓库里两套面板动画。
5. 详情页从 `context.push` 整页跳转改为推开面板；面板内容的 widget 复用现有详情页内部
   组件，**不新造数据、不新增页面**（ADR-0008）。

**前置决策**：面板承载什么（§五 D1'）。决定"详情的第二种呈现"还是"平行工作区"会直接
影响 P2 是否改主内容网格。

**验收**：列表点开一项主内容**不跳页**、右侧滑出；再点另一项面板原地切换；
拖动分隔条两侧自适应且最小宽度之下自动折叠为抽屉；仓库内面板动画实现只有一处。

---

## 四、验证方式：截图生成器 + 人工检查

### 4.1 既定做法（2026-11-01 决定）

**不新建 golden 测试体系。** 视觉缺陷由**人工检查**，素材来自既有截图生成器：

```powershell
cd Luminous
flutter test tool/screenshots/generate.dart --update-goldens
python tool/screenshots/contact_sheet.py outputs/screenshots build/contact
```

产物在 `outputs/screenshots/`（gitignored），按 tab 分目录，附 `MANIFEST.md`
与 `_rendered_text.txt`（每页渲染出的全部字符串，可用于对比两次运行）。

### 4.2 需要给生成器补的桌面档位

现状（`tool/screenshots/generate.dart:121-124`）只有**一种帧**：

```dart
const double _frameWidth = 448;          // Pixel 8 Pro
const double _frameHeight = 2992 / 3;
const double _frameDpr = 3;
```

且顶部不渲染桌面窗口条（`desktopChrome: false`，见该工具 README:45-46），
理由是"在 Windows 上跑测试会把最小化/最大化/关闭画进移动端页面截图"。

**改动**：把帧参数提为可切换的档位，而不是常量。

| 档位 | 尺寸 | dpr | desktopChrome | 覆盖的断点 |
| --- | --- | --- | --- | --- |
| `phone`（现状，保持默认） | 448×998 | 3 | `false` | < 600 |
| `desktop`（新增） | 1280×800 @ 逻辑像素 | 2 | **`true`** | ≥ 1200，侧边栏 + 右侧面板 |
| `tablet`（新增，可选） | 960×640 | 2 | `true` | 960–1200，侧边栏折叠态 |

桌面档**必须打开 `desktopChrome: true`**——窗口按钮、拖拽区是本计划 P4 的验收对象，
用 `false` 截出来的图看不到这部分。

输出目录按档位分：`outputs/screenshots/desktop/...`；`long/` 长截图只在 phone 档
产出（桌面档内容通常不满一屏，且长截图会绕过桌面布局）。

### 4.3 人工检查清单（每次改动后按此过一遍）

对照 `docs/reference/design-system.md` 与 Lumine 的六条机制（§一 1.2），逐项目视：

1. **三层亮度**：侧边栏 / 画布 / 卡片在亮色与暗色下都能区分，且暗色下卡片比画布**更亮**。
2. **不靠边框**：把边框临时关掉后层次依然成立。
3. **间距递减**：`24 > 20 > 16 > 14`，卡片内边距不小于圆角。
4. **行高档位**：桌面长段落（报告正文）行高 1.4–1.5，不出现挤压感。
5. **右侧面板**：与左侧侧边栏同色、仅左上圆角；拖动分隔条时两侧自适应、到达最小宽度
   后折叠为抽屉。
6. **侧边栏**：hover 有反馈、选中态清晰、折叠/展开宽度过渡无跳变。
7. **玻璃顶栏**：滚动时内容从半透明顶栏下穿过，无撕裂。
8. **窗口最小尺寸**：拖到 960×640 时布局不破、不出现手机式单列塌缩。

**人工检查结论要写回**：每轮检查在当日 `docs/logs/migration-log/YYYY-MM-DD.md`
记一行「截图轮次 → 发现项 → 已修 / 待修」，让"人工检查"这件事留痕，否则
下一次没人知道上一轮看过什么。

### 4.4 每阶段收尾命令

```powershell
flutter analyze
flutter test
flutter test tool/screenshots/generate.dart --update-goldens
python tool/screenshots/contact_sheet.py outputs/screenshots build/contact
dart run scripts/workflows/daily.dart
```

> 注：仓库当前测试基线为 `test/` 下无桌面布局相关用例，`tool/screenshots`
> 是**唯一**的桌面视觉证据来源。若某阶段改动让生成器本身失败（例如 448 宽下的
> 手机页面因 P3 行高变更而溢出），说明 P3 的桌面行高分支没有正确按平台隔离——
> 这本身就是一条验收信号。

---

## 五、待决策

| # | 问题 | 阻塞 | 说明 |
| --- | --- | --- | --- |
| **D1'** | 桌面侧边栏分哪几组、组名是什么？ | P1 | 原 D1。桌面端确认继续发展后，5 个平铺 tab 的信息量在 256px 宽的侧边栏里明显不足。分组名同时是 l10n key。**不阻塞 P0/P3/P4**，P1 可先用单组把结构立起来 |
| **D2'** | 右侧面板承载什么？ | P2 | 决定 P2 是"详情的第二种呈现"还是"平行工作区"；后者会改主内容网格。不阻塞前四个阶段 |
| **D5** | §2.3 手写替换清单的处置结论 | P-1 | 每项需要"替换 / 保留 + 理由"的明确结论，写进本文件后再进 P0 |

已关闭的决策：**D2（桌面 vs 手机 token）→ 共用一套**（§0.1 D2）；
**D3（桌面是否发布）→ 继续发展**（§0.1 D1）；
**D4（右侧面板承载什么）→ 保留为 D2'，不阻塞**。

---

## 六、风险

| 风险 | 说明 | 应对 |
| --- | --- | --- |
| 行高全量改动（P3-2） | 影响所有文本高度，可能引起大量布局回归 | **单独提交**；先改桌面分支，手机保持 1.0；用 `tool/screenshots` 手机档位跑一遍对比 `_rendered_text.txt` 与截图 |
| **两端共用 token（D2 的代价）** | 按 §0.1 决定，桌面与手机共用一套 token，因此每次 token 改动都会同时影响两端 | 每个阶段都**两份截图**（phone 档 + desktop 档）各过一遍 §4.3 清单；不建独立 theme family 是为了省翻倍工作量，代价由这条回归覆盖 |
| `forui 0.27.5` 0.x API 漂移 | `FSidebarGroup` / `FResizable` 均非 1.0 | 升级 forui 时重跑桌面截图档；不在本计划内顺手升版本 |
| 与 `2026-10-28-composable-tabs.md` 冲突 | 那份计划在做响应式三档与跨表面挂载，同改 shell 层 | **执行本计划前先对齐**，避免两处同时改 `desktop_tab_shell` |
| 与 `2026-10-31-ui-craft-gap-audit.md` 重叠 | 那份已收干净「颜色/间距/圆角/字号」四类 token；本计划的 P0/P3 会再动这些值 | 本计划只动**桌面分支**取值，不改手机端已收的规范；冲突点写进当日迁移日志 |
| 人工检查的主观性 | 没有自动 golden，视觉缺陷靠人眼，容易漏 | §4.3 清单固定 8 项，逐项打勾；每轮结论写进迁移日志留痕 |

---

## 七、完成后

按 `Luminous/AGENTS.md`：
- 视觉行为变化写入当日 `docs/logs/migration-log/YYYY-MM-DD.md`（含每轮人工检查的发现项）。
- 稳定约束进 `docs/reference/design-system.md`；桌面专属约束进 `lib/features/shell/README.md`。
- ADR-0008 修订（§0.2 提案）在评审通过后落地，并联动改 §0.3 列出的三个文件。
- 本计划执行完毕后**删除本文件**，并在 `plans/README.md` 的「已执行完毕」列表记一行。
