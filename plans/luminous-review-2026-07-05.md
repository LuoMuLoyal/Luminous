# Luminous 全项目审查报告 — 剩余未处理项

**审查日期：** 2026-07-05
**分支：** refactor
**审查范围：** 全项目（lib/ 目录）

> ⚠️ **修正说明：** 07-05 审查报告中 4 项曾被误标为"已解决"（重复组件名、层间解耦、动画时长、maxWidth），
> 经代码实查确认问题仍存在，已移回本表。
>
> 已完成项（裸 catch、路由拆分、Mock 日期、maxWidth 提取、动画时长、路由硬编码、i18n、
> 冗余组件删除、统一组件、层间解耦、Clock注入、button_styles评估、Web兼容验证）已从本文档删除。

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

### 2.1 超大页面（🟡）

| 文件 | 行数 | 问题 |
|------|------|------|
| `auth/.../login_page.dart` | 620+ | 含 QQ、Apple、手机号、邮箱多种登录 |
| `medicine/.../medicine_reminder_edit_page.dart` | 400+ | 日期/时间/重复/剂量混合 |

### 2.2 状态管理 Provider 一致性（🟡）

`FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一。

### 2.3 TODO 遗留 — record_fast_entry_choices.dart（🟡）

快速录入选项硬编码，TODO 要求改为远程/本地配置文件加载。

### 2.4 Mock 文件残留（🟡）

6 个 Mock 文件仍在 `data/repositories/` 中，虽已无业务引用，但建议移入 `test/` 目录或清理。

---

## 三、低优先级观察

### 3.2 !. 强制解引用（🟡 74 处）

半数以上在 `.freezed.dart` 生成代码中，业务代码约 30+ 处需逐步清理。

---

## 四、下一步评估

### 当前阶段定位

Forui 迁移主体已完成，Phase 1 退出条件基本满足（`flutter analyze` 通过，关键测试通过）。  
可以进入 **Phase 2：移动端 MVP 体验打磨**。

### 推荐执行顺序

| 顺位 | 任务 | 工作量 | 理由 |
|------|------|--------|------|
| **1** | 重复组件名提取 | 中 | 减少 24 处代码重复 |
| **2** | 日期解析复用 | 极小 | 消除重复逻辑 |
| — | Clock 注入、页面拆分 | **暂缓** | Phase Guide 明确"现在不要做" |
| — | Provider 一致性、Mock 清理 | **暂缓** | 非 Phase 2 目标 |

### 建议下一步

可以开始 **重复组件名提取** 或直接进入 **Phase 2 移动端体验打磨**。

---

*报告生成时间：2026-07-05*
*聚焦范围：仅保留未处理项，已完成项已移除*
