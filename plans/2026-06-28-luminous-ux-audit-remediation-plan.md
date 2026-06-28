# Luminous UX 审计整改计划

> **来源**：`Luminous/docs/review/luminous-ux-audit-report.md`（审计日期 2026-06-27）  
> **创建时间**：2026-06-28  
> **范围**：Luminous Flutter 客户端（`lib/app/router.dart`、`lib/features/*`、`lib/core/widgets/*`）  
> **目标**：消除报告中 12 项 High、11 项 Medium、8 项 Low 问题（Critical 项已清零），使产品从“能跑”达到可用、可信、导航一致的体验基线。

---

## 0. 决策确认与待确认边界

### 已确认决策

| 边界 | 决策 |
|---|---|
| HIGH-3：Today 空态按钮 | 保留，跳转 `/record/create` |
| HIGH-4/5：推荐类型导航 | `medicine` → `/medicine`；`sleep` → `/record/create?kind=sleep`；`record` → `/record/create?kind=water`；`report` → `/report`；`habit`/未知 → `/record`；"查看更多"改为刷新 |
| HIGH-6：提醒快速入口 | 允许从 dashboard 直接创建提醒，fallback 到 `/medicine/reminders/new`；创建页无药品时显示 inline 提示"请先选择药品" + 跳转 `/medicine/search` 的按钮 |
| HIGH-7/8：Shell 路由方案 | 方案 A，分两个子阶段：先移 `/settings`/`/assistant`/`/notifications` 三个隐藏分支为顶层 GoRoute，再移 `/record/*`/`/medicine/*`/`/mine/*` 子页为顶层全屏路由 |
| HIGH-9/11：AppBackButton | 新建 `AppBackButton`，支持自定义 `fallbackRoute`（默认 `/today`）；按顺序替换：先非 Shell 子页 `SettingsBackButton`，再移出 Shell 后验证，最后替换 `AuthBackButton` |
| HIGH-12/13：错误态文案 | 使用 l10n；HIGH-13 区分 404 与通用错误，通用描述为 "加载提醒详情失败，请检查网络后重试" |
| HIGH-1/2：Mock 数据 | mock repository 用户可见值加 `[DEMO]` / `--` / `demo@example.com` 等占位；搜索 mock ID 改为 `__mock_*__` |

### 待确认边界

当前所有 HIGH 项边界均已确认，无阻塞执行的问题。

### 子计划清单

本计划为总控文档，具体实施步骤见子计划：

- **Phase 1**：~~`plans/2026-06-28-ux-audit-high-phase1-interactions-and-back-button.md`~~ 已完成。实施结果记录在 `docs/Current_State.md` 与 `docs/migration-log/2026-06-28.md`。
- **Phase 2**：~~`plans/2026-06-28-ux-audit-high-phase2-shell-routing.md`~~ 已完成（HIGH-7/8、MED-5/6/7）。实施结果记录在 `docs/Current_State.md` 与 `docs/migration-log/2026-06-28.md`。
- **Phase 3**：~~HIGH-1/2 Mock 数据标记~~ 已完成。实施结果记录在 `docs/Current_State.md` 与 `docs/migration-log/2026-06-28.md`。
- **Phase 4**：~~`plans/2026-06-28-ux-audit-high-phase4-error-states.md`~~ 已完成（HIGH-12、HIGH-13）。实施结果记录在 `docs/Current_State.md` 与 `docs/migration-log/2026-06-28.md`。

---

## 1. 问题确认与总览

审计报告将问题分为 6 大类。经确认，以下问题必须在本计划中解决：

| 类别 | Critical | High | Medium | Low |
|---|---:|---:|---:|---:|
| 假数据 / Mock 数据 | 0 | 2 | 0 | — |
| 可点击元素反馈 | 0 | 4 | 2 | 1 |
| 页面导航与路由 | 0 | 2 | 3 | 1 |
| 返回键 / 返回按钮 | — | 3 | 2 | 1 |
| 延迟 / MVP 功能混淆 | — | — | 1 | 1 |
| 通用 UX | — | 2 | 4 | 3 |
| **合计** | **0** | **12** | **11** | **8** |

### 1.1 最紧急的问题（先修）

1. **HIGH-7 / HIGH-8**：Shell 路由架构不一致，`record/*` 子页保留底部导航而 `medicine/*` 子页没有；Settings / Assistant / Notifications 作为隐藏 ShellBranch 导致底部导航突兀消失。
2. **HIGH-10**：`SearchPage` 没有任何返回/关闭按钮，用户可能被困。

---

## 2. 整改原则

1. **不展示逼真假数据**：加载态统一使用 shimmer skeleton；Mock 数据要么带 `[DEMO]` 标记、要么仅在测试/开发构建生效。
2. **可点击必有反馈**：每个 `onTap` 必须有真实行为；临时不可用的入口要么隐藏、要么给出明确解释，不能是空回调或只弹 toast。
3. **路由一致性优先**：明确“全屏子页” vs “Shell 内子页”的划分规则，统一返回按钮组件。
4. **最小侵入**：尽量复用现有 `AppSkeletonScope`、`AppStateErrorView`、`AppToast`、`PageScaffoldShell`。
5. **ARB-only 文案**：新增用户可见文案必须进 `lib/l10n/app_zh.arb` / `app_en.arb`。
6. **测试跟上**：每个 Phase 的关键改动配套 widget/unit 测试，确保 `flutter test` 不回归。

---

## 3. 分阶段实施

### Phase 1：修复崩溃与死胡同（关键 High）— 已完成

**目标**：消除所有会导致崩溃、空白页或完全无反馈的路径。  
**实施细节**：见 `plans/2026-06-28-ux-audit-high-phase1-interactions-and-back-button.md`。

#### 3.1 修复缺失/错误的路由（HIGH-10, MED-4）

| 问题 | 文件 | 动作 |
|---|---|---|
| HIGH-10 | `lib/features/search/presentation/pages/search_page.dart` | 添加 `AppBar` + 返回按钮；移动端用 `PageScaffoldShell` 包装，返回按钮使用统一 `AppBackButton`（见 3.3）。 |
| MED-4 | `lib/app/router.dart` | 删除 `/mine/medicine/new` 或改为重定向到 `/medicine/search`；避免 URL 与页面不符。 |

#### 3.2 消灭无意义点击（HIGH-3, HIGH-4, HIGH-5, HIGH-6）

| 文件 | 问题 | 动作 |
|---|---|---|
| `today_dashboard_view.dart` | `TodayEmptyView` 的 `onAction` 为空回调 | **保留按钮**，`onAction` 改为 `() => context.push('/record/create')`。 |
| `today_recommendation_section.dart` | “查看更多”只是刷新 | **改为刷新行为**：保留文字但 action 改为 `ref.invalidate(...)` / `_refresh(ref)`；不实现独立列表页。 |
| `today_recommendation_section.dart` | 推荐行点击只弹 toast | **按推荐类型映射真实导航**（`category` 字符串来自后端，当前有 `medicine` / `sleep` / `record` / `report` / 默认 `habit`）：<br>- `medicine` → `context.push('/medicine')`<br>- `sleep` → `context.push('/record/create?kind=sleep')`<br>- `record` → `context.push('/record/create?kind=water')`<br>- `report` → `context.push('/report')`<br>- `habit` / 其他 → `context.push('/record')`<br>无明确目标类型的行移除 `InkWell`，避免无效点击。 |
| `medicine_mobile_quick_operations_section.dart` | 提醒入口 fallback 弹 tooltip toast | **允许从 dashboard 直接创建提醒**：fallback 改为 `context.push('/medicine/reminders/new')`；创建页内部处理无药品上下文时的引导（显示选药提示或跳转 `/medicine/search`）。 |

#### 3.3 统一返回按钮组件（HIGH-9, HIGH-11）

**决策**：新建 `lib/core/widgets/app_back_button.dart` 作为统一返回按钮。

- 行为：
  - 优先 `GoRouter.of(context).canPop()`；能 pop 则 `context.pop()`。
  - 无法 pop 时 fallback 到 `/today`（不是 `/`，避免回到 splash）。
- 替换范围：
  - `AuthBackButton` → `AppBackButton`（auth 相关页面）。
  - `SettingsBackButton` → `AppBackButton`（settings 子页、record 子页、medicine 子页、mine 编辑页、assistant 等所有使用处）。
- 删除或标记 `AuthBackButton`、`SettingsBackButton` 为 deprecated；若某些页面需要自定义 `onTap`，通过 `AppBackButton.onPressed` 透传，但默认行为必须走统一 fallback。
- 同步更新 `page_scaffold_shell.dart` 等组件中硬编码的返回按钮。

---

### Phase 2：路由架构统一（HIGH-7, HIGH-8, MED-5, MED-6, MED-7）— 已完成

**目标**：明确“全屏子页” vs “Shell 内子页”的划分，消除底部导航的突兀消失。  
**实施细节**：见 `docs/Current_State.md` 与 `docs/migration-log/2026-06-28.md`。

**决策**：采用方案 A——创建/详情/编辑类子页统一为顶层全屏 `GoRoute`，进入时隐藏底部导航；`/settings`、`/assistant`、`/notifications` 不再作为 `StatefulShellBranch`。

#### 3.4 全屏子页规则

**规则**：
- **创建/详情/编辑类子页**：统一作为**顶层全屏路由**，进入时隐藏底部导航，使用 `AppBackButton` 返回。
- **主 Tab 内的筛选/次级列表**：可保留在 Shell 内（当前无此类页面）。

**需移出 Shell 的路由**：
- `record/*`：`/record/create`、 `/record/:id`、 `/record/:id/edit`。
- `medicine/*`：`/medicine/search`、 `/medicine/risk-check`、 `/medicine/reminders/new`、 `/medicine/reminders/:medicineId`、 `/medicine/reminders/:medicineId/edit`。
- `mine/*`：`/mine/profile/edit`、 `/mine/allergy/new`、 `/mine/allergy/:id/edit`、 `/mine/condition/new`、 `/mine/condition/:id/edit`、 `/mine/medicine/new`、 `/mine/medicine/:id/edit`。
- 隐藏分支改为顶层：`/settings`、 `/settings/*`、 `/assistant`、 `/notifications`、 `/notifications/:id`。

**配套改动**：
- 从 `StatefulShellRoute` 中移除上述分支/子路由。
- 更新 `ShellBranch` enum，移除 hidden branches（settings/assistant/notifications）。
- `ShellPage` 中 `_onSettings`、 `_onHelp`、 assistant 入口从 `goBranch` 改为 `context.push('/settings')` 等。
- 所有入口点的 `context.go(...)` 若指向子页，改为 `context.push(...)` 以保留返回栈。

#### 3.5 Settings / Assistant / Notifications 的处理

- `/settings`、`/assistant`、`/notifications` 不再作为 `StatefulShellBranch`。
- 改为顶层 `GoRoute`，路由结构与现有子路由保持一致。
- 返回行为统一使用 `AppBackButton`：
  - 从 Mine 进入 Settings → pop 回 Mine。
  - 从 Settings 进入 Assistant → pop 回 Settings。
  - 无法 pop 时 fallback 到 `/today`。
- 入口跳转方式：`ShellPage` 中的 settings/help/assistant 图标从 `navigationShell.goBranch(index)` 改为 `context.push('/settings')` / `context.push('/assistant')`。
- `/notifications` 保留现有 `:id` 子路由，同样作为顶层路由。

#### 3.6 修复跨 Tab 跳转与嵌套 push（MED-5, MED-6, MED-7）

| 问题 | 文件 | 动作 |
|---|---|---|
| MED-5 | `report_page.dart` | 点击指标不再 `selectTab(1)`，而是 push `/record?filter=<kind>`（需后端/前端支持过滤参数；暂不支持时至少 push `/record`）。 |
| MED-6 | `assistant_page.dart` | `SettingsBackButton` 改为 `AppBackButton`；默认 pop，无法 pop 时回退 `/mine` 或 `/today`。 |
| MED-7 | `record_detail.dart` | 编辑按钮改用 `context.go('/record/$id/edit')` 或确认 `push` 在 Shell 改造后的行为正确。 |

---

### Phase 3：数据真实性与 Mock 治理（HIGH-1, HIGH-2, MED-8, LOW-4）— HIGH 部分已完成

**目标**：让 Mock 数据一看就是假的，且不会进入生产持久化。

> **HIGH-1 / HIGH-2 状态**：已完成。实施细节见 `docs/Current_State.md` 与 `docs/migration-log/2026-06-28.md`。MED-8、LOW-4 仍为待处理项。

#### 3.7 Mock 数据标记化（HIGH-1）— 已完成

- 所有 mock repository 已添加 demo-only 说明注释。
- 用户可见值已改为占位/demo 标记：
  - `MockMineRepository`：`[DEMO] User`、`demo@example.com`、`2099-01-01`。
  - `MockTodayRepository`：心率/血压/睡眠等数值改为 `--`。
  - `MockMedicineWorkspaceRepository`：hero 指标改为 `--`。
  - `MockRecordRepository`：血压/体重/趋势点改为 `--` 或空数组。

#### 3.8 搜索 Mock 结果隔离（HIGH-2）— 已完成

- `MockMedicineSearchRepository` 的 ID 改为 `__mock_cn_ibuprofen__` / `__mock_cn_acetaminophen__`。
- 名称/副标题/摘要加 `[DEMO]` 前缀，避免被误认为真实药品数据。
- 相关测试已同步更新。

#### 3.9 清理延迟功能残留（MED-8, LOW-4）

- 若 `quickActions` 字段确认不用于当前 MVP，从 workspace entity 中移除。
- 搜索所有 `quickActionCameraTitle` 引用，移除或加 `kDebugMode` 保护。

---

### Phase 4：通用 UX 与细节打磨（HIGH-12, HIGH-13 + Medium/Low）

#### 3.10 错误/空态补强（HIGH-12, HIGH-13）

| 问题 | 文件 | 动作 |
|---|---|---|
| HIGH-12 | `today_recommendation_section.dart` | error 状态改为 `AppStateErrorView` compact 版本：<br>- `title`: `l10n.todayRecommendationErrorTitle`<br>- `description`: `l10n.todayRecommendationErrorDescription`<br>- `actionLabel`: `l10n.todayRetryAction`<br>- `onAction`: `() => ref.invalidate(todayRecommendationsProvider)` |
| HIGH-13 | `medicine_reminder_detail_page.dart` | **区分错误类型**：<br>- 404 / 提醒不存在：`title` 用 `l10n.medicineReminderNotFoundTitle`，`description` 传入明确“提醒不存在”文案。<br>- 通用加载失败：`title` 用通用错误 title，`description`: `"加载提醒详情失败，请检查网络后重试"`，`actionLabel`: `"重试"`。
| MED-9 | `report_page.dart` | error 状态添加 `AppBackButton` 或 `AppStateErrorView` 的返回动作。 |
| ~~LOW-7~~ | `medicine_reminder_detail_page.dart` | 无提醒时已隐藏删除按钮。 |
| ~~LOW-1~~ | `medicine_mobile_drugbox_section.dart` | 已过滤 `currentMedicineId == null` 的药品行，避免不可点击行。 |

#### 3.11 Settings 页增强（MED-2, MED-3, MED-10, MED-11）— 已完成

| 问题 | 动作 |
|---|---|
| ~~MED-2~~ | `HelpSettingsPage` 过滤逻辑增加 `resource.available` 校验，不显示禁用项。 |
| ~~MED-3~~ | `AboutSettingsPage` 使用后端 `privacyPolicyUrl` / `termsOfServiceUrl` / `supportEmail`（带硬编码回退），并新增 `buildDate` 展示。 |
| ~~MED-10~~ | `SettingsPage` 数据共享同意行点击后先弹出确认 Dialog，确认后才调用 `setDataSharingConsent`。 |
| ~~MED-11~~ | 导出按钮统一导航到 `/settings/export`，与现有 `DataExportPage` 保持一致。 |

#### 3.12 布局与 SafeArea 细节（LOW-5, LOW-8）— 已完成

| 问题 | 文件 | 动作 |
|---|---|---|
| ~~LOW-5~~ | `page_scaffold_shell.dart` | FAB 的 `bottom` 已增加 `MediaQuery.paddingOf(context).bottom`。 |
| ~~LOW-8~~ | `today_dashboard_view.dart` | 移动端底部 padding 已改为 `AppSpacingTokens.x5l + MediaQuery.paddingOf(context).bottom`。 |

#### 3.13 登录返回路由验证（LOW-2）— 已完成

- 已审阅 `loginRouteForCurrentLocation` 与 `loginRouteForReturnTo`：使用 `Uri(path: '/login', queryParameters: {'returnTo': ...})` 编码，可正确回传含 query 参数的路径。
- 已补充 `test/auth/auth_required_dialog_test.dart`，覆盖 `/today`、`/record/create`、`/medicine/search` 及带 query 参数路径的编码与 round-trip。 |

#### 3.14 滚动位置保留验证（LOW-6）— 已完成

- 已检查各 Tab 列表 `PageStorageKey`：每个主 Tab 的移动/桌面布局均使用独立 key（`today-dashboard-*`、`medicine-*`、`record-*`、`report-*`、`mine-*`、`medicine-search-*`），无重复 key。
- 当前实现已满足切换 Tab 后滚动位置保留的前提，无需调整。 |

---

## 4. 验收标准

完成全部 Phase 后，必须满足：

1. **无崩溃路由**：`/settings/theme`、`/settings/language`、`/settings/more` 能正常打开；`/notifications` 已有对应页面。
2. **无逼真 Mock 数据**：5 个主 Tab 在 loading 时显示 skeleton，不出现 `Lumi User`、`lumi@example.com`、`92% adherence` 等字样（Critical 项已完成）。
3. **无空回调**：`flutter analyze` + 人工 grep 无 `onTap: () {}`、无“只弹 toast 无实际行为”的交互（明确的 toast 提示除外）。
4. **返回按钮一致**：所有子页使用 `AppBackButton`，`AuthBackButton` / `SettingsBackButton` 已删除或仅作为别名。
5. **路由架构清晰**：创建/详情/编辑子页统一为全屏路由或统一在 Shell 内，无混合情况。
6. **测试通过**：`flutter analyze` 无错误，`flutter test` 全绿。
7. **文档更新**：
   - 在 `docs/Current_State.md` 中更新路由架构与错误态现状。
   - 在 `docs/Next_Plan.md` 中删除已完成的项。
   - 在 `docs/migration-log/2026-06-28.md` 记录本次整改要点。

---

## 5. 风险与待决策事项

| 风险/决策 | 建议 | 备注 |
|---|---|---|
| `record/*` 移出 Shell 还是 `medicine/*` 移入 Shell？ | 推荐统一全屏子页（都移出）。 | 涉及多个文件的路径与返回行为。 |
| 搜索功能是否接入真实后端？ | 若未接入，生产构建中返回空或 throw。 | 避免 mock ID 污染真实数据。 |
| `AppBackButton` 默认回退到 `/today` 还是 `/`？ | 回退到 `/today`（`/ `是 splash）。 | 需在组件注释中说明。 |
| 推荐行“实际导航”需要哪些新路由？ | 先实现药品/睡眠/情绪三类映射；其余类型移除点击。 | 避免过度设计。 |

---

## 6. 相关文件清单

```text
lib/app/router.dart
lib/core/widgets/page_scaffold_shell.dart
lib/core/widgets/app_back_button.dart          # 新增或复用
lib/features/auth/presentation/widgets/auth_back_button.dart
lib/features/shell/presentation/shell_branch.dart
lib/features/shell/presentation/shell_page.dart
lib/features/today/presentation/pages/today_page.dart
lib/features/today/presentation/widgets/today_dashboard_view.dart
lib/features/today/presentation/widgets/today_recommendation_section.dart
lib/features/record/presentation/pages/record_page.dart
lib/features/record/presentation/pages/record_detail.dart
lib/features/medicine/presentation/pages/medicine_page.dart
lib/features/medicine/presentation/widgets/medicine_mobile_quick_operations_section.dart
lib/features/medicine/presentation/widgets/medicine_mobile_drugbox_section.dart
lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart
lib/features/medicine/presentation/pages/reminder/medicine_reminder_edit_page.dart
lib/features/report/presentation/pages/report_page.dart
lib/features/mine/presentation/pages/mine_page.dart
lib/features/search/presentation/pages/search_page.dart
lib/features/settings/presentation/pages/settings_page.dart
lib/features/assistant/presentation/pages/assistant_page.dart
lib/features/*/data/repositories/mock_*.dart
lib/l10n/app_zh.arb
lib/l10n/app_en.arb
```

---

## 7. 建议执行顺序

```text
Phase 1.1 路由补全/移除          → 消除崩溃（HIGH-10, MED-4）
Phase 1.2 无意义点击修复          → 消除死胡同（HIGH-3, HIGH-4/5, HIGH-6）
Phase 1.3 AppBackButton 组件      → 统一返回行为（HIGH-9/11）
Phase 2   Shell 路由架构改造      → 一致性（HIGH-7/8, MED-5/6/7）
Phase 3   Mock 数据治理（剩余项） → MED-8, LOW-4（HIGH-1/2 延后）
Phase 4   UX 细节打磨            → HIGH-12, HIGH-13, Medium/Low
```

每个 Phase 完成后运行：

```bash
flutter analyze
flutter test
```

---

*本计划为整改期间的活跃执行文档。完成后，将稳定决策写入 `docs/Current_State.md`、`docs/Next_Plan.md` 与当日 `docs/migration-log/YYYY-MM-DD.md`，并删除本计划。*
