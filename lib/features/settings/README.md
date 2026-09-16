# lib/features/settings — 设置

一句话:偏好与配置聚合(语言/主题/通知/勿扰/AI/导出/存储等),混合远程 UserSettings 与本地 SharedPreferences 两类状态。

## 职责与边界

- 管:user settings 的读/patch(ADR-0003 authGuarded)、本地通知偏好与权限状态、数据导出请求、离线保留期/图片质量偏好、睡眠提醒本地通知协调(application/)、语言/时区/单位偏好经 health-context profile 回写后端、semver 比较服务。
- 不管:药品提醒排程(medicine)、账号资料字段编辑(mine)、推送通道与消息展示(notification)。

## 对外契约

- 路由(presentation/routes.dart):`Routes.settings` 与 language / theme / more(含 /more/feature-flags) / notifications(含 /sleep、/dnd) / accessibility / ai / export / help / about / data-storage 子路由。
- 导出(被跨 feature import):presentation/providers/user_settings.dart、data_export.dart、data_storage.dart、notification.dart,data/providers/notification_permission.dart。
- 被依赖:today/review 读 user_settings(review 另读 data_export);mine 读 notification;core 读 user_settings(sensitive_action_password_resolver)、notification_permission(push/lifecycle)、data_storage(database/cache_cleanup);app/bootstrap.dart 启动睡眠提醒协调器。

## 不变量

- user settings patch:失败保留旧值并抛 `LucentFailure` 供 UI toast 回滚,不得置 AsyncLoading 闪骨架;成功后 emit `DataChangeTopic.userSettings`。
- 本地通知 ID 段互斥:睡眠提醒基址 2_100_000,药品提醒 2_000_000,新增基址不得重叠。
- 通知设置 controller 的远程 mutation 串行执行(_remoteMutationTail);本地偏好写入失败不得中断 UI 流程。

## 依赖禁区

- data 层不 import 其他 feature;profile_remote.dart 直用 Dio(取自 `lucentDioClientProvider`)写 profile 偏好是 transport-only 例外,不得扩散为通用模式。

## 陷阱与决策

- 个人信息页(`presentation/pages/profile.dart`)是「左标签 / 右当前值 / 点击进编辑」的分组列表:页面不内联常驻输入框、也没有整体保存按钮;每个健康字段由单字段 sheet 独立提交,只发送被改动的那一个(其余保持 `healthContextNoChange`)。
- 身高/体重滚轮(`widgets/shared/quantity_sheet.dart`)的取值可能被 clamp 到滚轮边界(旧数据越界,如 260cm 超过 250 上限)。clamp 命中时必须把边界值**同步写回** `slot`,否则用户不动滚轮直接确认会把越界值原样回写。反向约束同样重要:只在真正越界时回写——滚轮按整数取值,无条件回写会让每次打开 sheet 都轻微改写用户当前值(60kg 会变成 132lb 折回的 59.87kg)。`imperial` 在 sheet 打开后视为不可变(late final `_indexes`),要支持切换需走 `didUpdateWidget`。
- 头像与昵称只在个人信息页可改;账号管理页(`/account`)与账号安全中心只跳转过来,不复制概要卡片或第二份编辑入口。
- 本目录刻意无厚 domain:业务规则限于表单校验与偏好持久化,datasource 直接映射生成 DTO(profile_remote.dart 头注);本地偏好键统一走 PrefKeys。
- 桌面端 master-detail 双栏(presentation/widgets/master_detail.dart);About 页用 domain/services/version_check.dart 做更新比较。
- 决策:authGuarded 工厂见 ../../../docs/reference/adr/0003-riverpod-generator-and-auth-guard.md。
