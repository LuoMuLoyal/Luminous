# lib/features/health_data — 健康平台同步

读取 iOS HealthKit / Android Health Connect 的健康指标并写入 daily record 的同步
feature:统一指标实体、权限、手动/前台自动同步能力。

## 职责与边界

- 管:`HealthMetric`(13 类指标)/`HealthPermissionStatus`/`HealthSyncResult` 实体;
  `HealthSyncRepository`(平台可用性/权限/读取/syncToRecords);手动同步页
  `/health-sync`;自动同步偏好(本地 SharedPreferences)。
- 不管:daily record 的存储、展示与业务口径在 record feature(经
  `dailyRecordRepositoryProvider` 写入);健康档案(过敏/疾病/当前用药)在
  health_context;后台自动同步执行器尚未接入(见 health_auto_sync.dart)。

## 对外契约

- 路由:`Routes.healthSync`;`presentation/routes.dart`:`HealthSyncRoute`
  (`/health-sync`)。
- 导出:`domain/entities/health_metric.dart`(`HealthMetricType`/`HealthMetric`)、
  `domain/entities/health_permission.dart`、`domain/repositories/health_sync.dart`
  (`HealthSyncRepository`)。
- 被依赖:当前无其他 feature 直接 import(仅 `lib/app/router.dart` 引 routes);
  写入口经 record 的 `dailyRecordRepositoryProvider`。

## 不变量

- 平台可用性:iOS 恒可用,Android 取决于 Health Connect SDK,desktop/web 恒不可用
  (`data/datasources/health_platform.dart`);`health` 插件只在该 datasource 触碰。
- 同步单向:只读健康平台 → 写 daily records,不回写健康平台;successCount>0 时必须
  广播 `DataChangeTopic.dailyRecords`(`health_sync_controller.dart`)。
- 自动同步偏好仅存 SharedPreferences(`PrefKeys.healthAutoSyncEnabled`),不上云;
  availability 不满足时强制 false(`health_auto_sync.dart`)。
- 测试锚点:`test/health_data/health_sync_repository_test.dart`(注入 fake datasource,
  不启真机)、`health_sync_providers_test.dart`、`mapper_test.dart`。

## 依赖禁区

- 跨 feature 只依赖 domain 接口/实体;不 import 其他 feature 的 presentation。
- 平台能力(health 插件)只进 `data/datasources/`;测试一律注入 fake datasource。

## 陷阱与决策

- 装配在 `data/providers/health_sync.dart` 直接 watch record 的
  `dailyRecordRepositoryProvider`,属既有 data→data 边缘;新代码经 domain 接口,
  勿再扩散。
- `healthAutoSyncExecutorConfigured` 是显式 capability seam(恒 false):后台自动同步
  未接入,接入时在同一边界验证,勿绕过 availability 判断。
- 血压/睡眠映射多个 `HealthDataType`,读取后需在 mapper 合并。
