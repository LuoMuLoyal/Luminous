# Luminous 多端覆盖规划

最后更新: 2026-05-29

> 从当前"手机端优先"出发，逐步扩展到桌面端（Windows/macOS）和 Web 端，
> 参考 Apple.com 设计语言打造高端健康助手体验。

---

## 当前状态

| 维度           | 现状                                                    |
| -------------- | ------------------------------------------------------- |
| 断点系统       | ✅ 已有 4 档：compact / medium / expanded / webExpanded |
| 导航切换       | ✅ compact=底部TabBar, medium+=NavigationRail           |
| 内容宽度限制   | ✅ AppContentWidths 已定义最大宽度                      |
| 页面响应式     | ⚠️ 仅 HomePage、DrugPage 有局部适配                     |
| Master-Detail  | ❌ 未实现（桌面端核心交互模式）                         |
| 桌面端专属组件 | ❌ 无                                                   |
| 键盘/鼠标交互  | ❌ 无专门适配                                           |
| 多窗口/拖拽    | ❌ 无                                                   |

---

## 设计理念

### 核心原则

1. **一套代码，两种表达** — 同一套业务逻辑，compact 和 expanded 各自的 UI 壳
2. **手机端是"一页一任务"** — 全屏沉浸，底部 Tab 切换
3. **桌面端是"一览全局"** — 侧边栏 + 多面板，信息密度高
4. **Apple 设计语言为参考** — 干净、留白、单一强调色、无装饰阴影

### 设计参考（DESIGN.md）

从 Apple.com 提取可复用的设计语言：

| 设计元素     | 手机端表达                | 桌面端表达                 |
| ------------ | ------------------------- | -------------------------- |
| 单一强调色   | 当前 theme.primary        | Action Blue #0066cc 风格   |
| 负字距标题   | 17px+ 标题 -0.12~-0.374px | 同上，但字号更大           |
| 交替深浅区块 | 卡片背景交替              | 全宽 tile 交替             |
| 极简阴影     | 仅产品图有阴影            | 同上                       |
| 胶囊按钮     | 主要 CTA                  | 同上                       |
| 毛玻璃导航   | —                         | 次级导航栏 backdrop-filter |

---

## 断点与布局策略

### 现有断点（保持不变）

```
compact:      0-599px    → 手机竖屏，底部 TabBar
medium:       600-839px  → 平板/手机横屏，NavigationRail（折叠）
expanded:     840-1199px → 小桌面/平板横屏，NavigationRail（展开）
webExpanded:  1200px+    → 大桌面，NavigationRail（展开）+ 更多列
```

### 布局映射

| 页面       | compact         | medium              | expanded / webExpanded                      |
| ---------- | --------------- | ------------------- | ------------------------------------------- |
| 首页(今日) | 单列卡片流      | 双列网格            | Master-Detail：左侧日程列表 + 右侧详情      |
| 记录       | 全屏日历+时间线 | 日历左侧 + 记录右侧 | 三栏：日历 \| 记录列表 \| 详情              |
| 用药       | 药品列表        | 双列网格            | Master-Detail：左侧药品列表 + 右侧详情/提醒 |
| 我的       | 纵向滚动        | 双列信息卡          | 侧边信息 + 右侧内容区                       |
| 更多       | 列表菜单        | 双列功能卡          | 侧边菜单 + 右侧内容区                       |

---

## 分阶段实施

### Phase 1：基础适配层（1-2 周）🔴 当前

> 让现有页面在平板/小桌面端"能用"，不丑。

**1.1 统一页面宽度约束**

- 所有页面使用 `AppContentWidths` 限制最大可读宽度
- 创建 `AppCanvasPageScaffold` 通用页面壳（居中 + 最大宽度 + 内边距）
- 已有的 HomePage、DrugPage 的响应式逻辑提取为通用模式

**1.2 响应式网格组件**

- 统一 `ResponsiveQuickGrid` 的列数计算规则
- compact: 1-2 列, medium: 2-3 列, expanded: 3-4 列, webExpanded: 4-5 列
- 卡片间距随断点缩放：compact 12px → webExpanded 24px

**1.3 NavigationRail 增强**

- expanded 桌面端使用展开式 NavigationRail（带文字标签）
- 添加用户头像/设置入口到 Rail 底部
- Rail 宽度：折叠 72px / 展开 228px

**1.4 字号缩放**

- 创建 `AppTypographyScale` 根据断点自动缩放
- compact: 基准 14px body → expanded: 16px body
- 标题按比例放大，保持负字距

---

### Phase 2：桌面端核心交互（2-3 周）

> 让桌面端"好用"，信息密度和效率提升。

**2.1 Master-Detail 模式**

- 用药页：左侧药品列表（可搜索/筛选）+ 右侧详情面板
- 今日页：左侧日程时间线 + 右侧健康指标/建议
- 记录页：日历 + 记录列表 + 详情三栏
- 使用 `TwoPane` 或自定义 `Row` 实现

**2.2 桌面端专属导航**

- 顶部全局导航栏（Apple global-nav 风格）
  - 高度 44px，纯黑背景
  - 左侧 Logo + 主导航链接
  - 右侧搜索、通知、用户头像
- 次级导航栏（sub-nav-frosted 风格）
  - 高度 52px，毛玻璃背景
  - 当前页面标题 + 功能入口

**2.3 键盘快捷键**

- `Cmd/Ctrl + K` 全局搜索
- `Cmd/Ctrl + ,` 打开设置
- `1-5` 数字键切换 Tab
- `Esc` 关闭弹窗/返回

**2.4 鼠标交互增强**

- 悬停状态：卡片 hover 边框高亮
- 右键菜单：药品卡片右键 → 添加提醒/查看详情
- 拖拽排序：提醒列表支持拖拽排序

---

### Phase 3：视觉升级（1-2 周）

> 让桌面端"好看"，对标 Apple 设计语言。

**3.1 Apple 风格色彩系统**

- 参考 DESIGN.md 的单色强调策略
- 当前 5 套主题保留，但桌面端默认使用更克制的配色
- 深色 tile 交替：`#272729` / `#2a2a2c` / `#252527` 微步进

**3.2 排版升级**

- 桌面端标题使用 SF Pro Display 风格（负字距）
- body 文字 17px（Apple 标准，比常规 16px 多 1px）
- 行高系统：标题 1.07-1.19 / 正文 1.47 / 密集链接 2.41

**3.3 组件视觉升级**

- 胶囊按钮：`rounded: pill`（9999px）替代当前圆角
- 卡片阴影：仅产品图有 `rgba(0,0,0,0.22) 3px 5px 30px`
- 毛玻璃效果：次级导航栏 `backdrop-filter: blur(20px)`
- 按压反馈：`transform: scale(0.95)` 统一微交互

**3.4 全宽 Tile 布局（桌面端首页）**

- 交替深浅全宽区块（product-tile 风格）
- 每个区块：标题 → 描述 → CTA → 产品图
- 80px 垂直内边距，内容居中最大宽度 980px

---

### Phase 4：平台专项优化（持续）

**4.1 Windows/macOS 桌面端**

- 窗口最小尺寸：360×600
- 原生标题栏集成（自定义标题栏或系统标题栏）
- 系统托盘图标 + 快速操作
- 通知集成（Windows Toast / macOS Notification Center）
- 自动更新机制

**4.2 Web 端**

- SEO 优化（Flutter Web 的 meta tags）
- URL 深链接（GoRouter 已支持）
- 浏览器前进/后退适配
- PWA 支持（离线缓存）
- 响应式图片加载（srcset 风格）

**4.3 平板端**

- 横屏优化：Master-Detail 默认展开
- 分屏支持：iPad/Android 平板分屏适配
- Apple Pencil / 手写笔输入（记录页面）

---

## 组件架构

### 通用适配壳

```
lib/shared/layout/
├── app_breakpoints.dart          ← 断点定义 ✅ 已有
├── app_adaptive_scaffold.dart    ← 自适应壳 ✅ 已有
├── content_constraints.dart      ← 内容宽度 ✅ 已有
├── app_typography_scale.dart     ← 字号缩放 🔜 Phase 1
├── app_canvas_page_scaffold.dart ← 通用页面壳 🔜 Phase 1
└── master_detail_scaffold.dart   ← Master-Detail 壳 🔜 Phase 2
```

### 桌面端专属组件

```
lib/shared/widgets/desktop/
├── global_nav_bar.dart           ← 顶部全局导航 🔜 Phase 2
├── sub_nav_frosted.dart          ← 毛玻璃次级导航 🔜 Phase 2
├── hover_card.dart               ← 悬停高亮卡片 🔜 Phase 2
├── context_menu.dart             ← 右键菜单 🔜 Phase 2
├── keyboard_shortcuts.dart       ← 快捷键管理 🔜 Phase 2
└── full_bleed_tile.dart          ← 全宽交替区块 🔜 Phase 3
```

### 页面适配模式

```dart
// 每个页面的 build 方法统一模式：
@override
Widget build(BuildContext context, WidgetRef ref) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);

      return switch (windowClass) {
        AppWindowClass.compact => _buildMobileLayout(context, ref),
        AppWindowClass.medium => _buildTabletLayout(context, ref),
        _ => _buildDesktopLayout(context, ref),
      };
    },
  );
}
```

---

## 文件改动清单

### Phase 1 改动

| 文件                                                                     | 改动            |
| ------------------------------------------------------------------------ | --------------- |
| `lib/shared/layout/app_typography_scale.dart`                            | 🆕 创建         |
| `lib/shared/layout/app_canvas_page_scaffold.dart`                        | 🆕 创建         |
| `lib/shared/widgets/responsive_quick_grid.dart`                          | ✏️ 统一列数规则 |
| `lib/features/home/presentation/pages/home_page.dart`                    | ✏️ 使用通用壳   |
| `lib/features/drug/presentation/drug_page.dart`                          | ✏️ 使用通用壳   |
| `lib/features/mine/presentation/mine_page.dart`                          | ✏️ 添加响应式   |
| `lib/features/main_shell/presentation/widgets/main_navigation_rail.dart` | ✏️ 增强展开模式 |

### Phase 2 改动

| 文件                                                        | 改动                  |
| ----------------------------------------------------------- | --------------------- |
| `lib/shared/widgets/desktop/`                               | 🆕 创建桌面端组件目录 |
| `lib/features/main_shell/presentation/pages/main_page.dart` | ✏️ 添加桌面端顶部导航 |
| `lib/features/medicine/presentation/`                       | ✏️ Master-Detail 重构 |
| `lib/features/record/presentation/`                         | ✏️ 三栏布局           |
| `lib/router/app_router.dart`                                | ✏️ 添加桌面端路由     |
| `lib/core/theme/app_theme_spec.dart`                        | ✏️ 添加桌面端色彩     |

---

## 跳过/暂缓

- ~~Watch 端~~ — 短期不考虑
- ~~TV 端~~ — 不适用
- ~~嵌入式~~ — 不适用
- 国际化 RTL 布局 — 等有需求时再做
- 无障碍（Accessibility）— 持续改进，非阻塞

---

## 验收标准

### Phase 1 完成标准

- [ ] 所有 5 个 Tab 页在 600px+ 宽度下不出现水平滚动
- [ ] 所有页面在 1200px+ 宽度下内容居中、最大宽度合理
- [ ] NavigationRail 在 expanded 档展开显示文字
- [ ] 卡片网格列数随断点自动调整
- [ ] 字号在桌面端适当放大

### Phase 2 完成标准

- [ ] 用药页支持 Master-Detail 模式
- [ ] 桌面端顶部全局导航栏可点击跳转
- [ ] 键盘快捷键可搜索、切 Tab
- [ ] 鼠标悬停卡片有视觉反馈

### Phase 3 完成标准

- [ ] 桌面端首页使用全宽交替 Tile 布局
- [ ] 胶囊按钮、毛玻璃导航等 Apple 风格组件就位
- [ ] 深色模式配色对标 DESIGN.md
- [ ] 按压反馈 scale(0.95) 统一应用
