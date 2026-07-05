# Luminous 全项目审查报告 — 剩余未处理项

**审查日期：** 2026-07-05
**分支：** refactor
**审查范围：** 全项目（lib/ 目录）

> ⚠️ **修正说明：** 07-05 审查报告中 4 项曾被误标为"已解决"（重复组件名、层间解耦、动画时长、maxWidth），
> 经代码实查确认问题仍存在，已移回本表。
>
> **本轮修复完成项：** 裸 catch ✅、路由拆分 ✅、Mock 硬编码日期 ✅、maxWidth:560 提取 ✅、
> 动画时长统一 ✅、路由硬编码 ✅、i18n 硬编码字符串 ✅、冗余组件文件删除 ✅、统一组件创建 ✅。
>
> 已完成项已从本文档删除。以下仅保留尚未处理的遗留问题。

---

## 一、重复造轮子

### 1.1 重复私有组件名未提取（🟡 24 处）

以下私有组件在不同文件中重复定义，表明存在可提取的共享模式：

| 组件名 | 重复次数 | 所在文件 |
|--------|----------|----------|
| `_VerificationCodeField` | 4 | login_page、register_page、forgot_password_page、change_email_page |
| `_MineEditFormLoading` | 4 | profile_edit、allergy_edit、condition_edit、current_medicine_edit |
| `_SectionTitle` | 2 | medicine_reminder_form_body、meal_analysis_summary_card |
| `_SectionLabel` | 2 | theme_settings_page、notification_settings_page |
| `_SheetDragHandle` | 2 | record_ocr_entry_dialog、record_voice_entry_dialog |
| `_SoftIcon` | 2 | mine_archive_section、mine_status_overview |
| `_QuickActionTile` | 2 | medicine_quick_action_section、record_quick_actions |
| `_TrendPlaceholder` | 2 | report_trend_section、report_skeleton_view |
| `_AiSummaryPlaceholder` | 2 | today_skeleton_view、report_skeleton_view |
| `_IconActionButton` | 2 | record_quick_entry_panel、mine_top_bar |

**建议：** 提取到 `core/widgets/shared/` 中复用。

---

## 二、维护隐患

### 2.1 路由数量膨胀（🟡 42 个 GoRoute — 已拆分 ✅）

`lib/app/router.dart` 中 42 个 GoRoute 已按 feature 拆分到 `lib/app/router/` 子文件：
- `router_settings.dart` → `settingsRoutes`
- `router_auth.dart` → `authRoutes`
- `router_account.dart` → `accountRoutes`
- `router_record.dart` → `recordRoutes`
- `router_medicine.dart` → `medicineRoutes`
- `router_mine.dart` → `mineRoutes`
- `router_notifications.dart` → `notificationsRoutes`
- `router_assistant.dart` → `assistantRoute`
- `router_scan.dart` → `scanRoute`

主 `router.dart` 从 418 行缩减至 ~100 行，仅保留 StatefulShellBranch + 各 feature 路由的 spread。

### 2.2 层间耦合未完全解耦（🟡 7 处 — 已修复 ✅）

6 个 Provider 不再直接 import mock 实现类。通过以下方式解耦：

1. 5 个仓库接口新增 `signedOutDashboard` / `signedOutWorkspace` 方法
2. Lucent 实现类返回空 signed-out 数据，Mock 实现类返回 mock 数据
3. Provider 中所有 mock 导入和 `kDebugMode` 分支移除，统一调用 `ref.watch(xxxRepositoryProvider).signedOutDashboard`
4. `main.dart` 中通过 `ProviderScope(overrides: [...])` 在 debug 模式注入 5 个 mock 仓库

### 2.3 超大页面（🟡）

| 文件 | 行数 | 问题 |
|------|------|------|
| `auth/.../login_page.dart` | 620+ | 含 QQ、Apple、手机号、邮箱多种登录 |
| `medicine/.../medicine_reminder_edit_page.dart` | 400+ | 日期/时间/重复/剂量混合 |

### 2.4 Clock 抽象注入未完成（🟡）

`lib/core/utils/clock.dart` 的 TODO 仍未完成，业务代码约 15 处直接 `DateTime.now()`。

### 2.5 状态管理 Provider 一致性（🟡）

`FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一。

### 2.6 TODO 遗留 — record_fast_entry_choices.dart（🟡）

快速录入选项硬编码，TODO 要求改为远程/本地配置文件加载。

### 2.7 Mock 文件残留（🟡）

6 个 Mock 文件仍在 `data/repositories/` 中，虽已无业务引用，但建议移入 `test/` 目录或清理。

---

## 三、低优先级观察

### 3.1 button_styles.dart 评估（🟢 419 行）

`lib/theme/styles/button_styles.dart` 较大，需评估是否可通过 `forui` 的 `FButtonStyle` 主题定制替代。

### 3.2 结果解析/日期解析未复用（🟢）

`lucent_assistant_repository.dart` 的 `_parseDateTime()` 与 `lucent_today_ai_repository.dart` 的直接 `DateTime.parse()` 重复。

### 3.3 env_reader.dart Web 兼容性（🟢）

`dart:io` 的 `Platform.environment` 在 Web 端不可用，需确认实现是否已处理该兼容性问题。

### 3.4 !. 强制解引用（🟢 74 处）

半数以上在 `.freezed.dart` 生成代码中，业务代码约 30+ 处需逐步清理。

---

## 四、下一步评估

### 当前阶段定位

Forui 迁移主体已完成，Phase 1 退出条件基本满足（`flutter analyze` 通过，关键测试通过）。  
可以进入 **Phase 2：移动端 MVP 体验打磨**。

### 推荐执行顺序

| 顺位 | 任务 | 工作量 | 理由 |
|------|------|--------|------|
| **1** | button_styles 评估 | 小 | 确定是否可与 forui 合并 |
| **2** | 重复组件名提取 | 中 | 减少代码重复 |
| — | Clock 注入、页面拆分 | **暂缓** | Phase Guide 明确"现在不要做" |
| — | Provider 一致性、Mock 清理 | **暂缓** | 非 Phase 2 目标 |

### 建议下一步

所有 P1 架构债已清偿。可以开始 **button_styles 评估** 或直接进入 **Phase 2 移动端体验打磨**。

---

*报告生成时间：2026-07-05*
*聚焦范围：仅保留未处理项，已完成项已移除*
