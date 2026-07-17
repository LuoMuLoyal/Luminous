# Luminous 架构审查改进计划（2026-07-16）

来源：2026-07-16 全库架构审查（lib/ 全量、test/、integration_test/、docs/00-current + 02-reference 交叉核对）。

总体评价：基础设施层质量较高（`core/network` 三拦截器、Drift + SyncWorker、GoRouter 集中配置、Forui 图标零残留、无 StateProvider/ChangeNotifier，ADR-0007/0009/0010 落地扎实）。主要债务集中在 **feature 切片分层执行不一致** 和 **mock 切换机制**。

每条完成并落地到 docs 后，从本文件删除对应章节。

---

## 低优先级

### 10. 信封 `code != 0` 业务错误处理散落

**证据**：`ErrorInterceptor` 只映射 `DioException`（`core/network/interceptors/error_interceptor.dart:14-18`），200-OK-but-`code != 0` 由各调用点手动 `throw StateError(...)`（4 文件 11 处：notification 8 处、record datasource、search lucent、medicine risk_check），绕过 ADR-0008 的 `AppError`/`LucentApiException` 体系。

**行动**：在 `core/network/envelope.dart` 加统一 `unwrapOrThrow` helper（非零 code → `LucentApiException`），各 datasource 替换手动检查。

### 11. 原始 dio 直调 + 硬编码 `/api/v1/...` 路径，绕过生成 client

**证据**：`scan/data/scan_repository.dart:38,55,75`（`/api/v1/user/files/upload`、`/api/v1/medicines/recognize`）；`medicine/data/datasources/dose_log_remote.dart`、`record/data/datasources/record.dart`、`settings/data/datasources/profile_remote.dart` 各 1 处。

**行动**：缺失端点补进 Lucent OpenAPI 合同再生成 client；无法入合同的集中到 `core/network` typed helper，路径常量化。

### 12. 自家命名规则违反 + 空目录残留

**证据**：`medicine/data/repositories/lucent_workspace_repository.dart`（`_repository` 后缀）、`reminder_detail_page.dart`/`reminder_edit_page.dart`/`data_export_page.dart`（`_page` 后缀）、`scan/data/scan_repository.dart`（散文件）；mock 文件 `mock.dart` vs `mock_workspace.dart` 不一致；`lib/features/shell/providers/` 空目录；`test/` 不镜像 `lib/` 结构（`test/auth/login_page_test.dart` 扁平 vs `test/features/legal/...` 嵌套并存）。

**行动**：下次触碰这些文件时顺带改名；删空目录；test 目录统一镜像结构。

### 13. SharedPreferences 散落 11 个文件，presentation provider 直接读写 prefs

**证据**：core 层 6 处 + `medicine/presentation/providers/reminders.dart`、`reminder_notification_coordinator.dart`（presentation 越过 data 层直接持久化）+ `record/data/quick_entry_preferences.dart` + settings 2 处；key 字符串无注册表。

**行动**：建 `core/config/pref_keys.dart` 常量注册表；medicine 的 prefs 读写挪入 data 层。

### 14. `setState` 与 hooks/Notifier 混用（30 处 / 10 文件）

**证据**：today suggestion.dart、quick_entry_panel、settings advanced、oauth_panels、barcode_scanner、deferred_content 等，均为局部 UI 状态（动画、loading 标志），不构成架构问题，但与 AGENTS.md 表述有出入。

**行动**：在 state-management.md 明确「ephemeral UI 状态允许 StatefulWidget/hooks」的边界，避免后续审查反复标记。
