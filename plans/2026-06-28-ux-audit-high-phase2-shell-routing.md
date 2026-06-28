# UX 审计 HIGH 项 Phase 2：Shell 路由架构统一

> 父计划：`plans/2026-06-28-luminous-ux-audit-remediation-plan.md`
> 范围：Luminous Flutter 客户端（`lib/app/router.dart`、`lib/features/shell/*`）
> 目标：消除 Shell 路由架构不一致，统一全屏子页体验。

---

## 1. 涉及问题

| 问题 | 当前事实 | 目标状态 |
|---|---|---|
| HIGH-7 / HIGH-8 | `/record/*`、`/medicine/*`、`/mine/*` 子页保留底部导航；`/settings`、`/assistant`、`/notifications` 是隐藏 ShellBranch，进入时底部导航突兀消失 | 创建/详情/编辑类子页统一为顶层全屏路由，进入时隐藏底部导航 |
| MED-5 | `report_page.dart` 点击指标调用 `selectTab(1)` | 改为 push `/record`（或带过滤参数） |
| MED-6 | `assistant_page.dart` 使用 `SettingsBackButton` | 使用 `AppBackButton` |
| MED-7 | `record_detail.dart` 编辑按钮路由行为需确认 | 与 Shell 改造后的行为对齐 |

---

## 2. 决策摘要

- 采用方案 A：创建/详情/编辑类子页统一为**顶层全屏 `GoRoute`**。
- 分两个子阶段执行：
  1. **子阶段 2.1**：将 `/settings`、`/assistant`、`/notifications` 三个隐藏分支改为顶层 `GoRoute`。
  2. **子阶段 2.2**：将 `/record/*`、`/medicine/*`、`/mine/*` 子页移出 Shell。
- 所有入口跳转从 `goBranch` / `go` 改为 `push`，保留返回栈。
- 返回行为统一使用 `AppBackButton`（已在 Phase 1 完成）。

---

## 3. 子阶段 2.1：隐藏分支改为顶层路由

### 3.1 文件变更

- `lib/app/router.dart`
  - [ ] 从 `StatefulShellRoute` 中移除 `/settings`、`/assistant`、`/notifications` 三个 `StatefulShellBranch`。
  - [ ] 在 `StatefulShellRoute` 同级添加顶层 `GoRoute`：
    - `/settings`（含子路由 `language`、`theme`、`more`、`notifications`、`notifications/sleep`、`ai`、`export`、`help`、`about`）
    - `/assistant`
    - `/notifications`（含子路由 `:id`）
  - [ ] 确保这些顶层路由的页面 builder 与现有行为一致。

- `lib/features/shell/presentation/shell_branch.dart`
  - [ ] 更新 `ShellBranch` enum，移除 `settings`、`assistant`、`notifications` 三个 hidden branch。
  - [ ] 同步更新 `ShellBranch.values`、`currentIndex` 等逻辑。

- `lib/features/shell/presentation/shell_page.dart`
  - [ ] 更新 `_onSettings`、`_onHelp`、assistant 入口：从 `navigationShell.goBranch(index)` 改为 `context.push('/settings')`、`context.push('/assistant')` 等。
  - [ ] 更新 `isHiddenBranch` 判断逻辑（若仍需要）。
  - [ ] 桌面端侧边栏的 settings/help/assistant 入口同样改为 `context.push`。

### 3.2 验证

- [ ] 访问 `/settings` 移动端全屏显示，底部导航不出现。
- [ ] 访问 `/settings` 桌面端侧边栏仍在（因为桌面 Shell 在顶层路由下也会渲染）。
- [ ] 从 Mine 进入 Settings，点击返回回到 Mine。
- [ ] `flutter test test/app/router_test.dart test/app/shell_page_test.dart` 通过。

---

## 4. 子阶段 2.2：业务子页移出 Shell

### 4.1 需移出的路由

- **record**：
  - `/record/create`
  - `/record/:id`
  - `/record/:id/edit`

- **medicine**：
  - `/medicine/search`
  - `/medicine/risk-check`
  - `/medicine/reminders/new`
  - `/medicine/reminders/:medicineId`
  - `/medicine/reminders/:medicineId/edit`

- **mine**：
  - `/mine/profile/edit`
  - `/mine/allergy/new`
  - `/mine/allergy/:id/edit`
  - `/mine/condition/new`
  - `/mine/condition/:id/edit`
  - `/mine/medicine/new`
  - `/mine/medicine/:id/edit`

### 4.2 文件变更

- `lib/app/router.dart`
  - [ ] 从 `/record`、`/medicine`、`/mine` 的 `routes` 列表中移除上述子路由。
  - [ ] 在 `StatefulShellRoute` 同级添加对应的顶层 `GoRoute`，保持现有 page builder 和转场动画。
  - [ ] 确保路由参数（`:id`、`:medicineId`）解析不变。

- `lib/features/shell/presentation/shell_page.dart`
  - [ ] 更新底部导航/侧边栏的选中态逻辑：当处于 `/record/create` 等顶层路由时，不再高亮任何主 Tab（因为不在 Shell 内）。
  - [ ] 或者：如果希望保留高亮，需要在 `ShellPage` 外部监听当前 location 并映射回主 Tab。

- 各入口页面
  - [ ] 检查所有 `context.go('/record/create')` 等调用，改为 `context.push('/record/create')` 以保留返回栈。
  - [ ] 验证从 `/record` 进入 `/record/create` 再返回，能回到 `/record`。

### 4.3 验证

- [ ] 移动端从 `/record` 进入 `/record/create`，底部导航隐藏。
- [ ] 从 `/record/create` 返回，回到 `/record`，底部导航恢复。
- [ ] 桌面端从 `/record` 进入 `/record/create`，侧边栏是否保留？（需要决策：全屏子页在桌面端是否也应隐藏侧边栏）
- [ ] `flutter test` 全量通过。

---

## 5. MED-5 / MED-6 / MED-7 同步处理

### 5.1 MED-5：Report 指标点击

**文件**：`lib/features/report/presentation/pages/report_page.dart`

- [ ] 找到指标点击调用 `selectTab(1)` 的代码。
- [ ] 改为 `context.push('/record')`。
- [ ] 若未来支持过滤参数，再扩展为 `context.push('/record?filter=<kind>')`。

### 5.2 MED-6：Assistant 返回按钮

**文件**：`lib/features/assistant/presentation/pages/assistant_page.dart`

- [ ] 将 `SettingsBackButton` 替换为 `AppBackButton`。
- [ ] 若需要自定义返回行为，传 `onPressed`。

### 5.3 MED-7：Record 详情编辑按钮

**文件**：`lib/features/record/presentation/pages/record_detail.dart`

- [ ] 检查编辑按钮当前使用 `context.go` 还是 `context.push`。
- [ ] 在 Shell 改造后，统一使用 `context.push('/record/$id/edit')`。
- [ ] 验证编辑完成后返回详情页。

---

## 6. 验收标准

- [ ] `/settings`、`/assistant`、`/notifications` 不是 `StatefulShellBranch`。
- [ ] `/record/*`、`/medicine/*`、`/mine/*` 子页是顶层 `GoRoute`。
- [ ] 进入全屏子页时移动端底部导航隐藏。
- [ ] 从全屏子页返回能回到进入前的页面。
- [ ] Report 指标点击跳转 `/record`。
- [ ] Assistant 页使用 `AppBackButton`。
- [ ] Record 详情编辑使用 `context.push`。
- [ ] `flutter analyze` 无错误，`flutter test` 全量通过。

---

## 7. 风险与回滚

| 风险 | 影响 | 缓解 |
|---|---|---|
| 路由结构大改导致 deep link 失效 | 高 | 子阶段 2.1 和 2.2 分开验证；每次改完跑 `router_test.dart` 和 `shell_page_test.dart` |
| `context.push` 与 `context.go` 混用导致返回栈混乱 | 中 | 统一检查所有子页入口，使用 `push` |
| 桌面端全屏子页是否隐藏侧边栏有争议 | 中 | 子阶段 2.2 实施前与用户确认 |
| 隐藏分支移除后 `ShellBranch` 索引变化 | 中 | 同步更新所有依赖 `ShellBranch.values.length` 的代码 |
