# Luminous 全项目审查报告 — 剩余未处理项

**审查日期：** 2026-07-05
**分支：** refactor
**审查范围：** 全项目（lib/ 目录）

> ⚠️ **修正说明：** 07-05 审查报告中 4 项曾被误标为"已解决"（重复组件名、层间解耦、动画时长、maxWidth），
> 经代码实查确认问题仍存在，已移回本表。裸 catch 修复 ✅、冗余组件文件删除 ✅、统一组件创建 ✅ 三项确认完成。
>
> 已完成项已从本文档删除。以下仅保留尚未处理的遗留问题。

---

## 一、不优雅写法

### 1.1 i18n 硬编码字符串（🔴 11 处）

项目已有完善的 l10n 体系（`lib/l10n/`），但以下用户可见字符串仍直接硬编码：

| 位置 | 硬编码内容 | 类型 |
|------|------------|------|
| `scan/.../medicine_recognize_dialog.dart:50,74` | `Text('识别结果')` | 中文 |
| `scan/.../medicine_recognize_dialog.dart:113` | `Text('未能识别到药品信息')` | 中文 |
| `scan/.../medicine_recognize_dialog.dart:200` | `const Text('重新拍照')` | 中文 |
| `scan/.../medicine_recognize_dialog.dart:214` | `const Text('确认，查看详情')` | 中文 |
| `scan/.../medicine_box_scan_page.dart:24` | `const Text('选择识别方式')` | 中文 |
| `scan/.../barcode_scanner_page.dart:61` | `AppToast.show(..., '未找到该条码对应的药品')` | 中文 |
| `scan/.../barcode_scanner_page.dart:77` | `AppToast.show(..., '搜索失败: $e')` | 中文 |
| `auth/.../login_page.dart:618` | `const Text('Sign in with QQ')` | 英文 |
| `auth/.../login_page.dart:625` | `const Text('QQ callback link / code')` | 英文 |
| `auth/.../login_page.dart:640` | `const Text('Complete QQ sign-in')` | 英文 |

### 1.2 Mock 数据硬编码日期（🟡 3 处残留）

- `lib/features/report/data/repositories/mock_report_repository.dart:30-31`
  - `DateTime(2026, 6, 6)` / `DateTime(2026, 6, 12)`
- `lib/features/report/presentation/providers/report_dashboard_provider.dart:19-20`
  - `DateTime(2026, 6, 6)` / `DateTime(2026, 6, 12)`

**建议：** 替换为 `DateTime.now().subtract(const Duration(days: 7))` 等相对日期。

### 1.3 路由硬编码（🟡 6 处）

`'/'` 和 `'/login'` 直接硬编码，未使用 `AppRoutes` 常量：

| 位置 | 硬编码内容 |
|------|------------|
| `auth/.../login_page.dart:50` | `trimmed.startsWith('/')` |
| `auth/.../login_page.dart:65` | `context.go('/')` |
| `auth/.../login_page.dart:309` | `fallbackRoute: '/'` |
| `auth/.../forgot_password_page.dart:35` | `fallbackRoute: '/'` |
| `auth/.../register_page.dart:36` | `fallbackRoute: '/'` |
| `auth/.../register_page.dart:370` | `'/'` |

### 1.4 maxWidth: 560 魔法数字未统一（🟡 4 处）

`lib/core/widgets/common/app_dialog_shell.dart` 的默认参数 `maxWidth = 560` 是合理的参数化设计，但业务代码中仍有 4 处直接硬编码 560：

| 位置 | 说明 |
|------|------|
| `assistant/.../assistant_page.dart:260,278` | 2 处 `maxWidth: 560` |
| `assistant/.../assistant_message_bubble.dart:52` | `BoxConstraints(maxWidth: 560)` |
| `auth/.../auth_shell.dart:47` | `BoxConstraints(maxWidth: 560)` |

**建议：** 提取为 `ContentMaxWidth` 或 `FormMaxWidth` 常量统一引用。

### 1.5 动画时长未统一（🟡 3 处分散）

| 位置 | 时长 | 说明 |
|------|------|------|
| `auth/.../auth_shell.dart:171,175` | `180.ms` | 淡入动画 |
| `shell/.../shell_page.dart:17` | `200.ms` | 侧栏动画 |

**建议：** 创建 `AppAnimationDurations` 类集中管理。

---

## 二、重复造轮子

### 2.1 重复私有组件名未提取（🟡 24 处）

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

## 三、维护隐患

### 3.1 路由数量膨胀（🟡 42 个 GoRoute — 已拆分 ✅）

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

### 3.2 层间耦合未完全解耦（🟡 7 处）

Provider 仍直接 import 具体 mock 实现，而非依赖抽象接口：

| Provider | 直接依赖的 Mock |
|----------|----------------|
| `today_dashboard_provider.dart` | `mock_today_repository.dart` |
| `report_dashboard_provider.dart` | `mock_report_repository.dart` |
| `record_dashboard_provider.dart` | `mock_record_repository.dart` |
| `mine_dashboard_provider.dart` | `mock_mine_repository.dart` |
| `medicine_workspace_provider.dart` | `mock_medicine_workspace_repository.dart` |
| `medicine_reminder_providers.dart` | `mock_medicine_workspace_repository.dart` |

**建议：** 使用 Riverpod 的 `override` 机制在顶层注入实现，Provider 中只依赖接口类型。

### 3.3 超大页面（🟡）

| 文件 | 行数 | 问题 |
|------|------|------|
| `auth/.../login_page.dart` | 620+ | 含 QQ、Apple、手机号、邮箱多种登录 |
| `medicine/.../medicine_reminder_edit_page.dart` | 400+ | 日期/时间/重复/剂量混合 |

### 3.4 Clock 抽象注入未完成（🟡）

`lib/core/utils/clock.dart` 的 TODO 仍未完成，业务代码约 15 处直接 `DateTime.now()`。

### 3.5 状态管理 Provider 一致性（🟡）

`FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一。

### 3.6 TODO 遗留 — record_fast_entry_choices.dart（🟡）

快速录入选项硬编码，TODO 要求改为远程/本地配置文件加载。

### 3.7 Mock 文件残留（🟡）

6 个 Mock 文件仍在 `data/repositories/` 中，虽已无业务引用，但建议移入 `test/` 目录或清理。

---

## 四、低优先级观察

### 4.1 button_styles.dart 评估（🟢 419 行）

`lib/theme/styles/button_styles.dart` 较大，需评估是否可通过 `forui` 的 `FButtonStyle` 主题定制替代。

### 4.2 结果解析/日期解析未复用（🟢）

`lucent_assistant_repository.dart` 的 `_parseDateTime()` 与 `lucent_today_ai_repository.dart` 的直接 `DateTime.parse()` 重复。

### 4.3 env_reader.dart Web 兼容性（🟢）

`dart:io` 的 `Platform.environment` 在 Web 端不可用，需确认实现是否已处理该兼容性问题。

### 4.4 !. 强制解引用（🟢 74 处）

半数以上在 `.freezed.dart` 生成代码中，业务代码约 30+ 处需逐步清理。

---

## 五、下一步评估

### 当前阶段定位

Forui 迁移主体已完成，Phase 1 退出条件基本满足（`flutter analyze` 通过，关键测试通过）。  
可以进入 **Phase 2：移动端 MVP 体验打磨**。

### 推荐执行顺序

| 顺位 | 任务 | 工作量 | 理由 |
|------|------|--------|------|
| **1** | **i18n 硬编码字符串**（11 处） | 小 | P1，用户可见，集中在 scan/ 和 auth/ |
| **2** | **Mock 硬编码日期**（3 处） | 极小 | P1，MVP 可信度问题 |
| **3** | **maxWidth: 560 提取**（4 处） | 极小 | 统一常量，消除魔法数字 |
| **4** | **路由硬编码**（6 处） | 小 | 配合 Route 常量定义 |
| **5** | **动画时长统一** | 极小 | 创建 AppAnimationDurations 类 |
| **6** | **层间解耦**（6 个 Provider） | 中 | 使用 Riverpod override 机制 |
| **7** | button_styles 评估 | 小 | 确定是否可与 forui 合并 |
| — | Clock 注入、页面拆分 | **暂缓** | Phase Guide 明确"现在不要做" |
| — | 重复组件名提取、Provider 一致性 | **暂缓** | 非 Phase 2 目标 |

### 建议下一步

**先做 i18n 硬编码修复**：集中在 `scan/` 和 `auth/login_page.dart` 两个模块，改动范围小、影响面明确、完成后可立即消除一个 P1 问题。

---

*报告生成时间：2026-07-05*
*聚焦范围：仅保留未处理项，已完成项已移除*
