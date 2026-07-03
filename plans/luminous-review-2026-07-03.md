# Luminous 全项目审查报告

**审查日期：** 2026-07-03  
**分支：** refactor  
**审查范围：** 全项目（lib/ 目录及配置文件）  
**审查重点：** 不优雅写法、重复造轮子、第三方包替代、健壮性、维护隐患

---

## 1. 不优雅写法

### 1.1 硬编码字符串（i18n 遗漏）

**问题描述：** 多处中文 UI 字符串直接硬编码，未使用 `AppLocalizations`（l10n），国际化覆盖不完整。

| 位置 | 硬编码内容 |
|------|------------|
| `medicine_recognize_dialog.dart:74` | `Text('识别结果', ...)` |
| `medicine_recognize_dialog.dart:114` | `Text('未能识别到药品信息', ...)` |
| `medicine_recognize_dialog.dart:183` | `const Text('重新拍照')` |
| `medicine_recognize_dialog.dart:202` | `const Text('确认，查看详情')` |
| `medicine_box_scan_page.dart:165` | `Text('选择识别方式', ...)` |
| `barcode_scanner_page.dart:109` | `const Text('扫描条形码', ...)` |
| `login_page.dart:617` | `const Text('Sign in with QQ')` |
| `login_page.dart:624` | `const Text('QQ callback link / code')` |
| `login_page.dart:639` | `const Text('Complete QQ sign-in')` |
| `barcode_scanner_page.dart:59` | `AppToast.show(context, '未找到该条码对应的药品')` |
| `barcode_scanner_page.dart:74` | `AppToast.show(context, '搜索失败: $e')` |

**建议：** 所有用户可见字符串必须通过 `l10n` 或 `AppLocalizations` 获取。已有完善的 l10n 体系（`lib/l10n/` 和 `app_localizations.dart`），不应在业务代码中直接写死字符串。

### 1.2 魔法数字 / 硬编码常量

| 位置 | 数值 | 说明 | 建议 |
|------|------|------|------|
| `app_dialog_shell.dart:11, 56` | `maxWidth = 560` | 对话框最大宽度 | 提取到 `AppDialogConstants` 或设计令牌中 |
| `app_state_views.dart:208` | `widthFactor = 0.72` | 占位宽度比例 | 提取到 `AppStateViewConstants` |
| `app_state_views.dart:280` | `fallbackWidth = 96` | 回退宽度 | 提取到设计令牌 |
| `app_status_pill.dart:11` | `backgroundAlpha = 0.12` | 背景透明度 | 提取到 `AppOpacityTokens` 或颜色系统 |
| `app_radius_tokens.dart:8` | `levelFull = 9999` | 全圆角（9999 是常见 hack） | 语义化命名合理，但注释说明这是用于全圆角 |
| `app_responsive_sizing.dart:17-42` | `0.72, 260, 320, 0.22, 280, 360, 2, 3, 4` | 响应式计算参数 | 已较好封装，但内部参数注释不足 |
| `lucent_result_code.dart` | `400001, 400002, ...` | 业务错误码 | 命名常量已定义，但 `lucent_envelope.dart:16` 中 `code == 0` 应使用 `ResultCode.success` |
| `medicine_reminder_edit_page.dart` | `year - 5`, `year + 10` | 日期选择器范围 | 提取为 `MIN_YEAR_OFFSET`, `MAX_YEAR_OFFSET` |
| `medicine_reminder_edit_page.dart` | `weekday % 7` | 星期计算 | 提取为 `DateTime.toWeekdayIndex()` 工具函数，注释说明 `% 7` 的意图（将周日=7 转为周日=0） |

### 1.3 路由硬编码

| 位置 | 硬编码路由 | 问题 |
|------|------------|------|
| `auth_required_dialog.dart:102` | `loginRouteForReturnTo('/')` | `'/'` 应使用命名常量 `AppRoutes.home` |
| `login_page.dart:65` | `context.go('/')` | 同上 |
| `login_page.dart:308` | `fallbackRoute: '/'` | 同上 |
| `forgot_password_page.dart:35` | `fallbackRoute: '/'` | 同上 |
| `change_email_page.dart:175` | `context.push(!isSignedIn ? '/login' : '/')` | 多处硬编码 `/login` 和 `/` |
| `register_page.dart:36` | `fallbackRoute: '/'` | 同上 |
| `register_page.dart:370` | `'/'` | 同上 |
| `login_page.dart:50` | `trimmed.startsWith('/')` | 路由验证逻辑也硬编码前缀符 |

**建议：** 已使用 `GoRouter`，应在 `app/router.dart` 或 `AppRoutes` 中统一定义所有路由字符串，业务代码只引用常量。

### 1.4 重复代码块

**`Future.delayed` 使用：** 扫描未发现大量 `await Future.delayed` 的重复模式，但需警惕延迟加载的重复实现。

---

## 2. 重复造轮子

### 2.1 DateTime.now() 直接调用 vs Clock 抽象

**问题描述：** `lib/core/utils/clock.dart` 已定义了 `Clock` 抽象和 `SystemClock` 实现，用于测试时 mock 时间，但文件头部有 TODO：

```dart
/// TODO: inject [Clock] throughout the codebase instead of calling
/// [DateTime.now()] directly in business logic.
```

**实际使用情况：** 业务代码中大量使用 `DateTime.now()` 直接调用：

| 文件 | 使用位置 |
|------|----------|
| `assistant_controller.dart:243` | `createdAt: DateTime.now()` |
| `medicine_reminder_notification_coordinator.dart:106` | `return DateTime.now;` |
| `medicine_reminder_providers.dart:126` | `final today = DateTime.now();` |
| `medicine_reminder_formatters.dart:139` | `final now = DateTime.now();` |
| `medicine_page.dart:93` | `final today = DateTime.now();` |
| `medicine_reminder_edit_page.dart` | 多处使用 `DateTime.now()` |
| `lucent_medicine_workspace.dart:39` | `final today = DateTime.now();` |
| `lucent_today_repository.dart:26` | `final today = DateTime.now();` |
| `record_time_provider.dart` | `return DateTime.now();` |
| `local_notification_gateway.dart:77` | `!scheduledAt.isAfter(DateTime.now())` |
| `lucent_assistant_repository.dart` | 多处使用 `DateTime.now()` 作为 fallback |

**建议：** 完成 TODO，将 `Clock` 通过 Riverpod Provider 注入，业务代码统一使用 `ref.read(clockProvider).now()`。

### 2.2 空值处理 / 防御模式

多处使用相同的空值处理模式但未提取：
- `dto.field ?? ''` 或 `dto.field ?? DateTime.now()` 在多个 repository 中重复
- `isNotEmpty == true` 在 `login_page.dart` 中重复出现

### 2.3 结果解析 / 日期解析

`lucent_assistant_repository.dart` 中有 `_parseDateTime()` 私有方法，但 `lucent_today_ai_repository.dart` 中直接调用 `DateTime.parse()`，没有复用统一的日期解析逻辑。

---

## 3. 可用第三方包替代

### 3.1 日期处理

`assistant-tool-date-resolver.ts`（Lucent 后端）有复杂日期解析，但 Luminous 前端同样有日期计算需求。当前使用原生 `DateTime`，若遇到更复杂场景（如时区、跨天计算），可考虑：
- **intl**（已使用，用于格式化）
- **jiffy** 或 **time**（dart）— 但当前原生 DateTime 已满足需求，暂不必须

### 3.2 表单验证

`login_page.dart` 和 `register_page.dart` 中有手动表单验证逻辑，已使用 `AuthValidationMixin`，但仍有部分手动检查。当前模式尚可，暂不必须替换。

### 3.3 状态管理

已使用 Riverpod + Freezed，无需替换。但需确认：
- `AuthRequiredException` 等自定义异常是否应该使用更标准的 `Result<T, E>` 模式而非异常控制流？

---

## 4. 健壮性不足

### 4.1 裸 catch / 异常吞没（严重）

**问题描述：** 大量 catch 块完全吞没异常或仅做最简处理，导致错误静默，调试困难。

| 位置 | 问题 | 风险 |
|------|------|------|
| `app.dart:118` | `catch (_) { ... }` | 应用级错误处理，但完全无日志 |
| `assistant_controller.dart` | 7 个 `catch (error)` | 助手功能所有操作异常都被吞没，AI 对话失败用户完全不知 |
| `assistant_page.dart` | 5 个 `catch (error)` | 页面级错误处理，但大量 `if (!ctx.mounted) return;` 后无日志 |
| `lucent_medicine_workspace.dart:56, 69` | 两个 `catch (_) {}` | 空 catch 块，完全静默失败 |
| `medicine_risk_check_repository.dart:45` | `catch (_) { ... }` | 药品风险检查失败无日志 |
| `lucent_today_repository.dart:44, 62, 188` | 三个 `catch (_) { ... }` | 今日数据获取失败无日志 |
| `today_ai_analysis_provider.dart:63` | `catch (error)` | AI 分析异常无日志 |
| `settings_profile_sync_provider.dart:33` | `catch (error)` | 设置同步失败无日志 |
| `data_export_page.dart:200` | `catch (error)` | 数据导出失败无日志 |
| `language_settings_page.dart:100` | `catch (error)` | 语言设置失败无日志 |
| `advanced_settings_page.dart:68` | `catch (_) { ... }` | 高级设置失败无日志 |
| `record_fast_entry_dialog.dart:129` | `catch (_) { ... }` | 快速录入失败无日志 |
| `record_ocr_entry_dialog.dart:81` | `catch (e)` | OCR 录入失败无日志 |
| `record_create.dart:292` | `catch (e)` | 记录创建失败无日志 |
| `health_edit_forms.dart` | 7 个 `catch (e)` | 健康信息编辑失败无日志 |
| `search_provider.dart:85` | `catch (e)` | 搜索失败无日志 |
| `search_page.dart:111` | `catch (e)` | 搜索页面失败无日志 |
| `medicine_box_scan_page.dart:59` | `catch (e)` | 扫描页面失败无日志 |
| `barcode_scanner_page.dart:72` | `catch (e)` | 条码扫描失败无日志 |
| `login_page.dart:281` | `catch (e)` | 登录失败虽然有 UI 反馈，但日志可能不足 |
| `medicine_reminder_providers.dart:242, 259` | 两个 `catch (error)` | 提醒操作失败无日志 |
| `medicine_page.dart:106` | `catch (error)` | 药品页面操作失败无日志 |
| `medicine_reminder_notification_coordinator.dart:170` | `catch (_) { ... }` | 通知协调器失败无日志 |

**最严重的问题：** `lucent_medicine_workspace.dart` 的两个完全空 catch 块：
```dart
} catch (_) {}
```
这意味着药品工作空间加载失败时，UI 可能显示空白或错误状态，但没有任何日志记录。

**建议：** 所有 catch 块至少使用 `AppLogger.e('context', error)` 或 `debugPrint` 记录。可以封装一个 `safeRun()` 工具函数统一处理。

### 4.2 空值操作符使用（`!`）

虽然 `!` 在 Dart 中用于非空断言，但部分使用可能过于激进：

| 位置 | 问题 |
|------|------|
| `lucent_error_mapper.dart:11` | `error.error! as LucentApiException` | 如果 `error.error` 为 null 会崩溃 |
| `lucent_dio_client.dart:288` | `envelope.data == null` 前有 `!envelope.isSuccess` 检查，但逻辑链条长 |
| 多处 `!mounted` | 大部分正确，但需确认每个 `!` 都有前置验证 |

### 4.3 缺少 mounted 检查的 setState

**问题描述：** 在 `async` 操作后调用 `setState` 未检查 `mounted` 可能导致崩溃。

| 位置 | 问题 |
|------|------|
| `record_fast_entry_dialog.dart:100, 137` | `_saveChoice()` 中有 `setState`，但已在外层检查 `_saving` 状态 |
| `shell_deferred_content.dart:35` | `setState(() => _ready = true)` 在 `addPostFrameCallback` 中，可能安全但需确认 |
| `medicine_recognize_dialog.dart:123, 167` | `setState` 在 `onTap` 中，是同步操作，安全 |
| `barcode_scanner_page.dart:60, 75` | `setState` 在 catch 块后，虽然页面大概率还在，但异步扫描后可能已离开页面 |

**建议：** 所有 `async` 操作后的 `setState` 应加 `if (mounted)` 检查。

### 4.4 边界检查

| 位置 | 问题 |
|------|------|
| `lucent_dio_client.dart` | 网络请求超时和重试逻辑是否完善？需确认是否有统一的超时配置 |
| `medicine_reminder_edit_page.dart` | `DateTime(now.year - 5)` 和 `DateTime(now.year + 10, 12, 31)` 的边界 — 如果 now 是 2038 年，`year + 10` 可能溢出？不，DateTime 支持到约 275760 年 |
| `local_notification_gateway.dart` | `scheduledAt.isAfter(DateTime.now())` 检查存在，但如果 scheduledAt 是过去时间，只是静默不调度，是否应有日志？ |

---

## 5. 维护隐患

### 5.1 紧耦合

**问题描述：** 部分组件/页面直接依赖具体实现而非接口。

| 位置 | 问题 | 建议 |
|------|------|------|
| `lucent_assistant_repository.dart` | 直接依赖 `LucentApi` 和 dto | 已通过 Repository 模式解耦，但内部仍有大量手动 dto→entity 转换，可用 `freezed` + `map` 简化 |
| `lucent_today_repository.dart` | 同样有大量手动转换 | 同上 |
| `lucent_medicine_workspace.dart` | 直接调用 API 和本地存储 | 混合了远程和本地数据源，职责略模糊 |

### 5.2 职责不单一（超大文件）

| 文件 | 问题 |
|------|------|
| `login_page.dart` | 620+ 行，包含 QQ、Apple、手机号、邮箱等多种登录方式的 UI 和逻辑，建议拆分为 `login_page.dart` + `login_qq_panel.dart` + `login_apple_panel.dart` + `login_form.dart` 等 |
| `assistant_page.dart` | 200+ 行，包含状态展示、输入框、对话列表、错误处理，已拆得不错但可以进一步提取小部件 |
| `medicine_reminder_edit_page.dart` | 400+ 行，包含日期选择、时间选择、重复规则、剂量编辑等，建议拆分为多个子 widget |
| `assistant_controller.dart` | 400+ 行，包含 7 种不同操作（send, load, regenerate, execute, etc.），可以考虑拆分为更细粒度的 controller 或提取 use case 类 |

### 5.3 文档缺失

| 位置 | 问题 |
|------|------|
| `record_fast_entry_choices.dart:7` | TODO 注释：`TODO: load these from a remote configuration or local config file` — 自 2026-05 至今未处理？ |
| `clock.dart` | 有 TODO 但未完成 |
| `app_radius_tokens.dart` | `levelFull = 9999` 缺乏注释说明这是全圆角 hack |
| `app_responsive_sizing.dart` | 响应式计算参数（0.72, 0.22 等）缺乏注释说明这些数字是怎么来的 |
| `lucent_result_code.dart` | 错误码体系已建立，但缺少每个错误码的触发场景文档 |

### 5.4 设计令牌一致性

**问题描述：** 已建立完善的设计令牌系统（`app_radius_tokens.dart`, `app_spacing_tokens.dart`, `app_breakpoints.dart`），但部分组件仍使用裸数值：

- `app_dialog_shell.dart:11` 的 `560` 未使用设计令牌
- `app_state_views.dart` 的 `0.72`, `96` 未使用设计令牌
- `app_status_pill.dart:11` 的 `0.12` 未使用设计令牌

**建议：** 确保所有视觉数值都通过设计令牌获取，或至少说明为何不使用令牌。

### 5.5 假数据 / Mock 残留

**问题描述：** 根据 UX 审查历史，用户曾要求检查假数据。当前代码中：

- `mock_medicine_workspace_repository.dart` 存在 mock 实现
- 需确认是否在其他 repository 中仍有假数据 fallback

### 5.6 状态管理一致性

**问题描述：** 部分 provider 的命名和结构略有差异：
- `assistant_controller.dart` 使用 `Notifier<AssistantState>`
- `login_form_provider.dart` 使用 `NotifierProvider<LoginFormNotifier, LoginFormState>`
- `medicine_reminder_providers.dart` 使用 `MedicineReminderFormNotifier`

命名风格基本一致，但需确认是否所有新 provider 都遵循同一模式。

---

## 6. 其他问题

### 6.1 打印语句残留

扫描未发现 `print(` 语句残留，良好。

### 6.2 重复 import

未发现重复 import 问题，良好。

### 6.3 表情符号硬编码

`record_fast_entry_choices.dart` 中硬编码了表情符号：
```dart
prefix: const Text('😄'),
prefix: const Text('🙂'),
prefix: const Text('😐'),
prefix: const Text('😟'),
prefix: const Text('😫'),
```

这些表情符号作为 UI 元素，当前实现方式尚可（它们是通用 Unicode 表情，不需要 i18n），但如果在 i18n 扩展中需要本地化表情符号，应考虑配置化。

### 6.4 依赖版本

**pubspec.yaml 中的依赖：** 需检查是否有依赖版本过旧，特别是：
- `flutter` 和 `dart` 版本约束
- 第三方包的最新版本和安全补丁

---

## 总结

| 类别 | 严重问题数 | 中等问题数 | 轻微问题数 |
|------|-----------|-----------|-----------|
| 不优雅写法 | 2 | 6 | 4 |
| 重复造轮子 | 2 | 3 | 2 |
| 第三方包替代 | 0 | 1 | 0 |
| 健壮性不足 | 12 | 6 | 3 |
| 维护隐患 | 3 | 5 | 4 |

**最优先修复项：**
1. **所有裸 catch 吞没异常** — 这是头号问题，超过 20 处完全静默失败，生产环境无法排查。添加 `debugPrint` 或 `AppLogger.e()` 是最低要求。
2. **i18n 硬编码字符串** — 所有用户可见中文字符串必须进入 l10n 体系。
3. **路由硬编码** — 所有 `'/'`、`'/login'` 等路由应使用 `AppRoutes` 常量。
4. **Clock 抽象注入** — 完成 TODO，将 `DateTime.now()` 替换为注入的 `Clock`。
5. **超大页面拆分** — `login_page.dart`（620+ 行）、`medicine_reminder_edit_page.dart`（400+ 行）应拆分。
6. **空 catch 块** — `lucent_medicine_workspace.dart:56, 69` 的两个空 catch 必须立即修复。

---

## 7. 模糊点细化（2026-07-03 审查后回查）

以下是对报告中不确定表述的回查确认结果：

### 7.1 i18n 硬编码字符串（已确认仍存在）

经回查最新源码（commit bc730bcf），以下硬编码字符串**仍然存在**，未修复：

| 位置 | 内容 | 状态 |
|------|------|------|
| `scan/presentation/widgets/medicine_recognize_dialog.dart:74` | `Text('识别结果')` | ❌ 仍存在 |
| `scan/presentation/widgets/medicine_recognize_dialog.dart:114` | `Text('未能识别到药品信息')` | ❌ 仍存在 |
| `scan/presentation/widgets/medicine_recognize_dialog.dart:183` | `const Text('重新拍照')` | ❌ 仍存在 |
| `scan/presentation/widgets/medicine_recognize_dialog.dart:202` | `const Text('确认，查看详情')` | ❌ 仍存在 |
| `scan/presentation/pages/medicine_box_scan_page.dart:165` | `Text('选择识别方式')` | ❌ 仍存在 |
| `scan/presentation/pages/barcode_scanner_page.dart:109` | `const Text('扫描条形码')` | ❌ 仍存在 |
| `scan/presentation/pages/barcode_scanner_page.dart:59` | `AppToast.show(context, '未找到该条码对应的药品')` | ❌ 仍存在 |
| `scan/presentation/pages/barcode_scanner_page.dart:74` | `AppToast.show(context, '搜索失败: $e')` | ❌ 仍存在 |
| `auth/presentation/pages/login_page.dart:617` | `const Text('Sign in with QQ')` | ❌ 仍存在 |
| `auth/presentation/pages/login_page.dart:624` | `const Text('QQ callback link / code')` | ❌ 仍存在 |
| `auth/presentation/pages/login_page.dart:639` | `const Text('Complete QQ sign-in')` | ❌ 仍存在 |

**注意：** `record_fast_entry_choices.dart` 中的部分选项已使用 `l10n`，但 `DailyRecordKind.water` 和 `DailyRecordKind.sleep` 仍使用硬编码英文标签。

### 7.2 路由硬编码（已确认仍存在）

经回查，以下路由硬编码**仍然存在**：

| 位置 | 硬编码内容 | 状态 |
|------|------------|------|
| `auth/presentation/pages/login_page.dart:65` | `context.go('/')` | ❌ 仍存在 |
| `auth/presentation/pages/login_page.dart:308` | `fallbackRoute: '/'` | ❌ 仍存在 |
| `auth/presentation/pages/forgot_password_page.dart:35` | `fallbackRoute: '/'` | ❌ 仍存在 |
| `auth/presentation/pages/register_page.dart:36` | `fallbackRoute: '/'` | ❌ 仍存在 |
| `auth/presentation/pages/register_page.dart:370` | `'/'` | ❌ 仍存在 |

### 7.3 catch 块异常吞没（已确认仍存在）

回查确认以下严重问题**仍未修复**：

| 位置 | 问题 | 状态 |
|------|------|------|
| `medicine/data/repositories/lucent_medicine_workspace.dart:56` | `catch (_) {}` — 完全空 catch | ❌ 仍存在 |
| `medicine/data/repositories/lucent_medicine_workspace.dart:69` | `catch (_) {}` — 完全空 catch | ❌ 仍存在 |
| `app/app.dart:118` | `catch (_)` — 无日志 | ❌ 仍存在 |
| `medicine/presentation/providers/medicine_reminder_notification_coordinator.dart:170` | `catch (_)` | ❌ 仍存在 |
| `today/data/repositories/lucent_today_repository.dart` | 三处 `catch (_)` | ❌ 仍存在 |
| `settings/presentation/pages/advanced_settings_page.dart:68` | `catch (_)` | ❌ 仍存在 |
| `record/presentation/widgets/dialogs/record_fast_entry_dialog.dart:129` | `catch (_)` | ❌ 仍存在 |
| `record/presentation/pages/record_edit.dart` | 四处 `catch (_)` | ❌ 仍存在 |

### 7.4 mounted 检查（已确认安全）

经回查源码，以下位置的 `setState` **已有适当保护**：

| 位置 | 原问题 | 回查结果 |
|------|--------|----------|
| `shell/presentation/shell_deferred_content.dart:35` | `addPostFrameCallback` 中的 `setState` | ✅ 已有 `if (mounted)` 保护 |
| `record/presentation/widgets/dialogs/record_fast_entry_dialog.dart:100,137` | `_saveChoice()` 中的 `setState` | ✅ 外层有 `if (!mounted) return;` 保护 |
| `scan/presentation/pages/barcode_scanner_page.dart:60,75` | 异步扫描后的 `setState` | ✅ 已有 `if (mounted)` 保护 |

### 7.5 空值操作符 `!`（已确认）

| 位置 | 原问题 | 回查结果 |
|------|--------|----------|
| `core/network/lucent_error_mapper.dart:11` | `error.error! as LucentApiException` | ⚠️ 仍存在，但前一行已检查 `error.error is LucentApiException`，理论安全 |
| `core/network/lucent_dio_client.dart:288` | `envelope.data!` | ✅ 前一行已检查 `envelope.data == null`，逻辑安全 |

### 7.6 边界检查（已确认）

| 位置 | 原问题 | 回查结果 |
|------|--------|----------|
| `core/notifications/local_notification_gateway.dart:77` | 过去时间静默不调度是否应有日志？ | ⚠️ 当前实现：`if (!scheduledAt.isAfter(DateTime.now())) { return; }` — 确实无日志，建议添加 `debugPrint` 或 `AppLogger` 记录跳过的通知 |

### 7.7 Mock 数据残留（已确认）

| 位置 | 原问题 | 回查结果 |
|------|--------|----------|
| `features/*/data/repositories/mock_*_repository.dart` | 是否仍在使用？ | ✅ 共 5 个 mock 文件存在，但业务代码中已无引用（`grep` 未找到非 mock 文件中的引用）。建议确认是否可以删除或移入 test/ 目录 |

### 7.8 TODO 注释（已确认）

| 位置 | TODO 内容 | 状态 |
|------|-----------|------|
| `core/utils/clock.dart` | `TODO: inject [Clock] throughout the codebase` | ❌ 仍存在，且 `DateTime.now()` 仍在业务代码中大量使用 |
| `features/record/domain/constants/record_fast_entry_choices.dart:7` | `TODO: load these from a remote configuration...` | ❌ 仍存在，部分已 l10n 化但 water/sleep 仍硬编码 |

### 7.9 设计令牌一致性（已确认）

| 位置 | 原问题 | 回查结果 |
|------|--------|----------|
| `core/widgets/common/app_dialog_shell.dart:11,56` | `maxWidth = 560` | ❌ 仍未使用设计令牌 |
| `core/widgets/common/app_state_views.dart:208` | `widthFactor = 0.72` | ❌ 仍未提取 |
| `core/widgets/common/app_state_views.dart:280` | `fallbackWidth = 96` | ❌ 仍未提取 |
| `core/widgets/common/app_status_pill.dart:11` | `backgroundAlpha = 0.12` | ❌ 仍未提取 |



## 8. 2026-07-03 晚间修复更新

基于当天 `docs/TODO.md` 中记录的源文件级问题进行了修复，并同步更新了相关文档。以下早间审查中标记的状态已变化：

### 8.1 `report_metrics_grid.dart` Column 溢出 — 已修复

**原问题：** `Column` 在 `_MetricCard` 内底部溢出：移动端 27px、桌面端 6.0px，影响 `report_page_test` 和 `shell_page_test`。

**修复：** 上调 `_metricCardHeight`：
- mobile: 164 → 192
- tablet: 176 → 204
- desktop: 188 → 216

**验证：** `flutter test test/report/report_page_test.dart test/app/shell_page_test.dart --no-pub` 全部通过。

### 8.2 `mine_page_test` auth-required-dialog 未显示 — 已修复

**原问题：** 退出登录状态下点击 Mine 档案入口未弹出登录对话框。

**根因：** 退出登录态的 Mine 首屏内容过高，导致"基础信息"档案条目被推到屏幕可视区域外，`tester.tap` 命中了屏幕外的坐标，未触发 `FTappable.onPress` → `pushAuthRequiredRoute`。

**修复：** 压缩 Mine 退出登录状态的首屏高度：
- `mine_account_hero.dart`：头像占位 84→64，图标 48→32，卡片内边距 `level5`→`level4`，进度条前间距 `level4`→`level2`。
- `mine_status_overview.dart`：卡片垂直内边距 `level5`→`level4`。
- `mine_archive_section.dart`：档案行垂直内边距 `level4`→`level3`。

**验证：** `flutter test test/mine/mine_page_test.dart --no-pub` 全部通过，"Mine archive shows login dialog when signed out" 用例可正常找到 `auth-required-dialog`。

### 8.3 `ReportPanel` / `MedicinePanel` 默认 padding — 项已过时

**原问题：** TODO 中记录 `ReportPanel` / `MedicinePanel` 默认 padding 从 md 改到 lg 导致布局溢出。

**现状：** 代码库中已不存在 `ReportPanel` 或 `MedicinePanel` 类（`rg` / `grep` 在 `lib/` 中无匹配）。该 TODO 项属于历史残留，已从 `docs/TODO.md` 删除。

### 8.4 文档同步

- `docs/TODO.md` 删除了本节提到的 3 条已关闭/过时记录。
- `docs/Current_State.md` 在 Completed Baselines 中追加"布局溢出修复"条目。
- `docs/migration-log/2026-07-03.md` 追加修复记录。

### 8.5 当前相关测试状态

```
flutter test test/report/report_page_test.dart test/app/shell_page_test.dart test/mine/mine_page_test.dart --no-pub
# 29/29 passed
```

**注：** 本审查报告中第 1–7 节的其余问题（i18n 硬编码、路由硬编码、catch 吞没异常、`DateTime.now()` 直接调用、设计令牌一致性等）未在本次晚间修复中处理，仍保持原审查结论。
