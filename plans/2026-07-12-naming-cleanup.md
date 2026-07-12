# Luminous 文件命名重构计划

> 创建日期：2026-07-12
> 状态：待执行
> 涉及仓库：Luminous

---

## 一、命名原则

### 核心规则

```
目录 = 命名空间（说明类型/层级）
文件名 = 具体职责（说明"做什么"，不说明"在哪里"）
```

### 做什么

- **去掉类型后缀**：目录已经表达了类型，文件名不重复 `_provider`、`_page`、`_widget`、`_section`、`_data_source`、`_repository`
- **保留业务词**：`session`、`login`、`dashboard`、`suggestion`、`risk_check` 这些是职责描述，必须保留
- **消灭纯类型名**：`provider.dart`、`providers.dart`、`repository.dart`、`controller.dart`（无业务词）是最差的命名——零职责信息

### 命名质量层级

| 层级 | 示例（在 `providers/` 下） | 问题 |
|---|---|---|
| **最差** | `provider.dart` | 纯类型词，零业务语义 |
| **最差** | `providers.dart` | 纯类型词复数，零业务语义 |
| 差 | `auth_provider.dart` | 业务词太泛 + 类型后缀冗余 |
| 冗余 | `session_provider.dart` | 有业务词但 `_provider` 后缀冗余 |
| **最佳** | `session.dart` | 业务语义清晰，无冗余类型词 |

### 判断流程

```
文件名中有没有业务词？
├─ 否（如 provider.dart, repository.dart）→ 必须改名，加上业务词
└─ 是（如 session_provider.dart）
   └─ 有没有类型后缀重复目录？
      ├─ 是（如 _provider, _page, _section）→ 去掉类型后缀
      └─ 否（如 session.dart）→ 已经是最佳，不改
```

---

## 二、问题清单

### 2.1 纯类型名——零业务语义（最差，必须改）

这些文件名只有类型词，没有任何职责描述：

| 当前文件 | 所在目录 | 实际职责 | 建议改为 |
|---|---|---|---|
| `provider.dart` | `search/presentation/providers/` | 药品搜索状态管理 | `medicine_search.dart` |
| `controller.dart` | `assistant/presentation/providers/` | AI 对话控制器 | `conversation.dart` |
| `providers.dart` | `record/data/providers/` | 记录数据层 DI 绑定（barrel） | `record_access.dart` |
| `providers.dart` | `notification/presentation/providers/` | 通知列表/未读数（barrel） | `notification.dart` |
| `repository.dart` | `today/domain/repositories/` | 今日数据仓库接口 | `dashboard.dart` |
| `repository.dart` | `search/domain/repositories/` | 搜索仓库接口 | `search.dart` |
| `repository.dart` | `report/domain/repositories/` | 报告仓库接口 | `report.dart` |
| `repository.dart` | `record/domain/repositories/` | 记录仓库接口 | `record.dart` |
| `repository.dart` | `mine/domain/repositories/` | 个人中心仓库接口 | `profile.dart` |
| `repository.dart` | `health_context/domain/repositories/` | 健康上下文仓库接口 | `snapshot.dart` |

> 共 **10 个文件**。这是最高优先级——不仅冗余，而且无法从文件名判断内容。

### 2.2 类型后缀冗余——目录已表达类型

#### `_provider` 后缀（12 个文件）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `suggestion_provider.dart` | `today/presentation/providers/` | `suggestion.dart` |
| `dashboard_provider.dart` | `today/presentation/providers/` | `dashboard.dart` |
| `ai_analysis_provider.dart` | `today/presentation/providers/` | `ai_analysis.dart` |
| `dashboard_provider.dart` | `report/presentation/providers/` | `dashboard.dart` |
| `ai_summary_provider.dart` | `report/presentation/providers/` | `ai_summary.dart` |
| `dashboard_provider.dart` | `record/presentation/providers/` | `dashboard.dart` |
| `time_provider.dart` | `record/presentation/providers/` | `time.dart` |
| `dashboard_provider.dart` | `mine/presentation/providers/` | `dashboard.dart` |
| `workspace_provider.dart` | `medicine/presentation/providers/` | `workspace.dart` |
| `risk_check_provider.dart` | `medicine/presentation/providers/` | `risk_check.dart` |
| `safety_tips_provider.dart` | `medicine/presentation/providers/` | `safety_tips.dart` |
| `oauth_login_provider.dart` | `auth/presentation/providers/` | `oauth_login.dart` |

> 生成文件 `.g.dart` / `.freezed.dart` 跟随源文件重命名。

#### `_providers` 后缀（barrel 文件，4 个）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `legal_providers.dart` | `legal/presentation/providers/` | `legal.dart` |
| `resources_providers.dart` | `support/data/providers/` | `resources.dart` |
| `reminder_providers.dart` | `medicine/presentation/providers/` | `reminders.dart` |
| `data_providers.dart` | `auth/data/providers/` | `auth.dart` |

> 另有 `health_context/data/providers/data_providers.dart` → `health_context.dart`，`settings/data/providers/profile_data_providers.dart` → `profile.dart`，`settings/data/providers/notification_permission_providers.dart` → `notification_permission.dart`。共 **7 个**。

#### `_controller` 后缀（在 `providers/` 下，4 个）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `data_export_controller.dart` | `settings/presentation/providers/` | `data_export.dart` |
| `user_settings_controller.dart` | `settings/presentation/providers/` | `user_settings.dart` |
| `data_storage_settings_controller.dart` | `settings/presentation/providers/` | `data_storage.dart` |
| `notification_settings_controller.dart` | `settings/presentation/providers/` | `notification.dart` |

> `_controller` 也是类型词，`providers/` 目录已隐含。`data_storage_settings` 中的 `settings` 指的是"用户设置数据"（业务词），不是目录名重复——但可以简化为 `data_storage`，因为 `settings/` 已在路径中。

#### `_data_source` 后缀（8 个文件）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `suggestion_remote_data_source.dart` | `today/data/datasources/` | `suggestion_remote.dart` |
| `ai_remote_data_source.dart` | `today/data/datasources/` | `ai_remote.dart` |
| `profile_remote_data_source.dart` | `settings/data/datasources/` | `profile_remote.dart` |
| `ai_summary_remote_data_source.dart` | `report/data/datasources/` | `ai_summary_remote.dart` |
| `dose_log_remote_data_source.dart` | `medicine/data/datasources/` | `dose_log_remote.dart` |
| `cached_dose_log_data_source.dart` | `medicine/data/datasources/` | `dose_log_cached.dart` |
| `safety_tips_remote_data_source.dart` | `medicine/data/datasources/` | `safety_tips_remote.dart` |
| `reminder_remote_data_source.dart` | `medicine/data/datasources/` | `reminder_remote.dart` |

> `remote` / `cached` 是实现限定词（区分远程 vs 缓存实现），不是类型词，保留。去掉的只是 `_data_source`。

#### `remote_data_source.dart`（裸名，6 个文件）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `remote_data_source.dart` | `search/data/datasources/` | `medicine_search.dart` |
| `remote_data_source.dart` | `report/data/datasources/` | `report.dart` |
| `remote_data_source.dart` | `record/data/datasources/` | `record.dart` |
| `remote_data_source.dart` | `health_context/data/datasources/` | `snapshot.dart` |
| `remote_data_source.dart` | `auth/data/datasources/` | `auth.dart` |
| `remote_data_source.dart` | `assistant/data/datasources/` | `assistant.dart` |

> 这些归入 2.1 的"纯类型名"问题，因为 `remote_data_source` 全是类型词。改为业务词后，如果将来加了缓存实现，再追加 `xxx_cached.dart`。

#### `_repository` 后缀（12 个文件）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `legal_repository.dart` | `legal/domain/repositories/` | `documents.dart` |
| `lucent_repository.dart` | `legal/data/repositories/` | `lucent.dart` |
| `lucent_repository.dart` | `today/data/repositories/` | `lucent.dart` |
| `lucent_ai_repository.dart` | `today/data/repositories/` | `lucent_ai.dart` |
| `lucent_repository.dart` | `search/data/repositories/` | `lucent.dart` |
| `lucent_repository.dart` | `report/data/repositories/` | `lucent.dart` |
| `lucent_ai_summary_repository.dart` | `report/data/repositories/` | `lucent_ai_summary.dart` |
| `lucent_repository.dart` | `record/data/repositories/` | `lucent.dart` |
| `lucent_daily_repository.dart` | `record/data/repositories/` | `lucent_daily.dart` |
| `lucent_repository.dart` | `mine/data/repositories/` | `lucent.dart` |
| `lucent_repository.dart` | `assistant/data/repositories/` | `lucent.dart` |
| `lucent_repository.dart` | `health_context/data/repositories/` | `lucent.dart` |
| `mock_repository.dart` | 多处 | `mock.dart` |
| `mock_workspace_repository.dart` | `medicine/data/repositories/` | `mock_workspace.dart` |
| `risk_check_repository.dart` | `medicine/data/repositories/` | `risk_check.dart` |
| `workspace_repository.dart` | `medicine/domain/repositories/` | `workspace.dart` |
| `daily_repository.dart` | `record/domain/repositories/` | `daily.dart` |

> `lucent` / `mock` 是实现限定词（区分实现来源），保留。去掉的只是 `_repository`。

#### `_page` 后缀（7 个文件）

| 当前文件 | 所在目录 | 建议改为 |
|---|---|---|
| `login_page.dart` | `auth/presentation/pages/` | `login.dart` |
| `register_page.dart` | `auth/presentation/pages/` | `register.dart` |
| `forgot_password_page.dart` | `auth/presentation/pages/` | `forgot_password.dart` |
| `change_email_page.dart` | `auth/presentation/pages/` | `change_email.dart` |
| `account_settings_page.dart` | `auth/presentation/pages/` | `account_settings.dart` |
| `detail_page.dart` | `legal/presentation/pages/` | `detail.dart` |
| `list_page.dart` | `legal/presentation/pages/` | `list.dart` |
| `detail_page.dart` | `notification/presentation/pages/` | `detail.dart` |
| `list_page.dart` | `notification/presentation/pages/` | `list.dart` |
| `risk_check_page.dart` | `medicine/presentation/pages/` | `risk_check.dart` |
| `barcode_scanner_page.dart` | `scan/presentation/pages/` | `barcode_scanner.dart` |
| `box_scan_page.dart` | `scan/presentation/pages/` | `box_scan.dart` |

> `_page` 后缀在 `pages/` 目录下冗余。业务词（`login`、`register`、`barcode_scanner`）保留。

#### `_settings_page` 后缀（13 个文件）

| 当前文件名 | 建议改为 |
|---|---|
| `about_settings_page.dart` | `about.dart` |
| `advanced_settings_page.dart` | `advanced.dart` |
| `language_settings_page.dart` | `language.dart` |
| `security_pin_settings_page.dart` | `security_pin.dart` |
| `theme_settings_page.dart` | `theme.dart` |
| `sleep_reminder_settings_page.dart` | `sleep_reminder.dart` |
| `notification_settings_page.dart` | `notification.dart` |
| `feature_flags_settings_page.dart` | `feature_flags.dart` |
| `help_settings_page.dart` | `help.dart` |
| `dnd_settings_page.dart` | `dnd.dart` |
| `data_storage_settings_page.dart` | `data_storage.dart` |
| `ai_settings_page.dart` | `ai.dart` |
| `accessibility_settings_page.dart` | `accessibility.dart` |

> `_settings_page` 双重冗余：`_settings` 重复了 `settings/` feature 目录，`_page` 重复了 `pages/` 目录。

#### `_section` 后缀（16 个文件）

**`today/.../widgets/sections/`（5 个）：**

`summary_section.dart` → `summary.dart`、`suggestion_section.dart` → `suggestion.dart`、`observation_section.dart` → `observation.dart`、`quick_actions_section.dart` → `quick_actions.dart`、`record_hint_section.dart` → `record_hint.dart`

**`report/.../widgets/sections/`（7 个）：**

`suggestion_history_section.dart` → `suggestion_history.dart`、`ai_summary_section.dart` → `ai_summary.dart`、`trend_section.dart` → `trend.dart`、`findings_section.dart` → `findings.dart`、`patterns_section.dart` → `patterns.dart`、`export_section.dart` → `export.dart`、`readiness_section.dart` → `readiness.dart`

**`medicine/.../widgets/sections/`（4 个）：**

`mobile_quick_operations_section.dart` → `mobile_quick_operations.dart`、`mobile_safety_section.dart` → `mobile_safety.dart`、`mobile_drugbox_section.dart` → `mobile_drugbox.dart`、`mobile_records_section.dart` → `mobile_records.dart`

### 2.3 `app_` 无意义前缀（core/ 目录，7 个文件）

`app_` 不是业务词（一切都属于 app），去掉后剩余的词就是职责：

| 当前文件名 | 所在目录 | 建议改为 |
|---|---|---|
| `app_database.dart` | `core/database/` | `database.dart` |
| `app_logger.dart` | `core/logger/` | `logger.dart` |
| `app_error.dart` | `core/errors/` | `error.dart` |
| `app_toast.dart` | `core/feedback/` | `toast.dart` |
| `app_locale.dart` | `core/i18n/` | `locale.dart` |
| `app_locale_controller.dart` | `core/i18n/` | `locale_controller.dart` |
| `app_theme_controller.dart` | `core/theme/` | `theme_controller.dart` |

> `app_theme_controller.dart` → `theme_controller.dart`：`_controller` 保留，因为 `core/theme/` 没有 `controllers/` 子目录，`_controller` 在此用于区分 `theme.dart`（主题定义）和控制器。

### 2.4 功能名=目录名前缀冗余

#### `features/legal/` — `legal_` 前缀

| 当前文件 | 建议改为 | 说明 |
|---|---|---|
| `legal_doc_type.dart` | `doc_type.dart` | `legal` 在路径中 |
| `legal_document.dart` | `document.dart` | `legal` 在路径中 |
| `legal_repository.dart` | `documents.dart` | 见 2.2 `_repository` 后缀 |
| `legal_providers.dart` | `legal.dart` | barrel 文件，见 2.2 |

#### `features/auth/data/datasources/wechat/` — `wechat_` 前缀（9 个）

| 当前文件 | 建议改为 |
|---|---|
| `wechat_mobile_auth_client.dart` | `mobile_auth_client.dart` |
| `wechat_mobile_auth_client_base.dart` | `mobile_auth_client_base.dart` |
| `wechat_mobile_auth_client_fluwx.dart` | `mobile_auth_client_fluwx.dart` |
| `wechat_mobile_auth_client_stub.dart` | `mobile_auth_client_stub.dart` |
| `wechat_mobile_auth_config.dart` | `mobile_auth_config.dart` |
| `wechat_desktop_oauth_callback_server.dart` | `desktop_oauth_callback_server.dart` |
| `wechat_desktop_oauth_callback_listener.dart` | `desktop_oauth_callback_listener.dart` |
| `wechat_desktop_oauth_callback_listener_io.dart` | `desktop_oauth_callback_listener_io.dart` |
| `wechat_desktop_oauth_callback_listener_stub.dart` | `desktop_oauth_callback_listener_stub.dart` |

#### `features/medicine/.../widgets/reminder/` — `reminder_` 前缀（6 个）

| 当前文件 | 建议改为 |
|---|---|
| `reminder_rows.dart` | `rows.dart` |
| `reminder_log_panels.dart` | `log_panels.dart` |
| `reminder_form_fields.dart` | `form_fields.dart` |
| `reminder_loading.dart` | `loading.dart` |
| `reminder_form_body.dart` | `form_body.dart` |
| `reminder_delete_dialog.dart` | `delete_dialog.dart` |

#### `features/record/.../widgets/meal/` — `meal_` 前缀（3 个）

| 当前文件 | 建议改为 |
|---|---|
| `meal_analysis_summary_card.dart` | `analysis_summary_card.dart` |
| `meal_dish_editor_section.dart` | `dish_editor.dart` |
| `meal_analysis_status_badge.dart` | `analysis_status_badge.dart` |

### 2.5 `app/app.dart` 双重 app（1 个文件）

| 当前路径 | 建议改为 |
|---|---|
| `lib/app/app.dart` | `lib/app/bootstrap.dart` |

### 2.6 Auth providers 子目录扁平化

当前 `auth/presentation/providers/` 有子目录 `session/` 和 `forms/`，导致路径冗余：

| 当前路径 | 建议改为 | 说明 |
|---|---|---|
| `session/session_provider.dart` | `session.dart` | 扁平化，去掉 `_provider` |
| `session/account_provider.dart` | `account.dart` | 扁平化，去掉 `_provider` |
| `forms/login_form_provider.dart` | `forms/login.dart` | 去掉 `_form_provider` |
| `forms/register_form_provider.dart` | `forms/register.dart` | 去掉 `_form_provider` |
| `forms/password_reset_provider.dart` | `forms/password_reset.dart` | 去掉 `_provider` |

> `session/session.dart` 是路径冗余（session 出现两次），扁平化为 `providers/session.dart` 更清晰。

---

## 三、统计

| 类别 | 源文件数 |
|---|---|
| 纯类型名（零业务语义） | 10 |
| `_provider` / `_providers` 后缀 | 19 |
| `_controller` 后缀（在 providers/ 下） | 4 |
| `_data_source` 后缀 | 8 |
| `_repository` 后缀 | 17 |
| `_page` 后缀 | 12 |
| `_settings_page` 后缀 | 13 |
| `_section` 后缀 | 16 |
| `app_` 无意义前缀 | 7 |
| 功能名=目录名前缀 | 22 |
| `app/app.dart` 双重 | 1 |
| Auth 子目录扁平化 | 5 |
| **合计（去重后）** | **~120** |

---

## 四、实施计划

### Phase 1：纯类型名修复（10 个文件，最高优先级）

这些文件不仅冗余，而且无法从文件名判断内容。

| 步骤 | 内容 | 工作量 |
|---|---|---|
| 1 | 重命名 10 个纯类型名文件 + 生成文件跟随 | 0.5h |
| 2 | 全局搜索替换 import 路径 | 1h |
| 3 | `dart run build_runner build --delete-conflicting-outputs` | 0.25h |
| 4 | `flutter analyze` + `flutter test` | 0.5h |

### Phase 2：`_provider` / `_providers` / `_controller` 后缀清理（23 个文件）

| 步骤 | 内容 | 工作量 |
|---|---|---|
| 1 | 重命名 23 个文件 + 生成文件跟随 | 1h |
| 2 | 全局搜索替换 import 路径 | 1h |
| 3 | `dart run build_runner build` + `flutter analyze` + `flutter test` | 0.5h |

### Phase 3：`_page` / `_settings_page` / `_section` 后缀清理（41 个文件）

| 步骤 | 内容 | 工作量 |
|---|---|---|
| 1 | 重命名 41 个文件 | 1h |
| 2 | 全局搜索替换 import 路径 + 路由声明 | 1h |
| 3 | `flutter analyze` + `flutter test` | 0.5h |

### Phase 4：`_data_source` / `_repository` 后缀清理（25 个文件）

| 步骤 | 内容 | 工作量 |
|---|---|---|
| 1 | 重命名 25 个文件 + 生成文件跟随 | 1h |
| 2 | 全局搜索替换 import 路径 | 1h |
| 3 | `dart run build_runner build` + `flutter analyze` + `flutter test` | 0.5h |

### Phase 5：`app_` 前缀 + 功能名=目录名前缀 + 子目录扁平化（35 个文件）

| 步骤 | 内容 | 工作量 |
|---|---|---|
| 1 | core/ 的 7 个 `app_` 前缀文件 + `app/app.dart` | 0.5h |
| 2 | legal/ 4 个 + wechat/ 9 个 + reminder/ 6 个 + meal/ 3 个 + auth 扁平化 5 个 | 1h |
| 3 | 全局搜索替换 import 路径 | 1h |
| 4 | `dart run build_runner build` + `flutter analyze` + `flutter test` | 0.5h |

---

## 五、注意事项

### 5.1 已经是最佳命名的文件（不改）

- `reminder_notification_coordinator.dart` — 职责清晰，无类型后缀
- `health_edit_forms.dart` — 职责清晰，无类型后缀
- `metrics_grid.dart`、`score_hero.dart` — 职责清晰，无 `_section` 后缀
- `form_mixin.dart` — 职责清晰
- `session.dart`（auth/domain/entities/）— 已经是最佳命名
- `suggestion.dart`（today/domain/entities/）— 已经是最佳命名
- `dashboard.dart`（today/domain/entities/）— 已经是最佳命名

### 5.2 生成文件跟随

`.g.dart`、`.freezed.dart` 等生成文件必须跟随源文件重命名，重命名后运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成。

### 5.3 分批提交

按 Phase 分批提交，每个 Phase 一个 commit：
- `refactor(naming): 修复纯类型名文件，补充业务语义`
- `refactor(naming): 去掉 providers/controllers 类型后缀冗余`
- `refactor(naming): 去掉 pages/sections 类型后缀冗余`
- `refactor(naming): 去掉 data_source/repository 类型后缀冗余`
- `refactor(naming): 去掉 app_ 前缀和功能名=目录名前缀冗余`

### 5.4 不改动的部分

- `lib/main.dart` — Flutter 入口约定
- `lib/l10n/app_localizations*.dart` — `flutter gen-l10n` 生成，文件名由 `l10n.yaml` 配置决定
- `lib/l10n/src/` 下的 ARB 分片文件 — 前缀是 `arb_tools.dart` fragment 规则的一部分
- `lib/app/router.dart` 和 `lib/app/router/helpers.dart` — `router` 是子目录名不是 `app_` 前缀
- `page.dart`（各 feature 主页面入口）— `page` 是约定名，类似 `index` 的角色
- `routes.dart` / `routes.g.dart` — 路由声明文件，命名是 go_router_builder 约定

---

## 六、验证清单

- [ ] `dart run build_runner build --delete-conflicting-outputs` 无错误
- [ ] `flutter analyze` 零问题
- [ ] `flutter test` 全部通过
- [ ] 全项目无 `provider.dart` / `providers.dart` / `repository.dart` / `controller.dart` 纯类型名文件
- [ ] 全项目无 `_provider` / `_data_source` / `_section` / `_settings_page` 类型后缀
- [ ] git diff 中只有 rename + import 路径变更，无逻辑改动
