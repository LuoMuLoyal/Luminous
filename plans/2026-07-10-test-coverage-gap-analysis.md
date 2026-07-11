# Luminous 测试缺口分析报告

> 生成日期：2026-07-10
> 数据来源：`coverage/lcov.info` + `lib/` 源文件全量扫描

---

## 一、总体概况

| 指标 | 数值 |
|------|------|
| 被测追踪的源文件 | 331 |
| 单元/Widget 测试文件 | 133 |
| 集成测试文件 | 17 |
| 总代码行 | 24,249 |
| 已覆盖行 | 15,111 |
| **整体行覆盖率** | **62.3%** |
| 零覆盖文件（有追踪但 0%） | 25 |
| 低覆盖文件（<50%） | 84 |
| 完全未追踪文件 | 88 |

---

## 二、完全无测试的功能模块

### 1. `scan` 模块 — 零测试覆盖

整个扫描功能没有任何独立测试文件，`test/` 下不存在 `scan/` 目录：

| 源文件 | 覆盖率 | 说明 |
|--------|--------|------|
| `scan/data/scan_repository.dart` | 0%（未追踪） | 扫描仓库核心逻辑 |
| `scan/domain/services/text_matcher.dart` | 2%（1/56） | OCR 文本匹配引擎，含正则+模糊匹配算法 |
| `scan/domain/services/ocr_service.dart` | 33%（3/9） | OCR 服务封装 |
| `scan/presentation/pages/box_scan_page.dart` | 0%（0/85） | 药盒扫描页面 |
| `scan/presentation/pages/barcode_scanner_page.dart` | 1%（1/84） | 条码扫描页面 |
| `scan/presentation/widgets/dialogs/recognize_dialog.dart` | 0%（0/113） | 识别结果对话框 |

> `text_matcher.dart` 包含药品批准文号正则、条码正则、模糊匹配等核心业务逻辑，**缺少测试是高风险项**。

### 2. `shell` 模块 — 无独立测试

Shell 模块的测试散落在 `test/app/` 下（`shell_page_test.dart`、`shell_provider_test.dart`），但以下文件完全未追踪：

- `shell/presentation/branch.dart`
- `shell/presentation/deferred_content.dart`
- `shell/presentation/tab.dart`

---

## 三、零覆盖文件（25 个，按严重程度排序）

### 高优先级 — 核心业务逻辑

| 文件 | 代码行 | 说明 |
|------|--------|------|
| `record/domain/entities/dashboard.dart` | 22 | 记录仪表盘领域模型 |
| `record/data/repositories/lucent_daily_repository.dart` | 17 | 每日记录远程仓库 |
| `record/presentation/widgets/dialogs/voice_entry_dialog.dart` | 142 | 语音录入对话框 |
| `record/presentation/widgets/dialogs/ocr_entry_dialog.dart` | 113 | OCR 录入对话框 |
| `record/presentation/widgets/sections/quick_actions.dart` | 41 | 快捷操作区 |
| `record/presentation/widgets/sections/week_strip.dart` | 49 | 周日历条 |
| `today/data/datasources/ai_remote_data_source.dart` | 37 | AI 远程数据源 |
| `medicine/domain/entities/workspace.dart` | 1 | 药品工作台实体 |
| `medicine/domain/entities/safety_tip.dart` | 1 | 安全提示实体 |
| `medicine/presentation/widgets/reminder/reminder_form_body.dart` | 107 | 提醒表单主体 |
| `medicine/presentation/widgets/reminder/reminder_form_fields.dart` | 52 | 提醒表单字段 |
| `medicine/presentation/widgets/reminder/reminder_delete_dialog.dart` | 13 | 提醒删除对话框 |
| `mine/presentation/widgets/sections/status_overview.dart` | 57 | 状态概览 |
| `mine/presentation/widgets/shared/components.dart` | 23 | 共享组件 |
| `report/presentation/widgets/dialogs/range_picker_dialog.dart` | 56 | 日期范围选择对话框 |
| `search/data/datasources/remote_data_source.dart` | 7 | 搜索远程数据源 |
| `search/domain/entities/entities.dart` | 3 | 搜索领域实体 |
| `scan/data/scan_repository.dart` | 31 | 扫描仓库 |
| `scan/presentation/pages/box_scan_page.dart` | 85 | 药盒扫描页 |
| `scan/presentation/widgets/dialogs/recognize_dialog.dart` | 113 | 识别对话框 |
| `assistant/data/datasources/remote_data_source.dart` | 59 | AI 助手远程数据源 |
| `health_context/data/repositories/lucent_repository.dart` | 34 | 健康上下文仓库 |

### 低优先级 — 生成代码 / 简单文件

- `auth/domain/entities/session.g.dart`（生成代码，52 行）
- `core/design/animation_durations.dart`（常量定义，1 行）
- `medicine/domain/entities/safety_tip.dart`（类型别名，1 行）
- `medicine/domain/entities/workspace.dart`（类型别名，1 行）

---

## 四、完全未追踪文件（88 个，重点列出关键缺口）

这些文件在 lcov 中根本不存在，意味着测试执行时从未触及它们：

### `core/` 层 — 基础设施缺口

| 文件 | 说明 |
|------|------|
| `core/network/interceptors/auth_interceptor.dart` | **Token 注入 + 401 刷新 + 重试 + 会话清除**，安全关键 |
| `core/network/interceptors/retry_interceptor.dart` | 网络重试拦截器 |
| `core/network/interceptors/error_interceptor.dart` | 错误拦截器 |
| `core/network/api.dart` | API 定义 |
| `core/database/sync/sync_worker.dart` | **离线同步引擎**，监听网络恢复后回放队列 |
| `core/database/daos/*.dart`（6 个 DAO） | 全部 6 个 DAO 无测试 |
| `core/database/tables/*.dart`（7 个表定义） | 全部表定义无测试 |
| `core/database/app_database.dart` | 数据库入口 |
| `core/database/cache_cleanup_provider.dart` | 缓存清理 |
| `core/database/database_providers.dart` | 数据库 DI |
| `core/errors/app_error.dart` | 错误模型 |
| `core/errors/result.dart` | Result 类型 |
| `core/errors/run_guarded.dart` | 守护执行 |
| `core/providers/auth_guarded.dart` | 认证守护 |
| `core/widgets/common/state_views.dart` | 错误状态视图 |
| `core/design/*.dart`（10 个文件） | 设计令牌（常量，低风险） |

### `features/` 层 — 功能模块缺口

| 文件 | 说明 |
|------|------|
| `today/data/utils/suggestion_json_codec.dart` | **建议卡片 JSON 序列化/反序列化**，缓存层关键 |
| `today/presentation/providers/suggestion_provider.dart` | 今日建议 Provider |
| `today/data/datasources/suggestion_remote_data_source.dart` | 建议远程数据源 |
| `today/domain/entities/suggestion.dart` | 建议领域实体 |
| `today/domain/entities/recommendation.dart` | 推荐领域实体 |
| `today/domain/repositories/repository.dart` | 仓库接口 |
| `today/presentation/widgets/shared/suggestion_icon_mapping.dart` | 图标映射 |
| `auth/presentation/providers/oauth_login_provider.dart` | OAuth 登录 Provider |
| `auth/presentation/providers/shared/auth_action_runner.dart` | 认证动作执行器 |
| `auth/presentation/services/wechat_oauth_service.dart` | 微信 OAuth 服务 |
| `auth/presentation/widgets/shared/oauth_callback_parser.dart` | OAuth 回调解析器 |
| `auth/presentation/widgets/shared/oauth_panels.dart` | OAuth 面板 |
| `medicine/data/datasources/cached_dose_log_data_source.dart` | 缓存剂量日志数据源 |
| `medicine/presentation/widgets/workspace/*.dart`（5 个文件） | 工作台全部 widget |
| `record/data/utils/daily_record_json_codec.dart` | 记录 JSON 编解码 |
| `record/domain/entities/candidates.dart` | NLP 候选实体 |
| `record/domain/entities/inputs.dart` | 输入实体 |
| `record/domain/repositories/repository.dart` | 仓库接口 |
| `record/presentation/widgets/shared/overview.dart` | 概览组件 |
| `health_context/domain/entities/snapshot.dart` | 健康快照实体 |
| `search/domain/repositories/repository.dart` | 仓库接口 |
| `mine/domain/repositories/repository.dart` | 仓库接口 |

---

## 五、低覆盖率热点（<50%，按影响排序）

### 最需要关注的低覆盖文件

| 文件 | 覆盖率 | 代码行 | 说明 |
|------|--------|--------|------|
| `assistant/data/repositories/lucent_repository.dart` | 2% | 180 | AI 助手仓库，大量逻辑未测 |
| `auth/data/datasources/remote_data_source.dart` | 30% | 169 | 认证远程数据源 |
| `medicine/presentation/pages/reminder/reminder_edit_page.dart` | 22% | 258 | 提醒编辑页（最大页面之一） |
| `medicine/presentation/widgets/reminder/reminder_rows.dart` | 11% | 120 | 提醒列表行 |
| `record/presentation/pages/create.dart` | 48% | 223 | 创建记录页 |
| `record/data/quick_entry_preferences.dart` | 49% | 59 | 快捷录入偏好 |
| `record/data/voice_recording_service.dart` | 4% | 49 | 语音录制服务 |
| `scan/domain/services/text_matcher.dart` | 2% | 56 | OCR 文本匹配引擎 |
| `settings/data/services/notification_permission_service.dart` | 16% | 55 | 通知权限服务 |
| `today/data/repositories/lucent_ai_repository.dart` | 8% | 37 | AI 仓库 |
| `search/data/repositories/lucent_repository.dart` | 3% | 30 | 搜索仓库 |
| `medicine/data/repositories/risk_check_repository.dart` | 9% | 22 | 风险检查仓库 |

### Settings 子页面 — 系统性低覆盖

以下设置页面覆盖率均为 ~1%，说明测试只触发了构建但未测交互逻辑：

| 文件 | 覆盖率 | 代码行 |
|------|--------|--------|
| `security_pin_settings_page.dart` | 1% | 161 |
| `feature_flags_settings_page.dart` | 1% | 121 |
| `ai_settings_page.dart` | 1% | 119 |
| `data_export_page.dart` | 1% | 109 |
| `data_storage_settings_page.dart` | 1% | 80 |
| `dnd_settings_page.dart` | 2% | 50 |
| `sleep_reminder_settings_page.dart` | 2% | 53 |
| `accessibility_settings_page.dart` | 2% | 62 |
| `advanced_settings_page.dart` | 25% | 190 |

---

## 六、测试缺口分类汇总

| 缺口类型 | 数量 | 优先级 |
|----------|------|--------|
| **完全无测试的功能模块**（`scan`） | 1 整个模块 | 🔴 高 |
| **网络拦截器零测试**（auth/retry/error interceptor） | 3 文件 | 🔴 高 |
| **离线同步引擎零测试**（`sync_worker`） | 1 文件 | 🔴 高 |
| **DAO 层零测试**（6 个 DAO + 7 个表定义） | 13 文件 | 🟡 中 |
| **零覆盖业务文件**（排除生成代码/常量） | ~20 文件 | 🔴 高 |
| **JSON 编解码零测试**（suggestion/daily_record codec） | 2 文件 | 🟡 中 |
| **Settings 子页面 ~1% 覆盖** | 9 文件 | 🟡 中 |
| **Reminder 表单组件零覆盖** | 3 文件（172 行） | 🟡 中 |
| **语音/OCR 录入对话框零覆盖** | 2 文件（255 行） | 🟡 中 |
| **仓库实现低覆盖**（assistant/auth/search/today） | 4 文件 | 🟡 中 |
| **OAuth/微信认证链未追踪** | ~6 文件 | 🟡 中 |

---

## 七、建议优先补测清单

1. **`scan/domain/services/text_matcher.dart`** — 含正则匹配和模糊匹配核心算法，纯逻辑无 UI 依赖，最容易补且价值最高
2. **`core/network/interceptors/auth_interceptor.dart`** — Token 刷新、401 重试、会话清除，安全关键路径
3. **`core/database/sync/sync_worker.dart`** — 离线同步引擎，涉及数据一致性
4. **`today/data/utils/suggestion_json_codec.dart`** — JSON 序列化往返测试，简单高效
5. **`record/data/utils/daily_record_json_codec.dart`** — 同上
6. **`assistant/data/repositories/lucent_repository.dart`** — 180 行仅 2% 覆盖，业务逻辑密集
7. **Settings 子页面 widget 测试** — 系统性问题，可批量补测交互逻辑
8. **`medicine/presentation/widgets/reminder/` 三件套** — 表单主体+字段+删除对话框，共 172 行零覆盖
