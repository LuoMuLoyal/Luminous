# mine

一句话:五 tab shell 的"我的"tab(`Routes.mine`):聚合账号、健康档案完成度、状态提醒与归档入口,并承载健康档案(profile/过敏/疾病/当前用药)的编辑 UI。

## 职责与边界
- 管:`MineDashboard` 聚合读模型(`domain/entities/dashboard.dart`);档案编辑页与表单状态(`presentation/pages/`、`presentation/providers/health_edit_forms.dart`);同步失败横幅/详情(`presentation/widgets/sections/sync_failed_*` + `presentation/mappers/sync_error_user_message.dart`)。
- 不管:健康档案数据契约归 `health_context`(读快照、写经 `HealthContextRepository` + `write_inputs.dart`);数据导出页归 `settings`(`Routes.settingsExport`);帮助/FAQ 归 `settings`,支持资源归 `support` feature;登录会话归 `core/auth`。

## 对外契约
- 路由:tab `Routes.mine`;子页为 `presentation/routes.dart` 的 TypedGoRoute:`MineProfileEditRoute`、`MineAllergy(New|Edit)Route`、`MineCondition(New|Edit)Route`、`MineMedicine(New|Edit)Route`(new 形式有常量 `Routes.mineProfileEdit`/`mineAllergyNew`/`mineConditionNew`/`mineMedicineNew`,见 `lib/app/router.dart`)。
- 导出:`mineRepositoryProvider`(`data/providers/mine.dart`)、`MineRepository`(`domain/repositories/profile.dart`)、`MineDashboard` 及子模型、`mineDashboardProvider`(`presentation/providers/dashboard.dart`)。
- 被依赖:lib 内无其他 feature 消费(仅 `lib/app/router.dart` 装配;测试侧 `test/mine/`、`test/auth/session_gate_test.dart`、`integration_test/support/e2e_test_helpers.dart`)。

## 不变量
- `LucentMineRepository` 无自有 datasource/mapper:dashboard 一律由 `healthContextSnapshotProvider` 聚合;快照失败 → `TaskEither` Left,不得用默认值伪造 dashboard(`data/repositories/lucent.dart` 头注释;`test/mine/data/repositories/lucent_test.dart`)。
- 未登录经 `authGuarded` 返回 `signedOutDashboard` 纯本地值,永不失败(`domain/repositories/profile.dart` 接口注释)。
- 状态卡只携带结构化数据(`MineStatusCard.kind/items/count`),截断与文案本地化是展示层职责(`presentation/widgets/sections/status_alerts.dart`)。
- 编辑写成功后由 `DataChangeTopic.healthContext` 驱动 `mineDashboardProvider`(keepAlive)自动刷新,不手动重拉。

## 依赖禁区
- 跨 feature 数据只经共享 provider seam:health_context 快照/写入输入、notification 未读数(`notification/data/providers/unread_count.dart`);不得 import 其他 feature 的 datasource/mapper/repository 实现层。
- 不 import 其他 feature 的 presentation;桌面壳经 `shell` 的 `DesktopTabShell`/`ShellDeferredContent`(全 tab 统一模式)。

## 陷阱与决策
- 「数据导出/AI 隐私」入口在本页 `presentation/widgets/sections/ai_privacy.dart`,页面本体属 settings——导出与 FAQ 逻辑不要写进 mine。
- 完成度按「有用」而非「有值」计,`onboardingCompleted` 暂不纳入(无真实引导流程写入方;口径见 `data/repositories/lucent.dart` 注释)。
- wire enum 的展示文案统一走 `presentation/utils/health_enum_l10n.dart`,勿在页面内直接渲染英文 wire 值。
