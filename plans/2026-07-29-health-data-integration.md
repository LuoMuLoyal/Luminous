# 健康数据集成计划：iOS HealthKit + Android Health Connect

> 创建日期：2026-07-29
> 状态：规划中，尚未开始执行
> 涉及仓库：Luminous + Lucent（Phase 0 需前后端配合，Phase 1+ 前端独立）
> 完成后删除本文件，将稳定决策更新到 `docs/02-reference/architecture.md` 及相关文档。

---

## 1. 背景与目标

### 现状

`record` feature 支持 `water`、`meal`、`vital`、`sleep`、`activity` 等 `DailyRecordKind`，
但所有数据靠手动录入或拍照 OCR。用户没有从可穿戴设备 / 系统健康平台自动采数的通道。

`health_context` 模块管理过敏、状况、当前用药，但缺少从健康平台拉取 vital 的能力。

### 目标

接入 `health` 插件（pub.dev: `health` v13.3.1，verified publisher carp.dk），
实现 iOS HealthKit 和 Android Health Connect 的健康数据自动同步。

- **iOS**：Apple HealthKit 在国内完全可用，无任何限制
- **Android**：Google Health Connect 依赖 Google Play Services，仅覆盖有 GMS 的设备（海外用户）
- **不做国内 Android 厂商 SDK**（华为 / 小米 / OPPO / vivo），这些用户走现有手动录入

### 不做的事情

- 不接入华为 Health Kit / 小米健康 / OPPO Health / vivo Health
- 不做后台自动同步（后台同步在 `native-bridging-roadmap.md` Phase 1 中独立处理）
- 不做 Web 端 / 桌面端健康数据（`health` 插件只支持 iOS + Android）

---

## 2. 前置工作：激活 vital 和 activity kind（Phase 0）

### 问题

当前 `vital` 和 `activity` 两个 `DailyRecordKind` 在前端处于半废弃状态：

- `activeDailyRecordKinds`（`form_fields.dart`）不包含 `vital` 和 `activity`，用户无法在创建页面选择
- `_isActiveRecordEntryType`（`lucent.dart`）对 `vitals` 返回 `false`，筛选器和快捷操作中不展示
- `RecordEntryType.heartRate` / `weight` 在 `dailyRecordKindForEntryType()` 中返回 `null`，不映射到任何 kind
- 后端 `vital` / `activity` 的 `payload` 没有结构化 schema（只有 `sleep` 有）

**如果不做这步，健康数据同步过去后用户在前端根本看不到。**

### 后端改动（Lucent）

#### 定义 vitalPayloadSchema

在 `Lucent/src/modules/daily-records/schemas/daily-record-candidates.schema.ts` 中新增：

```typescript
export const vitalPayloadSchema = z
  .object({
    vitalType: z.enum([
      'heartRate',
      'bloodPressure',
      'bloodOxygen',
      'bloodGlucose',
      'bodyTemperature',
      'weight',
      'respiratoryRate',
    ]),
    // 主值
    value: z.number(),
    unit: z.string().trim().min(1).max(20),
    // 血压专用：收缩压存 value，舒张压存 secondaryValue
    secondaryValue: z.number().optional(),
    secondaryUnit: z.string().trim().min(1).max(20).optional(),
  })
  .strict();
```

在 `records.service.ts` 中增加 vital payload 校验（类似 `ensureValidSleepPayload`）：

```typescript
private ensureValidVitalPayload(
  kind: string,
  payload: Record<string, unknown> | undefined,
) {
  if (kind !== DailyRecordKind.vital) return;
  if (payload == null || typeof payload['vitalType'] !== 'string') {
    badRequest('Vital records require payload.vitalType.');
  }
  if (typeof payload['value'] !== 'number') {
    badRequest('Vital records require payload.value as a number.');
  }
}
```

同样为 `activity` 定义 `activityPayloadSchema`：

```typescript
export const activityPayloadSchema = z
  .object({
    activityType: z.enum(['steps', 'flightsClimbed', 'distance', 'exerciseTime']),
    value: z.number(),
    unit: z.string().trim().min(1).max(20),
  })
  .strict();
```

#### 更新 DTO 描述

在 `create-record.dto.ts` 和 `record-item.dto.ts` 中更新 `payload` 字段的 `@ApiPropertyOptional` 描述，
补充 vital 和 activity 的 payload 约定说明。

#### 导出 OpenAPI

运行 `pnpm export:openapi` 重新生成 `Lucent/docs/openapi.json`。

### 前端改动（Luminous）

#### 激活 vital 和 activity

| 文件 | 改动 |
|------|------|
| `lib/features/record/presentation/widgets/forms/form_fields.dart` | `activeDailyRecordKinds` 列表增加 `DailyRecordKind.vital` 和 `DailyRecordKind.activity` |
| `lib/features/record/domain/entities/type_mapping.dart` | `dailyRecordKindForEntryType()` 中 `heartRate` / `weight` 映射到 `DailyRecordKind.vital`（不再返回 `null`） |
| `lib/features/record/data/repositories/lucent.dart` | `_isActiveRecordEntryType()` 中 `vitals` 返回 `true` |
| `lib/features/record/data/repositories/lucent.dart` | 添加 `vitals` 到 `_staticQuickActions` 和 `_staticFilters`（如需要） |

#### vital 表单适配

`vital` kind 的表单已经是 `showTitle: true, showValue: true, showUnit: true`，可以正常工作。
手动录入时 title 填写体征名称（如「心率」），value 填数值，unit 填单位（如「bpm」），
payload 留空（手动录入不需要 payload）。

健康数据自动同步时，mapper 负责生成结构化 payload。

### Phase 0 验证

- [ ] Lucent: 创建 `vital` 记录时 payload 不含 `vitalType` → 返回 400
- [ ] Lucent: 创建 `vital` 记录时 payload 合法 → 成功
- [ ] Lucent: 创建 `activity` 记录时 payload 合法 → 成功
- [ ] Luminous: record 创建页面可以看到「体征」和「活动」选项
- [ ] Luminous: 手动创建 `vital` 记录 → 在时间线和摘要中可见
- [ ] `pnpm test` + `flutter analyze` + `flutter test` 通过
- [ ] `pnpm export:openapi` → `dart run scripts/bootstrap_generated_sources.dart`

---

## 3. 技术选型

| 项 | 选择 | 理由 |
|---|------|------|
| Flutter 插件 | `health: ^13.3.1` | pub.dev verified publisher，同时封装 iOS HealthKit + Android Health Connect，社区活跃 |
| 平台覆盖 | iOS 14+ / Android API 26+ | `health` 插件最低要求 |
| 数据写入方式 | 现有 `DailyRecordRepository.create()` | 复用已有的 `POST /api/v1/daily-records` 接口 |
| 跨 feature 通知 | `DataChangeBus` + `DataChangeTopic.dailyRecords` | 与现有 record / today / report 联动 |

---

## 4. 数据映射

### vital 类型（`DailyRecordKind.vital`）

payload 结构：`{ "vitalType": string, "value": number, "unit": string, "secondaryValue"?: number, "secondaryUnit"?: string }`

| 原生健康数据 | `health` 插件枚举 | vitalType | value | unit | secondaryValue | secondaryUnit | 说明 |
|---|---|---|---|---|---|---|---|
| 心率 | `HEART_RATE` | `heartRate` | bpm 值 | `bpm` | — | — | |
| 血压 | `BLOOD_PRESSURE_SYSTOLIC` + `BLOOD_PRESSURE_DIASTOLIC` | `bloodPressure` | 收缩压 | `mmHg` | 舒张压 | `mmHg` | 收缩/舒张合并为一条记录 |
| 血氧 | `BLOOD_OXYGEN` | `bloodOxygen` | 百分比 | `%` | — | — | |
| 血糖 | `BLOOD_GLUCOSE` | `bloodGlucose` | mg/dL | `mg/dL` | — | — | |
| 体温 | `BODY_TEMPERATURE` | `bodyTemperature` | °C | `°C` | — | — | |
| 体重 | `BODY_MASS` / `WEIGHT` | `weight` | kg | `kg` | — | — | |
| 呼吸频率 | `RESPIRATORY_RATE` | `respiratoryRate` | 次/分 | `rpm` | — | — | |

### activity 类型（`DailyRecordKind.activity`）

payload 结构：`{ "activityType": string, "value": number, "unit": string }`

| 原生健康数据 | `health` 插件枚举 | activityType | value | unit | 说明 |
|---|---|---|---|---|---|
| 步数 | `STEPS` | `steps` | 步数 | `count` | 每日步数汇总 |
| 爬楼层数 | `FLIGHTS_CLIMBED` | `flightsClimbed` | 层数 | `count` | |
| 运动时间 | `EXERCISE_TIME` | `exerciseTime` | 分钟 | `min` | |

### sleep 类型（`DailyRecordKind.sleep`）

payload 结构（已有 schema，无需改动）：`{ "startAt": ISO8601, "endAt": ISO8601, "durationMinutes": int, "quality"?: string, "deepMinutes"?: int, "lightMinutes"?: int, "remMinutes"?: int }`

| 原生健康数据 | `health` 插件枚举 | 说明 |
|---|---|---|
| 睡眠 | `SLEEP_ASLEEP` + `SLEEP_DEEP` + `SLEEP_LIGHT` + `SLEEP_REM` | 合并为一条 sleep 记录，deep/light/rem 分别填入 payload 字段 |

### height — 写入 health_context profile

| 原生健康数据 | `health` 插件枚举 | 目标 | 说明 |
|---|---|---|---|
| 身高 | `HEIGHT` | `health_context` profile `heightCm` | 不写入 daily-records，而是通过 `PATCH /api/v1/user/health-context/profile` 更新 |

### water — 写入 daily-records kind=water

| 原生健康数据 | `health` 插件枚举 | 说明 |
|---|---|---|
| 饮水量 | `WATER` | value 填升数，unit 填 `L`，payload 留空 |

### `source` 字段标记

所有自动同步的 `DailyRecordItem` 的 `source` 字段设为：
- iOS：`"apple_health"`
- Android：`"health_connect"`

后端 `UserDailyRecord.source` 是 `String?` 字段，默认 `"manual"`，不需要改 schema。

---

## 5. 架构设计

### 5.1 新建 `health_data` feature

遵循 Luminous 现有的 feature-based clean architecture：

```
lib/features/health_data/
├── data/
│   ├── datasources/
│   │   └── health_platform.dart          ← `health` 插件封装，读写原生健康平台
│   ├── mappers/
│   │   └── health_record_mapper.dart     ← 原生 HealthDataPoint → DailyRecordCreateInput
│   ├── providers/
│   │   └── health_sync.dart              ← Riverpod providers
│   └── repositories/
│       └── health_sync.dart              ← HealthSyncRepository 实现
├── domain/
│   ├── entities/
│   │   ├── health_permission.dart        ← 权限状态枚举
│   │   ├── health_sync_result.dart       ← 同步结果（成功/跳过/失败计数）
│   │   └── health_metric.dart            ← 统一健康指标中间模型
│   └── repositories/
│       └── health_sync.dart              ← HealthSyncRepository 抽象接口
└── presentation/
    ├── pages/
    │   └── health_sync.dart              ← 同步页面（权限请求 + 数据预览 + 确认导入）
    └── providers/
        └── health_sync.dart              ← 页面状态管理
```

### 5.2 核心接口设计

#### domain/repositories/health_sync.dart

```dart
abstract interface class HealthSyncRepository {
  /// 检查健康平台是否可用（iOS 始终可用，Android 需 Health Connect 已安装）
  bool get isPlatformAvailable;

  /// 请求健康数据读取权限
  Future<HealthPermissionStatus> requestPermissions(Set<HealthMetricType> types);

  /// 获取当前已授权的数据类型
  Future<Set<HealthMetricType>> getAuthorizedTypes();

  /// 拉取指定时间范围内的健康数据
  Future<List<HealthMetric>> fetchMetrics({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  });

  /// 将健康指标写入 daily-records（通过现有 DailyRecordRepository）
  Future<HealthSyncResult> syncToRecords(List<HealthMetric> metrics);
}
```

#### domain/entities/health_metric.dart

```dart
@freezed
abstract class HealthMetric with _$HealthMetric {
  const factory HealthMetric({
    required HealthMetricType type,
    required double value,
    required String unit,
    required DateTime recordedAt,
    double? secondaryValue,
    String? secondaryUnit,
    // sleep 专用
    Duration? sleepDuration,
    String? sleepQuality,
    int? deepMinutes,
    int? lightMinutes,
    int? remMinutes,
  }) = _HealthMetric;
}

enum HealthMetricType {
  steps,
  flightsClimbed,
  exerciseTime,
  heartRate,
  bloodPressure,
  bloodOxygen,
  bloodGlucose,
  bodyTemperature,
  weight,
  respiratoryRate,
  sleep,
  height,
  water,
}

enum HealthPermissionStatus { granted, denied, notAvailable, notDetermined }
```

#### domain/entities/health_sync_result.dart

```dart
@freezed
abstract class HealthSyncResult with _$HealthSyncResult {
  const factory HealthSyncResult({
    required int successCount,
    required int skippedCount,
    required int failedCount,
    @Default([]) List<String> errors,
  }) = _HealthSyncResult;
}
```

### 5.3 DataSource 封装

`data/datasources/health_platform.dart` 封装 `health` 插件：

- `Health().requestAuthorization()` — 请求权限
- `Health().hasPermissions()` — 检查已授权类型
- `Health().getHealthDataFromTypes()` — 拉取数据
- `Health().getTotalStepsInInterval()` — 步数专用高效接口

DataSource 只负责与 `health` 插件交互，不做业务逻辑。
Mapper 负责将 `HealthDataPoint` 转换为 `HealthMetric`，再由 Repository 转换为 `DailyRecordCreateInput`。

### 5.4 与现有系统的集成

#### 写入路径

```
health 平台 → HealthPlatform DataSource → HealthMetric (domain)
  → HealthRecordMapper → DailyRecordCreateInput
  → DailyRecordRepository.create() (现有 record feature)
  → DataChangeBus.emit(DataChangeTopic.dailyRecords)
```

`HealthSyncRepositoryImpl` 依赖 `DailyRecordRepository`（通过 domain interface，符合 cross-feature import rules）。

#### 去重策略

- 按 `kind + occurredAt + source` 三元组去重
- 同步前先调用 `DailyRecordRepository.fetchRecords()` 获取已有记录的指纹集合
- 跳过已存在的记录，计入 `skippedCount`

#### 入口位置

在 `mine` 页面的设置 section 中新增「从健康 App 导入」入口（而非 app 启动时自动触发）。

- `mine` → 设置区域 → 点击「从健康 App 导入」→ 进入 `health_sync` 页面
- 路由：`/health-sync`（top-level full-screen route，outside shell）

### 5.5 权限策略

- 不在 app 启动时请求健康数据权限，仅在用户主动点击「从健康 App 导入」时请求
- 权限粒度按数据类型分开请求（步数、心率、睡眠各自独立授权）
- 用户拒绝某类数据权限时，该类型自动跳过，不影响其他类型同步
- 同步页面展示各数据类型的授权状态（已授权 / 未授权 / 不可用）

### 5.6 Settings 开关

在 `settings` feature 中新增「健康数据自动同步」开关：

- 文件：`lib/features/settings/domain/entities/user_settings.dart` 增加字段
- 文件：`lib/features/settings/presentation/pages/` 新增 `health_sync.dart` 设置页
- 默认关闭
- 开启后，每次 app 进入前台时自动同步最近 24 小时的健康数据（前台触发，不做后台同步）

---

## 6. 平台配置

### 6.1 iOS

**Info.plist 权限声明：**

```xml
<key>NSHealthShareUsageDescription</key>
<string>读取您的步数、心率、睡眠等健康数据，自动同步到 Luminous 记录中</string>
```

**Xcode Capability：**

- 在 Runner target 中启用 `HealthKit` capability
- 勾选需要读取的 HealthKit 类型（StepCount, HeartRate, BloodPressure, SleepAnalysis, BodyMass, Height, OxygenSaturation）

**最小部署版本：** iOS 14.0（`health` 插件要求）

### 6.2 Android

**AndroidManifest.xml 权限声明：**

```xml
<!-- Health Connect permissions -->
<uses-permission android:name="android.permission.health.READ_STEPS" />
<uses-permission android:name="android.permission.health.READ_HEART_RATE" />
<uses-permission android:name="android.permission.health.READ_BLOOD_PRESSURE" />
<uses-permission android:name="android.permission.health.READ_SLEEP" />
<uses-permission android:name="android.permission.health.READ_WEIGHT" />
<uses-permission android:name="android.permission.health.READ_HEIGHT" />
<uses-permission android:name="android.permission.health.READ_OXYGEN_SATURATION" />
```

**Health Connect 可见性声明（Android 14+）：**

```xml
<queries>
    <package android:name="com.google.android.apps.healthdata" />
</queries>
```

**Intent filter（处理 Health Connect 权限页面返回）：**

在 `MainActivity.kt` 中处理 `androidx.health.connect.action.SHOW_MIGRATION_INFO` intent。

**最小 SDK：** API 26（`health` 插件要求，现有项目 `min_sdk_android: 21` 需评估是否提升）

> **注意**：现有 `pubspec.yaml` 中 `flutter_launcher_icons` 配置了 `min_sdk_android: 21`。
> 需要检查 `health` 插件是否强制要求 minSdk 26。如果是，需要在 `android/app/build.gradle`
> 中提升 `minSdkVersion`，并评估对现有用户的影响。

---

## 7. 同步流程

### 7.1 用户操作流程

```
mine 页面 → 点击「从健康 App 导入」
  → /health-sync 路由
  → 同步页面展示：
    - 数据类型选择（步数 / 心率 / 血压 / 睡眠 / 体重 / 血氧）
    - 时间范围选择（今天 / 最近 3 天 / 最近 7 天）
    - 「开始同步」按钮
  → 点击「开始同步」：
    1. 请求未授权的数据类型权限（系统弹窗）
    2. 拉取数据
    3. 显示预览（「步数 8,432 步」「睡眠 7h 12m」等）
    4. 用户确认导入
    5. 批量写入 daily-records
    6. 显示同步结果（成功 X 条 / 跳过 Y 条 / 失败 Z 条）
    7. emit DataChangeTopic.dailyRecords
```

### 7.2 自动同步流程（Settings 开关开启时）

```
app 进入前台（AppLifecycleState.resumed）
  → 检查「健康数据自动同步」开关
  → 检查距上次同步是否 > 1 小时
  → 静默同步最近 24 小时数据
  → 跳过权限未授予的类型
  → emit DataChangeTopic.dailyRecords（如有新数据）
```

---

## 8. 执行计划

### Phase 0: 激活 vital 和 activity kind（前置）

| 子步骤 | 仓库 | 内容 |
|--------|------|------|
| 0.1 | Lucent | `schemas/daily-record-candidates.schema.ts` 新增 `vitalPayloadSchema` + `activityPayloadSchema` |
| 0.2 | Lucent | `services/records.service.ts` 新增 `ensureValidVitalPayload` + `ensureValidActivityPayload` 校验 |
| 0.3 | Lucent | `dto/create-record.dto.ts` + `dto/record-item.dto.ts` 更新 payload 字段描述 |
| 0.4 | Lucent | 单元测试：vital/activity payload 校验 |
| 0.5 | Lucent | `pnpm lint:check` + `pnpm build` + `pnpm test` + `pnpm export:openapi` |
| 0.6 | Luminous | `dart run scripts/bootstrap_generated_sources.dart` 同步 OpenAPI client |
| 0.7 | Luminous | `form_fields.dart`：`activeDailyRecordKinds` 增加 `vital` 和 `activity` |
| 0.8 | Luminous | `type_mapping.dart`：`heartRate` / `weight` 映射到 `DailyRecordKind.vital` |
| 0.9 | Luminous | `lucent.dart`：`_isActiveRecordEntryType` 中 `vitals` 返回 `true` |
| 0.10 | Luminous | 验证手动创建 vital / activity 记录在前端可见 |
| 0.11 | Luminous | `flutter analyze` + `flutter test` + 文档检查 |

### Step 1: 项目配置与依赖

| 子步骤 | 内容 |
|--------|------|
| 1.1 | `pubspec.yaml` 添加 `health: ^13.3.1` 依赖 |
| 1.2 | iOS Info.plist 添加 `NSHealthShareUsageDescription` |
| 1.3 | iOS Xcode 启用 HealthKit capability（需手动操作 Xcode） |
| 1.4 | Android AndroidManifest.xml 添加 Health Connect 权限声明 |
| 1.5 | 检查并按需提升 Android `minSdkVersion` |
| 1.6 | `flutter pub get` 验证依赖解析 |

### Step 2: Domain 层

| 子步骤 | 内容 |
|--------|------|
| 2.1 | 创建 `features/health_data/domain/entities/health_metric.dart` — `HealthMetric` + `HealthMetricType` 枚举 |
| 2.2 | 创建 `features/health_data/domain/entities/health_permission.dart` — `HealthPermissionStatus` 枚举 |
| 2.3 | 创建 `features/health_data/domain/entities/health_sync_result.dart` — `HealthSyncResult` |
| 2.4 | 创建 `features/health_data/domain/repositories/health_sync.dart` — `HealthSyncRepository` 抽象接口 |
| 2.5 | `dart run build_runner build` 生成 freezed 代码 |

### Step 3: Data 层

| 子步骤 | 内容 |
|--------|------|
| 3.1 | 创建 `features/health_data/data/datasources/health_platform.dart` — 封装 `health` 插件 API |
| 3.2 | 创建 `features/health_data/data/mappers/health_record_mapper.dart` — `HealthDataPoint → HealthMetric` 和 `HealthMetric → DailyRecordCreateInput` 映射 |
| 3.3 | 创建 `features/health_data/data/repositories/health_sync.dart` — `HealthSyncRepositoryImpl`，依赖 `DailyRecordRepository`（domain interface） |
| 3.4 | 实现去重逻辑：同步前按 `kind + occurredAt + source` 查询已有记录 |
| 3.5 | 创建 `features/health_data/data/providers/health_sync.dart` — Riverpod provider 绑定 |

### Step 4: Presentation 层

| 子步骤 | 内容 |
|--------|------|
| 4.1 | 创建 `features/health_data/presentation/providers/health_sync.dart` — 页面状态 Notifier |
| 4.2 | 创建 `features/health_data/presentation/pages/health_sync.dart` — 同步页面 UI |
| 4.3 | UI 组件：数据类型选择卡片、时间范围选择器、同步预览列表、结果摘要 |
| 4.4 | 遵循 Forui-first 设计系统，loading 用 shimmer skeleton，错误用 `AppStateErrorView` |
| 4.5 | 所有用户可见文本走 ARB fragment `health_sync_zh.arb` / `health_sync_en.arb` |

### Step 5: 路由与入口

| 子步骤 | 内容 |
|--------|------|
| 5.1 | 在 `lib/app/router.dart` 中添加 `/health-sync` 路由（`@TypedGoRoute`，auth required） |
| 5.2 | 在 `mine` 页面的设置 section 中添加「从健康 App 导入」tile |
| 5.3 | tile 仅在移动端显示（`Platform.isIOS || Platform.isAndroid`），桌面 / Web 隐藏 |

### Step 6: Settings 开关

| 子步骤 | 内容 |
|--------|------|
| 6.1 | 在 `settings/domain/entities/user_settings.dart` 增加 `healthAutoSyncEnabled` 字段 |
| 6.2 | 在 `settings/presentation/pages/` 增加 `health_sync.dart` 设置子页面 |
| 6.3 | 在设置主页面 `page.dart` 的隐私/数据 section 添加「健康数据自动同步」入口 |
| 6.4 | 实现 app 前台自动同步逻辑（监听 `AppLifecycleState.resumed`） |

### Step 7: L10n

| 子步骤 | 内容 |
|--------|------|
| 7.1 | 创建 `lib/l10n/src/health_sync_zh.arb` 和 `health_sync_en.arb` fragment |
| 7.2 | `dart scripts/arb_tools.dart merge` |
| 7.3 | `flutter gen-l10n` |
| 7.4 | 同步 `docs/02-reference/Localization.md` 增加 health_sync fragment 所有权 |

### Step 8: 测试

| 子步骤 | 内容 |
|--------|------|
| 8.1 | `health_record_mapper` 单元测试：各种 `HealthDataPoint` → `DailyRecordCreateInput` 映射 |
| 8.2 | `HealthSyncRepositoryImpl` 单元测试：mock DataSource + mock DailyRecordRepository |
| 8.3 | 去重逻辑测试：相同 `kind + occurredAt + source` 跳过 |
| 8.4 | Widget 测试：同步页面 UI 状态流转（选择 → 请求权限 → 预览 → 导入 → 结果） |
| 8.5 | `flutter analyze` + `flutter test` 全量通过 |

### Step 9: 文档

| 子步骤 | 内容 |
|--------|------|
| 9.1 | 追加 `docs/03-logs/migration-log/2026-07-29.md` 条目 |
| 9.2 | 更新 `docs/02-reference/architecture.md` 增加 `health_data` feature 说明 |
| 9.3 | 更新 `docs/02-reference/Localization.md` 增加 health_sync fragment |
| 9.4 | `dart run scripts/check_doc_coverage.dart --warning-only` 确认文档覆盖 |

---

## 8. 文件变更清单

### 新建文件

| 文件 | 说明 |
|------|------|
| `lib/features/health_data/domain/entities/health_metric.dart` | 健康指标模型 + 类型枚举 |
| `lib/features/health_data/domain/entities/health_metric.freezed.dart` | 生成 |
| `lib/features/health_data/domain/entities/health_permission.dart` | 权限状态枚举 |
| `lib/features/health_data/domain/entities/health_sync_result.dart` | 同步结果模型 |
| `lib/features/health_data/domain/entities/health_sync_result.freezed.dart` | 生成 |
| `lib/features/health_data/domain/repositories/health_sync.dart` | 抽象接口 |
| `lib/features/health_data/data/datasources/health_platform.dart` | `health` 插件封装 |
| `lib/features/health_data/data/mappers/health_record_mapper.dart` | 数据映射 |
| `lib/features/health_data/data/repositories/health_sync.dart` | Repository 实现 |
| `lib/features/health_data/data/providers/health_sync.dart` | Provider 绑定 |
| `lib/features/health_data/data/providers/health_sync.g.dart` | 生成 |
| `lib/features/health_data/presentation/providers/health_sync.dart` | 页面状态 |
| `lib/features/health_data/presentation/providers/health_sync.freezed.dart` | 生成 |
| `lib/features/health_data/presentation/pages/health_sync.dart` | 同步页面 |
| `lib/features/health_data/routes.dart` | 路由定义 |
| `lib/features/health_data/routes.g.dart` | 生成 |
| `lib/l10n/src/health_sync_zh.arb` | 中文 l10n fragment |
| `lib/l10n/src/health_sync_en.arb` | 英文 l10n fragment |

### Phase 0 修改文件（Lucent 后端）

| 文件 | 变更 |
|------|------|
| `Lucent/src/modules/daily-records/schemas/daily-record-candidates.schema.ts` | 新增 `vitalPayloadSchema` + `activityPayloadSchema` |
| `Lucent/src/modules/daily-records/services/records.service.ts` | 新增 vital/activity payload 校验 |
| `Lucent/src/modules/daily-records/dto/create-record.dto.ts` | 更新 payload 字段描述 |
| `Lucent/src/modules/daily-records/dto/record-item.dto.ts` | 更新 payload 字段描述 |
| `Lucent/src/modules/daily-records/services/records.service.spec.ts` | 新增 vital/activity 校验测试 |

### Phase 0 修改文件（Luminous 前端）

| 文件 | 变更 |
|------|------|
| `lib/features/record/presentation/widgets/forms/form_fields.dart` | `activeDailyRecordKinds` 增加 `vital` 和 `activity` |
| `lib/features/record/domain/entities/type_mapping.dart` | `heartRate` / `weight` 映射到 `DailyRecordKind.vital` |
| `lib/features/record/data/repositories/lucent.dart` | `_isActiveRecordEntryType` 激活 `vitals` |
| `lib/l10n/src/record_zh.arb` / `record_en.arb` | 补充 vital / activity 相关文案（如需） |

### 健康数据集成修改文件

| 文件 | 变更 |
|------|------|
| `pubspec.yaml` | 添加 `health: ^13.3.1` |
| `ios/Runner/Info.plist` | 添加 `NSHealthShareUsageDescription` |
| `android/app/src/main/AndroidManifest.xml` | 添加 Health Connect 权限声明 + queries |
| `android/app/build.gradle` | 按需提升 `minSdkVersion` |
| `lib/app/router.dart` | 添加 `/health-sync` 路由 |
| `lib/features/mine/presentation/widgets/sections/account_security.dart` 或新建 section | 添加「从健康 App 导入」tile |
| `lib/features/settings/domain/entities/user_settings.dart` | 增加 `healthAutoSyncEnabled` 字段 |
| `lib/features/settings/presentation/pages/page.dart` | 添加健康数据同步设置入口 |
| `lib/l10n/src/mine_zh.arb` / `mine_en.arb` | 添加「从健康 App 导入」文案 |
| `lib/l10n/src/settings_zh.arb` / `settings_en.arb` | 添加自动同步开关文案 |

### iOS Xcode 手动操作

| 操作 | 说明 |
|------|------|
| Runner target → Signing & Capabilities → + Capability → HealthKit | 启用 HealthKit |
| Runner target → Signing & Capabilities → HealthKit → 勾选 Clinical Health Records 之外的所需类型 | 配置读取权限 |

---

## 10. 风险与缓解

| 风险 | 概率 | 缓解 |
|------|------|------|
| `health` 插件要求 Android minSdk 26，现有项目 minSdk 21 | 高 | 先检查 `health` 插件 pubspec 约束；如果需要提升，评估现有用户影响，可能需要 `flutter` 条件导入降级处理 |
| HealthKit 权限审核被拒 | 低 | 只请求与功能直接相关的数据类型，Info.plist 提供清晰的用途说明 |
| 同步大量历史数据时性能问题 | 中 | 限制单次同步范围（默认最近 7 天），分页拉取，UI 显示进度 |
| 重复同步产生重复记录 | 中 | 按 `kind + occurredAt + source` 去重，跳过已存在记录 |
| `health` 插件 API breaking change | 低 | 锁定 `^13.3.1`，关注 changelog |
| 用户在同步过程中退出页面 | 中 | 同步操作使用 `unawaited` + `cancelled` 检测，已写入的数据不回滚 |
| Phase 0 激活 vital/activity 后旧数据展示异常 | 中 | 已有 vital/activity 记录的 title/value/unit 格式可能与新 payload 约定不一致；timeline 渲染需兼容无 payload 的旧记录 |
| 后端 vital payload schema 过于严格 | 低 | 使用 `.strict()` 但保留 `secondaryValue`/`secondaryUnit` 可选，不影响手动录入（手动录入不带 payload） |

---

## 11. 验证清单

### Phase 0 验证

- [ ] Lucent: 创建 `vital` 记录时 payload 不含 `vitalType` → 返回 400
- [ ] Lucent: 创建 `vital` 记录时 payload 合法 → 成功
- [ ] Lucent: 创建 `activity` 记录时 payload 合法 → 成功
- [ ] Lucent: 创建 `vital` 记录时无 payload（手动录入） → 成功（不校验）
- [ ] Luminous: record 创建页面可以看到「体征」和「活动」选项
- [ ] Luminous: 手动创建 `vital` 记录 → 在时间线和摘要中可见
- [ ] Luminous: 手动创建 `activity` 记录 → 在时间线和摘要中可见
- [ ] Luminous: 已有的旧 vital/activity 记录正常显示（兼容无 payload）

### 健康数据集成验证

- [ ] iOS: 模拟器 Health app 手动录入步数 → Luminous 同步 → 验证 record 页面出现 `activity` 类型记录，payload 含 `activityType: steps`
- [ ] iOS: 模拟器录入心率 → 同步 → 验证 `vital` 类型记录，payload 含 `vitalType: heartRate`
- [ ] iOS: 模拟器录入血压 → 同步 → 验证 `vital` 类型记录，payload 含 `vitalType: bloodPressure` + `value`(收缩) + `secondaryValue`(舒张)
- [ ] iOS: 模拟器录入睡眠 → 同步 → 验证 `sleep` 类型记录，payload 含 `startAt`/`endAt`/`durationMinutes`
- [ ] iOS: 模拟器录入体重 → 同步 → 验证 `vital` 类型记录，payload 含 `vitalType: weight`
- [ ] Android: Health Connect 测试数据 → 同步 → 验证记录正确（需要有 GMS 的设备或模拟器）
- [ ] 权限拒绝场景：用户拒绝某类数据权限 → 该类型跳过，其他类型正常同步
- [ ] 部分授权场景：只授权步数 → 只同步步数，其他类型显示「未授权」
- [ ] 重复同步：连续同步两次相同时间范围 → 第二次全部跳过
- [ ] 自动同步开关：开启 → app 切后台再切回前台 → 自动同步最近 24 小时
- [ ] `pnpm lint:check` + `pnpm build` + `pnpm test`（Lucent）
- [ ] `flutter analyze` 零警告
- [ ] `flutter test` 全量通过
- [ ] `dart run scripts/check_doc_coverage.dart --warning-only` 无缺失
