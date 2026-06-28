# UX 审计 HIGH 项 Phase 1：交互修复与返回按钮统一

> 父计划：`plans/2026-06-28-luminous-ux-audit-remediation-plan.md`  
> 范围：Luminous Flutter 客户端  
> 状态：**已完成**（2026-06-28）  
> 目标：消除无意义点击、修复死胡同页面、统一返回按钮组件。

---

## 1. 涉及问题

| 问题 | 文件 | 目标状态 |
|---|---|---|
| HIGH-10 | `lib/features/search/presentation/pages/search_page.dart` | 搜索页有明确的返回/关闭按钮 |
| HIGH-3 | `lib/features/today/presentation/widgets/today_dashboard_view.dart` | Today 空态按钮有真实跳转行为 |
| HIGH-4 / HIGH-5 | `lib/features/today/presentation/widgets/today_recommendation_section.dart` | "查看更多"是刷新；推荐行按类型真实导航 |
| HIGH-6 | `lib/features/medicine/presentation/widgets/medicine_mobile_quick_operations_section.dart` | 提醒入口可进入创建页，无药品时引导选药 |
| HIGH-9 / HIGH-11 | 新建 `lib/core/widgets/app_back_button.dart`，替换多处返回按钮 | 所有子页使用统一返回按钮 |

---

## 2. 决策摘要

- HIGH-3：保留按钮，跳转 `/record/create`。
- HIGH-4/5：
  - "查看更多"改为刷新行为（调用 provider refresh）。
  - 推荐行导航映射：
    - `medicine` → `/medicine`
    - `sleep` → `/record/create?kind=sleep`
    - `record` → `/record/create?kind=water`
    - `report` → `/report`
    - `habit` / 未知 / 无目标 → `/record`
- HIGH-6：fallback 改为 `/medicine/reminders/new`；创建页无药品时显示 inline 提示 + 跳转 `/medicine/search` 的按钮。
- HIGH-9/11：新建 `AppBackButton({String? fallbackRoute})`，默认 `/today`；优先 pop，无法 pop 时 fallback。

---

## 3. 实施步骤

### 3.1 HIGH-10：搜索页返回按钮

**文件**：`lib/features/search/presentation/pages/search_page.dart`

- [x] 移动端用 `PageScaffoldShell` 包装 `MedicineSearchView`。
- [x] 添加 `AppBar` + `AppBackButton()`。
- [x] 桌面端保持现有无边框布局（不添加返回按钮）。
- [x] 若 `PageScaffoldShell` 需要标题，新增/使用已有 l10n key（`medicineSearchPageTitle`）。
- [x] 更新 `test/search/search_page_test.dart`，验证返回按钮存在。

### 3.2 HIGH-3：Today 空态按钮

**文件**：`lib/features/today/presentation/widgets/today_dashboard_view.dart`

- [x] 找到 `TodayEmptyView` 中的 `AppStateMessageView`。
- [x] 将 `onAction: () {}` 改为 `onAction: () => context.push('/record/create')`。
- [x] 确认 `todayEmptyAction` 文案语义与跳转一致（保留）。
- [ ] 更新 `test/today/today_page_test.dart` 验证空态按钮可跳转。  
  > 注：`TodayEmptyView` 在当前生产代码中未被引用，是保留组件；未补充专项测试。

### 3.3 HIGH-4 / HIGH-5：推荐区交互

**文件**：`lib/features/today/presentation/widgets/today_recommendation_section.dart`

- [x] "查看更多"：`onAction` 改为 `_refresh(ref)`。
- [x] 推荐行 `InkWell.onTap` 按 `category` 映射到对应路由。
- [x] 移除 `AppToast.show(context, item.action)` 调用。
- [x] 更新 `test/today/today_page_test.dart`，新增推荐区 error 重试测试（与 Phase 4 合入）。

### 3.4 HIGH-6：提醒快速入口

**文件**：
- `lib/features/medicine/presentation/widgets/medicine_mobile_quick_operations_section.dart`
- `lib/features/medicine/presentation/pages/reminder/medicine_reminder_edit_page.dart`

- [x] 将提醒操作 fallback 改为 `context.push('/medicine/reminders/new')`。
- [x] 在提醒创建/编辑页中检测 `medicineId` 参数：
  - 若为 null 或空，显示 inline 提示："请先选择药品"。
  - 提供按钮跳转 `/medicine/search`，选药后带回 `medicineId`。
- [x] 新增 l10n key：`medicineReminderSelectMedicineHint`、`medicineReminderSelectMedicineAction`。
- [x] 更新 `test/medicine/medicine_reminder_pages_test.dart`，验证无药品时显示选药提示。

### 3.5 HIGH-9 / HIGH-11：统一返回按钮

**文件**：
- 新建 `lib/core/widgets/app_back_button.dart`
- `lib/features/settings/presentation/widgets/settings_components.dart`
- 各使用 `SettingsBackButton` 的页面

- [x] 新建 `AppBackButton`：
  ```dart
  class AppBackButton extends StatelessWidget {
    const AppBackButton({super.key, this.fallbackRoute});
    final String? fallbackRoute;
    ...
  }
  ```
- [x] 实现逻辑：
  - `GoRouter.of(context).canPop()` 为 true → `context.pop()`。
  - 否则 → `context.go(fallbackRoute ?? '/today')`。
- [x] 第一阶段：在 settings 子页、record 子页、medicine 子页、mine 编辑页、assistant 页、risk-check 页中替换 `SettingsBackButton` 为 `AppBackButton`。
- [x] 删除 `settings_components.dart`（原 `SettingsBackButton` 定义文件）。
- [ ] 保留自定义 `onPressed` 的透传能力。  
  > 当前 `AppBackButton` 未暴露 `onPressed`，子页无此需求；若后续需要可扩展。
- [ ] 第二阶段（Phase 2 Shell 改造后）：验证所有子页返回行为。
- [ ] 第三阶段：替换 `AuthBackButton`，auth 页可传 `fallbackRoute: '/'`。
- [ ] 删除或标记 `AuthBackButton` 为 deprecated。
- [x] 更新相关 widget tests。

---

## 4. 验收标准

- [x] `SearchPage` 移动端有可见的返回按钮。
- [x] Today 空态按钮点击后进入 `/record/create`（组件保留）。
- [x] 推荐区"查看更多"点击后刷新推荐列表，不再 toast。
- [x] 推荐行按类型正确导航。
- [x] 提醒快速入口进入创建页；无药品时显示选药引导。
- [x] `AppBackButton` 存在且被非 auth 子页使用。
- [x] `flutter analyze` 无错误。
- [x] `flutter test` 全量通过（489 / 489）。

---

## 5. 风险与回滚

| 风险 | 缓解 |
|---|---|
| 推荐行导航破坏现有测试 | 先补测试再改代码 |
| `AppBackButton` 与 `SettingsBackButton` 视觉差异 | 统一使用 `BackButton` 样式，保留颜色参数 |
| 提醒创建页选药引导增加复杂度 | 只做 inline 提示 + 跳转按钮，不改动搜索页返回逻辑 |

---

## 6. 后续工作

- `AuthBackButton` 替换留给 Phase 2 / 后续 UX 阶段处理（需验证登录返回路径）。
- Phase 2 Shell 路由改造完成后，统一验证所有子页返回行为。
