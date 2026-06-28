# Luminous UX 审计整改计划

> **来源**：`Luminous/docs/review/luminous-ux-audit-report.md`（审计日期 2026-06-27）  
> **创建时间**：2026-06-28  
> **范围**：Luminous Flutter 客户端（`lib/app/router.dart`、`lib/features/*`、`lib/core/widgets/*`）  
> **目标**：消除报告中 6 项 Critical、12 项 High、14 项 Medium、8 项 Low 问题，使产品从“能跑”达到可用、可信、导航一致的体验基线。

---

## 1. 问题确认与总览

审计报告将问题分为 6 大类。经确认，以下问题必须在本计划中解决：

| 类别 | Critical | High | Medium | Low |
|---|---:|---:|---:|---:|
| 假数据 / Mock 数据 | 1 | 2 | 1 | — |
| 可点击元素反馈 | 1 | 4 | 2 | 1 |
| 页面导航与路由 | 1 | 2 | 3 | 1 |
| 返回键 / 返回按钮 | — | 3 | 2 | 1 |
| 延迟 / MVP 功能混淆 | — | — | 1 | 1 |
| 通用 UX | — | 2 | 4 | 3 |
| **合计** | **6** | **12** | **14** | **8** |

### 1.1 最紧急的 5 个问题（先修）

1. **CRIT-1**：5 个主 Tab 加载状态直接展示逼真 Mock 数据，造成“已加载”错觉。
2. **CRIT-2**：`/settings/theme`、`/settings/language`、`/settings/more` 在 `router.dart` 中无定义，点击即崩溃/空白。
3. **CRIT-3**：`/notifications` 注册为 `StatefulShellBranch`，但对应页面文件不存在。
4. **HIGH-7 / HIGH-8**：Shell 路由架构不一致，`record/*` 子页保留底部导航而 `medicine/*` 子页没有；Settings / Assistant / Notifications 作为隐藏 ShellBranch 导致底部导航突兀消失。
5. **HIGH-10**：`SearchPage` 没有任何返回/关闭按钮，用户可能被困。

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

### Phase 1：修复崩溃与死胡同（Critical + 关键 High）

**目标**：消除所有会导致崩溃、空白页或完全无反馈的路径。

#### 3.1 修复缺失/错误的路由（CRIT-2, CRIT-3, HIGH-10, MED-4）

| 问题 | 文件 | 动作 |
|---|---|---|
| CRIT-2 | `lib/app/router.dart` | 补全 `/settings/theme`、`/settings/language`、`/settings/more` 三个 `GoRoute`；对应页面已存在，直接 builder 指向即可。 |
| CRIT-3 | `lib/app/router.dart` | 决策：若近期不实现通知中心，则**移除** `/notifications` 的 `StatefulShellBranch` 及 `ShellBranch.notifications`；若保留，则新建 `NotificationsPage` 并接入未读数。 |
| HIGH-10 | `lib/features/search/presentation/pages/search_page.dart` | 添加 `AppBar` + 返回按钮；移动端优先使用 `PageScaffoldShell` + `AppBackButton`（见 3.4）。 |
| MED-4 | `lib/app/router.dart` | 删除 `/mine/medicine/new` 或改为重定向到 `/medicine/search`；避免 URL 与页面不符。 |

#### 3.2 移除加载态逼真 Mock 数据（CRIT-1, MED-1）

| 页面 | 当前问题 | 动作 |
|---|---|---|
| `today_page.dart` | `loading` 使用 `MockTodayRepository.previewDashboard` | 改为传入 `null`/空 dashboard，`TodayDashboardView` 内部根据 `isLoading` 展示 skeleton。 |
| `record_page.dart` | `loading` 使用 `MockRecordRepository.previewDashboard` | 同上，使用空数据 + skeleton。 |
| `medicine_page.dart` | `loading` 使用 `MockMedicineWorkspaceRepository.previewWorkspace` | 同上。 |
| `report_page.dart` | `loading` 使用 `MockReportRepository.previewDashboard` | 同上；日期范围标签在 loading/error 时显示 `--` 或 `l10n.reportLoadingDateRange`。 |
| `mine_page.dart` | `loading` 使用 `MockMineRepository.previewDashboard` | 同上。 |

- 复用 `AppSkeletonScope` / `AppSkeletonText`（已存在）。
- 若子组件不接受空数据，先在 `Phase 1` 内将其改为可空或增加 `isLoading` 分支。

#### 3.3 消灭无意义点击（HIGH-3, HIGH-4, HIGH-5, HIGH-6）

| 文件 | 问题 | 动作 |
|---|---|---|
| `today_dashboard_view.dart` | `TodayEmptyView` 的 `onAction` 为空回调 | 接入 `/record/create`；若该入口不应存在，则移除 `actionLabel`。 |
| `today_recommendation_section.dart` | “查看更多”只是刷新 | 将 action 改为刷新图标按钮，或实现 `/today/recommendations` 列表页。 |
| `today_recommendation_section.dart` | 推荐行点击只弹 toast | 根据推荐类型导航：药品 → `/medicine`，睡眠 → `/record/create?type=sleep`，否则移除 `InkWell`。 |
| `medicine_mobile_quick_operations_section.dart` | 提醒入口 fallback 弹 tooltip toast | 始终导航到 `/medicine/reminders/create`；若当前上下文无药品，则在创建页内引导先选药。 |

#### 3.4 统一返回按钮组件（HIGH-9, HIGH-11）

- 新建/复用单一组件 `AppBackButton`（建议放在 `lib/core/widgets/app_back_button.dart`）。
- 行为：优先 `context.pop()`；无法 pop 时回退到安全路由（如 `/today`，不是 `/`）。
- 使用 `GoRouter.of(context).canPop()` 替代 `Navigator.of(context).canPop()`。
- 将 `AuthBackButton` 和 `SettingsBackButton` 全部替换为 `AppBackButton`。

---

### Phase 2：路由架构统一（HIGH-7, HIGH-8, MED-5, MED-6, MED-7）

**目标**：明确“全屏子页” vs “Shell 内子页”的划分，消除底部导航的突兀消失。

#### 3.5 决策：子页是否保留底部导航

**建议规则（需在计划中确认）**：
- **创建/详情/编辑类子页**：统一作为**顶层全屏路由**，进入时隐藏底部导航，使用 `AppBackButton` 返回。
- **主 Tab 内的筛选/次级列表**：可保留在 Shell 内。

**按此规则调整**：
- `record/*`（create / detail / edit）从 Shell 内移出，成为顶层 `GoRoute`。
- 或：将 `medicine/*` 子页移入 Shell，与 `record` 保持一致。

**推荐方案**：统一为**全屏子页**（更利于专注），即把 `record/*` 也移出 Shell。

#### 3.6 Settings / Assistant / Notifications 的处理

- 这三个页面不应是 `StatefulShellBranch`（它们不在底部导航中）。
- 改为**顶层 `GoRoute`**：`/settings`、`/assistant`、`/notifications`。
- 返回行为：从 Mine 进入 Settings → 返回 Mine；从 Settings 进入 Assistant → 返回 Settings。
- 使用 `AppBackButton` 默认行为即可满足（可 pop 时 pop，否则回退 `/today`）；如需更精确，可在入口点传 `from` 参数或维护历史栈。

#### 3.7 修复跨 Tab 跳转与嵌套 push（MED-5, MED-6, MED-7）

| 问题 | 文件 | 动作 |
|---|---|---|
| MED-5 | `report_page.dart` | 点击指标不再 `selectTab(1)`，而是 push `/record?filter=<kind>`（需后端/前端支持过滤参数；暂不支持时至少 push `/record`）。 |
| MED-6 | `assistant_page.dart` | `SettingsBackButton` 改为 `AppBackButton`；默认 pop，无法 pop 时回退 `/mine` 或 `/today`。 |
| MED-7 | `record_detail.dart` | 编辑按钮改用 `context.go('/record/$id/edit')` 或确认 `push` 在 Shell 改造后的行为正确。 |

---

### Phase 3：数据真实性与 Mock 治理（HIGH-1, HIGH-2, MED-8, LOW-4）

**目标**：让 Mock 数据一看就是假的，且不会进入生产持久化。

#### 3.8 Mock 数据标记化（HIGH-1）

- 所有 Mock Repository 中的字符串加 `[DEMO]` 前缀或使用明显占位符：
  - `displayName: '[DEMO] Lumi User'` → 或直接 `'__mock_user__'`
  - `email: 'placeholder@example.com'`
  - 药品名：`'[DEMO] 布洛芬缓释胶囊'`
  - ID：`demo-drug-001`（避免与真实 ID 冲突）
- 日期使用固定明显日期如 `DateTime(2099, 1, 1)` 或动态 `DateTime.now()`。

#### 3.9 搜索 Mock 结果隔离（HIGH-2）

- `mock/mock_repository.dart` 返回的 `MedicineSearchResult` 应带 `isDemo: true` 标记，或在添加药品时阻止写入真实 `sourceRefId`。
- **更稳妥方案**：在生产构建中让搜索仓库 throw `UnimplementedError` 或返回空列表，直到真实搜索接口就绪。

#### 3.10 清理延迟功能残留（MED-8, LOW-4）

- 若 `quickActions` 字段确认不用于当前 MVP，从 workspace entity 中移除。
- 搜索所有 `quickActionCameraTitle` 引用，移除或加 `kDebugMode` 保护。

---

### Phase 4：通用 UX 与细节打磨（HIGH-12, HIGH-13 + Medium/Low）

#### 3.11 错误/空态补强

| 问题 | 文件 | 动作 |
|---|---|---|
| HIGH-12 | `today_recommendation_section.dart` | error 状态不再 `SizedBox.shrink()`，改为 `AppStateErrorView` + 重试。 |
| HIGH-13 | `medicine_reminder_detail_page.dart` | error 描述传入 `l10n.medicineReminderErrorDescription` 或通用错误文案。 |
| MED-9 | `report_page.dart` | error 状态添加 `AppBackButton` 或 `AppStateErrorView` 的返回动作。 |
| LOW-7 | `medicine_reminder_detail_page.dart` | 无提醒时隐藏删除按钮，或改为空态提示。 |
| LOW-1 | `medicine_mobile_drugbox_section.dart` | 确保 `currentMedicineId` 不为 null；若确实可能 null，则隐藏不可点击行。 |

#### 3.12 Settings 页增强（MED-2, MED-3, MED-10, MED-11）

| 问题 | 动作 |
|---|---|
| MED-2 | Help dialog 过滤掉无 URL 的资源，不显示禁用项。 |
| MED-3 | About dialog 增加隐私政策、服务条款、开源许可、支持联系、build number。 |
| MED-10 | 数据共享同意行点击先弹出确认 dialog，确认后再 toggle。 |
| MED-11 | 导出按钮统一导航到 `/settings/export`；若决定保留行内导出，则删除 `/settings/export` 路由。 |

#### 3.13 布局与 SafeArea 细节（LOW-5, LOW-8）

| 问题 | 文件 | 动作 |
|---|---|---|
| LOW-5 | `page_scaffold_shell.dart` | FAB 的 `bottom` 增加 `MediaQuery.paddingOf(context).bottom`。 |
| LOW-8 | `today_dashboard_view.dart` | 底部 padding 改用 `MediaQuery.paddingOf(context).bottom + bottomNavHeight` 或 `SafeArea`。 |

#### 3.14 登录返回路由验证（LOW-2）

- 审阅 `loginRouteForCurrentLocation` 与 `loginRouteForReturnTo` 的实现，确保 URL 编码正确、登录后确实回到原页面。
- 补充单元测试覆盖常见路径：`/today`、`/record/create`、`/medicine/search`。 |

#### 3.15 滚动位置保留验证（LOW-6）

- 检查各 Tab 列表 `PageStorageKey` 的唯一性和一致性。
- 手动验证切换 Tab 后滚动位置是否保留；若不行，统一 key 命名。 |

---

## 4. 验收标准

完成全部 Phase 后，必须满足：

1. **无崩溃路由**：`/settings/theme`、`/settings/language`、`/settings/more` 能正常打开；`/notifications` 要么有页面、要么已从 router 移除。
2. **无逼真 Mock 数据**：5 个主 Tab 在 loading 时显示 skeleton，不出现 `Lumi User`、`lumi@example.com`、`92% adherence` 等字样。
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
| `/notifications` 是否保留？ | 若 MVP 无通知中心，建议移除；后续需要时重新设计。 | 影响 `ShellBranch` 枚举。 |
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
Phase 1.1 路由补全/移除      → 消除崩溃
Phase 1.2 加载态 skeleton    → 消除假数据
Phase 1.3 无意义点击修复      → 消除死胡同
Phase 1.4 AppBackButton 组件  → 统一返回行为
Phase 2   Shell 路由架构改造  → 一致性
Phase 3   Mock 数据治理       → 数据可信
Phase 4   UX 细节打磨         → 体验完整
```

每个 Phase 完成后运行：

```bash
flutter analyze
flutter test
```

---

*本计划为整改期间的活跃执行文档。完成后，将稳定决策写入 `docs/Current_State.md`、`docs/Next_Plan.md` 与当日 `docs/migration-log/YYYY-MM-DD.md`，并删除本计划。*
