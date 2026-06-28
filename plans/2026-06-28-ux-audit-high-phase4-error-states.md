# UX 审计 HIGH 项 Phase 4：错误/空态补强

> 父计划：`plans/2026-06-28-luminous-ux-audit-remediation-plan.md`
> 范围：Luminous Flutter 客户端
> 目标：补强 Today 推荐区和 Medicine 提醒详情页的错误状态。
>
> **状态**：已完成（2026-06-28）。验证：`flutter analyze` 无错误，`flutter test` 全量通过。

---

## 1. 涉及问题

| 问题 | 文件 | 当前事实 | 目标状态 |
|---|---|---|---|
| HIGH-12 | `lib/features/today/presentation/widgets/today_recommendation_section.dart` | error 状态为 `SizedBox.shrink()` | 显示 compact 错误视图 + 重试 |
| HIGH-13 | `lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart` | error description 为空字符串 | 区分 404 与通用错误，传入明确描述 |

---

## 2. 决策摘要

- 错误态组件使用现有 `AppStateErrorView`。
- 新增文案全部走 ARB。
- HIGH-13 区分：
  - 404 / 提醒不存在：使用 `l10n.medicineReminderNotFoundTitle`，description 传入"该提醒已被删除或不存在"。
  - 通用加载失败：title 用通用错误 title，description 用"加载提醒详情失败，请检查网络后重试"，action 为重试。

---

## 3. 实施步骤

### 3.1 HIGH-12：Today 推荐区错误态

**文件**：`lib/features/today/presentation/widgets/today_recommendation_section.dart`

- [ ] 新增/确认 ARB key：
  - `todayRecommendationErrorTitle`："推荐加载失败"
  - `todayRecommendationErrorDescription`："请检查网络后重试"
  - `todayRetryAction`："重试"
- [ ] 将 `error: (_, __) => const SizedBox.shrink()` 替换为：
  ```dart
  error: (_, __) => AppStateErrorView(
    title: l10n.todayRecommendationErrorTitle,
    description: l10n.todayRecommendationErrorDescription,
    actionLabel: l10n.todayRetryAction,
    onAction: () => ref.invalidate(todayRecommendationsProvider),
    compact: true, // 若 AppStateErrorView 支持 compact 模式
  )
  ```
- [ ] 若 `AppStateErrorView` 不支持 compact，考虑用 `Padding` + 较小字号实现，避免过度占用空间。
- [ ] 更新 `test/today/today_page_test.dart`，验证 error 状态显示 title/action。

### 3.2 HIGH-13：Medicine 提醒详情错误态

**文件**：`lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart`

- [ ] 新增/确认 ARB key：
  - `medicineReminderNotFoundDescription`："该提醒已被删除或不存在"
  - `medicineReminderGenericErrorTitle`："加载失败" 或 "出错了"
  - `medicineReminderGenericErrorDescription`："加载提醒详情失败，请检查网络后重试"
  - `medicineReminderRetryAction`："重试"
- [ ] 在 provider 层或页面层区分错误类型：
  - 判断错误是否为 404 / not found（可能需要 repository 抛出特定异常）。
  - 若无法区分，统一按通用错误处理。
- [ ] 修改 `error` builder：
  ```dart
  error: (error, _) {
    final isNotFound = error is MedicineReminderNotFoundException; // 或按错误类型判断
    return AppStateErrorView(
      title: isNotFound
          ? l10n.medicineReminderNotFoundTitle
          : l10n.medicineReminderGenericErrorTitle,
      description: isNotFound
          ? l10n.medicineReminderNotFoundDescription
          : l10n.medicineReminderGenericErrorDescription,
      actionLabel: l10n.medicineReminderRetryAction,
      onAction: () => ref.invalidate(medicineReminderDetailProvider(reminderId)),
    );
  }
  ```
- [ ] 若当前 repository 不抛出特定异常，可先用通用错误文案兜底，后续再细化。
- [ ] 更新 `test/medicine/medicine_reminder_pages_test.dart`，验证 error 状态文案。

---

## 4. 验收标准

- [ ] Today 推荐区加载失败时显示错误提示和重试按钮，不再是空白。
- [ ] Medicine 提醒详情加载失败时显示明确错误描述和重试按钮。
- [ ] 新增/修改文案全部来自 ARB，不硬编码中文。
- [ ] `flutter analyze` 无错误。
- [ ] `flutter test` 全量通过。

---

## 5. 风险与回滚

| 风险 | 缓解 |
|---|---|
| `AppStateErrorView` 不支持 compact 模式导致推荐区布局跳动 | 使用 Padding 包装或调整组件参数 |
| 无法精确区分 404 与通用错误 | 先用通用错误兜底，不阻塞交付 |
| 新增 ARB key 导致 l10n 生成失败 | 改完跑 `flutter gen-l10n` |
