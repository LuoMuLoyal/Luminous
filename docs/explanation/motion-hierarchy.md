---
status: active
owner: frontend
updated: 2026-09-12
---

# 动画体系调研与选型:全局分级动画(Motion Hierarchy)

> 结论:**分三层建动画体系,核心过渡走官方 Material Motion 实现**。导航过渡
> (tab 切换 + 子页面 push/pop)用 **官方 `animations` 包的 SharedAxis/FadeThrough**
> ——`slidePage` 用 SharedAxis(水平)、`tabFadePage` 与 tab 分支切换用 FadeThrough;
> `PageTransitionsTheme` 全局兜底统一为 M3 共享轴,消灭桌面 Zoom / 移动原生的平台混搭。
> 列表/内容过渡用官方 `PageTransitionSwitcher`(页面状态切换)+ 已依赖的
> **`flutter_animate`**(限制规模)+ record 首页入场;微交互优先吃 **Forui 自带动画**
> (FTappable/FPopover/FTooltip motion + `FAccessibilityMotion` 自动降级)。明确不引入
> page_transition / motion(GPL-3)/ rive / lottie / go_router_animated_branch 等小众包。
>
> **状态:全部落地**(2026-09-12)。阶段 1 调研 → 阶段 2 tab fade-through + 设置页
> master-detail → 阶段 3 路由 push/pop → 阶段 4 record 首页入场 → 阶段 5 引入官方
> `animations` 包统一品牌过渡 + 页面状态切换 fade-through。
>
> 依据:本地代码审计(2026-09-12)+ 官方调研(Flutter 3.38+ 源码与文档、go_router
> 17.x 文档与示例、M3 motion 规范)+ 社区包调研(pub.dev / GitHub 实时数据)。
> 本文 §2/§3 为两份调研的浓缩结论,关键参考链接见 §7。

## 1. 现状审计:Luminous 动画缺什么

### 1.1 已有的(不需要重做)

| 层 | 现状 | 位置 |
|---|---|---|
| 路由过渡(部分) | `fadePage`(auth 400/280ms 淡入)、`tabFadePage`(官方 FadeThrough 260ms)、`slidePage`(官方 SharedAxis 水平 220/150ms)、`sidePanelPage`(桌面右滑面板) | `lib/app/router_helpers.dart` |
| in-widget 基础 | `MotionTokens`(entrance/exit/standard/snappy)+ `DurationTokens` 4+ 档 | `lib/core/design/tokens/motion.dart` |
| flutter_animate | 已依赖 4.5.2,~6 处使用(auth 表单入场、assistant 旋转指示、mine/review dashboard 入场) | 各 feature |
| 显式动画 | `AnimationController` 3 处(summary 展开、suggestion card、risk score ring) | today / medicine |
| 桌面 hover | `AnimatedContainer` 200ms snappy(背景+边框) | `desktop_hover.dart` |
| 弹层 | Forui `showFDialog` / `showFSheet` / `FPopover` 自带动画 | core + features |
| 主题切换 | Forui `FTheme` 自带 `FThemeMotion`(默认 200ms linear)平滑过渡 | forui 0.26 内置 |
| assistant 内 | flow_ui 0.1.0 自带流式 reveal / thinking 呼吸 / jump 动画 | flow_ui 包 |

### 1.2 缺的(本次要补)

| 场景 | 缺口 | 根因 |
|---|---|---|
| **Tab 切换** | ✅ **已补**(2026-09-12):`ShellTabBranchContainer` fade-through | `StatefulShellRoute.indexedStack` 官方**明确不做分支切换过渡**;现改用自定义 `navigatorContainerBuilder` |
| **设置页桌面 master-detail** | ✅ **已补**:右侧 pane `AnimatedSwitcher`(220ms) | 原 `setState` 直接换 body |
| **子页面路由** | ✅ **已补**:`slidePage` 换官方 SharedAxis 水平轴,push/pop 双向 | 原手写 slide 仅用 `animation`(单侧),`secondaryAnimation` 未用 |
| **页面状态切换** | ✅ **已补**:`PageStateSwitch` 用官方 `PageTransitionSwitcher` + FadeThrough | 原 `switch` 硬替换(骨架 ↔ 内容 ↔ 错误) |
| **列表项进场交错** | 未做 | 收益/风险比不佳:核心列表(如 review 历史)被单帧 `pump()` + 位置断言测试覆盖,交错入场会引入脆弱性 |
| **micro-interaction** | 部分:Forui 自带按压/hover + `flutter_animate` 少量使用,无统一节奏 | 未统一 M3 tokens |
| **Hero/共享元素** | 零使用 | 未规划;跨 StatefulShellRoute 分支不工作(独立 Navigator),仅限同分支"列表→详情" |

### 1.3 约束(选型必须满足)

1. **GoRouter 是唯一导航入口**(`no_direct_navigator` lint,白名单 `lib/core/router/` 与 shell)。
2. **Forui 主题 + material_ui 1.x**:`foruiMaterialTheme()` 返回 material_ui `ThemeData`;`PageTransitionsTheme` 同型(已核实 forui 0.26 源码)。
3. **测试面大**:`test/` 约 540 处 `pumpAndSettle` + e2e 大量 `pumpAndSettle` —— 新动画必须能在 `pumpAndSettle` 下收敛(无限循环动画如 shimmer 需测试规避,既有先例)。
4. **reduced-motion 已建**:`accessibilitySettingsControllerProvider.reduceAnimations` → `MediaQuery.accessibleNavigation`;Forui 组件自动响应。
5. **桌面端是主战场**(Windows/Linux),但 Web 也发布 —— 过渡需两端可用。

## 2. 官方方案调研结论(要点)

核心事实:

1. **Tab 切换**:`StatefulShellRoute` 官方文档明确"分支切换过渡由 `navigatorContainerBuilder` 负责,默认 IndexedStack 无动画";官方示例 [custom_stateful_shell_route.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/others/custom_stateful_shell_route.dart) 用 AnimatedSwitcher/FadeTransition 包分支。M3 规范称此模式为 **Fade through**(旧页淡出、新页淡入+轻微缩放,≈300ms)。
2. **子页面路由**:GoRouter 默认 pageBuilder 返回 `MaterialPage`,过渡由 `ThemeData.pageTransitionsTheme` 按平台接管(零配置、平台原生);特殊页才用 `CustomTransitionPage`(默认 300ms,`key: state.pageKey`);无动画用 `NoTransitionPage`。
3. **PageTransitionsTheme 默认行为**(Flutter 3.38+ 源码核实):Android=`PredictiveBackPageTransitionsBuilder`(非手势回退 `FadeForwards`,450ms);iOS/macOS=`CupertinoPageTransitionsBuilder`(~400ms);Windows/Linux=`ZoomPageTransitionsBuilder`(300ms,快照动画,Web 自动禁快照);未匹配兜底 Zoom。
4. **隐式动画**:`AnimatedSwitcher`/`AnimatedSize`/`AnimatedContainer` 等由 `ImplicitlyAnimatedWidget` 派生,统一显式传 M3 tokens(微交互 100–200ms + `Easing.standard`;容器 200–400ms + emphasized 系)。
5. **Hero**:同 Navigator 内正常;StatefulShellRoute **跨分支 Hero 不工作**(独立 Navigator,[flutter/flutter#192043](https://github.com/flutter/flutter/issues/192043))—— 限定"列表→详情"同分支使用。
6. **reduce motion**:`MediaQueryData.disableAnimations` 来自引擎,框架 `AnimationController` **自动**压缩时长;自写显式动画须判断该 flag;iOS `reduceMotion` 与 disableAnimations 暂不互通([PR #190287](https://github.com/flutter/flutter/pull/190287) 在途)。
7. **M3 分级**(navigation / transitions / micro-interactions 三级):navigation 300–600ms + emphasized 系;transitions 200–400ms + emphasized;micro-interactions 100–200ms + standard。精确 easing:`Easing.standard`=`(0.2,0,0,1)`、`Curves.easeInOutCubicEmphasized`(ThreePointCubic)、`Easing.emphasizedDecelerate`=`(0.05,0.7,0.1,1)`、`Easing.emphasizedAccelerate`=`(0.3,0,0.8,0.15)`。

## 3. 社区包调研结论(要点)

### 3.1 生态背景(影响选型)

- **Flutter 正从 `flutter/material.dart` 迁移到独立 `material_ui` 包**(Flutter 3.47 起)。项目**已依赖 `material_ui 1.x`**(pubspec.yaml),`forui 0.26` 与 `animations 3.0.0` 均已迁移到 material_ui —— 类型同源。
- **`flutter_animate` 4.5.2 维护停滞**(2024-11 后无更新),已知 bug:CurvedAnimation 泄漏([#166](https://github.com/gskinner/flutter_animate/pull/166)/[#155](https://github.com/gskinner/flutter_animate/issues/155))、dispose 后崩溃(#145)。活跃 fork `flutter_animate_plus 5.1.0` 是升级预案。
- **StatefulShellRoute tab 切换无动画**是 go_router 设计使然([issue #134418](https://github.com/flutter/flutter/issues/134418)),任何包都绕不开 `navigatorContainerBuilder`。

### 3.2 逐包推荐清单

| 包 | 结论 | 理由 |
|---|---|---|
| **`animations` 3.0.0**(官方 flutter.dev) | **已引入** ✅ | SharedAxis/FadeThrough/OpenContainer;6.8k likes / 160 points / 1.24M 下载;BSD-3;依赖 material_ui ^1.0.0 与项目同源;活跃维护。**限制**:OpenContainer 与 go_router 不兼容([#121929](https://github.com/flutter/flutter/issues/121929),勿用于路由,只做页内容器变换) |
| **`flutter_animate` 4.5.2**(已依赖) | **维持现状,限制规模** ⚠️ | 做 micro-interaction / 列表交错性价比最高;维护停滞 + 泄漏 bug,大量使用会放大风险;监控 `flutter_animate_plus` fork 作升级预案 |
| `rive` 0.14.11 | 不引入 ❌ | 交互式矢量动画才有需要;原生依赖 + 构建复杂度,普通 UI 过渡用不上 |
| `lottie` 3.5.1 | 不引入 ❌ | 设计团队产出 AE 素材才需要;当前无需求,未来按设计工具链二选一 |
| `page_transition` 2.2.2 | 不引入 ❌ | 功能与 animations + 官方 CustomTransitionPage 重叠 |
| `motion` 2.0.2 | 不引入 ❌ | **GPL-3.0 许可证**(商业 App 禁用),且无桌面端 |
| `motion_switcher` / `anim_search_bar` | 不引入 ❌ | 废弃/单点组件 |
| `go_transitions` / `go_router_animated_branch` / `shell_route_transition` | 不引入 ❌ | 小众不成熟;官方能力可替代(自己写 20 行 navigatorContainerBuilder) |

### 3.3 Forui 0.26 自带动画能力(优先使用,零成本)

- `FTappable` 按压 bounce(可配 motion 关闭)、`FPopover`/`FTooltip` origin-aware motion、`FButton` 反馈、`FAccordion`/`FTabs`/`FSwitch` 展开切换动画、`FSheet`/`FDialog` slide/fade 过渡、`FToast` 入场/自动消失。
- **`FAccessibilityMotion`**(0.24.0 起):所有 Forui 组件自动响应系统"减少动态效果" —— 无障碍降级已内建。

## 4. 推荐方案:三层动画体系

> 分级原则:同一套 duration/easing tokens(M3 对齐)供三层共用;全局唯一无障碍入口
> (系统 disableAnimations + 项目 reduceAnimations);测试可收敛。

### 层级一:导航过渡(Navigation,300–450ms + emphasized 系)

1. **Tab 切换(最高优先级,用户痛点)**:`StatefulShellRoute` 加自定义 `navigatorContainerBuilder`,做 **fade-through**:切 Tab 时旧分支淡出、新分支淡入 + 轻微缩放(0.98→1.0),≈280–300ms `Easing.emphasizedDecelerate`/`Curves.easeInOutCubicEmphasized`。要点:
   - 保持 IndexedStack 的"分支常驻"语义(各分支 GlobalKey/状态不丢)—— 用 `Stack` + `AnimatedOpacity`/`AnimatedSwitcher` + `IgnorePointer` + `TickerMode` 处理隐藏分支。
   - `ShellDeferredContent` 已保证首帧不阻塞,过渡照常。
   - 复用官方 custom_stateful_shell_route 示例结构,不引第三方包。
2. **子页面路由**:评估现有 `slidePage` 是否保留。两个方向:
   - **方向 A(官方推荐,零配置)**:去掉逐路由 `CustomTransitionPage`,让默认 `MaterialPage` + `PageTransitionsTheme` 按平台接管(桌面 Zoom、移动平台原生)。品牌统一可改 `theme.pageTransitionsTheme` 覆盖(如全平台统一 FadeForwards/自写 emphasized 淡入)。
   - **方向 B(保留自写,增强)**:保留 `slidePage` 但补 `secondaryAnimation`(返回时反向滑动)+ 统一 M3 tokens。
   - 建议:**先做方向 B 的增强**(改动小、保住现有视觉),再评估方向 A 收敛(不逐路由覆盖)。
3. **设置页桌面 master-detail**:左栏切换 body 加 `AnimatedSwitcher`(Fade through,200–250ms)。

### 层级二:内容/列表过渡(Transitions,200–400ms + emphasized)

- 列表项进场:`.animate(interval: ...)` 交错淡入+上移(flutter_animate,限制核心列表页)。
- 数据刷新替换:`AnimatedSwitcher`(带稳定 key)或 `AnimatedCrossFade`。
- 展开/折叠:`AnimatedSize`/Forui `FCollapsible`(已有先例)。
- Hero:同一分支内"列表→详情"可用(如 medicine 搜索→详情);**跨分支禁用**。

### 层级三:微交互(Micro-interactions,100–200ms + standard)

- 优先 Forui 自带(FTappable/FPopover/FTooltip motion)。
- flutter_animate 补充自由编排(悬停 scale、图标切换、数字滚动)。
- 统一 `Easing.standard`(=`MotionTokens` 新增 token),时长走 `DurationTokens`。

### 无障碍(reduce motion)

- 框架动画自动响应 `disableAnimations`(AnimationController 自动压缩)。
- 自写显式动画统一经 `AnimationController` 并判断 `MediaQueryData.disableAnimations`;项目 `reduceAnimations` 设置已映射到 `accessibleNavigation`,继续沿用。
- flutter_animate 无内置 disableAnimations 支持 —— 使用处需自行判断(现状未做,补上)。

## 5. 落地建议(分阶段,每阶段独立提交可回滚)

1. **阶段 1(调研落地,仅文档)**:本调研报告 + 迁移日志;不动代码。✅ 已完成(2026-09-12)。
2. **阶段 2(核心痛点)**:tab 切换 fade-through(`navigatorContainerBuilder`)+ 设置页桌面 master-detail `AnimatedSwitcher`;补 `DurationTokens`/`MotionTokens` M3 对齐 token(emphasized 系 + 分级时长)。✅ 已完成(2026-09-12)。
   - 新增 `ShellTabBranchContainer`(`lib/features/shell/presentation/tab_branch_container.dart`):M3 fade-through(淡入+轻微缩放 0.98→1.0,260/200ms emphasized),保持 IndexedStack 的"分支常驻 + 非当前分支 offstage"语义。
   - `router.dart`:`StatefulShellRoute.indexedStack` → `StatefulShellRoute` + 自定义 `navigatorContainerBuilder`。
   - 设置页桌面 `master_detail.dart`:右侧 pane 包 `AnimatedSwitcher`(220ms,`emphasizedDecelerate` 入场)。
   - `motion.dart` 新增 `MotionTokens.emphasized` / `emphasizedDecelerate` + `DurationTokens.tabFadeThrough` / `tabFadeThroughOut` / `masterDetailSwitch`。
3. **阶段 3(路由增强)**:`slidePage` 补 `secondaryAnimation` 反向过渡(被覆盖的旧页向左让位,形成 push/pop 方向感)。✅ 已完成(2026-09-12),**该手写实现随后被阶段 5 的官方 `SharedAxisTransition` 取代**(行为等价:push/pop 双向,位移量级由 15% 屏幕宽改为固定约 30 逻辑像素)。`PageTransitionsTheme` 品牌统一已在阶段 5 落地,见下。
4. **阶段 4(内容/列表)**:record 首页 dashboard 入场动画(fade + 轻微上移,与 mine 对齐)。✅ 部分完成(2026-09-12)。review 历史列表刷新过渡**暂缓**:该 section 被大量单帧 `pump()` + 位置断言测试覆盖,入场动画会引入脆弱性;且周期/筛选切换频繁刷新,过渡易显"跳"。数据刷新过渡等 `animations` 包引入后以 `PageTransitionSwitcher` 统一再做。
5. **阶段 5(品牌统一)**:引入官方 `animations` 3.0.0 统一过渡实现。✅ 已完成(2026-09-12)。
   - `slidePage` → 官方 `SharedAxisTransition`(horizontal):替换阶段 3 手写的 slide + `secondaryAnimation` 让位,push/pop 共用包内 `DualTransitionBuilder` 实现(M3 共享轴,位移约 30 逻辑像素 + 淡入淡出)。
   - `tabFadePage` → 官方 `FadeThroughTransition`(260ms / reverse 0),与 tab 分支容器的 fade-through 同模式;`DurationTokens.tabPageTransitionIn/Out`(150/0ms)随之退役。
   - `foruiMaterialTheme()` 新增 `pageTransitionsTheme`:全平台(android/iOS/macOS/windows/linux/fuchsia)统一 `SharedAxisPageTransitionsBuilder(horizontal)`。**注意**:当前所有路由都自带 `pageBuilder`(`router_helpers.dart`),故该项是"未来未指定过渡的路由不再回落到平台默认"的兜底,而非现有路由生效点;真正的品牌统一来自上面两个 helper 的替换。
   - `PageStateSwitch`(today / medicine / mine / record / review legacy 兼容页共用)→ 官方 `PageTransitionSwitcher` + `FadeThroughTransition`:骨架 → 内容 → 错误之间的切换由硬替换变为 fade-through。要点:
     - `KeyedSubtree` 按**状态变体**取 key(loading/error/empty/ready),同变体内的数据刷新在原地更新、不重播动画;
     - 自定义 `layoutBuilder` 用 `StackFit.passthrough`,保住入参约束(record 页把它挂在 `SingleChildScrollView` 内,默认 loose Stack 会给子级无界约束);
     - 首次构建不播动画(`PageTransitionSwitcher` 首子项 `primaryController = 1.0`),页面首帧即时渲染。
   - 新增 `DurationTokens.pageStateSwitch`(240ms)。

## 6. 风险与权衡

| 项 | 评估 |
|---|---|
| 测试面 | 新增过渡/动画必须 `pumpAndSettle` 可收敛;tab 过渡建议 280–300ms 有界;shimmer 等无限动画既有规避先例 |
| go_router 版本 | 项目 17.3.0;升级 18.0 需回归(ShellRoute Hero 回归 #192043,与本次无关但记录) |
| flutter_animate | 限制规模;跟踪 flutter_animate_plus;不做路由过渡 |
| animations 3.0.0 | 已引入;与项目 material_ui 同源,类型零摩擦;OpenContainer 勿用于路由 |
| 平台一致性 | 全平台统一 M3 共享轴(`pageTransitionsTheme`)+ helper 内官方过渡,不再有桌面 Zoom / 移动原生混搭 |
| 过渡位移量级 | SharedAxis 水平位移为**固定约 30 逻辑像素**(非屏幕比例),比原 15% 更克制;移动端观感明显更"轻" |
| 不透明盖底 | `FadeThroughTransition` / `SharedAxisTransition` 退出侧会用 `fillColor`(默认 `Theme.canvasColor`)盖底;本项目 `canvasColor == scaffoldBackgroundColor`,使用点均在 scaffold 底色上,故不可见 |
| reduced-motion | 框架自动 + 自写判断;Forui/flow_ui 已内建 |

## 6.1 实测(profile trace,2026-09-12,Android · GLES · 60Hz · 592 帧 / 23.4s)

用 DevTools 性能快照(`traceBinary`,Perfetto protobuf)对"启动 → 切 tab → 进/退登录页 → 回今日 → AI 对话弹登录提示"整条链路做了解码分析。结论**修正了此前的判断**:

| 指标 | 实测 |
|---|---|
| UI 线程帧耗时(`Frame`,build/layout/paint) | p50 **1.17ms** / p90 2.64ms / max 15.56ms;**超 16.67ms 预算 0 帧** |
| Raster 帧耗时(`GPURasterizer::Draw`) | p50 **15.31ms** / p90 18.23ms / p99 29.66ms;**超预算 153/591 帧(25.9%)** |
| 帧间隔 | p50 16.74ms ≈ 59.8fps |

- **瓶颈在 raster(GPU),不在 Dart 侧**。本项目新增的过渡全部在 UI 线程,只花 1–2ms,不是卡顿主因;raster 中位数已占满整个预算,因此任何额外 raster 开销都会掉帧。这也解释了"首次切 tab 卡顿":首次构建那一帧 UI 15.6ms + raster 29.7ms,UI 未超预算但整帧被 raster 拖垮。
- **骨架 shimmer 是启动阶段最大的一笔**:`InlineSkeletonCircle` / `InlineSkeletonSection` 各自包一层 `Shimmer.fromColors`,而每个 `Shimmer` = 一个 `ShaderMask` = **每帧一次 `saveLayer`**。实测启动期 `Canvas::saveLayer` ≈ **22 次/帧**、raster p50 15.7ms;内容加载后降到 1–5 次/帧、raster p50 3.7ms。→ 已修:`SkeletonShimmer` 引入作用域,嵌套实例不再创建 mask。
- **登录页进入的卡顿是真实且可修的**:`ImageCache.putIfAbsent` **41.8ms** + `listener` 41.7ms(`AssetBundleImageKey`),叠加 `ConcurrentMark` 31.3ms、3 次 `flutter/assets` 读取(8–13ms)。根因是 `app_icon.png` **1024×1024(解码位图 4MB)却按 24–64 逻辑像素渲染**。→ 已修:新增 `BrandIcon` 统一按显示尺寸解码(`cacheWidth/cacheHeight = size × dpr`)。
- 登录页**本身**渲染很便宜(raster p50 3.7–5.5ms),说明 auth 过渡实现无问题。
- 设备侧:trace 显示 **GLES 后端**(`ReactorGLES` / `SurfaceGLES` / `RenderPassGLES`)。若为模拟器,上述 raster 数字会被显著放大,真机需复测。

## 7. 参考链接

**官方**
- [PageTransitionsTheme API](https://api.flutter.dev/flutter/material/PageTransitionsTheme-class.html) · [StatefulShellRoute 文档](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html) · [custom_stateful_shell_route.dart 示例](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/others/custom_stateful_shell_route.dart) · [go_router transition-animations.md](https://github.com/flutter/packages/blob/main/packages/go_router/doc/transition-animations.md) · [M3 Motion overview](https://m3.material.io/styles/motion/overview/how-it-works) · [M3 easing/duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs) · [MDC Motion.md](https://github.com/material-components/material-components-android/blob/master/docs/theming/Motion.md) · [Easing class](https://api.flutter.dev/flutter/material/Easing-class.html) · [Android 默认过渡 breaking change](https://docs.flutter.dev/release/breaking-changes/default-android-page-transition) · [MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) · [reduceMotion PR #190287](https://github.com/flutter/flutter/pull/190287) · [Hero 跨分支 issue #192043](https://github.com/flutter/flutter/issues/192043)

**社区**
- [animations](https://pub.dev/packages/animations) · [flutter_animate](https://pub.dev/packages/flutter_animate) · [flutter_animate_plus](https://pub.dev/packages/flutter_animate_plus) · [page_transition](https://pub.dev/packages/page_transition) · [motion](https://pub.dev/packages/motion)(GPL-3) · [rive](https://pub.dev/packages/rive) · [lottie](https://pub.dev/packages/lottie) · [go_router_animated_branch](https://pub.dev/packages/go_router_animated_branch) · [OpenContainer+go_router issue #121929](https://github.com/flutter/flutter/issues/121929) · [shell tab 动画 issue #134418](https://github.com/flutter/flutter/issues/134418) · [forui changelog](https://pub.dev/packages/forui/changelog)
