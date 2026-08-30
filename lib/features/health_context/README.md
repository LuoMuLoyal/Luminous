# lib/features/health_context — 健康档案上下文

## Summary

health_context 是**跨 feature 共享的健康档案数据 feature**：聚合当前用户在当前时刻的
健康档案快照（当前用药 / 过敏 / 疾病 / 基础档案 / 健康指标摘要），并提供档案写入能力。
它**没有 presentation 层**——档案的编辑 UI 属于 `mine` feature，本 feature 只向全 app
暴露数据契约（domain entity + repository 接口 + provider）。

## 目录结构

- `domain/entities/snapshot.dart` — 读模型：`HealthContextSnapshot` 聚合 + 5 个子模型
  （`HealthSummary` / `HealthProfile` / `AllergyItem` / `ConditionItem` / `CurrentMedicineItem`），
  全部 `@freezed`。对应 `GET /api/v1/user/health-context` 的响应。
- `domain/entities/write_inputs.dart` — 写模型：`HealthContextWireEnum` 接口 + 6 个 wire enum
  （`HealthSexAtBirth` / `HealthUnitSystem` / `HealthAllergyKind` / `HealthAllergySeverity` /
  `HealthConditionStatus` / `HealthMedicineSource`）+ 7 个 Write/Update Input 类。
  Update 类用 `healthContextNoChange` 哨兵表示"未变更字段"，序列化时跳过。
- `domain/repositories/snapshot.dart` — `HealthContextRepository` 接口：1 个读 +
  9 个写方法，全部返回 `TaskEither<LucentFailure, HealthContextSnapshot>`（写成功后返回**刷新后的快照**）。
- `domain/services/unit_conversion.dart` — 纯展示换算：kg→lb、ml→fl oz（仅展示，存储口径不变）。
- `data/datasources/snapshot.dart` — `HealthContextRemoteDataSource`：包装生成的
  `UserHealthContextApi` + Dio 直调（写路径走 Dio 以便离线入队），并含各 payload 构建函数。
- `data/repositories/lucent.dart` — `LucentHealthContextRepository`：cache-first 读
  （Drift 缓存 + 30s 节流后台刷新）；写失败（`DioException`）入 pending-sync 队列供
  `SyncWorker` 断网重放。
- `data/mappers/health_context.dart` — `HealthContextMapper`：OpenAPI DTO → domain。
- `data/utils/health_context_snapshot_codec.dart` — `HealthContextSnapshotCodec`：手动
  JSON 序列化，供 Drift 缓存层与 SyncWorker replay 共用。
- `data/providers/health_context.dart` — provider 装配 + 对外读入口
  `healthContextSnapshotProvider`。

## 数据模型概览（domain/entities/snapshot.dart）

```
HealthContextSnapshot
├── summary   HealthSummary      age / onboardingCompleted / 各计数 / missingCoreProfileFields
├── profile   HealthProfile      birthDate / sexAtBirth / heightCm / weightKg / bloodType /
│                                locale / timezone / unitSystem / onboardingCompletedAt /
│                                emergencyContact(姓名+电话) / extras
├── allergies List<AllergyItem>  id / kind / label / reaction / severity / isActive / note / 时间戳
├── conditions List<ConditionItem> id / label / status / diagnosedAt / resolvedAt / note / 时间戳
└── currentMedicines List<CurrentMedicineItem> id / source / sourceRefId / displayName /
                       strengthText / doseText / route / startedAt / endedAt / isCurrent / note / 时间戳
```

## Provider 依赖图（data/providers/health_context.dart）

```
healthContextSnapshotProvider  (keepAlive, Future<HealthContextSnapshot>)
  ├─ watch dataChangeVersionProvider(DataChangeTopic.healthContext / currentMedicines) → 数据变更自动重建
  ├─ authGuarded（未登录报错而非返回空数据）
  └─ healthContextRepositoryProvider
       ├─ healthContextRemoteDataSourceProvider  ← lucentClientProvider.userHealthContext + lucentDioClientProvider
       ├─ healthContextMapperProvider
       ├─ healthContextDaoProvider（core/database）+ pendingSyncDaoProvider + syncWorkerProvider
       └─ 注册 'health_context' replay handler（重放原 HTTP 请求后刷新缓存）
```

读入口 `healthContextSnapshotProvider` 是跨 feature 消费的唯一共享 provider（5s 超时，
Left 投影为 `AsyncValue.error`）。

## 为什么被 7 个 feature 依赖

健康档案是跨 feature 的**共享领域模型**：当前用药是 reminder/dose/安全建议的锚点，
过敏/疾病是风险判断的输入，profile 是快速录入与归档的展示数据。`rg` 核实的依赖方：

- **today** — `dashboard_view.dart`（health event 的当前用药选项）、
  `data/repositories/lucent.dart`（看板聚合 currentMedicines）、
  `data/providers/today_suggestion.dart`
- **medicine** — `data/providers/workspace.dart`、`data/repositories/lucent_workspace.dart`
  （依赖 repository 接口）、reminder 表单/列表（form_body / rows / edit / reminders /
  reminder_formatters）、`medicine_detail.dart`
- **mine** — 档案编辑页（profile_edit / allergy_edit / condition_edit /
  current_medicine_edit）、`health_edit_forms.dart`、`health_enum_l10n.dart`、
  `sections/archive.dart`（含 unit_conversion）、`data/repositories/lucent.dart`
- **record** — `pages/detail.dart`（含 unit_conversion）、
  `quick_entry/medication_flow.dart`、`application/usecases/quick_entry_medication.dart`
- **search** — `pages/page.dart`、`shared/add_to_box.dart`（写当前用药）
- **review** — `pages/page.dart`（provider）
- **scan** — `barcode_scanner.dart`、`dialogs/recognize_dialog.dart`（扫码药品与档案比对）

依赖面既有**读**（`snapshot.dart` / `healthContextSnapshotProvider`）也有**写**
（`write_inputs.dart` + repository）；跨 feature 写入遵循 AGENTS.md 规则，通过
`HealthContextRepository` 接口进行。
