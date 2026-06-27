# Desktop Shell SaaS 骨架改造 PRD

## 背景

Luminous 目前已有基础的响应式骨架：
- 手机端使用底部 5 个 Tab（`NavigationBar`）。
- 桌面端（`width >= AppBreakpoints.desktop`，即 1200px）显示左侧固定侧边栏，右侧为内容区。

但随着业务功能增多，二级页面（添加药品、用药提醒、记录详情、设置等）都是全屏路由，进入后桌面侧边栏会消失，破坏了桌面 SaaS 平台的使用感。本次改造先聚焦“骨架”本身，目标是让桌面端达到“能用”的 SaaS 仪表盘体验，不追求每个 Tab 内部的完美响应式。

## 目标

1. **可折叠侧边栏**：桌面端侧边栏支持“宽形态（232px，图标+文字）”与“窄形态（72px，仅图标+Tooltip）”切换。
2. **Tab 常驻**：桌面端进入二级页面时，侧边栏不消失，内容在右侧内容区内嵌展示。
3. **嵌套路由**：使用 `go_router` 的 `StatefulShellRoute`，让二级页面拥有独立 URL 且刷新后仍处于 Shell 内。
4. **SaaS 质感**：固定导航、稳定的内容区边界、轻量动画，暂不做全局 Topbar。

## 非目标

- 不做全局顶部导航栏（Topbar）。
- 不改造各 Tab 页面内部的响应式细节（后续逐个 Tab 优化）。
- 不改动手机端行为：手机端二级页面仍保持当前全屏行为。
- 本次不引入窗口可拖拽改变侧边栏宽度。

## 关键定义

| 名称 | 值 / 说明 |
|---|---|
| 桌面断点 | `AppBreakpoints.desktop` = 1200px，≥ 此宽度显示侧边栏；< 1200px 显示底部导航。 |
| 宽边栏宽度 | 232px（与当前 `_DesktopSidebar` 一致）。 |
| 窄边栏宽度 | 72px，每个 Tab 项接近正方形。 |
| Tab 项高度 | 56px（窄边栏下视觉接近 72×56，仍偏“方块感”）。 |
| 动画时长 | 200ms，easeOutCubic。 |
| 持久化 Key | `luminous_desktop_sidebar_collapsed`（`shared_preferences`）。 |
| 默认状态 | 展开。 |

## 用户行为与需求

### FR-1 折叠/展开侧边栏

- 侧边栏顶部品牌行（Logo + “Luminous”）右侧放置一个折叠/展开按钮。
- 按钮在展开状态下显示“收起”图标（如 `Icons.chevron_left` 或 `Icons.menu_open`），在折叠状态下显示“展开”图标（如 `Icons.chevron_right` 或 `Icons.menu`）。
- 点击按钮后，侧边栏宽度在 232px 与 72px 之间切换，伴随抽屉式滑动动画。
- 切换过程中，内容区随之左右平移（由于侧边栏宽度变化，内容区宽度重新计算）。

### FR-2 窄边栏展示

- 窄边栏下每个 Tab 只显示图标，图标居中。
- 鼠标悬停（桌面）或长按（触屏）时显示 Tooltip，内容为 Tab 名称。
- 当前选中的 Tab 仍使用高亮背景/描边。
- 底部“设置”、“帮助”入口同样只显示图标。

### FR-3 Tab 常驻（桌面端）

- 桌面端点击 Tab 切换主页面（如 Today / Record / Medicine / Report / Mine）。
- 从 Tab 内进入二级页面（如 Medicine 的搜索 `/medicine/search`、添加提醒 `/medicine/reminders/new`、记录创建 `/record/create`、设置 `/settings`、通知 `/notifications`、AI 助手 `/assistant`）时，侧边栏保持可见，页面在右侧内容区渲染。
- 手机端行为不变：二级页面仍全屏覆盖。

### FR-4 路由与嵌套

- 使用 `go_router` 的 `StatefulShellRoute.indexedStack` 或等效方案。
- 可见 Tab 对应 Branch：
  - Today → `/`
  - Record → `/record`
  - Medicine → `/medicine`
  - Report → `/report`
  - Mine → `/mine`
- 非 Tab 但需内嵌的页面也作为独立 Branch（不在底部导航中显示）：
  - Settings → `/settings`（及其子路由 `/settings/language`、`/settings/theme`、`/settings/notifications`、`/settings/more`）
  - Assistant → `/assistant`
  - Notifications → `/notifications`（及 `/notifications/:id`）
- 以下页面保持全屏，不进入 Shell：
  - `/login`、`/register`、`/forgot-password`
  - `/account*`（账户管理相关）

### FR-5 状态持久化

- 侧边栏折叠状态使用 `shared_preferences` 持久化。
- 默认值：展开。
- 仅在桌面端有意义；手机端忽略该状态。

### FR-6 动画与质感

- 侧边栏宽度变化使用 `AnimatedContainer` 或等效动画，时长 200ms。
- 标签文字在展开时淡入，收起时淡出，避免文字被截断的突兀感。
- 内容区不强制重新布局，但允许因宽度变化产生自然的左右平移/重排。

### FR-7 移动端保持现状

- 底部 `NavigationBar` 仍显示 5 个可见 Tab。
- 二级页面（如 `/settings`）在手机端仍全屏显示。
- 侧边栏折叠状态不影响手机端。

## 边界与约束

- 隐藏 Branch（settings/assistant/notifications）的 `currentIndex` 不应触发底部导航高亮；移动端 `NavigationBar` 只绑定 5 个可见 Tab 的 index。
- 当处于隐藏 Branch 时，可见 Tab 均不高亮；侧边栏可保留一个“未选中任何主 Tab”的视觉状态。
- 返回手势/返回键：在内容区内部导航栈中正常工作。

## 验收标准

- [ ] 桌面端侧边栏有折叠按钮，点击可在 232px 与 72px 之间切换。
- [ ] 窄边栏下 Tab 仅显示图标，Tooltip 正常。
- [ ] 折叠状态刷新后保持。
- [ ] 桌面端访问 `/medicine/search`、`/settings`、`/assistant`、`/notifications` 时侧边栏仍在。
- [ ] 浏览器直接刷新上述 URL，页面正确渲染在 Shell 内容区内。
- [ ] 手机端访问 `/settings` 仍全屏显示，底部导航不出现。
- [ ] `flutter analyze` 无 issue，`flutter test` 相关测试通过。

## 风险

- `StatefulShellRoute` 改造会较大调整 `router.dart`，需确保现有 deep link 和 `context.push` 行为不变。
- 隐藏 Branch 的实现需要小心处理 index 映射，避免底部导航越界或高亮错误。
- 现有 widget/integration 测试可能依赖当前路由结构，需要同步更新。
