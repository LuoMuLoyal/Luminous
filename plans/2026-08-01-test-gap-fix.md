# Luminous 测试缺口修复计划

> **For agentic workers:** 按任务清单逐项执行，每项完成后运行对应验证命令并提交。
> 步骤使用复选框（`- [ ]`）跟踪进度。

**Goal:** 修复 Luminous 测试套件的 CI 红态（14 个失败用例 + 1 个导致套件挂起的阻断问题），并消除最大覆盖率缺口（health_data 3.3%、scan 36.9%、core/database 41.8%、medicine risk_check 0-25%）。

**Architecture:** 全部为 Flutter unit/widget 测试（`flutter test`）。优先修复 CI 阻断（失败用例 + 挂起），再按"模块覆盖率从低到高 + 业务价值"补测试。纯 Dart 逻辑（mapper/entity/usecase）用 `test()`，widget/页面用 `testWidgets()`，已有 `Mock*Repository` 与 `test/helpers/test_helpers.dart` 惯例。

**Tech Stack:** Flutter 3.44.0 / Dart 3.12.0、Riverpod（Notifier + AsyncNotifier）、drift（core/database）、generated lucent_api client。

---

## 现状基线（2026-08-01 实测）

- 测试总数：**2672**（2658 通过 + **14 失败**），`flutter test` 退出码 1 → **CI 红态**。
- 总覆盖率：**63.0%**（22867/36279，540 个文件；排除 `.g.dart`/`.freezed.dart`/l10n 生成物后约 69%）。
- CI（`.github/workflows/flutter-ci.yml`）：`flutter test --coverage --reporter=compact`，无覆盖率门槛，失败即红。

### P0-阻断：套件挂起（已修复 ✅）

**根因**：[user_settings_controller_test.dart](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/test/settings/user_settings_controller_test.dart) 的 `buildContainer()` 只 override 了 `lucentClientProvider`，**漏掉 `authSessionProvider`**。被测 provider 的 `build()` 走 `authGuarded()` → `ref.watch(authSessionProvider)` 落到真实实现 → 测试环境无会话 → 永远处于 `isRestoring` → `pendingAuthSessionResolution()` 返回永不完结的 Future → **每个用例挂到超时**。配合 [dart_test.yaml](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/dart_test.yaml) 的 `timeout: 5m`，15 个用例 × 5 分钟 = 单文件拖 75 分钟；`flutter test --coverage` 因此"跑不完"（曾被误判为工具链问题）。

**修复**（已完成）：补上共享 helper 的 session 覆盖：

```dart
import 'package:luminous/core/auth/session_provider.dart';
import '../helpers/test_helpers.dart';
// buildContainer overrides 内新增：
authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
```

验证：`flutter test test/settings/user_settings_controller_test.dart` → 15 用例 <1s 全绿（修复前每个挂 30s+）。

**后续防线**：把 `dart_test.yaml` 的 `timeout: 5m` 收紧到 `90s`（见 Phase 1 Task 0.2），避免未来单个挂起文件再拖垮整套。

### 14 个失败用例清单（P0，CI 红态）

| # | 文件 | 用例 | 错误摘要 | 类别 |
|---|---|---|---|---|
| 1 | `core/design/layout_tokens_test.dart` | desktop scale >=1200 | Expected 28.0, Actual 36.0 | 过期断言 |
| 2 | `record/data/repositories/lucent_repository_test.dart` | topFoods detail vitals 过滤 | Expected empty, 实际含 vitals 条目 | 行为变更未同步 |
| 3 | 同上 | topFoods detail activity 过滤 | Expected empty, 实际含 activity 条目 | 行为变更未同步 |
| 4 | `record/domain/entities/type_mapping_test.dart` | heartRate → null | Actual `DailyRecordKind.vital` | 行为变更未同步 |
| 5 | 同上 | weight → null | Actual `DailyRecordKind.vital` | 行为变更未同步 |
| 6 | `record/type_mapping_test.dart` | 非映射类型 → null | Actual `DailyRecordKind.vital` | 行为变更未同步 |
| 7 | `report/page_test.dart` | 医院导出打开最新下载链接 | 见异常日志，需排查 | 待排查 |
| 8 | `report/widgets/range_picker_dialog_test.dart` | tapping custom 打开日历 | 找不到 `FCalendar` widget | UI 变更未同步 |
| 9 | 同上 | custom 预填日期 | 同上（Multiple exceptions） | UI 变更未同步 |
| 10 | `scripts/tooling_support_test.dart` | openapi 默认路径回退 | fixture 建 `openapi.value`，实现找 `openapi.json` | 测试 fixture 错误 |
| 11 | `settings/help_settings_page_test.dart` | 渲染可用资源 | 找不到文本 "Enabled URL" | 文案变更未同步 |
| 12 | 同上 | 空态 | 找不到文本 "暂无帮助内容" | 文案变更未同步 |
| 13 | `shell/shell_page_test.dart` | 桌面 header 心形脉冲图标 | 找不到 `IconData(U+0E1A0)` | 图标变更未同步 |
| 14 | `today/presentation/widgets/shared/view_models_extended_test.dart` | confirm 徽标图标 | Expected `U+0E241`, Actual `U+0E06C` | 图标变更未同步 |

已确认 #4/#5/#6 为**测试过时**（实现 [type_mapping.dart](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/lib/features/record/domain/entities/type_mapping.dart#L15-L16) 已刻意把 heartRate/weight 统一映射为 `vital`）；#1 同理（layout scale 实现已改）。#10 为测试自身写错扩展名（[tooling_support.dart:129](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/scripts/tooling_support.dart#L129) 硬编码 `openapi.json`）。

### 覆盖率缺口清单（P1/P2）

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

## Phase 0: 收尾 P0 挂起修复

- [ ] **Task 0.1: 提交已完成的挂起修复**

```bash
git add test/settings/user_settings_controller_test.dart docs/03-logs/migration-log/2026-08-01.md
git commit -m "test(settings): user_settings 测试补 authSessionProvider 覆盖修复套件挂起"
```

（提交前先按 AGENTS.md 追加 `docs/03-logs/migration-log/2026-08-01.md` 迁移日志条目，说明根因与修复。）

- [ ] **Task 0.2: 收紧 dart_test.yaml 超时**

将 [dart_test.yaml](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/dart_test.yaml) 的 `timeout: 5m` 改为 `timeout: 90s`，防止未来单个挂起测试再拖垮整套（单文件 15 用例最坏从 75 分钟降到 22 分钟，且更早暴露）。

```yaml
concurrency: 4
timeout: 90s
```

验证：`flutter test test/settings/user_settings_controller_test.dart` 仍 <1s 通过。

```bash
git add dart_test.yaml
git commit -m "chore(test): 收紧测试超时到 90s 防止挂起拖垮套件"
```

---

## Phase 1: 修复 14 个 CI 失败（P0，目标：`flutter test` 全绿）

> 原则：以当前实现/设计为准更新过期断言（先人工确认实现行为是刻意的，而非回归）；#7/#8/#9 需先定位根因再修。

### Task 1.1: 设计 token 过期断言（#1）

- [ ] 读 `test/core/design/layout_tokens_test.dart` 中 desktop scale 用例与 `lib/core/design/layout_scale.dart` 的 `resolve` 常量，将期望值从 `28.0` 更新为实现的当前桌面缩放值（`36.0`），保留断言语义（桌面 >=1200 使用桌面缩放）。
- [ ] 验证：`flutter test test/core/design/layout_tokens_test.dart`
- [ ] Commit：`test(design): 同步桌面缩放期望值与实现`

### Task 1.2: record 类型映射过期断言（#4/#5/#6）

- [ ] 读 [type_mapping.dart](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/lib/features/record/domain/entities/type_mapping.dart) 确认 heartRate/weight → `vital` 是刻意设计（已确认），将 `test/record/domain/entities/type_mapping_test.dart` 与 `test/record/type_mapping_test.dart` 中"heartRate/weight/非映射类型 → null"的断言改为：
  - heartRate → `DailyRecordKind.vital`、weight → `DailyRecordKind.vital`；
  - 仅保留真正不可映射的枚举值（如 medication 已映射，需从 switch 中找唯一返回 null 的分支）作为 null 断言。
- [ ] 验证：`flutter test test/record/domain/entities/type_mapping_test.dart test/record/type_mapping_test.dart`
- [ ] Commit：`test(record): 同步 dailyRecordKindForEntryType vital 映射断言`

### Task 1.3: record repository 过滤行为（#2/#3）

- [ ] 读 `test/record/data/repositories/lucent_repository_test.dart` 中 topFoods detail 用例与 `lib/features/record/data/repositories/lucent.dart` 的 `_isActiveRecordEntryType`，确认 vitals/activity 现在被纳入是刻意变更后，把"应被过滤"断言改为"应包含"，并补对应 `dailyRecordKind` 期望。
- [ ] 验证：`flutter test test/record/data/repositories/lucent_repository_test.dart`
- [ ] Commit：`test(record): 同步 topFoods detail 纳入 vitals/activity 的断言`

### Task 1.4: 图标/文案过期断言（#13/#14/#11/#12）

- [ ] **#13** `test/shell/shell_page_test.dart:245`：心形脉冲图标期望改为当前实现使用的图标（先用 `flutter test` 失败信息里的 Actual，或读 `lib/features/shell/presentation/desktop_tab_shell.dart`/header 组件确认）。
- [ ] **#14** `test/today/presentation/widgets/shared/view_models_extended_test.dart`：confirm 徽标图标 `U+0E241` → `U+0E06C`，以当前实现为准。
- [ ] **#11/#12** `test/settings/help_settings_page_test.dart`：读 `lib/features/support/` 的资源模型与 `lib/features/settings/presentation/pages/help.dart` 的可见文案（"Enabled URL"、"暂无帮助内容"可能已换 l10n key），按当前渲染文案更新断言；若文案有 l10n 变更，遵循 AGENTS.md 的 ARB fragment 流程。
- [ ] 验证：`flutter test test/shell/shell_page_test.dart test/today/presentation/widgets/shared/view_models_extended_test.dart test/settings/help_settings_page_test.dart`
- [ ] Commit：`test(ui): 同步图标与帮助页文案断言`

### Task 1.5: tooling_support fixture 错误（#10）

- [ ] 将 `test/scripts/tooling_support_test.dart` 中 fallback 用例的 fixture 文件从 `openapi.value` 改为 `openapi.json`（实现 [tooling_support.dart:129](file:///d:/25080/Documents/VSCodeProject/Lumos/Luminous/scripts/tooling_support.dart#L129) 硬编码 `openapi.json`），并修正用例描述文本。
- [ ] 验证：`flutter test test/scripts/tooling_support_test.dart`
- [ ] Commit：`test(scripts): 修正 openapi fixture 扩展名为 openapi.json`

### Task 1.6: 排查并修复 #7/#8/#9

- [ ] **#8/#9** `test/report/widgets/range_picker_dialog_test.dart`：失败为点击 custom 后找不到 `FCalendar`。先单跑 `flutter test test/report/widgets/range_picker_dialog_test.dart --reporter=expanded` 看完整异常；确认是自定义日历组件替换了 `FCalendar`（读 `lib/features/report/presentation/widgets/dialogs/range_picker_dialog.dart`），将 finder 换成实际渲染的日历组件，或更新交互步骤。
- [ ] **#7** `test/report/page_test.dart` 医院导出用例：单跑看异常栈（可能是 `pdf_download.dart` 的 URL 拼接或 mock 注入变化），按当前导出流程更新。
- [ ] 验证：`flutter test test/report/widgets/range_picker_dialog_test.dart test/report/page_test.dart`
- [ ] Commit：`test(report): 修复 range-picker 与医院导出用例`

### Task 1.7: 全量验证 Phase 1

- [ ] `flutter test --timeout=90s` 全绿（`All tests passed!`），记录通过数（基线 2672+）。

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
  - 复用 `ProviderContainer` + 依赖 override 模式（参考 Phase 0 修复的 session override 惯例），覆盖：开始同步状态机（idle→running→done/error）、权限拒绝、自动同步开关、手动触发。
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

- 追加 `docs/03-logs/migration-log/2026-08-01.md`：记录挂起根因与修复、14 个失败修复、覆盖率变化（63.0% → X%）。
- 若有 l10n 文案断言改动 → 遵循 ARB fragment 流程并同步 `docs/02-reference/Localization.md`。
- 运行 `dart run scripts/check_doc_coverage.dart --warning-only` 确认文档规则。
- 删除 `docs/00-current/TODO.md` 中已完成的相关行（如有）。

- [ ] **Task 8.3: 计划收尾**

按 AGENTS.md 规则，执行完毕的计划段直接删除；整个计划完成后删除本文件，将覆盖率基线与 CI 修复结论落到 `docs/00-current/Current_State.md`。

---

## 完成标准

1. `flutter test` 全绿（14 个失败清零，含挂起问题不再复发）。
2. `dart_test.yaml` 超时收紧到 90s。
3. 整体行覆盖率 ≥70%（基线 63.0%）。
4. health_data 模块 ≥70%；medicine risk_check、report clinic_summary ≥70%；scan ≥60%。
5. `flutter analyze` 无新增告警。
6. 迁移日志已追加；计划段执行完毕即删除。

## 风险与回退

| 风险 | 可能性 | 影响 | 缓解 |
|---|---|---|---|
| 过期断言更新时误改实现而非测试 | 中 | 低 | 每个断言先对照实现意图（本计划已确认 #1/#4/#5/#6 是测试过时）；不确定时用 git log 确认变更意图 |
| health_data 平台数据源难 mock | 高 | 中 | 优先测 mapper/repository/provider 纯逻辑；平台桥接文件按排除项注明 |
| scan 相机插件在 widget 测试中不可用 | 中 | 中 | 走抽象层 mock（现有 `scan_test.dart` 惯例），不启动真实相机 |
| 修复 #7/#8/#9 时发现是真实回归而非测试问题 | 低 | 高 | 若是回归：修实现并补回归测试，提交信息注明 |
| 覆盖率仍不足 70%（生成物占比大） | 中 | 低 | 排除项已声明；若接近阈值可放宽目标到 68% 并记录基线 |
