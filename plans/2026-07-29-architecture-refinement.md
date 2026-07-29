# Luminous 架构精炼计划

> 创建于 2026-07-29。本计划记录对 Luminous 前端架构的全面审计结果和增量重构方案。
> 完成后删除本文件，将稳定决策更新到 `docs/02-reference/architecture.md`。

---

## 1. 现状诊断

### 1.1 数据概览

| 指标 | 数值 |
|------|------|
| 非生成 Dart 文件总数 | 354 |
| >200 行文件 | 113 (32%) |
| >300 行文件 | ~45 (13%) |
| >500 行文件 | 16 (4.5%) |
| feature 总数 | 15 |
| 最大 feature (record) | 63 文件 |
| 最大单文件 (record/page.dart) | 1226 行 |

### 1.2 架构底子评估

现有架构已做对的事情：

1. **Feature-first 垂直切片** — 15 个 feature 各自拥有 `data/domain/presentation` 三层
2. **依赖反转已部分落地** — domain 层定义 `abstract interface class XxxRepository`，data 层实现，通过 Riverpod provider 注入
3. **DataChangeBus 解耦跨 feature 写路径** — `today` 通过 `dataChangeVersionProvider` 监听 6 个 topic，避免直接 `ref.invalidate()` 其他 feature
4. **healthContextSnapshotProvider 共享只读 hub** — 多 feature 统一读取健康档案，避免重复 fetch
5. **authGuarded 工厂** — 统一处理 auth/session/fallback 三态
6. **core/ 横切基础设施成熟** — network、database、design、feedback、logger 各司其职

### 1.3 核心问题

#### 问题 A：Presentation 层膨胀（最高优先级）

16 个文件超过 500 行，其中绝大多数是 presentation 层的 page/widget 文件。页面
承担了过多本应由 application 层处理的业务编排逻辑。

**膨胀最严重的文件**：

| 文件 | 行数 | 根因 |
|------|------|------|
| `record/presentation/pages/page.dart` | 1226 | 页面内嵌 6 种快速入口流程编排（meal/sleep/medication/mood/water/symptom）、NLP 处理、日期管理、拖拽逻辑、undo 栈 |
| `settings/presentation/pages/page.dart` | 832 | 所有设置分组（账号安全、通用、快捷入口、隐私、关于、登出）内联在同一文件 |
| `medicine/presentation/widgets/risk/check_tab_content.dart` | 766 | 3 个 risk tab 的内容挤在一个 widget |
| `record/presentation/pages/edit.dart` | 709 | 表单所有 section 内联 |
| `record/presentation/widgets/sections/timeline.dart` | 695 | timeline item + drag logic + filter header 全在一个文件 |
| `record/presentation/pages/detail.dart` | 634 | 详情页 + edit/delete 编排 |
| `auth/presentation/pages/account_settings.dart` + `_sections.dart` | 592 + 581 | 两个文件共同承载所有账号设置 |
| `medicine/presentation/pages/reminder/reminder_edit.dart` | 567 | reminder 表单 + 药品选择 + 时间选择 |
| `assistant/presentation/pages/page.dart` | 556 | 聊天 UI + 输入 + 消息列表 |
| `assistant/presentation/providers/conversation.dart` | 544 | 单 Notifier 管理 8 种状态 + 全部业务逻辑 |

**根因分析**：缺少 application 层。页面直接调用 repository + 编排多个 provider，
编排逻辑无处安放，全部上浮到 `StatefulWidget` 的方法中。

#### 问题 B：跨 Feature 直接耦合

跨 feature import 统计（排除 shared/required_dialog 等共享 widget 后的真正
数据/逻辑耦合）：

**Tier 1：重度耦合（需重构）**

| 消费方 | 被依赖 feature | 依赖层 | 问题 |
|--------|---------------|--------|------|
| `today/data/providers/today_suggestion.dart` | record, medicine, health_context, settings | data + data + data + data | provider 组装层直接 import 4 个其他 feature 的 data provider 和 data source |
| `today/data/repositories/lucent.dart` | record, medicine, health_context, settings | domain + data + data + domain | repository 实现依赖其他 feature 的 data source 具体类型（`CachedDoseLogDataSource`）而非抽象接口 |
| `record/presentation/pages/page.dart` | auth, health_context, medicine, shell | presentation + data + presentation + presentation | 页面直接读 medicine 的 datasource 和 health_context 的 provider |
| `report/presentation/pages/page.dart` | auth, settings, today, shell | presentation×4 + domain×1 | 页面直接 import today 的 entity 和 provider |
| `assistant/presentation/providers/conversation.dart` | auth, record, settings | presentation + data + domain + domain + presentation | Notifier 直接调用 record 的 repository provider + record 的 entity + settings 的 provider |

**Tier 2：中度耦合（可接受但需监控）**

`mine` feature 的多个编辑页面（`profile_edit`, `condition_edit`, `allergy_edit`,
`current_medicine_edit`）统一依赖 `health_context/data/providers/health_context.dart`
和 `health_context/domain/entities/*`。这是 `healthContextSnapshotProvider` 作为
共享 hub 的设计意图，属于可接受耦合。但 `mine` 编辑页面还直接 import
`auth/presentation/providers/session.dart` 和 `auth/presentation/widgets/shared/required_dialog.dart`，
形成 mine → auth presentation 的依赖。

**Tier 3：轻度耦合（正常）**

几乎所有 feature 都 import `auth/presentation/providers/session.dart`（读取
登录状态）和 `auth/presentation/widgets/shared/required_dialog.dart`（登录
引导弹窗）。这两个文件实际上扮演了 cross-cutting concern 的角色，但放在
`auth` feature 内部导致所有 feature 都依赖 auth 的 presentation 层。

#### 问题 C：Domain 层过薄

| Feature | Domain 文件数 | 问题 |
|---------|-------------|------|
| record | 8 (但 services/ 为空) | 有 domain 目录但 `services/` 空目录，业务逻辑全部在 repository 实现或 page 中 |
| assistant | 2 | 只有 entity + repo 接口，544 行编排逻辑在 Notifier |
| mine | 2 | 只有 entity + repo 接口 |
| search | 2 | 只有 entity + repo 接口 |
| notification | 2 | 只有 entity + repo 接口 |
| support | 2 | 只有 entity + repo 接口 |

`record/domain/services/` 目录存在但为空——这是之前架构整理时预留的，但从未填充。

#### 问题 D：跨 Feature 依赖方向违反

现有规则是 "feature 不得 import 其他 feature 的 presentation provider"。但实际：

- `today/data/providers/today_suggestion.dart` import 了 `record/data/providers/record_access.dart`
  和 `medicine/data/providers/workspace.dart` — data→data 跨 feature 依赖
- `record/presentation/pages/page.dart` import 了 `medicine/presentation/providers/reminders.dart`
  — presentation→presentation 跨 feature 依赖
- `report/presentation/pages/page.dart` import 了 `today/presentation/providers/suggestion.dart`
  和 `today/domain/entities/suggestion.dart` — presentation→presentation + presentation→domain

---

## 2. 方案选择：为什么不是 DDD / Clean Architecture / 六边形

### 2.1 不选择全套 DDD

- DDD 战术模式（聚合根、值对象、领域事件、CQRS）对 Flutter 客户端来说仪式代码过多
- 后端 Lucent 更适合 DDD（有复杂业务规则、多实体聚合），客户端主要是 UI 编排 + API 调用
- DDD 的战略设计（限界上下文、通用语言）已有参考价值，但无需正式引入

### 2.2 不选择教科书式 Clean Architecture

- Uncle Bob 同心圆模型会导致每个操作一个 UseCase 类的过度抽象
- 对个人健康记录 app，UseCase 粒度太细（一个 page 可能需要 5-8 个 UseCase）
- 但 Clean Architecture 的依赖方向原则（外层依赖内层，内层不知道外层）值得借鉴

### 2.3 不选择六边形架构单独引入

- 项目已在做端口与适配器：domain 接口 = port，data 实现 = adapter
- 单独"迁移到六边形"不会解决文件膨胀和跨 feature 耦合

### 2.4 选择：Pragmatic Feature-Sliced Refinement

在现有 feature-first + 三层结构上做**增量改进**，不推倒重来。核心动作：

1. **加一层** application — 把页面里的业务编排逻辑抽出来
2. **提两类共享** — 把被广泛依赖的 cross-cutting concern 从 feature 提升到 core
3. **立三条边界** — 定义跨 feature 通信契约，禁止违反方向的 import

---

## 3. 重构方案

### 3.1 新增 Application 层

#### 目录结构

```
lib/features/<feature>/
├── application/              ← 新增层
│   ├── usecases/             ← 单一业务编排（创建记录、快速入口、导出报告…）
│   │   ├── create_record.dart
│   │   ├── quick_entry.dart
│   │   └── ...
│   └── orchestrators/        ← 多步骤流程编排（NLP 流程、AI 分析流程…）
│       └── nlp_flow.dart
├── data/                     ← 不变
├── domain/                   ← 不变（补 services/ 如有需要）
└── presentation/             ← 瘦身后只负责 build + 路由 + 触发 use case
```

#### Application 层的职责

| 放入 application | 留在 presentation | 放入 domain/services |
|---|---|---|
| 多 repository 编排 | widget build 方法 | 纯领域计算（药品冲突检测算法） |
| 跨 provider 状态协调 | 路由参数解析 | 实体推导规则（BMI 计算） |
| 快速入口流程编排 | UI 反馈触发（Toast） | |
| 导出/分享流程 | ephemeral UI state | |
| NLP 候选词处理流程 | | |

#### Application 层的形式

**不是每个操作一个 UseCase 类**（避免过度抽象）。采用两种形式：

**形式 1：函数式 UseCase（简单编排）**

```dart
// application/usecases/change_record_date.dart
Future<Result<void>> changeRecordDate({
  required Ref ref,
  required BuildContext context,
  required String recordId,
  required DateTime newDate,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final dateStr = formatRecordDate(newDate);
  try {
    await ref.read(dailyRecordRepositoryProvider)
        .update(recordId, DailyRecordUpdateInput(occurredAt: dateStr));
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
    ref.read(selectedRecordDateProvider.notifier).setDate(newDate);
    if (!context.mounted) return const Success(null);
    await Toast.show(context, l10n.recordDragDateChanged);
    return const Success(null);
  } catch (e) {
    if (!context.mounted) return Failure(AppError.unknown(e));
    await Toast.show(context, l10n.recordDragDateError);
    return Failure(AppError.unknown(e));
  }
}
```

**形式 2：Orchestrator 类（多步骤流程）**

```dart
// application/orchestrators/quick_entry_flow.dart
class QuickEntryFlow {
  QuickEntryFlow({
    required this.repository,
    required this.emitDataChange,
    required this.preferences,
  });

  final DailyRecordRepository repository;
  final void Function(DataChangeTopic) emitDataChange;
  final QuickEntryPreferences preferences;

  Future<QuickEntryResult> execute(QuickEntryContext context) async {
    // 编排逻辑：判断类型 → 构建输入 → 调用 repo → emit change → 返回结果
  }
}
```

#### 页面瘦身目标

| 文件 | 当前行数 | 目标行数 | 抽出内容 |
|------|---------|---------|---------|
| `record/presentation/pages/page.dart` | 1226 | ~350 | 6 个 quick action handler → `application/usecases/quick_entry_*.dart`；`_changeRecordDate` → `application/usecases/change_record_date.dart`；`_openNlpSheet` + NLP 处理 → `application/orchestrators/nlp_flow.dart`；header actions → `presentation/widgets/header_actions.dart` |
| `settings/presentation/pages/page.dart` | 832 | ~200 | `_AccountHeader`, `_GeneralSection`, `_QuickEntrySection`, `_PrivacySection`, `_AboutSection`, `_SignOutTile` → 各自独立 widget 文件 |
| `medicine/presentation/widgets/risk/check_tab_content.dart` | 766 | ~250 | 按 tab 拆为 `overview_tab.dart`, `findings_tab.dart`, `coverage_tab.dart`（去掉 `risk_` 前缀，目录名 `risk/` 已表明归属） |
| `record/presentation/pages/edit.dart` | 709 | ~300 | form sections → `presentation/widgets/forms/` 下独立文件 |
| `record/presentation/widgets/sections/timeline.dart` | 695 | ~300 | timeline item → `timeline_item.dart`；drag handler → `timeline_drag_handler.dart` |
| `record/presentation/pages/detail.dart` | 634 | ~300 | edit/delete 编排 → `application/usecases/record_detail_actions.dart` |
| `auth/presentation/pages/account_settings.dart` | 592 | ~300 | sections 已部分拆分，继续拆出剩余内联 section |
| `medicine/presentation/pages/reminder/reminder_edit.dart` | 567 | ~300 | 药品选择 → `presentation/widgets/reminder/medicine_selector.dart`；时间选择 → `time_selector.dart` |
| `assistant/presentation/pages/page.dart` | 556 | ~300 | 消息列表 → `presentation/widgets/message_list.dart`；输入区 → `input_bar.dart` |
| `assistant/presentation/providers/conversation.dart` | 544 | ~300 | bootstrap + send 逻辑 → `application/orchestrators/conversation_flow.dart` |

### 3.2 提升 Cross-Cutting Concern 到 core/

以下文件被 5+ 个 feature 依赖，但放在单个 feature 内部，导致不自然的跨 feature import：

#### 3.2.1 `auth/presentation/providers/session.dart` → `core/auth/`

被 14 个 feature import。`AuthSessionState`、`authSessionProvider` 是全局 session 状态，
不是 auth feature 的私有逻辑。

**迁移目标**：

```
lib/core/auth/
├── session_state.dart     ← AuthSessionState + extensions
├── session_provider.dart  ← authSessionProvider + AuthSessionNotifier
└── auth_guarded.dart      ← 已在 core/providers/，保持不变
```

`auth` feature 保留登录/注册/OAuth 流程的 presentation 层，但 session 状态提升到 core。

#### 3.2.2 `auth/presentation/widgets/shared/required_dialog.dart` → `core/widgets/auth/`

被 12+ 个 feature import。`showAuthRequiredDialog`、`pushAuthRequiredRoute` 是
cross-cutting UI concern。

**迁移目标**：

```
lib/core/widgets/auth/
└── required_dialog.dart   ← showAuthRequiredDialog + pushAuthRequiredRoute
```

#### 3.2.3 `notification/data/providers/unread_count.dart` 保持现状

已有注释说明放在 data 层是有意为之（避免其他 feature import notification/presentation/）。
这是正确的设计，不需要迁移。

#### 3.2.4 `health_context` 的共享 hub 保持现状

`healthContextSnapshotProvider` 已作为共享只读 hub 设计，`health_context` 本质
上是一个 "shared domain" feature。保持现状。

### 3.3 建立跨 Feature 通信契约

#### 3.3.1 三条边界规则

**规则 1：data 层不得 import 其他 feature 的 data 层**

```
❌ today/data/repositories/lucent.dart
     import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';

✅ today/data/repositories/lucent.dart
     import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';
     // 通过 domain 接口依赖，具体实现在 provider 组装层注入
```

**规则 2：presentation 层不得 import 其他 feature 的 presentation provider**

```
❌ report/presentation/pages/page.dart
     import 'package:luminous/features/today/presentation/providers/suggestion.dart';

✅ report/presentation/pages/page.dart
     import 'package:luminous/features/today/domain/entities/suggestion.dart';
     // 通过 application 层 use case 或 core provider 获取数据
```

**规则 3：application 层可以 import 其他 feature 的 domain 层（接口+实体）**

这是 application 层的特权——它负责跨 feature 编排，但只能通过 domain 接口，
不能触碰其他 feature 的 data/presentation 实现。

#### 3.3.2 跨 Feature 数据获取模式

**模式 A：通过 DataChangeBus（写路径通知）**

已有，保持不变。

**模式 B：通过共享 Provider Hub（读路径）**

已有 `healthContextSnapshotProvider`。对 `today` 的 suggestion 历史被 `report`
消费的情况，考虑将 `suggestionHistoryProvider` 的接口定义提升到
`today/domain/repositories/` 中，`report` 通过 domain 接口 + provider override
获取，而非直接 import `today/presentation/providers/suggestion.dart`。

**模式 C：通过 Application UseCase（编排路径）**

当一个 feature 需要调用另一个 feature 的操作时，通过 application 层封装：

```dart
// report/application/usecases/export_report.dart
// 可以 import today/domain/entities/suggestion.dart
// 可以 import today/domain/repositories/suggestion.dart
// 不可以 import today/presentation/providers/suggestion.dart
```

#### 3.3.3 Provider 组装层隔离

`today/data/providers/today_suggestion.dart` 的问题是在 provider 组装时直接
import 了 4 个 feature 的 data provider。改为：

```dart
// today/data/providers/today_suggestion.dart — 重构后
@riverpod
TodayRepository todayRepository(Ref ref) {
  return LucentTodayRepository(
    // 通过 domain 接口注入，不直接依赖其他 feature 的 data 层
    fetchHealthContextSnapshot: () =>
        ref.read(healthContextSnapshotProvider.future),
    dailyRecordRepository: ref.watch(dailyRecordRepositoryProvider),
    doseLogRepository: ref.watch(doseLogRepositoryProvider),       // ← 新 domain 接口
    userSettingsRepository: ref.watch(userSettingsRepositoryProvider),
    medicineReminderRepository: ref.watch(medicineReminderRepositoryProvider), // ← 新 domain 接口
    talker: ref.watch(talkerProvider),
  );
}
```

需要新增的 domain 接口：
- `medicine/domain/repositories/dose_log.dart` — `DoseLogRepository`（目前只有 `CachedDoseLogDataSource`）
- `medicine/domain/repositories/reminder.dart` — `ReminderRepository`（目前只有 `MedicineReminderRemoteDataSource`）

### 3.5 文件命名规范化

对全库 `lib/features/`、`lib/core/` 做 AGENTS.md 命名规则审计，发现 24 处源文件违规
（R1 类型后缀 ×4、R3 目录名前缀 ×19、R4 `app_` 前缀 ×1）。`.g.dart` 生成文件
自动跟随源文件重命名，无需手动处理。

> **说明**：`presentation/pages/page.dart` 是 AGENTS.md Rule 3 示例明确认可的命名
> （`medicine_page.dart` → `page.dart`），不视为违规，不在本节范围内。

#### R1：类型后缀（4 处，`core/`）

`_controller` 后缀在目录上下文已明确时是冗余的：

| 当前文件 | 重命名 | 规则 |
|---------|--------|------|
| `core/accessibility/settings_controller.dart` | `settings.dart` | R1 |
| `core/config/developer_settings_controller.dart` | `developer_settings.dart` | R1 |
| `core/config/feature_flags_controller.dart` | `feature_flags.dart` | R1 |
| `core/i18n/locale_controller.dart` | `locale.dart` | R1 |

#### R3：目录名前缀（19 处）

**Feature 层（11 处）**

| 当前文件 | 重命名 | 目录 |
|---------|--------|------|
| `medicine/presentation/pages/reminder/reminder_detail.dart` | `detail.dart` | `reminder/` |
| `medicine/presentation/pages/reminder/reminder_edit.dart` | `edit.dart` | `reminder/` |
| `medicine/presentation/widgets/risk/risk_check_loading.dart` | `check_loading.dart` | `risk/` |
| `medicine/presentation/widgets/risk/risk_coverage_issue_tile.dart` | `coverage_issue_tile.dart` | `risk/` |
| `medicine/presentation/widgets/risk/risk_finding_tile.dart` | `finding_tile.dart` | `risk/` |
| `medicine/presentation/widgets/risk/risk_metric_chip.dart` | `metric_chip.dart` | `risk/` |
| `medicine/presentation/widgets/risk/risk_red_flag.dart` | `red_flag.dart` | `risk/` |
| `medicine/presentation/widgets/risk/risk_score_ring.dart` | `score_ring.dart` | `risk/` |
| `record/presentation/widgets/nlp/nlp_candidate_editor.dart` | `candidate_editor.dart` | `nlp/` |
| `record/presentation/widgets/nlp/nlp_candidate_review.dart` | `candidate_review.dart` | `nlp/` |
| `record/presentation/widgets/nlp/nlp_retry_panel.dart` | `retry_panel.dart` | `nlp/` |

**Core 层（8 处源文件 + 4 个 `.g.dart` 自动跟随）**

| 当前文件 | 重命名 | 目录 |
|---------|--------|------|
| `core/ai/ai_runtime_config.dart` | `runtime_config.dart` | `ai/` |
| `core/ai/ai_runtime_providers.dart` | `runtime_providers.dart` | `ai/` |
| `core/database/database_connection.dart` | `connection.dart` | `database/` |
| `core/database/database_connection_io.dart` | `connection_io.dart` | `database/` |
| `core/database/database_connection_web.dart` | `connection_web.dart` | `database/` |
| `core/database/database_providers.dart` | `connection_providers.dart` | `database/` |
| `core/database/sync/sync_worker.dart` | `worker.dart` | `sync/` |
| `core/network/network_providers.dart` | `client_providers.dart` | `network/` |

> 对应的 `.g.dart`（`ai_runtime_providers.g.dart`、`database_providers.g.dart`、
> `sync_worker.g.dart`、`network_providers.g.dart`）在 `build_runner` 后自动重命名。

#### R4：`app_` 前缀（1 处）

| 当前文件 | 重命名 | 规则 |
|---------|--------|------|
| `core/shortcuts/app_shortcuts.dart` | `shortcuts.dart` | R4 |

**注意**：所有重命名仅改文件名，类名不变（Rule 6）。测试文件（`_test.dart`）
跟随源文件同步重命名（Rule 7）。`import` 路径需全局搜索替换。

**与现有计划的协同**：
- `reminder_detail.dart` 和 `reminder_edit.dart` 的内容重构已在 Phase 4 P2 规划，
  文件重命名应在内容重构时一并完成
- `risk/` 目录下 7 个文件的重命名与 Phase 4 P1 的 `check_tab_content.dart` 拆分
  可同步进行
- `nlp/` 目录下 3 个文件的重命名与 Phase 2 的 record 重构可同步进行

### 3.6 Feature 分层一致性补齐

补齐以下 feature 的 domain 层：

| Feature | 现状 | 动作 |
|---------|------|------|
| `settings` | 无 domain services | 保持现状（settings 无复杂业务逻辑，domain 层只需 entity + repo 接口） |
| `notification` | domain 仅 1 entity + 1 repo 接口 | 保持现状（功能简单） |
| `scan` | data 层文件在根目录 | 保持现状（功能简单） |
| `support` | 仅 data + domain | 保持现状（纯数据提供者） |
| `record/domain/services/` | 空目录 | 填充 `record_date_calculator.dart` 等纯领域逻辑，或删除空目录 |

---

## 4. 执行计划

### Phase 2：Record Feature 示范重构（中风险，高收益）

**目标**：以 `record` feature 为模板，展示 application 层怎么抽、页面怎么瘦身。

| 步骤 | 文件 | 动作 |
|------|------|------|
| 2.1 | `record/application/` | 创建目录，抽出 `change_record_date.dart`、`quick_entry_meal.dart`、`quick_entry_sleep.dart`、`quick_entry_medication.dart`、`nlp_flow.dart` |
| 2.2 | `record/presentation/pages/page.dart` | 从 1226 行瘦身到 ~350 行：移除所有 `_handle*QuickAction` 方法、`_changeRecordDate`、`_openNlpSheet`、`_showMealConfirmationDialog`、`_showSleepMergeDialog`、`_showSleepStartSelectionDialog` 等 |
| 2.3 | `record/presentation/widgets/header_actions.dart` | 从 page.dart 抽出 header actions 构建 |
| 2.4 | `record/presentation/widgets/sections/timeline.dart` | 拆出 `timeline_item.dart` 和 `timeline_drag_handler.dart` |
| 2.5 | `record/presentation/pages/edit.dart` | 抽出 form sections 到独立 widget 文件 |
| 2.6 | `record/presentation/pages/detail.dart` | 抽出 edit/delete 编排到 `application/usecases/record_detail_actions.dart` |

**验证**：`flutter analyze` + `flutter test test/features/record/` + 手动测试快速入口流程。

### Phase 3：跨 Feature 耦合拆解（中风险）

**目标**：消除 Tier 1 重度耦合。

| 步骤 | 动作 |
|------|------|
| 3.1 | 在 `medicine/domain/repositories/` 新增 `DoseLogRepository` 接口，让 `CachedDoseLogDataSource` 实现它 |
| 3.2 | 在 `medicine/domain/repositories/` 新增 `ReminderRepository` 接口 |
| 3.3 | 重构 `today/data/repositories/lucent.dart` 构造函数，只接收 domain 接口 |
| 3.4 | 重构 `today/data/providers/today_suggestion.dart`，通过 domain 接口注入 |
| 3.5 | 重构 `record/presentation/pages/page.dart`，将 medicine datasource 的直接引用改为通过 application use case |
| 3.6 | 重构 `report/presentation/pages/page.dart`，将 today provider 的直接引用改为通过 domain 接口或 application use case |

**验证**：`flutter analyze` + 全量 `flutter test`。

### Phase 4：其他 Feature 瘦身（低风险，按需执行）

按优先级逐个处理剩余的膨胀文件：

| 优先级 | Feature | 文件 | 动作 |
|--------|---------|------|------|
| P1 | settings | `page.dart` (832行) | 拆分为 6 个 section widget 文件 |
| P1 | medicine | `check_tab_content.dart` (766行) | 按 tab 拆为 3 个文件 |
| P1 | assistant | `conversation.dart` (544行) | 抽出 orchestrator |
| P2 | auth | `account_settings.dart` + `_sections.dart` | 继续拆分内联 section |
| P2 | medicine | `reminder_edit.dart` (567行) | 抽出 selector widget |
| P2 | medicine | `reminder_detail.dart` (499行) | 抽出 log panel |
| P3 | record | `create.dart` (559行) | 与 edit.dart 共享 form components |
| P3 | assistant | `page.dart` (556行) | 抽出 message list + input bar |
| P3 | report | `dashboard_view.dart` (526行) | 拆出 chart section |

### Phase 5：文件命名规范化（低风险，高收益）

**目标**：修复 24 处源文件命名违规，使全库文件名符合 AGENTS.md 规则。

| 步骤 | 范围 | 动作 |
|------|------|------|
| 5.1 | `core/accessibility/`、`core/config/`、`core/i18n/` | 4 个 `_controller` 文件去掉后缀 + 同步 test |
| 5.2 | `core/ai/` | 2 个文件去掉 `ai_` 前缀 + `build_runner` |
| 5.3 | `core/database/` | 4 个文件去掉 `database_` 前缀 + `build_runner` |
| 5.4 | `core/database/sync/` | `sync_worker` → `worker` + `build_runner` |
| 5.5 | `core/network/` | `network_providers` → `client_providers` + `build_runner` |
| 5.6 | `core/shortcuts/` | `app_shortcuts` → `shortcuts` + 同步 test |
| 5.7 | `medicine/presentation/widgets/risk/` | 7 个文件去掉 `risk_` 前缀 + 同步 test |
| 5.8 | `medicine/presentation/pages/reminder/` | 2 个文件去掉 `reminder_` 前缀 + 同步 test |
| 5.9 | `record/presentation/widgets/nlp/` | 3 个文件去掉 `nlp_` 前缀 + 同步 test |
| 5.10 | 全局 | 搜索替换所有 `import` 路径 |

**验证**：`flutter analyze` + `flutter test` + `dart run tool/check_doc_coverage.dart --warning-only`。

### Phase 6：规则固化（低风险）

| 步骤 | 动作 |
|------|------|
| 5.1 | 更新 `AGENTS.md` — 加入 application 层规则、跨 feature import 规则 |
| 5.2 | 更新 `docs/02-reference/architecture.md` — 更新目录结构图、分层说明 |
| 5.3 | 更新 `docs/02-reference/data-layer.md` — 补充 domain 接口注入模式 |
| 5.4 | 更新 `docs/02-reference/state-management.md` — 补充 application 层 provider 模式 |
| 5.5 | 考虑添加 lint rule（自定义 `custom_lint`）检测违规跨 feature import |

---

## 5. 风险与缓解

| 风险 | 概率 | 缓解 |
|------|------|------|
| Phase 2 重构引入 regression | 中 | 每步后运行 `flutter test`，优先补 quick entry 的 widget test |
| Phase 3 接口提取破坏现有 provider 链 | 中 | 保持旧 provider 作为 re-export，逐步迁移消费方 |
| re-export 层长期不清理 | 低 | 在 Phase 5 中添加 TODO 追踪 re-export 清理 |
| 重构期间与功能开发冲突 | 中 | 每个 Phase 独立可交付，可随时暂停 |

---

## 6. 不做的事情

- **不引入 BLoC / GetX / Provider 等新状态管理框架** — Riverpod 够用
- **不为每个操作创建 UseCase 类** — 函数式 use case 优先
- **不引入 CQRS / Event Sourcing** — 客户端不需要
- **不重写 core/ 基础设施** — network/database/design 稳定且成熟
- **不迁移 l10n 工作流** — 与架构无关
- **不碰 generated/ 目录** — 生成代码不在重构范围
- **不引入 Forui 之外的新 UI 框架** — Forui-first 方向不变 [[memory:17849504329474592541]]

---

## 7. 优先级总结

| 优先级 | Phase | 预期工作量 | 收益 |
|--------|-------|-----------|------|
| 🔴 高 | Phase 2: Record 示范 | 1-2 天 | 最大文件 1226→350 行，建立 application 层模板 |
| 🟡 中 | Phase 3: 耦合拆解 | 1 天 | 消除 Tier 1 耦合，domain 接口注入 |
| 🟢 低 | Phase 4: 其他瘦身 | 2-3 天 | 逐个处理膨胀文件，按需执行 |
| 🟡 中 | Phase 5: 命名规范化 | 0.5 天 | 24 处违规修复，全库命名一致 |
| 🟢 低 | Phase 6: 规则固化 | 0.5 天 | 更新文档和 lint 规则 |
