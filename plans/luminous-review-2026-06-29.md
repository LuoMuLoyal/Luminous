# Luminous 代码审查报告（前端 Flutter）

**审查时间**: 2026-06-29  
**审查范围**: Luminous refactor 分支  
**审查模型**: DeepSeek V4 Pro + 人工复核  
**审查原则**: 严格按工程化规范、零容忍不一致

---

## 📋 未解决问题汇总（截至 2026-06-29）

| # | 问题 | 状态 | 涉及文件 |
|---|------|------|----------|
| F1 | 6 个 Mock 仓库文件仍存在，多处使用假数据 | 🔴 未修复 | `lib/features/*/data/repositories/mock_*_repository.dart` |
| F2 | 药品模块硬编码假数据（medicineMockNameMetformin 等） | 🔴 未修复 | `lib/features/medicine/presentation/widgets/shared/medicine_copy.dart` |
| F3 | 大量页面无 AppBar，缺少返回键 | 🔴 未修复 | 28 个 page 文件 |
| F4 | InkWell 点击缺乏明显视觉反馈 | 🟡 部分存在 | 多处 `InkWell` 使用 |

---

## 一、Mock 数据问题

### 1.1【严重】Mock 仓库未清理

**问题描述**：项目中存在 6 个 Mock 仓库实现，且多处 Provider 仍然返回 Mock 数据。这些假数据会出现在生产环境，严重影响用户体验。

**涉及文件**：
- `lib/features/medicine/data/repositories/mock_medicine_workspace_repository.dart`
- `lib/features/mine/data/repositories/mock_mine_repository.dart`
- `lib/features/record/data/repositories/mock_record_repository.dart`
- `lib/features/report/data/repositories/mock_report_repository.dart`
- `lib/features/search/data/repositories/mock/mock_repository.dart`
- `lib/features/today/data/repositories/mock_today_repository.dart`

**使用位置**：
- `medicine_workspace_provider.dart`: `return Future.value(MockMedicineWorkspaceRepository.signedOutWorkspace)`
- `today_dashboard_provider.dart`: `return Future.value(MockTodayRepository.placeholderDashboard)`
- `record_dashboard_provider.dart`: `return const MockRecordRepository().fetchDashboard(...)`

**期望修复**：
- 删除所有 Mock 仓库文件
- 将 Provider 中的 Mock 调用替换为真实 Repository 调用
- 如需测试数据，使用条件编译或环境变量控制，不应硬编码在业务代码中

---

### 1.2【严重】药品模块硬编码假数据

**问题描述**：`medicine_copy.dart` 中硬编码了 `[DEMO] 示例药品 A/B/C` 等假数据，且通过 `l10n` 国际化文件传播到所有语言版本。

**涉及文件**：
- `lib/features/medicine/presentation/widgets/shared/medicine_copy.dart`
- `lib/l10n/app_localizations_en.dart`（medicineMockNameMetformin 等）
- `lib/l10n/app_localizations_zh.dart`（同上）

**期望修复**：
- 删除 `medicine_copy.dart` 中的假数据映射
- 从 l10n 文件中移除所有 `medicineMock*` 条目
- 药品数据应从后端 API 获取

---

## 二、导航体验问题

### 2.1【严重】大量页面缺少返回键

**问题描述**：28 个页面文件没有 `AppBar`，用户进入后无法通过界面返回，只能依赖系统返回键，UX 体验差。

**完整清单**：
- `lib/features/assistant/presentation/pages/assistant_page.dart`
- `lib/features/medicine/presentation/pages/medicine_page.dart`
- `lib/features/medicine/presentation/pages/medicine_risk_check_page.dart`
- `lib/features/medicine/presentation/pages/reminder/medicine_reminder_detail_page.dart`
- `lib/features/medicine/presentation/pages/reminder/medicine_reminder_edit_page.dart`
- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/record/presentation/pages/record_page.dart`
- `lib/features/mine/presentation/pages/mine_page.dart`
- `lib/features/notification/presentation/pages/notification_list_page.dart`
- `lib/features/notification/presentation/pages/notification_detail_page.dart`
- `lib/features/scan/presentation/pages/medicine_box_scan_page.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/account_settings_page.dart`
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/change_email_page.dart`
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/pages/help_settings_page.dart`
- `lib/features/settings/presentation/pages/notification_settings_page.dart`
- `lib/features/settings/presentation/pages/data_export_page.dart`
- `lib/features/settings/presentation/pages/language_settings_page.dart`
- `lib/features/settings/presentation/pages/theme_settings_page.dart`
- `lib/features/settings/presentation/pages/ai_settings_page.dart`
- `lib/features/settings/presentation/pages/advanced_settings_page.dart`
- `lib/features/settings/presentation/pages/sleep_reminder_settings_page.dart`
- `lib/features/settings/presentation/pages/about_settings_page.dart`
- `lib/features/settings/presentation/widgets/app_settings_master_toggle_page.dart`
- `lib/features/shell/presentation/shell_page.dart`

**期望修复**：
- 为需要返回导航的页面添加 `AppBar` + `AppBackButton`
- 主页面（如 `today_page.dart`、`medicine_page.dart`）如果是 Tab 页可以不添加，但子页面必须添加
- 统一使用项目中已有的 `AppBackButton` 组件

---

### 2.2【警告】点击反馈不够明显

**问题描述**：虽然项目中使用了 `InkWell`，但部分点击区域缺乏明显的水波纹或视觉反馈，用户不确定是否点击成功。

**涉及位置**：多处 `InkWell` 使用（约 30+ 处），特别是：
- 药品页面的快速操作区域
- 今日计划的药品条目
- 记录页面的快速入口面板

**期望修复**：
- 确保所有可点击区域都有 `InkWell` 或 `GestureDetector`
- 为关键操作添加点击动画或视觉反馈
- 禁用状态（`onTap: null`）时应有明显的禁用样式

---

## 三、代码复用问题（历史遗留，2026-06-26 深度审查）

### 3.1【警告】Auth 表单验证逻辑重复

**问题描述**：`RegisterFormNotifier` 和 `PasswordResetNotifier` 几乎一模一样：相同的字段状态管理、相同的 `validate()` 方法、相同的 `_isValidEmail()` 正则、相同的 cooldown timer 逻辑。

**涉及文件**：
- `lib/features/auth/presentation/providers/register_form_provider.dart`
- `lib/features/auth/presentation/providers/forms/password_reset_provider.dart`
- `lib/features/auth/presentation/providers/forms/login_form_provider.dart`（也有 `_isValidEmail`）

**状态**：🔴 未修复（三处都有重复的正则和验证逻辑）

**期望修复**：
- 抽象 `BaseAuthFormNotifier` 基类或 `AuthValidationMixin`
- 统一 email 验证逻辑（或引入 `email_validator` 包）

---

### 3.2【警告】手写 email 验证正则

**问题描述**：多处使用手写的 email 正则：
```dart
static bool _isValidEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
}
```

**状态**：🔴 未修复

**期望修复**：使用 `email_validator` 包（`EmailValidator.validate(email)`）

---

### 3.3【警告】手动管理 TextEditingController 生命周期

**问题描述**：几乎每个 StatefulWidget 都手动 `initState` 创建和 `dispose` 释放 controller，容易遗漏。

**状态**：🔴 未修复（仅 2 处使用了 flutter_hooks）

**期望修复**：使用 `flutter_hooks` 的 `useTextEditingController()` 或 Riverpod 管理

---

## 四、测试相关问题（来自 2026-06-28 测试审查）

### 3.1【严重】Dio 拦截器完整链路未测试

**问题描述**：当前测试仅覆盖了 Bearer Token 注入、`skipAuthorization` 标志和 `Accept-Language` 注入。但未测试 Dio 拦截器中的错误重试逻辑（如 401 自动刷新 token）、超时处理、连接错误等。

**状态**：🔴 未修复（从上次审查至今未补充）

**期望修复**：
- 补充 401 自动刷新 token 的测试
- 补充超时和连接错误处理测试
- 补充 token 过期后的重试逻辑测试

---

### 3.2【严重】Provider 错误未验证 UI 层传递

**问题描述**：测试了 `StateError` 抛出，但未确认当 API 返回非零 code 时，Riverpod 的 `AsyncValue` 是否进入 `error` 状态、UI 层是否显示合适的错误 Widget。

**状态**：🔴 未修复

---

### 3.3【警告】Provider 测试中未覆盖 `loading` 状态

**问题描述**：大多数 Provider 测试仅验证了成功数据和错误状态，但忽略了对 `loading` 状态的断言。

**状态**：🔴 未修复

---

### 3.4【警告】`pumpAndSettle` 使用过度

**问题描述**：骨架屏动画可能是无限循环的 shimmer，会导致测试超时或无限等待。

**状态**：🟡 未修复

---

### 3.5【警告】未测试不同屏幕尺寸

**问题描述**：缺少 `MediaQuery` override 模拟小屏/大屏/平板。

**状态**：🔴 未修复

---

### 3.6【警告】Mock API 没有模拟网络延迟

**问题描述**：同步返回数据，无法测试 loading 持续时间、超时、重试逻辑。

**状态**：🔴 未修复

---

### 3.7【Info】共享测试工具类提取

**建议**：提取 `buildMockUser()`、`createTestUser()` 等工厂函数到 `test/helpers/test_helpers.dart`。

**状态**：🟡 部分已做（已有 `test/helpers/test_helpers.dart` 文件）

---

## 四、整体评估

| 维度 | 评分 | 说明 |
|------|------|------|
| 假数据清理 | ⭐ | 大量 Mock 数据仍在代码中 |
| 导航体验 | ⭐⭐ | 28个页面缺少返回键 |
| 点击反馈 | ⭐⭐⭐ | 有 InkWell 但反馈不够明显 |
| 代码组织 | ⭐⭐⭐ | 基本清晰，但 mock 文件分散 |
| 测试覆盖 | ⭐⭐⭐ | 基础测试有，但边界场景和错误链路缺失 |

**总体评价**：功能开发进展快，但假数据清理严重滞后，UX 细节（返回键）需要补全，测试的边界场景和错误链路覆盖不足。

**建议修复优先级**：
1. P0：删除所有 Mock 仓库和假数据（生产环境不能展示假数据）
2. P0：为所有子页面添加返回键
3. P1：Auth 表单验证逻辑重复问题（RegisterFormNotifier / PasswordResetNotifier）
4. P1：补充 Dio 拦截器错误链路和 401 重试测试
5. P1：补充 Provider loading 状态测试
6. P2：优化点击反馈（水波纹/视觉反馈）
7. P2：补充不同屏幕尺寸适配测试
8. P2：引入 email_validator 替换手写正则
9. P2：考虑引入 flutter_hooks 减少 TextEditingController 样板代码
10. P2：Dialog 构建模式统一封装
