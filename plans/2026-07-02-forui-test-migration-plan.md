# Forui 迁移补测试计划

## 目标

把今天 Forui 大重构期间落下的测试补上，将测试从 Material3/旧主题层迁移到 Forui，恢复全量 `flutter test` 通过。

## 当前基线

- `flutter test`：490 通过 / 51 失败
- 失败全部是编译错误，无运行时断言失败
- `analysis_options.yaml` 临时排除了 `test/**`，导致 analyzer 不检查测试文件

## 失败根因

`lib/` 今天删除了以下测试依赖的类型/文件：

| 删除/重命名项 | 影响 |
|---------------|------|
| `lib/core/theme/app_theme.dart` (`AppTheme`) | 大量测试用 `MaterialApp(theme: AppTheme.light)` |
| `lib/core/theme/app_theme_extensions.dart` | 旧桥接文件 |
| `lib/core/design/app_color_tokens.dart` | `AppColorTokens` 已删 |
| `lib/core/design/app_typography_tokens.dart` | `AppTypographyTokens` 已删 |
| `lib/core/widgets/common/app_section_surface.dart` | `AppSectionSurface` 已删 |
| `lib/core/widgets/app_dialog.dart` | `AppDialog` 已删，替代为 `AppDialogShell` |
| `lib/features/auth/presentation/widgets/auth_text_field.dart` 等 | auth wrapper 已删，改用 `FTextField` |

## 执行顺序

### Phase 1：基础设施

1. **新增 Forui 测试辅助类** `test/helpers/test_forui_app.dart`
   - 提供 `TestForuiApp`（`MaterialApp` + `FTheme` + l10n）
   - 提供 `TestForuiRouterApp`（`MaterialApp.router` + `FTheme` + l10n）
   - 提供 `pumpForuiWidget` / `pumpForuiRouter` 便捷函数
   - 使用 `FThemes.neutral.light/dark`，与 `LuminousApp` 保持一致

2. **修复 `test/auth/auth_test_helpers.dart`**
   - 将 `TestAuthApp` 的 `AppTheme.light/dark` 替换为 Forui theme bootstrap
   - 该文件被 10+ 个测试间接引用，修复后可 unblock 大量失败

### Phase 2：core 层测试

3. **修复 `test/core/widgets/`**
   - `app_back_button_test.dart`：换 `TestForuiApp`，断言 `FButton` + `FLucideIcons.chevronLeft`
   - `app_state_views_test.dart`：换 theme，保留 `FCard` / `FButton` 断言
   - `app_dialog_test.dart`：`AppDialog` 已删，改为测 `AppDialogShell` / `showFDialog`
   - `app_status_pill_test.dart`、`minor_widgets_test.dart`、`remaining_widgets_test.dart`：修正 import + theme

4. **修复 `test/core/design/` 与 `test/core/feedback/`**
   - `app_color_tokens_test.dart`：删除（对应 runtime 已删）
   - `app_typography_tokens_test.dart`：删除（对应 runtime 已删）
   - `app_toast_test.dart`：换 theme，验证 Forui 颜色/图标路径

### Phase 3：auth 测试

5. **修复 `test/auth/`**
   - 依赖修复后的 `auth_test_helpers.dart`
   - 将已删 auth wrapper 断言替换为 `FTextField` / `FButton` / `FToast` / `FDialog` / `FCheckbox` / `FTabs`
   - 文件：`auth_ui_widgets_test.dart`、`auth_widgets_test.dart`、`change_email_page_test.dart`、`forgot_password_page_test.dart`、`login_form_provider_test.dart`、`login_page_test.dart`、`register_page_test.dart`

### Phase 4：settings 测试

6. **修复 `test/settings/`**
   - `settings_page_test.dart`：移除已删的 `AppSectionSurface`、`AppSettingsSection`、`AppSettingsNavigationRow`、`AppSettingsSwitchRow` import；参考 `settings_flow_test.dart` 的 `LuminousApp` 模式或改用 `TestForuiApp`
   - `about_settings_page_test.dart`、`help_settings_page_test.dart`：修正 theme + widget 断言

### Phase 5：各 feature 页面测试

7. **today**：`today_page_test.dart`、`today_ai_card_test.dart`
8. **mine**：`mine_page_test.dart`、`account_settings_page_test.dart`、`allergy_edit_page_test.dart`、`condition_edit_page_test.dart`、`current_medicine_edit_page_test.dart`、`profile_edit_page_test.dart`
9. **report**：`report_page_test.dart`、`report_section_models_test.dart`
10. **record**：`record_page_test.dart`、`record_create_page_test.dart`、`record_detail_page_test.dart`、`record_edit_page_test.dart`、`record_form_fields_test.dart`、`record_nlp_dialog_test.dart`
11. **medicine**：`medicine_page_test.dart`、`medicine_reminder_formatters_test.dart`、`medicine_reminder_pages_test.dart`、`medicine_reminder_utils_test.dart`、`medicine_safety_tip_style_test.dart`
12. **search**：`search_page_test.dart`
13. **notification**：`notification_detail_page_test.dart`、`notification_list_item_test.dart`、`notification_list_page_test.dart`、`notification_providers_test.dart`
14. **assistant**：`assistant_controller_test.dart`、`assistant_page_test.dart`、`assistant_widgets_test.dart`
15. **app**：`router_test.dart`、`shell_page_test.dart`

### Phase 6：恢复 analyzer 检查

16. **修改 `analysis_options.yaml`**
    - 删除 `exclude: - test/**` 这一行
    - 运行 `flutter analyze` 修复测试侧 lint

### Phase 7：验证

17. **全量验证**
    - `flutter gen-l10n`（如有 ARB 改动）
    - `flutter analyze`（零 error）
    - `flutter test`（目标全绿）

##  bootstrap 策略

- Widget 测试优先使用新的 `TestForuiApp` / `pumpForuiWidget` helper
- 需要完整 router + ProviderScope 的测试（如 `settings_flow_test.dart`）继续直接使用 `LuminousApp`
- 不再在测试中手动构造 `MaterialApp(theme: AppTheme.light)`

## 删除型测试处理

- `app_color_tokens_test.dart` → 删除（runtime 已删）
- `app_typography_tokens_test.dart` → 删除（runtime 已删）
- `app_dialog_test.dart` → 改写为 `AppDialogShell` / `FDialog` 测试

## 完成标准

- `flutter analyze` 无 error
- `flutter test` 全部通过
- `analysis_options.yaml` 不再排除 `test/**`
- 不引入新的运行时 `lib/` 改动（本次只动 `test/`、`analysis_options.yaml`、helper 文件）
