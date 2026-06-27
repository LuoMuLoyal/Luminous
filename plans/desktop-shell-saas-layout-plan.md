# Desktop Shell SaaS 骨架改造实施计划

对应 PRD：`plans/desktop-shell-saas-layout-prd.md`

## Phase 1：侧边栏折叠状态管理

### 目标
提供可持久化的桌面侧边栏折叠状态。

### 文件变更
- `lib/features/shell/providers/shell_sidebar_provider.dart`（新建）
  - `ShellSidebarState` / `ShellSidebarNotifier`
  - 读取/写入 `shared_preferences` key `luminous_desktop_sidebar_collapsed`
  - 默认 `expanded`
- `lib/features/shell/providers/shell_provider.dart`
  - 可选：保留 `shellProvider` 的 Tab index，不做破坏式改动。

### 验证
- 单元测试：provider 初始状态、toggle、持久化读写。

---

## Phase 2：路由改造为 StatefulShellRoute

### 目标
将当前平铺路由改造为嵌套路由，使非 auth 页面在桌面端保留 Shell。

### 文件变更
- `lib/app/router.dart`（大幅修改）
  - 引入 `StatefulShellRoute.indexedStack` / `StatefulShellBranch`。
  - 可见 Branch（5 个）：`today`、`record`、`medicine`、`report`、`mine`。
  - 隐藏 Branch（3 个）：`settings`、`assistant`、`notifications`。
  - 将以下现有路由移入对应 Branch：
    - `/medicine/search`、`/medicine/risk-check`、`/medicine/reminders/*`
    - `/record/create`、`/record/:id`、`/record/:id/edit`
    - `/mine/profile/edit`、`/mine/allergy/*`、`/mine/condition/*`、`/mine/medicine/*`
    - `/settings/*`、`/assistant`、`/notifications`、`/notifications/:id`
  - 保持以下路由为顶层全屏：
    - `/login`、`/login/oauth/wechat`、`/register`、`/forgot-password`
    - `/account`、`/account/oauth/wechat`、`/account/change-email`
  - 保留当前 slide/fade 转场动画。

### 关键设计
- 使用 `StatefulShellRoute` 的 `builder` 返回 `ShellPage`。
- `ShellPage` 接收 `child`（当前 Branch 的 Navigator）作为内容区。
- 隐藏 Branch 不渲染在底部导航；`NavigationBar` 仍只使用 5 个可见 `ShellTab`。

### 验证
- 运行 App，检查各 Tab 切换正常。
- 检查 `/medicine/search`、`/settings` 等 URL 在桌面端仍显示侧边栏。
- 检查 `/login` 仍全屏。

---

## Phase 3：侧边栏 UI 改造

### 目标
实现可折叠、带动画的桌面侧边栏。

### 文件变更
- `lib/features/shell/presentation/shell_page.dart`（大幅重构）
  - 将 `_DesktopSidebar` 拆出为独立 `DesktopSidebar` widget（仍可为 private，但内部结构清晰）。
  - 用 `AnimatedContainer` 包裹侧边栏，宽度在 232 ↔ 72 之间动画。
  - 监听 `shellSidebarProvider`。
  - 内容区保持 `Expanded(child: child)`，自然随侧边栏宽度变化。
- `lib/features/shell/presentation/shell_page.dart` 或新文件
  - 新增 `DesktopSidebarItem`：
    - 展开态：Row(Icon + label)，水平内边距 `md`。
    - 折叠态：Center(Icon)，宽度撑满，Tooltip 包裹。
  - 新增 `DesktopSidebarBrand`：
    - 展开态：Logo + “Luminous” + 折叠按钮。
    - 折叠态：仅 Logo + 展开按钮（或汉堡按钮）。
  - 底部 Settings / Help 项同样支持展开/折叠两种表现。

### 动画细节
- `AnimatedContainer(duration: 200ms, curve: Curves.easeOutCubic)`。
- 标签文字使用 `AnimatedOpacity` 控制显示/隐藏，避免折叠过程中文字溢出。
- 图标大小保持 18-20px，折叠态居中。

### 验证
- 桌面端手动测试折叠/展开动画。
- 检查窄边栏下 Tooltip。
- 检查选中态样式在两种状态下均正常。

---

## Phase 4：Tab 常驻与内容区适配

### 目标
确保二级页面在桌面端嵌入内容区，手机端仍全屏。

### 文件变更
- `lib/app/router.dart`
  - 已完成 StatefulShellRoute 改造后，二级页面自然在内容区渲染。
- `lib/features/shell/presentation/shell_page.dart`
  - 内容区容器保留当前圆角卡片、阴影、背景色。
  - 确保 `SafeArea` 和 `Padding` 不受侧边栏折叠影响。

### 验证
- 桌面端从 Medicine 进入“搜索药品”，侧边栏仍在。
- 桌面端从 Mine 进入“个人资料编辑”，侧边栏仍在。
- 手机端进入上述页面仍全屏。

---

## Phase 5：测试与回归

### 文件变更
- `test/app/shell_page_test.dart`
  - 更新现有测试：侧边栏存在、底部导航存在、Tab 切换。
  - 新增测试：折叠按钮存在、点击切换宽度、Tooltip。
- `test/app/router_test.dart`（如不存在则新建）
  - 测试 `/medicine/search`、`/settings`、`/assistant`、`/notifications` 在桌面 Shell 内渲染。
  - 测试 `/login` 不在 Shell 内。
- 更新受影响的 widget tests（如使用 `context.push('/settings')` 的测试可能需要改为 `go` 或验证当前 navigator）。

### 验证命令
```bash
cd Luminous
flutter analyze
flutter test test/app/shell_page_test.dart test/app/router_test.dart
gflutter test
```

---

## Phase 6：文档与提交

### 文件变更
- `Luminous/docs/migration-log/2026-06-27.md` 追加 Phase 6 实施记录。
- 提交信息示例：
  - `feat(shell): 桌面侧边栏支持折叠态与持久化`
  - `feat(router): 将业务二级页迁移到 StatefulShellRoute 以保留桌面侧边栏`
  - `refactor(shell): 拆分 DesktopSidebar 并统一折叠/展开动画`

### 验证
- 两个仓库均无未提交改动。
- CI（`flutter analyze` + `flutter test`）通过。

---

## 回滚策略

- 路由改造风险最高。实施时建议先在一个临时分支完成 Phase 2，验证所有 deep link 后再合并。
- 如 `StatefulShellRoute` 导致现有 `context.push` 行为异常，可退化为普通 `ShellRoute` + 手动维护 `Navigator`，但会牺牲 Tab 状态恢复。

## 时间预估

| Phase | 预估 |
|---|---|
| Phase 1 | 0.5h |
| Phase 2 | 3-4h |
| Phase 3 | 2-3h |
| Phase 4 | 1h |
| Phase 5 | 2-3h |
| Phase 6 | 0.5h |
| **合计** | **9-12h** |
