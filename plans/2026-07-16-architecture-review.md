# Luminous 架构审查改进计划（2026-07-16）

来源：2026-07-16 全库架构审查（lib/ 全量、test/、integration_test/、docs/00-current + 02-reference 交叉核对）。

总体评价：基础设施层质量较高（`core/network` 三拦截器、Drift + SyncWorker、GoRouter 集中配置、Forui 图标零残留、无 StateProvider/ChangeNotifier，ADR-0007/0009/0010 落地扎实）。主要债务集中在 **feature 切片分层执行不一致** 和 **mock 切换机制**。

每条完成并落地到 docs 后，从本文件删除对应章节。

---

## 高优先级

### 4. 跨 feature 的 presentation→presentation 直接耦合

**问题**：feature 间没有边界，改一个 dashboard provider 签名要动三个 feature。

**证据**：
- record 5 个 presentation 文件直接 import today/report 的 presentation providers 做 `ref.invalidate`：`nlp_controller.dart:12-13`、`pages/create.dart:28-30`、`detail.dart:23-25`、`edit.dart:36-38`、`fast_entry_dialog.dart:17-18`
- mine 直接 import notification providers：`pages/page.dart:18`、`top_bar.dart:6`、`notifications_reminders.dart:11`
- `mine/presentation/providers/health_edit_forms.dart:7-9` → medicine workspace + today dashboard providers
- `health_context/data/providers/health_context.dart` 成事实上的全局 hub，被 13+ 处其他 feature import
- 交叉 import 统计：mine→auth 20、medicine→health_context 15、mine→health_context 13、record→auth 11

**行动**：
1. 数据变更后的跨 feature 刷新改为 data 层事件（core 层轻量 invalidation bus，或 repository provider 之间 `ref.listen`），而非 UI 层互相 import。
2. `healthContextSnapshotProvider` 保留 hub 地位，在 architecture 文档中明确标注为共享只读快照。

**影响范围**：record/today/report/mine/notification 5 个 feature，渐进式重构。

---

## 中优先级

### 7. 缓存/离线策略三种实现位置，写路径回放只覆盖 record

**证据**：cache-first 在 record 和 health_context 放 repository，但 today suggestion 把 DAO + JSON codec + stale-while-error 全放在 presentation notifier（`today/presentation/providers/suggestion.dart:47-66`，直读 remote datasource + DAO 绕过 repository）；`SyncWorker` 的 replay handler 只注册了 `daily_record` 一路（`record/data/providers/record_access.dart:33`），health_context 更新、dose log create/mark、settings patch 离线写后无回放。

**行动**：
1. suggestion 缓存逻辑下沉到 `today/data/repositories/`。
2. 明确哪些写操作需要离线队列（dose log mark 属用药安全敏感路径，优先），逐路注册 handler。

**影响范围**：today data 层新增/调整，sync handler 逐 feature 补。

### 8. 巨型文件 / god class：10 个文件超 500 行

**证据**（实测行数）：
- `today/presentation/widgets/sections/suggestion.dart` **952 行 / 18 个类**
- `record/presentation/widgets/sections/quick_entry_panel.dart` 739
- `settings/presentation/pages/page.dart` 706
- `record/presentation/pages/edit.dart` 684
- `record/data/repositories/mock.dart` 642（兼藏真实 provider，见 #1）
- `record/presentation/pages/detail.dart` 624
- `assistant/presentation/providers/conversation.dart` 590（`AssistantController`）
- `report/presentation/pages/page.dart` 588
- `medicine/.../mobile_drugbox.dart` 580、`reminder_edit_page.dart` 518
- `docs/00-current/TODO.md:21` 的「超大页面拆分暂缓」仍列旧文件名 `login_page.dart`（现已 465 行），最大的 suggestion.dart 不在清单

**行动**：优先拆 suggestion.dart（按 primary card / feedback / ai-explain / evidence / states 分文件）和 mock.dart；TODO 清单按实测行数重写。

**影响范围**：纯文件拆分，不改逻辑。

### 9. 文档与代码系统性漂移

**证据**：
- `Luminous/AGENTS.md:152` 引用 `lib/theme/theme.dart`、`lib/app/app.dart`——均不存在，实为 `lib/core/theme/theme.dart`、`lib/app/bootstrap.dart`
- `docs/02-reference/architecture.md` 引用 `lib/app/app.dart`、`core/widgets/settings/`——均不存在
- `docs/02-reference/data-layer.md` 引用 `lucent_dio_client.dart`、`lucent_session_store.dart`——实为 `dio_client.dart`、`session_store.dart`
- `docs/00-current/Mock_Or_Deferred.md:57` 称 mock 命名为 `mock_*_repository.dart`——实为 `mock.dart`/`mock_workspace.dart`
- Current_State 的 ADR-0006 完成宣称——见 #6

**行动**：一次文档校准提交修正上述引用；architecture.md 目录树改为「以 lib/ 实际结构为准」的简述，降低再次漂移概率。

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

---

## 附：分层完整性速查

| Feature | data | domain | presentation | 主要缺口 |
|---|---|---|---|---|
| today / record / report / mine / medicine / search / legal / health_context / notification / settings / support | ✓ | ✓（含接口） | ✓ | health_context 无 presentation（hub，可接受） |
| assistant | ✓ | 仅 entities | ✓ | 接口错位在 data（#5） |
| auth | ✓ | 仅 entities | ✓ | 无 repository（#5） |
| scan | ✓（散文件） | 仅 services | ✓ | 无接口、DTO/Map 泄漏（#5） |
| shell | ✗ | ✗ | ✓ | 空 `providers/` 目录（#12） |
