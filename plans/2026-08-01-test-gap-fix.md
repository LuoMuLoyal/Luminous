# Luminous 测试覆盖补齐计划（未完成部分）

> **For agentic workers:** 按任务清单逐项执行，每项完成后运行对应验证命令并提交。
> 步骤使用复选框（`- [ ]`）跟踪进度。

**Goal:** 补齐 Luminous 覆盖率缺口（health_data 3.3%、scan 36.9%、core/database 41.8%、medicine risk_check 0-25%）。

**Architecture:** 全部为 Flutter unit/widget 测试（`flutter test`）。纯 Dart 逻辑（mapper/entity/usecase）用 `test()`，widget/页面用 `testWidgets()`，已有 `Mock*Repository` 与 `test/helpers/test_helpers.dart` 惯例。

**Tech Stack:** Flutter 3.44.0 / Dart 3.12.0、Riverpod（Notifier + AsyncNotifier）、drift（core/database）、generated lucent_api client。

---

> 进度说明（2026-08-03 更新）：原计划中 **P0 阻断（套件挂起）与 14 个失败用例已全部
> 清零**（`flutter test` 2709 通过 + 1 跳过），`dart_test.yaml` 超时已收紧至 90s，
> 见 `docs/03-logs/migration-log/2026-08-01.md`。本文件仅保留**未实施**的覆盖率
> 补测试任务（Phase 2-8）。

### 覆盖率缺口清单（P1/P2，未完成）

| 级别 | 模块/文件 | 覆盖率 | 说明 |
|---|---|---|---|
| P1 | `features/health_data/**`（13 文件） | **3.3%** | 整个健康同步功能零测试：mapper 0.4%、repository/provider/controller 0-0.5%、页面 0.5% |
| P1 | `features/scan/**` | 36.9% | `box_scan.dart` 0%、`barcode_scanner.dart` 0.5%、`paddle_ocr_provider.dart` 0%（OCR 提取器/仓库已有测试） |
| P1 | `features/medicine/risk_check*` | 0-25% | mapper 1.2%、repository 0%、datasource 0%、provider 25% —— 与 Lucent 端 risk-check 同源 |
| P1 | `features/report/clinic_summary*` | 0-1% | provider 0%、shared 0%、content widget 0%、preview dialog 1.1% |
| P1 | `core/database/**` | 41.8% | `tables/*.dart` 全 0%（drift 表定义，低价值）；`database.g.dart` 31.5%（生成物，跳过） |
| P2 | `core/widgets/command_palette.dart` | 0.7% | 较大 widget 完全未测 |
| P2 | `record/application/usecases/change_record_date.dart` | 0% | 纯业务用例 |
| P2 | `settings/utils/version_check.dart` | 0% | 纯函数（版本比较） |
| P2 | `settings/presentation/widgets/master_detail.dart` | 0% | 布局 widget |
| P2 | `search/.../sections/{quick_actions,categories,recent_searches}.dart` | 7-17% | 页面区块 widget |
| P2 | `core/widgets/common/security_elevation_dialog.dart` | 14.8% | 安全对话框 |
| P2 | `record/data/providers/record_access.dart` | 9.5% | 数据访问门卫 |

### 排除项（不为它们写测试）

- `.g.dart` / `.freezed.dart`（riverpod/drift/freezed 生成物）与 `l10n/app_localizations_*.dart`。
- 平台桩/桥接：`wechat/mobile_auth_client_fluwx.dart`、`desktop_oauth_callback_listener_io.dart`（真机/插件依赖，保持低覆盖并注释说明）。
- `main.dart`、`app/bootstrap.dart`（进程入口，由 integration_test 覆盖）。

---

## Phase 2: health_data 功能测试（P1，3.3% → ≥70%）

**Files:**
- Create: `test/health_data/mapper_test.dart`、`test/health_data/health_sync_repository_test.dart`、`test/health_data/health_sync_providers_test.dart`、`test/health_data/health_sync_page_test.dart`

- [ ] **Task 2.1: `health_record_mapper.dart`（0.4% → ≥90%）**
  - 纯函数映射（平台原始记录 → `HealthMetric`），先读文件列全映射分支，用 `test()` 覆盖：正常映射、空字段、未知单位、时间戳解析失败回退。
  - 验证：`flutter test test/health_data/mapper_test.dart`

- [ ] **Task 2.2: `data/repositories/health_sync.dart`（0%）**
  - mock `HealthPlatform` 数据源与 DAO，覆盖：同步成功落库、部分源失败跳过、并发/取消、结果聚合（`HealthSyncResult`）。
  - 验证：`flutter test test/health_data/health_sync_repository_test.dart`

- [ ] **Task 2.3: `presentation/providers/health_sync_controller.dart` 与 `data/providers/health_sync.dart`（0%）**
  - 复用 `ProviderContainer` + 依赖 override 模式（参考 `test/helpers/test_helpers.dart` 的 session override 惯例），覆盖：开始同步状态机（idle→running→done/error）、权限拒绝、自动同步开关、手动触发。
  - 验证：`flutter test test/health_data/health_sync_providers_test.dart`

- [ ] **Task 2.4: `presentation/pages/health_sync.dart`（0.5%）**
  - `testWidgets` 渲染各状态（空态、同步中、成功、错误）与权限引导按钮；`HealthPlatform` 用 mock provider override。
  - 验证：`flutter test test/health_data/health_sync_page_test.dart`

- [ ] **Task 2.5: Commit（每 Task 独立提交）**：`test(health_data): 补齐 mapper/repository/providers/page 测试`

---

## Phase 3: medicine risk_check 客户端测试（P1，0-25% → ≥80%）

**Files:**
- Create: `test/medicine/risk_check_mapper_test.dart`、`test/medicine/risk_check_repository_test.dart`、`test/medicine/risk_check_providers_test.dart`

- [ ] **Task 3.1: `data/mappers/risk_check.dart`（1.2%）**
  - 纯映射（`MedicineRiskCheckResponseDto` → 领域实体），覆盖全部 finding 类型、coverage issue reason、red flag rule、score/level 边界。
  - 验证：`flutter test test/medicine/risk_check_mapper_test.dart`

- [ ] **Task 3.2: `data/repositories/risk_check.dart` + `data/datasources/risk_check_remote.dart`（0%）**
  - mock generated API（同 `_FakeUserSettingsApi` 模式，`test/helpers/mocks/medicine.dart` 已有 risk 相关 fixture 则复用），覆盖：GET 记录、POST static/llm、空记录、Dio 错误传播。
  - 验证：`flutter test test/medicine/risk_check_repository_test.dart`

- [ ] **Task 3.3: `presentation/providers/risk_check.dart`（25% → ≥80%）**
  - 补：加载空态、静态检查成功/失败、LLM 检查成功/失败、刷新与缓存。
  - 验证：`flutter test test/medicine/risk_check_providers_test.dart`

- [ ] **Task 3.4: Commit**：`test(medicine): 补齐 risk_check 客户端测试`

---

## Phase 4: report clinic_summary 测试（P1，0-1% → ≥70%）

**Files:**
- Create: `test/report/clinic_summary_provider_test.dart`、`test/report/clinic_summary_content_test.dart`

- [ ] **Task 4.1: `presentation/providers/clinic_summary.dart`（0%）**
  - 覆盖：加载、空数据、错误、重试；mock repository。
- [ ] **Task 4.2: `clinic_summary_shared.dart` + `clinic_summary_content.dart` + `clinic_summary_preview_dialog.dart`（0-1%）**
  - `testWidgets` 渲染各章节（概况/发现/建议）、空态、展开交互。
- [ ] 验证：`flutter test test/report/clinic_summary_provider_test.dart test/report/clinic_summary_content_test.dart`
- [ ] Commit：`test(report): 补齐 clinic summary 测试`

---

## Phase 5: scan 页面测试（P1，36.9% → ≥60%）

- [ ] **Task 5.1: `presentation/pages/box_scan.dart`（0%）与 `barcode_scanner.dart`（0.5%）**
  - `testWidgets` 渲染与主交互（相机不可用态、识别中、结果展示）；相机插件用抽象/mock 隔离（读现有 `test/scan/data/repositories/scan_test.dart` 的 mock 惯例）。
- [ ] **Task 5.2: `domain/services/paddle_ocr_provider.dart`（0%）**
  - 若含可单测的解析逻辑则补 `test()`；纯平台桥接部分注明排除。
- [ ] 验证：`flutter test test/scan`
- [ ] Commit：`test(scan): 补齐扫描页面与 OCR provider 测试`

---

## Phase 6: core/database 补充（P1，41.8% → ≥55%）

- [ ] **Task 6.1: `tables/*.dart`（6 个，各 0%）**
  - drift 表定义本身低价值；价值在 DAO 查询。检查 `test/core/database/dao_test.dart` 与 `dao_extended_test.dart` 是否已覆盖各表的读写；对未覆盖的 DAO（如 `pending_sync_dao`、`today_suggestion_dao`）补查询用例。
- [ ] 验证：`flutter test test/core/database`
- [ ] Commit：`test(database): 补齐 DAO 查询覆盖`

---

## Phase 7: 高价值零覆盖文件（P2）

- [ ] **Task 7.1: `record/application/usecases/change_record_date.dart`（0%）** — 纯用例，补日期变更/非法回退分支。
- [ ] **Task 7.2: `settings/utils/version_check.dart`（0%）** — 版本字符串比较（旧<新、相等、畸形）。
- [ ] **Task 7.3: `core/widgets/command_palette/command_palette.dart`（0.7%）** — `testWidgets` 渲染、搜索过滤、选中回调、空结果。
- [ ] **Task 7.4: `settings/presentation/widgets/master_detail.dart`（0%）与 `core/widgets/common/security_elevation_dialog.dart`（14.8%）** — 布局与安全交互 widget 测试。
- [ ] **Task 7.5: search sections（quick_actions 7.1% / categories 7.9% / recent_searches 17.4%）与 `record/data/providers/record_access.dart`（9.5%）** — 补区块渲染与门卫分支。
- [ ] 每项独立验证与提交：`flutter test test/<对应路径>`；Commit：`test(<scope>): ...`

---

## Phase 8: 验证与收尾

- [ ] **Task 8.1: 全量测试 + 覆盖率复测**

```powershell
flutter analyze
flutter test --timeout=90s
flutter test --coverage --timeout=90s
python coverage/calc_coverage.py --coverage
```

Expected：`flutter test` 全绿；整体行覆盖率 ≥70%（基线 63.0%）；health_data ≥70%、risk_check/clinic_summary ≥70%。

- [ ] **Task 8.2: 文档与提交**

- 追加 `docs/03-logs/migration-log/2026-08-01.md`：记录覆盖率变化（63.0% → X%）。
- 若有 l10n 文案断言改动 → 遵循 ARB fragment 流程并同步 `docs/02-reference/Localization.md`。
- 运行 `dart run scripts/check_doc_coverage.dart --warning-only` 确认文档规则。
- 删除 `docs/00-current/TODO.md` 中已完成的相关行（如有）。

- [ ] **Task 8.3: 计划收尾**

按 AGENTS.md 规则，执行完毕的计划段直接删除；整个计划完成后删除本文件，将覆盖率基线与 CI 修复结论落到 `docs/00-current/Current_State.md`。

---

## 完成标准

1. `flutter test` 全绿（挂起问题不再复发）。
2. 整体行覆盖率 ≥70%（基线 63.0%）。
3. health_data 模块 ≥70%；medicine risk_check、report clinic_summary ≥70%；scan ≥60%。
4. `flutter analyze` 无新增告警。
5. 迁移日志已追加；计划段执行完毕即删除。

## 风险与回退

| 风险 | 可能性 | 影响 | 缓解 |
|---|---|---|---|
| health_data 平台数据源难 mock | 高 | 中 | 优先测 mapper/repository/provider 纯逻辑；平台桥接文件按排除项注明 |
| scan 相机插件在 widget 测试中不可用 | 中 | 中 | 走抽象层 mock（现有 `scan_test.dart` 惯例），不启动真实相机 |
| 覆盖率仍不足 70%（生成物占比大） | 中 | 低 | 排除项已声明；若接近阈值可放宽目标到 68% 并记录基线 |
