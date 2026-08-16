# 平台 / 通知 / 横切能力改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `Luminous/research/02-功能盘点/platform-通知与横切能力.md`(已审阅;内容以逐功能分析为准改写,速览表仅作参考;该调研文档无结尾汇总章节)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 1 位。

## 一、目标与范围

范围:Luminous 侧 `lib/features/notification/`、`lib/features/health_data/`、`lib/features/shell/`、`lib/core/notifications/`、`lib/core/push/`、`lib/core/shortcuts/`、`lib/core/analytics/`,另涉及 `lib/features/medicine/` 提醒协调器与投递历史 UI、`lib/features/settings/` 隐私/权限接线;Lucent 侧 `src/modules/notifications/`、`src/modules/environment/`、`src/modules/product-events/`,另涉及 `src/modules/medicine-reminders/` 调度器与 `src/common/queue/cron-jobs.service.ts`。

目标:本计划是横切能力的所有者,完成四项改造——

- (a) F-7 环境快照接口真实化(高德天气/空气 API + Redis 小时级缓存 + 手动选城市 + 注册为助手工具 + 可选记录上下文快照);
- (b) F-4 提醒投递记录三通道(`in_app`/`local`/`push`)落库改造,**F-2 本地通知回执与 F-3 push 结果记录均收敛在本项,不重复立项**;
- (c) F-3 JPush 密钥入部署(运维补齐);
- (d) F-6 health_sync 自动同步执行器。

F-9 不扩展 Flutter Desktop/PC Flutter Web 产品面；独立 Next.js + Tauri MVP 在 0.1.0 后启动，本计划不展开。

## 二、保留不动(清单)

- F-1 通知收件箱(列表/详情/未读数):真实现,客户端直连生成 API + 服务端 Prisma 真实 CRUD,未登录语义诚实。
- F-2 本地通知调度网关:真实现,调度/取消/重排/权限门控链路完整;其"无投递回执"问题并入 F-4 改造项处理。
- F-5 健康平台手动导入(HealthKit / Health Connect):真实现,指纹去重 + 真实写入 + 显式失败;仅两处小瑕疵列入附带修复(见 P2)。
- F-8 产品事件埋点与漏斗:真实现,幂等/白名单/小样本抑制齐备；消费面移入 0.1.0 后 TODO。
- F-9 App 壳与快捷键:真实现;桌面/Web 形态走向挂起,引用 `2026-08-14-product-surface-route.md`。

## 三、改造项(按优先级分组)

### P1

#### 1. F-7 环境快照接口真实化(Lucent environment 模块重写，0.1.0 后)

- 现状:`GET /api/v1/environment/snapshot?lat&lon` 返回六个硬编码纬度带 profile,`dataSource: 'static'`、`updatedAt` 写死 `2026-06-06`(`Lucent/src/modules/environment/config/reference.ts:8,23-191`),service 仅转发(`services/snapshot.service.ts:11-22`);客户端零调用,无任何消费方,Today 环境卡片文案(`lib/l10n/src/today_zh.arb:10,143-153`)为无 Dart 引用的死字符串。
- 改造方案:
  - 后端 environment 模块重写:以高德天气/空气 API 客户端替换静态 reference,响应改为 `dataSource: 'real'` + 动态 `updatedAt`;接入 Redis 小时级缓存(按城市 key,避免重复计费与限流);高德 key 走环境变量配置,不硬编码。
  - 花粉/紫外线字段高德免费接口不含,响应中显式标注"未实现",不得沿用静态编造值。
  - 城市来源改为用户手动选择(免定位权限),客户端需提供城市选择入口并持久化选择。
  - 消费面:注册为 AI 助手工具(Lucent 侧 tool.service 增加 environment 工具);可选作为记录上下文快照写入;**不做 Today 主卡**。
  - 模块代码与 Luminous 侧环境相关死字符串保留，0.1.0 后随真实数据源装配。
  - 同步修正 `docs/00-current/Mock_Or_Deferred.md` 中环境上下文连线条目的延后表述。
- 前后端分工:Lucent——API 客户端、Redis 缓存、snapshot service 重写、助手工具注册;Luminous——城市选择 UI 与持久化、可选记录上下文快照接线;死字符串不删不接。
- 依赖:高德开放平台 key(运维);助手工具消费面与 assistant 计划(第 5 位)、记录上下文快照与 record 计划(第 6 位)衔接。

#### 2. F-4 提醒投递记录三通道落库(含 F-2 回执、F-3 push 结果记录，0.1.0 前)

- 现状:调度器每分钟 BullMQ 任务只写 `channel: 'in_app'`、`status: 'delivered'` 一种行(`Lucent/src/modules/medicine-reminders/services/scheduler.service.ts:15-18,262-272`);push 发送(同文件 :279-283)与本地通知展示均不落投递行;客户端为 `local/push/email/sms` 备了本地化标签(`lib/features/medicine/presentation/utils/reminder_formatters.dart:92-100`),真正出现的 `in_app` 却落入 `_ => value` 原样显示英文。
- 改造方案(一次改造覆盖三条通道,F-2/F-3 不另立项):
- 后端与客户端共同保证「一个事件最多一次打扰」：前台仅应用内提示；后台本地通知优先，失败或不可达才 JPush；站内信只保留记录、不再额外弹出。本地通知展示后以稳定通知实例 ID 幂等回写 `channel: 'local'`、`status: 'delivered'`；JPush 仅在本地失败/不可达时按结果写入 `channel: 'push'` 行。
  - 前端:`deliveryChannelLabel` 补 `'in_app' → 应用内通知` 等通道标签翻译;`local/push/email/sms` 标签保留为真实通道展示位;状态侧 `scheduled/failed` 标签随真实数据出现自然生效。
  - 文档:修正 `docs/00-current/Mock_Or_Deferred.md:59` 的过时描述(in_app 行已在写入,非"尚未写入")。
  - 提醒详情页"提醒投递历史"面板本身保留不动。
- 前后端分工:Lucent——scheduler 补 push/local 落库、投递写入接口;Luminous——本地通知回执上报、通道标签 l10n(走 `lib/l10n/src/` 片段 → `dart scripts/arb_tools.dart merge` → `flutter gen-l10n` 流程)。
- 依赖:本地回执上报依赖 F-2 现有 `LocalNotificationGateway` 的通知回调能力;F-3 push 结果记录依赖 push 发送返回值已在调度器内可取。

#### 3. F-3 JPush 密钥补齐(运维项，0.1.0 前发布门槛)

- 现状:双端密钥均来自环境变量,缺省时全链路静默 no-op(客户端 `lib/core/push/jpush_gateway.dart:41`,服务端 `Lucent/src/modules/notifications/services/jpush.provider.ts:26-27`);`Lucent/deploy/` 内无任何 JPUSH 配置痕迹,当前部署大概率从未真正发出过推送。代码链路本身真实,属运维缺口。
- 改造方案:`Lucent/deploy/` 部署配置补齐 `JPUSH_APP_KEY` / `JPUSH_MASTER_SECRET`；客户端侧 appKey 配置核对。密钥不得入库硬编码，遵循 Safety 规则走部署密钥管理。密钥配置、真机到达、未读数刷新与 `/notifications` 跳转闭环缺任一项均不得发布。
- 前后端分工:纯运维/部署侧,无业务代码改动;补完后验证"推送到达 → invalidate 未读数 → 跳转 `/notifications`"闭环(`lib/core/push/message_handler.dart:35-48`)。
- 依赖:JPush 账号与密钥;可与 F-7 高德 key 合并进同一份上线密钥 checklist。

### P2

#### 4. F-6 health_sync 自动同步执行器（0.1.0 后）

- 现状:设置页"健康数据自动同步"开关无任何执行器消费;执行器配置位硬编码 `false`(`lib/features/health_data/presentation/providers/health_auto_sync.dart:29`),availability 恒 `notConfigured`、开关恒禁用显示"未配置"(`lib/features/settings/presentation/widgets/privacy_section.dart:34-43,124-137`);`PrefKeys.healthAutoSyncEnabled` 无消费方,存在"改成 true 即成纯假开关"的潜在陷阱。
- 改造方案(已决策,改为可选执行器):
- 引入 workmanager 周期任务(每日一次)+ App 启动时前台增量同步，复用现有 `health_sync` 真实导入逻辑；首次回补最近 30 天，后续从上次成功点增量拉取。
  - 默认关闭;首次开启给一次性授权解释文案。
  - iOS 上 workmanager 走 BGTaskScheduler、后台窗口受限,以"启动时同步"为主、周期任务为辅。
  - 平台导入数据带 source 来源标签,覆盖率统计区分"平台来源/手记来源","平台无数据"不等于"未记录"。
  - 同步消除上述假开关陷阱:执行器未真实接线前不得放开 `executorConfigured`。
- 前后端分工:全部在 Luminous;source 标签与覆盖率口径影响记录/统计域,需与 record 计划(第 6 位)对齐。
- 依赖:F-5 手动导入链路(保留项,直接复用);workmanager 插件接入与 iOS BGTaskScheduler 配置。

#### 5. F-5 附带小瑕疵修复(随本计划顺手处理，0.1.0 前)

- 现状:预览页指标标题硬编码中文绕过 l10n(`lib/features/health_data/presentation/pages/health_sync.dart:381-409`);`HealthMetricType.height` 实体存在但 UI 类型列表不可选。
- 改造方案:硬编码标题迁入 `lib/l10n/src/` 片段(走标准 ARB 流程);height 补入 `_MetricTypeSection` 可选项或从实体列表移除,二选一保持一致。
- 前后端分工:Luminous 单侧。
- 依赖:无。

## 四、跨计划引用与依赖

- 本计划为全局第 1 位,以下横切内容在本文档写全,其他计划只引用:F-7 天气真实化方案、F-4 投递记录三通道落库、F-3 JPush 密钥补齐、F-6 自动同步执行器。
- F-7 消费面外溢:助手工具注册涉及 assistant 计划(第 5 位);记录上下文快照涉及 record 计划(第 6 位)——两处只接线,方案以本文档为准。
- F-6 source 来源标签与覆盖率统计口径影响 record(第 6 位)/ report(第 8 位)域,口径以本文档为准。
- F-4 改造的调度器代码位于 `medicine-reminders` 模块,与 medicine 计划(第 2 位)有文件级交集;投递记录改造范围以本文档为准,medicine 计划不重复立项。
- F-9 桌面/Web 形态:Flutter Desktop 与 PC Flutter Web 不再扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动，本文不重复展开。
- 上线密钥 checklist:F-3(JPUSH)与 F-7(高德)同属"密钥缺失即静默 no-op"运维缺口,合并处理。

## 五、本计划内执行顺序

1. F-3 JPush 密钥补齐（0.1.0 前发布门槛）与 F-4 投递记录三通道落库（0.1.0 前）：先本地通知回执与幂等落库，JPush 仅作本地失败/不可达的后台回退。
2. F-5 附带小瑕疵（0.1.0 前，随时穿插）。
3. F-7 环境模块真实化（0.1.0 后）：后端 API + 缓存先行 → 城市选择 UI → 助手工具注册。
4. F-6 自动同步执行器（0.1.0 后）：依赖 F-5 保留链路。

## 六、已决边界与延期项

- 环境真实化与 health_sync 自动同步均标为 0.1.0 后；环境仅用户手选城市的真实天气/AQI 上下文，不使用定位、IP 或默认城市，不采集或展示花粉、UV，也不作为 Today 主卡。
- 本地通知优先，JPush 只作后台本地失败/不可达回退；通知中心仅记录。同一用药或建议升级事件最多一次打扰。
- 漏斗消费面移入 0.1.0 后 TODO，目标为受保护的周报或简表，不建设实时 Admin Dashboard。
- 桌面高级能力冻结；独立 Next.js + Tauri MVP 在 0.1.0 后启动。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
