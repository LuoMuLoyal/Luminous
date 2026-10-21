# 前端 DDD 重构计划：Health Logging / Medication / Identity / Preferences

Created: 2026-10-21
状态: 未开工
范围: Luminous 首批 4 个 feature；不改 UI、路由、l10n、公开契约
关系: 与 `docs/reference/architecture.md`、`docs/reference/data-layer.md` 对齐；不改变 features 间现有产品边界
前置: 先落 ADR-0010（前端限界上下文、聚合边界、上下文映射与领域事件），并扩展 `layered_import` 规则。

## 一、为什么先做这四个

判据：feature 规模、`presentation → data` 违规数、`application → presentation` 违规数、领域/安全风险，以及能否覆盖不同的 DDD 形态。

| Feature    | 限界上下文       | 子域类型  | 非生成 Dart 文件 | LOC    | presentation → data | application → presentation | 选择理由                                                     |
| ---------- | ---------------- | --------- | ---------------- | ------ | ------------------- | -------------------------- | ------------------------------------------------------------ |
| `record`   | Health Logging   | core      | 109              | 19,005 | 20                  | 7                          | 最大、违规最多；`DailyRecord` 聚合与稀疏事件语义先立模板      |
| `medicine` | Medication       | core      | 79               | 14,597 | 15                  | 0                          | `Reminder`/`DoseLog` 聚合清楚；存在 `domain → data` 严重违规  |
| `auth`     | Identity & Access | supporting | 59               | 7,837  | 8                   | 0                          | 安全关键；`Session` 聚合与 OAuth 防腐层验证                  |
| `settings` | Preferences      | supporting | 56               | 8,223  | 9                   | 1                          | 混合远程/本地状态；验证 supporting 上下文的薄聚合             |

不在首批：

- `today`、`review`：下游读模型/展示上下文，依赖 Health Logging/Medication 的发布语言；等上游事件契约稳定。
- `assistant`：AI 交互上下文，流式/提案/工具形态独立，放第二批。
- `search`、`scan`：药品目录只读消费方 + 加药命令，等 Medication 的 `add_to_box` 边界定稿。
- `mine`、`health_context`：User Profile/Health Context，作为上游 supporting 上下文，放第二批。

## 二、战略设计：限界上下文与上下文映射

### 2.1 子域划分（客户端视角）

| 子域类型  | 上下文                                                                 | 说明                                                     |
| --------- | ---------------------------------------------------------------------- | -------------------------------------------------------- |
| core      | Health Logging、Medication、Today/Review 读模型                         | 产品差异化；聚合与不变量优先投入                          |
| supporting | Identity & Access、Preferences、Health Context、Search/Scan、Assistant | 支撑核心域；模型可薄，但边界必须清楚                      |
| generic   | Shell/Navigation、Core（network/design/notifications）                 | 不承载业务规则；通过 port/ACL 接入                         |

### 2.2 限界上下文与 feature

| 限界上下文        | 现有 feature        | 首批 | 聚合根（目标）                                      |
| ----------------- | ------------------- | ---- | --------------------------------------------------- |
| Health Logging    | `record`            | 是   | `DailyRecord`、`QuickEntryPreference`                |
| Medication        | `medicine`          | 是   | `Reminder`、`DoseLog`、`RiskCheck`                   |
| Identity & Access | `auth`              | 是   | `Session`                                            |
| Preferences       | `settings`          | 是   | `UserSettings`、`NotificationPreferences`、`LocalPreferences` |
| Health Context    | `health_context`    | 否   | `HealthProfile`、`CurrentMedicine`                   |
| Today/Review      | `today`、`review`   | 否   | 无（读模型）                                         |
| Search/Scan       | `search`、`scan`    | 否   | `AddToBoxCommand`（应用命令，不是聚合）              |
| Assistant         | `assistant`         | 否   | `Conversation`（若客户端持有会话投影）               |

`medicine` 的 `MedicineWorkspace` 不是聚合，是 **读模型**；`today`/`review` 的卡片同样是读模型。读模型可以跨上下文投影，但不承担不变量。

### 2.3 上下文映射

```text
Identity & Access ──UserId / SessionState──▶ 所有上下文
Health Context ──ProfileFact / CurrentMedicine / Unit──▶ Medication / Health Logging / Preferences
Health Logging ──DailyRecordFact / MealFact──▶ Today / Review / Assistant
Medication ──DoseFact / ReminderFact──▶ Today / Record / Search
Preferences ──UserSettings / NotificationPreferences / Locale / Theme──▶ 所有上下文
Search/Scan ──AddMedicineCommand──▶ Health Context
Assistant ──ProposedAction──▶ Health Logging / Preferences（仅经用户确认）
```

| 上游              | 下游                          | 关系模式        | 发布语言 / 契约                                                |
| ----------------- | ----------------------------- | --------------- | -------------------------------------------------------------- |
| Identity & Access | 所有上下文                    | partnership     | `UserId`、`SessionState`；只共享会话快照，不共享 token 存储细节 |
| Health Context    | Medication / Health Logging / Preferences | customer-supplier | `ProfileFact`、`CurrentMedicine`、`Unit`；只读               |
| Health Logging    | Today / Review / Assistant    | customer-supplier | `DailyRecordFact`、`MealFact`；经 domain 事件 + 只读快照        |
| Medication        | Today / Record / Search       | customer-supplier | `DoseFact`、`ReminderFact`；经 domain 事件 + 只读快照           |
| Preferences       | 所有上下文                    | conformist      | `UserSettings`、`NotificationPreferences`、`Locale`、`Theme`    |
| Search/Scan       | Health Context                | customer-supplier | `AddMedicineCommand`；写药箱只经 Health Context 接口            |
| Assistant         | Health Logging / Preferences  | customer-supplier | `ProposedAction`；用户确认后执行，不直接写他上下文              |

上下文映射规则：

- **共享内核只允许标识与值对象**：`UserId`、`LocalDate`、`TimeOfDay`、`Timezone`、`Unit`。放在 `lib/shared/domain/`；不共享实体、聚合、provider 或 API DTO。
- **跨 feature 只经发布语言或领域事件**：禁止 import 其他 feature 的 `data/`、`presentation/providers/`；下游需要即时数据时用只读快照 port。
- **ACL 只放在下游**：`data/mappers/` 把生成客户端 DTO 转成领域实体/值对象；domain 不 import `lucent_api`、Dio、Drift、SharedPreferences。
- **客户端不复制后端聚合**：`Medicine` 目录、`Account` 详情是只读投影；客户端只对本地可写边界（记录、提醒、剂量、会话、偏好）建模聚合。
- **UI 不是领域**：页面/弹窗/导航是 presentation；应用服务不依赖 `BuildContext`、GoRouter、Toast。

### 2.4 统一语言

| 术语                    | 含义                                                       | 归属              |
| ----------------------- | ---------------------------------------------------------- | ----------------- |
| DailyRecord             | 某用户某本地日的一条稀疏记录聚合                            | Health Logging    |
| RecordEntry             | DailyRecord 内的一次事件条目（餐食/睡眠/症状/饮水等）       | Health Logging    |
| QuickEntryPreference    | 快速录入的本地排序/可见性偏好                               | Health Logging    |
| Reminder                | 某药品的服药提醒计划（时刻、星期、开关、声音）              | Medication        |
| DoseLog                 | 某次提醒槽位的服药/跳过事实                                 | Medication        |
| RiskCheck               | 一次用药风险检查及其发现                                    | Medication        |
| Session                 | 客户端持有的登录会话与 token 生命周期                       | Identity & Access |
| UserSettings            | 远程用户设置（语言/时区/单位等）                            | Preferences       |
| NotificationPreferences | 通知/DND/睡眠提醒偏好                                       | Preferences       |
| LocalPreferences        | 仅本地的主题/存储/实验偏好                                  | Preferences       |

## 三、战术设计：聚合、不变量、事件、仓储

### 3.1 聚合设计规则

- 一个事务只改一个聚合；跨聚合一致性用领域事件与幂等重放。
- 聚合之间只持 ID；聚合内部才允许实体/值对象引用。
- 聚合根是唯一入口；外部不能直接改内部条目。
- 不变量放聚合根方法；应用服务只编排，不写业务判断。
- 聚合尽量小；列表/看板/详情/工作台全部走读模型，不把展示字段塞进聚合。
- 复杂创建用工厂；跨聚合规则用领域服务；supporting 上下文允许薄聚合。
- 客户端聚合的“事务”是内存状态 + 本地持久化 + 远程提交；失败要保留可回滚的旧状态。

### 3.2 聚合与不变量

| 上下文            | 聚合根                  | 内部实体 / 值对象                                              | 必须保护的不变量                                                                 | 领域事件                                                                 |
| ----------------- | ----------------------- | --------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Health Logging    | `DailyRecord`           | `RecordEntry`、`RecordId`、`LocalDate`、`OccurredAt`、`RecordKind`、`MealAnalysis`、`SleepEntry`、`SymptomEntry`、`WaterIntake` | 每用户每日一条；只存主动记录；medication 永不落 daily record；空餐食拒绝；症状 payload 是真相；睡眠时长/小睡规则；条目类型映射唯一 | `DailyRecordCreated`、`DailyRecordUpdated`、`DailyRecordDeleted`、`MealAnalysisRequested`、`MealAnalysisCompleted` |
| Health Logging    | `QuickEntryPreference`  | `QuickEntryItem`、`QuickEntryOrder`                            | 类型集合稳定；排序无重复；隐藏项可恢复                                            | `QuickEntryPreferenceChanged`                                            |
| Medication        | `Reminder`              | `ReminderSlot`、`ReminderSchedule`、`ReminderId`、`ReminderSound` | 至少一个槽位；星期/时刻合法；同计划槽位不重复；停用后不再排程；通知 ID 稳定派生     | `ReminderCreated`、`ReminderUpdated`、`ReminderDeleted`                  |
| Medication        | `DoseLog`               | `DoseLogId`、`DoseStatus`、`DoseSource`                        | 每个提醒槽位/日期最多一条；take/skip 只对已排程槽位；幂等键防重复；离线可 pending   | `DoseLogged`、`DoseSkipped`                                              |
| Medication        | `RiskCheck`             | `RiskFinding`、`RiskLevel`、`RiskCheckId`                      | 一次运行对应一次结果；静态规则结果确定；完成后不可改写；预检不落库                   | `RiskCheckCompleted`                                                     |
| Identity & Access | `Session`               | `AuthToken`、`AuthUser`、`SessionExpiry`、`SessionId`          | refresh 单飞；网络错误不清会话；远程 logout 失败不登出；恢复有超时地板；停用即失效 | `SignedIn`、`SignedOut`、`SessionRefreshed`、`SessionExpired`            |
| Preferences       | `UserSettings`          | `Locale`、`Timezone`、`UnitSystem`                             | 只 patch 改动字段；失败保留旧值；成功后发变更事件                                   | `UserSettingsChanged`                                                    |
| Preferences       | `NotificationPreferences` | `DndWindow`、`SleepReminder`、`NotificationPermission`       | DND 可跨午夜；通知 ID 基址互斥；本地写失败不阻断 UI；远程 mutation 串行             | `NotificationPreferencesChanged`、`SleepReminderScheduled`               |
| Preferences       | `LocalPreferences`      | `ThemePreference`、`DataStoragePolicy`、`FeatureFlags`         | 本地键稳定；清理缓存不影响账号；实验开关可回退                                     | `LocalPreferencesChanged`                                                |

读模型不是聚合：`MedicineWorkspace`、`MedicineDetail`、`RecordDashboard`、`RecordTimeline`、`RiskCheckView`、`SettingsView` 由查询侧组装，不承担不变量。

### 3.3 领域事件

| 上下文            | 事件                                                                 | 主要消费者 / 用途                                      |
| ----------------- | -------------------------------------------------------------------- | ------------------------------------------------------ |
| Health Logging    | `DailyRecordCreated`、`DailyRecordUpdated`、`DailyRecordDeleted`、`MealAnalysisCompleted` | Today/Review 刷新、DataChangeBus、离线同步             |
| Medication        | `ReminderCreated`、`ReminderUpdated`、`ReminderDeleted`、`DoseLogged`、`DoseSkipped`、`RiskCheckCompleted` | 今日计划、Record 快录、通知重排、跨页刷新              |
| Identity & Access | `SignedIn`、`SignedOut`、`SessionRefreshed`、`SessionExpired`        | 路由守卫、设置页、敏感操作重验                          |
| Preferences       | `UserSettingsChanged`、`NotificationPreferencesChanged`、`SleepReminderScheduled`、`LocalPreferencesChanged` | 全局主题/语言、通知调度、Today/Review 读取              |

事件规则：

- 事件用过去式命名，只带 ID、版本、时间与必要事实；不塞整个聚合。
- 本地事件先落内存/本地队列，再触发 UI 刷新；远程事件由 data 层轮询/推送转成领域事件。
- 事件消费者幂等；离线重放按 `eventId`/幂等键去重。
- 事件不是 provider 的替代品：跨 feature 共享只读状态用快照 port，不用互相 import provider。

### 3.4 仓储与读模型

- 每个聚合根一个 repository，接口放 `domain/repositories/`；实现放 `data/repositories/`。
- repository 方法表达领域语言：`findByDate`、`save`、`findActive`、`nextId`；不暴露 Dio/Drift/SQL/生成 DTO。
- 不为内部实体建 repository；不为读模型建 repository；读模型用 query service / datasource。
- 跨 feature 读取用 `application/ports/` 的 reader/snapshot port；返回发布语言，不返回对方聚合。
- 本地持久化（Drift/SharedPreferences）是实现细节；聚合不 import 插件。

### 3.5 应用服务

- 一个 use case 一个公开方法：加载聚合 → 调用聚合行为 → 保存/提交 → 发布事件。
- 应用服务不写规则；规则在聚合或领域服务。应用服务可以编排多个聚合，但不跨聚合共享事务。
- 领域事件处理器放 `application/handlers/`；只做幂等副作用与后续命令。
- 查询 use case 直接读读模型；不加载聚合，不触发事件。
- `presentation/providers/` 是组合根：装配 use case/repository，持有 UI 状态；页面/组件/controller 不直接 import `data/`。

## 四、代码组织：DDD 为设计，分层为落地

### 4.1 目录骨架

```text
lib/features/<context>/
  domain/
    <aggregate>/
      <aggregate>.dart        # 聚合根
      <entity>.dart           # 聚合内实体
      <value_object>.dart     # 值对象
      events/
        <event>.dart
    repositories/             # repository port（每个聚合根一个）
    services/                 # 跨聚合领域服务
    policies/                 # 无状态规则/策略
  application/
    use_cases/
    handlers/                 # 领域事件处理器
    read_models/
    ports/                    # 远程/本地/通知/日历等出站 port
  data/
    repositories/             # port 实现
    datasources/              # Dio/Drift/SharedPreferences/平台 SDK
    mappers/                  # ACL：生成 DTO ↔ 领域模型
  presentation/
    pages/
    widgets/
    controllers/
    providers/                # 组合根 + UI 状态
    flows/                    # 依赖导航/弹窗的多步 UI 流程
    models/                   # view model
    utils/
```

### 4.2 依赖规则

- `domain/` 只依赖纯 Dart 与 `freezed_annotation`/`meta`；禁止 Flutter、Riverpod、Dio、Drift、GoRouter、`lucent_api`、`BuildContext`。
- `application/` 只依赖 `domain/` 与 `application/ports/`；禁止 Flutter、Riverpod、导航、Toast、Dialog、Dio/Drift 实现。
- `data/` 依赖 `domain/` + `core/network`/`core/database`；实现 repository port；禁止 import `application/`、`presentation/`。
- `presentation/pages|widgets|controllers` 只依赖 `application/` + `domain/` + 本层；禁止 import `data/`。
- `presentation/providers/` 是唯一组合根：可以 import `data/`；只做装配与 UI 状态，不写业务规则。
- `presentation/services/` 逐步取消：纯网络/平台适配器进 `data/datasources/`，依赖导航/弹窗的流程进 `presentation/flows/`。
- 跨 feature 只经对方 `domain/` 发布语言或只读快照；禁止跨 feature import `data/`、`presentation/providers/`。

### 4.3 文件命名

文件名表示职责；目录已表达的类型不再重复。

| 位置                          | 错误示例                          | 正确示例                     | 说明                                      |
| ----------------------------- | --------------------------------- | ---------------------------- | ----------------------------------------- |
| `domain/daily_record/`        | `daily_record_entity.dart`        | `daily_record.dart`          | 目录已表明聚合根                          |
| `domain/daily_record/`        | `record_entry_entity.dart`        | `record_entry.dart`          | 聚合内实体用业务名                        |
| `domain/daily_record/`        | `local_date_vo.dart`              | `local_date.dart`            | 值对象用业务名                            |
| `domain/repositories/`        | `daily_record_repository.dart`    | `daily_record.dart`          | 目录已表明 repository port                |
| `domain/daily_record/events/` | `record-created.event.dart`       | `record_created.dart`        | 目录已表明事件；事件名用过去式            |
| `application/use_cases/`      | `create_record_use_case.dart`     | `create_record.dart`         | 目录已表明 use case                       |
| `application/handlers/`       | `on-record-changed.handler.dart`  | `on_record_changed.dart`     | 目录已表明 handler                        |
| `application/read_models/`    | `record_dashboard_view_data.dart` | `record_dashboard.dart`      | 目录已表明读模型                          |
| `data/repositories/`          | `lucent_daily_record_repository.dart` | `lucent_daily_record.dart` | 目录已表明实现；`lucent` 是实现限定词     |
| `data/datasources/`           | `record_remote_data_source.dart`  | `remote.dart` / `cached.dart`| 目录已表明 data source；限定词表达来源    |
| `data/mappers/`               | `daily_record_mapper.dart`        | `daily_record.dart`          | 目录已表明 ACL/mapper                     |
| `presentation/pages/`         | `record_page.dart`                | `page.dart` / `detail.dart`  | tab 根用 `page.dart`；子页用业务名        |
| `presentation/widgets/`       | `header_actions_widget.dart`      | `header_actions.dart`        | 目录已表明 widget                         |
| `presentation/controllers/`   | `poller_controller.dart`          | `meal_analysis_poller.dart`  | 目录已表明 controller                     |
| `presentation/providers/`     | `dashboard_provider.dart`         | `dashboard.dart`             | 目录已表明 provider                       |

测试文件保留 `_test.dart`；生成文件 `*.g.dart` / `*.freezed.dart` 不参与改名。任一目录超过 10 个直接源文件时按子域再分。

## 五、Feature 目标结构

### 5.1 `record` — Health Logging

```text
lib/features/record/
  domain/
    daily_record/
      daily_record.dart
      record_entry.dart
      record_id.dart
      local_date.dart
      occurred_at.dart
      record_kind.dart
      meal_analysis.dart
      sleep_entry.dart
      symptom_entry.dart
      water_intake.dart
      events/
        record_created.dart
        record_updated.dart
        record_deleted.dart
        meal_analysis_requested.dart
        meal_analysis_completed.dart
    quick_entry/
      quick_entry_preference.dart
      quick_entry_item.dart
      events/
        quick_entry_preference_changed.dart
    repositories/
      daily_record.dart
      quick_entry_preference.dart
    services/
      sleep_entry_policy.dart
      record_kind_mapping.dart
      meal_calorie_range.dart
  application/
    use_cases/
      create_record.dart
      update_record.dart
      delete_record.dart
      change_record_date.dart
      quick_entry.dart
      quick_entry_meal.dart
      quick_entry_medication.dart
      quick_entry_sleep.dart
      quick_entry_undo.dart
      water_quick_entry.dart
      analyze_meal.dart
      confirm_nlp_candidates.dart
    handlers/
      on_daily_record_changed.dart
    read_models/
      record_dashboard.dart
      record_timeline.dart
      record_detail.dart
    ports/
      record_remote.dart
      meal_analyzer.dart
      quick_entry_preferences.dart
  data/
    repositories/
      lucent_daily_record.dart
      local_quick_entry_preference.dart
    datasources/
      remote.dart
      cached.dart
      preferences.dart
    mappers/
      daily_record.dart
      quick_entry_preference.dart
  presentation/
    pages/
      page.dart
      create.dart
      detail.dart
      edit.dart
      quick_entry_reorder.dart
      quick_entry_settings.dart
    widgets/
      detail/
      dialogs/
      forms/
      sections/
      shared/
      views/
    controllers/
      meal_analysis_poller.dart
      nlp.dart
      quick_entry.dart
    providers/
      dashboard.dart
      record_edit.dart
      time.dart
    flows/
      nlp.dart
      meal.dart
      medication.dart
      mood.dart
      symptom.dart
      quick_entry_context.dart
      quick_entry_settings.dart
    models/
      meal_analysis.dart
    utils/
      date_time_formatters.dart
      detail_labels.dart
      meal_analysis_payload_parser.dart
      sleep_formatters.dart
```

重点拆分：

- `presentation/quick_entry/*` 是依赖弹窗/导航的 UI 流程，移到 `presentation/flows/*`；只做数据编排的部分移到 `application/use_cases/*`。
- `application/usecases/*` 现在 import `presentation/providers/dashboard.dart`、`presentation/utils/*`、`core/widgets/*`：导航/Toast/Dialog 移回 `presentation/flows/*`，use case 只保留聚合调用。
- `data/utils/*` 的 JSON codec/mapper 归到 `data/mappers/`，不留在通用 `utils`。
- `data/providers/*` 逐步清空：`record_access`/`symptom_catalog`/`water_target` 迁到 `data/repositories` 或 `presentation/providers` 的组合根。

### 5.2 `medicine` — Medication

```text
lib/features/medicine/
  domain/
    reminder/
      reminder.dart
      reminder_slot.dart
      reminder_schedule.dart
      reminder_id.dart
      reminder_sound.dart
      events/
        reminder_created.dart
        reminder_updated.dart
        reminder_deleted.dart
    dose_log/
      dose_log.dart
      dose_log_id.dart
      dose_status.dart
      events/
        dose_logged.dart
        dose_skipped.dart
    risk_check/
      risk_check.dart
      risk_finding.dart
      risk_level.dart
      events/
        risk_check_completed.dart
    repositories/
      reminder.dart
      dose_log.dart
      risk_check.dart
    services/
      reminder_notification_planner.dart
      reminder_notification_payload.dart
      reminder_calendar_event.dart
  application/
    use_cases/
      load_workspace.dart
      create_reminder.dart
      update_reminder.dart
      delete_reminder.dart
      mark_dose.dart
      skip_dose.dart
      run_risk_check.dart
      run_risk_precheck.dart
    handlers/
      on_reminder_changed.dart
      on_dose_logged.dart
    read_models/
      medicine_workspace.dart
      medicine_detail.dart
      risk_check_view.dart
    ports/
      notification_gateway.dart
      calendar_writer.dart
      clock.dart
  data/
    repositories/
      lucent_reminder.dart
      cached_dose_log.dart
      lucent_risk_check.dart
    datasources/
      dose_log_cached.dart
      dose_log_remote.dart
      medicine_detail_remote.dart
      reminder_local_preferences.dart
      reminder_remote.dart
      risk_check_remote.dart
      safety_tips_remote.dart
      calendar_writer.dart
    mappers/
      medicine_detail.dart
      medicine_sequences.dart
      risk_check.dart
  presentation/
    pages/
      page.dart
      detail.dart
      risk_check.dart
      reminder/
        detail.dart
        edit.dart
    widgets/
      reminder/
      risk/
      sections/
      shared/
      views/
    providers/
      medicine_detail.dart
      reminders.dart
      risk_check.dart
      safety_tips.dart
      workspace.dart
      reminder_delivery.dart
      reminder_notification.dart
    utils/
      reminder_formatters.dart
      safety_tip_style.dart
```

重点拆分：

- `domain/services/reminder_notification_planner.dart` 现在 import `data/`：拆成纯 `reminder_notification_planner.dart`（计划）与 `reminder_notification_payload.dart`（值对象），平台调度走 `application/ports/notification_gateway.dart` + `data/datasources/`。
- `presentation/providers/reminder_notification_coordinator.dart` 只保留组合根；调度逻辑进 `application/use_cases` 或 `application/ports`。
- `presentation/pages/medicine_detail_*.dart` 合并到 `presentation/widgets/detail/`；页面只做组合。
- `data/providers/workspace.dart` 迁到 `presentation/providers/workspace.dart`；`MedicineWorkspace` 是读模型，不是聚合。
- `presentation/services/reminder_calendar.dart` 的纯函数进 `domain/services/reminder_calendar_event.dart`；写日历适配器进 `data/datasources/calendar_writer.dart`。

### 5.3 `auth` — Identity & Access

```text
lib/features/auth/
  domain/
    session/
      session.dart
      session_id.dart
      auth_token.dart
      auth_user.dart
      session_expiry.dart
      events/
        signed_in.dart
        signed_out.dart
        session_refreshed.dart
        session_expired.dart
    oauth/
      oauth_authorization.dart
      oauth_callback.dart
    repositories/
      session.dart
      device_session.dart
    services/
      oauth_callback_parser.dart
      session_restore_policy.dart
  application/
    use_cases/
      login.dart
      register.dart
      login_with_oauth.dart
      link_oauth_identity.dart
      refresh_session.dart
      sign_out.dart
      revoke_device_session.dart
      change_password.dart
      change_email.dart
      forgot_password.dart
      reset_password.dart
      verify_email.dart
    handlers/
      on_session_revoked.dart
    read_models/
      account_summary.dart
      device_session_list.dart
    ports/
      oauth_gateway.dart
      session_store.dart
      avatar_uploader.dart
  data/
    repositories/
      lucent_auth.dart
      lucent_session.dart
      local_session.dart
    datasources/
      auth.dart
      wechat/
        desktop_oauth_callback_listener.dart
        desktop_oauth_callback_listener_io.dart
        desktop_oauth_callback_listener_stub.dart
        desktop_oauth_callback_server.dart
        mobile_auth_client.dart
        mobile_auth_client_base.dart
        mobile_auth_client_fluwx.dart
        mobile_auth_client_stub.dart
        mobile_auth_config.dart
    mappers/
      auth.dart
  presentation/
    pages/
      login.dart
      register.dart
      forgot_password.dart
      change_email.dart
      account_identity.dart
      account_manage.dart
      account_manage_helpers.dart
      account_manage_sections.dart
      account_security.dart
      account_sessions.dart
      security_center.dart
      sessions.dart
    flows/
      oauth_callback.dart
      oauth_handlers.dart
      oauth_navigation.dart
      oauth_uris.dart
    providers/
      account.dart
      session.dart
      sessions.dart
      oauth_apple.dart
      oauth_google.dart
      oauth_qq.dart
      oauth_wechat.dart
      oauth_login.dart
```

重点拆分：

- `core/auth/session_provider.dart` 仍是全 app 会话快照入口；`auth` 拥有 `Session` 聚合，core 只读快照，不复制 token 逻辑。
- `data/providers/*` 迁到 `presentation/providers/*`；data 层只留 repository/datasource/mapper。
- `presentation/services/oauth_webview.dart`、`wechat_oauth.dart` 若纯平台适配，迁 `data/datasources/`；依赖 `BuildContext` 的流程留在 `presentation/flows/`。
- `presentation/pages/oauth_*.dart` → `presentation/flows/oauth_*.dart`；页面只保留登录/注册/账户页。

### 5.4 `settings` — Preferences

```text
lib/features/settings/
  domain/
    user_settings/
      user_settings.dart
      locale.dart
      timezone.dart
      unit_system.dart
      events/
        user_settings_changed.dart
    notification_preferences/
      notification_preferences.dart
      dnd_window.dart
      sleep_reminder.dart
      events/
        notification_preferences_changed.dart
        sleep_reminder_scheduled.dart
    local_preferences/
      local_preferences.dart
      theme_preference.dart
      events/
        local_preferences_changed.dart
    repositories/
      user_settings.dart
      notification_preferences.dart
      local_preferences.dart
    services/
      version_check.dart
      notification_permission_policy.dart
  application/
    use_cases/
      load_settings.dart
      update_settings.dart
      update_notification_preferences.dart
      export_data.dart
      check_version.dart
      request_notification_permission.dart
      schedule_sleep_reminder.dart
    handlers/
      on_settings_changed.dart
    read_models/
      settings_view.dart
      notification_settings_view.dart
    ports/
      profile_gateway.dart
      notification_gateway.dart
      package_info.dart
      data_exporter.dart
  data/
    repositories/
      lucent_user_settings.dart
      local_notification_preferences.dart
      local_preferences.dart
    datasources/
      profile_remote.dart
      data_storage.dart
    mappers/
      user_settings.dart
      notification_preferences.dart
  presentation/
    pages/
      page.dart
      profile.dart
      theme.dart
      language.dart
      accessibility.dart
      notification/
        page.dart
        dnd.dart
      data/
        export.dart
        storage.dart
      advanced/
        page.dart
        feature_flags.dart
      about/
        page.dart
        help.dart
        licenses.dart
      sleep_reminder.dart
    widgets/
      sections/
        about.dart
        general.dart
        privacy.dart
        quick_entry.dart
      navigation/
        tile.dart
        sign_out.dart
      account_header.dart
      master_detail.dart
    providers/
      notification/
        preferences.dart
        local.dart
        remote_sync.dart
        mapping.dart
      data_export.dart
      package_info.dart
      profile_sync.dart
      user_settings.dart
    utils/
      page_padding.dart
      theme_labels.dart
```

重点拆分：

- `application/sleep_reminder_notification_coordinator.dart` 若依赖通知/导航，移 `application/use_cases/schedule_sleep_reminder.dart` + `presentation/flows/`；application 不碰 UI。
- `presentation/providers/notification_*.dart` 收进 `providers/notification/`，避免单目录超过 10 个文件。
- `presentation/pages/` 按子域分组（notification/data/advanced/about），页面文件不再带 `settings_` 前缀。
- `data/providers/*` 全部迁到 `presentation/providers/*`；data 层只留适配器。
- `settings` 是 supporting 上下文：允许薄聚合，不强行造领域服务；`version_check` 是纯领域服务，`package_info` 是 port。

## 六、迁移顺序

每个 feature 独立成一个 PR 批次；批次内不改 UI、路由、文案、公开契约。

1. **Phase 0：战略设计与护栏**
   - 落 ADR-0010（限界上下文、聚合边界、上下文映射、领域事件）。
   - 建 `docs/reference/context-map.md` 与 `docs/reference/ubiquitous-language.md`。
   - 更新 `AGENTS.md`：`data/` 不再承载 provider，新增 `presentation/flows/`；application 改为纯 use case/orchestrator；跨 feature 收紧为只经 domain 或共享只读快照。
   - 扩 `layered_import`：domain 禁 Flutter/Dio/Drift/生成 DTO；application 禁 Flutter/presentation/data；pages/widgets/controllers 禁 data；跨 feature 禁 data/presentation provider。
   - 更新 4 个 feature 的 `README.md` 边界、聚合与发布语言说明。
   - 生成基线例外清单（文件 + 规则 + 到期日），CI 只允许递减。
2. **Phase 1：`record` — Health Logging**
   - 先划 `DailyRecord` 聚合与 `RecordEntry`/值对象，再建 repository 与事件；`RecordDashboard`/`RecordTimeline` 走读模型。
   - 再清 `application → presentation`（7 处）与 `presentation → data`（20 处）；`quick_entry` UI 流程归 `presentation/flows`。
3. **Phase 2：`medicine` — Medication**
   - 先划 `Reminder`/`DoseLog`/`RiskCheck` 聚合；修 `domain → data`，把提醒计划拆成纯 domain service + application port。
   - `MedicineWorkspace` 明确为读模型；`Medicine` 目录只读，不在客户端建聚合。
4. **Phase 3：`auth` — Identity & Access**
   - 先划 `Session` 聚合与状态机，再拆 login/OAuth/session use case；OAuth/平台适配器进 data/ports。
   - `core/auth` 只读会话快照；refresh 单飞、网络错误不清会话、远程 logout 失败不登出进聚合/领域服务测试。
5. **Phase 4：`settings` — Preferences**
   - 先划 `UserSettings`/`NotificationPreferences`/`LocalPreferences` 聚合；拆通知/导出/版本检查 use case。
   - 按子域重排 pages/widgets，最后清 data provider。

每批次完成后的门禁：

```bash
flutter analyze
flutter test
dart run scripts/workflows/daily.dart
dart run scripts/docs/verify.dart --warning-only
```

## 七、验收标准

- 每个限界上下文有明确的聚合根、不变量、领域事件与上下文映射；`context-map.md` 与代码目录一致。
- 每个聚合根一个 repository；没有内部实体 repository、通用 repository、读模型 repository。
- 聚合不变量有纯 Dart 单测；use case 测试只验证编排与失败回滚，不重复测规则。
- 跨 feature 只经 domain 发布语言/只读快照/领域事件；禁止 `data → data`、`presentation → presentation provider`。
- `domain/` 无 Flutter/Riverpod/Dio/Drift/GoRouter/`lucent_api`/`BuildContext`；`application/` 无 Flutter/导航/Toast/Dialog/实现细节。
- `presentation/pages|widgets|controllers` 无 `features/*/data/` import；`presentation/providers/` 之外无 data import。
- 读模型可绕过聚合，但只用于查询；写路径不读读模型做决策。
- UI、路由、l10n、OpenAPI 生成客户端零变化；现有 widget/golden 测试不改断言。
- 每个 feature 的 README 记录上下文边界、聚合、发布语言与禁止依赖。

## 八、风险与非目标

- **风险：客户端过度 DDD**。客户端没有服务端事务与多用户并发；聚合只保护本地可写不变量，展示/统计全部走读模型，不引入 event sourcing。
- **风险：跨 feature 事件变成隐式耦合**。事件只带发布语言事实；消费者幂等；禁止用事件反向调用发布方 provider。
- **风险：离线/乐观写入与聚合冲突**。聚合带版本/幂等键；失败回滚保留旧状态；pending-sync 只重放命令，不重放读模型。
- **风险：Riverpod 组合根被误判**。`presentation/providers/` 允许 import `data/`；禁止的是 pages/widgets/controllers 直接拿 repository/data source。
- **风险：文件改名打断 import**。用 analyzer/codemod 批量改，单 feature 单批次；不跨 feature 顺手改名。
- **风险：supporting 上下文被硬造领域模型**。`settings`/`auth` 允许薄聚合；不强制领域服务、不强推事件。
- **非目标**：不改 UI/交互、不改路由、不改 l10n、不改生成客户端、不引入新状态管理、不重写离线缓存策略、不做 event sourcing。
