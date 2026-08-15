# 通知 / 健康平台同步 / 壳与横切能力 功能盘点与审计

> 范围：
> Luminous —— `lib/features/notification/`、`lib/features/health_data/`、`lib/features/shell/`、
> `lib/core/notifications/`、`lib/core/push/`、`lib/core/shortcuts/`、`lib/core/analytics/`
> （另涉及 `lib/features/medicine/` 的提醒通知协调器与投递日志 UI、`lib/features/settings/` 的隐私/权限接线）；
> Lucent —— `src/modules/notifications/`、`src/modules/environment/`、`src/modules/product-events/`
> （另涉及 `src/modules/medicine-reminders/` 调度器、`src/common/queue/cron-jobs.service.ts`）。
> 参考文档：`Luminous/docs/01-product/Product_Vision.md`、`docs/00-current/Mock_Or_Deferred.md`、
> `docs/00-current/Active_Mobile_UI.md`、`Luminous/plans/2026-07-29-native-bridging-roadmap.md`（按计划视为已执行）。

## 功能点总览

| 功能点 | 一句话作用 | 真伪 | 结论 | 优先级 |
|---|---|---|---|---|
| F-1 通知收件箱（列表/详情/未读数） | 后端站内信的拉取、已读/删除管理与跳转 | 真实现 | 保留 | P0 |
| F-2 本地通知调度网关 | 用药提醒在设备端的本地定时通知 | 真实现 | 保留 | P0 |
| F-3 远程推送链路（JPush） | 服务端按用户 alias 推送到离线设备 | 部分实现 | 保留 | P1 |
| F-4 提醒投递历史 | 提醒每次投递的审计行展示 | 部分实现 | 改造 | P1 |
| F-5 健康平台手动导入 | 从 HealthKit/Health Connect 拉数据写入日常记录 | 真实现 | 保留 | P1 |
| F-6 健康数据自动同步开关 | 设置页"进入前台自动同步"开关 | 假实现（已被诚实禁用兜底） | 改造 | P2 |
| F-7 环境快照接口（Lucent） | 按纬度带返回花粉/UV/AQI/温湿度 | 静态桩（已决策真实化） | 改造 | P1 |
| F-8 产品事件埋点与漏斗 | 客户端/服务端事件采集 + 管理端漏斗聚合 | 真实现 | 保留 | P1 |
| F-9 App 壳与快捷键 | 五 Tab 壳、桌面侧栏、键盘快捷键 | 真实现 | 保留 | P2 |

## 逐功能分析

### F-1 通知收件箱（列表 / 详情 / 未读数）

- 现状：Mine 页顶栏铃铛与通知区、桌面侧栏入口进入 `/notifications`；分页列表按"今天/昨天/更早"分组，支持已读/未读切换、删除、全部已读、加载更多；详情页自动标记已读并可按 `action` 跳转。
- 实际作用：这是产品核心闭环（提醒 → 主动建议 → 用户确认）的触达界面。后端生产者是真实的：用药提醒调度器（`Lucent/src/modules/medicine-reminders/services/scheduler.service.ts:238`）、Today 建议升级（`Lucent/src/modules/today-suggestion/services/notification/escalation.service.ts:100` 附近）、today-analysis、auth（改密/ OAuth 登录/身份绑定）、data-export 完成通知。
- 实现真实性：真实现。客户端仓储直连生成 API（`Luminous/lib/features/notification/data/repositories/lucent.dart:27-86`），服务端为 Prisma 真实 CRUD（`Lucent/src/modules/notifications/services/notifications.service.ts:106-188`）。未发现占位填充或 unknown→0 映射；未登录时未读数走 `pendingAuthSessionResolution()`（永不了结的 Future），UI 按无数据处理不显示角标（`Luminous/lib/features/notification/data/providers/unread_count.dart:15-20`），语义诚实。
- 结论：保留。
- 仍需修的小问题：无大问题。`notificationUnreadCountProvider` 是前台拉取式，轮询/刷新依赖页面进入与失效，无服务端推送增量刷新——与 F-3 的"收到推送即 invalidate 未读数"已形成基本闭环，可接受。
- 优先级：P0。

### F-2 本地通知调度网关

- 现状：`LocalNotificationGateway` 封装 `flutter_local_notifications`，`zonedSchedule` 精确/非精确调度自动降级；消费者是用药提醒协调器，按提醒设置整体重排（先取消旧 id 再排新）。
- 实际作用：无网/离线也能响的用药提醒，是"用药安全可信入口"最底线的触达能力。
- 实现真实性：真实现。调度与取消均真实调用插件（`Luminous/lib/core/notifications/local_notification_gateway.dart:56-127`），重排链路完整（`Luminous/lib/features/medicine/presentation/providers/reminder_notification_coordinator.dart:30-97`），并受通知权限与"用药提醒"设置开关门控（同文件 :122-196）。权限服务也是真实插件调用（`Luminous/lib/features/settings/domain/services/notification_permission.dart:69-154`）。
- 结论：保留。
- 小问题：本地通知的实际展示没有回执——设备端"是否真的弹了"无任何记录（见 F-4）。
- 优先级：P0。

### F-3 远程推送链路（JPush）

- 现状：客户端 `JpushGateway` 包装 jpush_flutter，登录后以 userId 绑定 alias，冷启动读取 launch notification 并路由；服务端 `JpushPushProvider` 直调 JPush REST v3，`PushDeliveryService` best-effort 发送。
- 实际作用：服务端提醒（用药提醒、建议升级）能触达被杀进程的用户。
- 实现真实性：部分实现（链路真实、接通面不完整）。
  - 客户端接线真实（`Luminous/lib/core/push/jpush_gateway.dart:55-93`、`lifecycle.dart:47-70`），bootstrap 真实调用（`Luminous/lib/app/bootstrap.dart:83,157-162`）；消息处理会失效未读数并跳转 `/notifications`（`Luminous/lib/core/push/message_handler.dart:35-48`）。
  - 服务端真实 HTTP 调用（`Lucent/src/modules/notifications/services/jpush.provider.ts:71-91`），失败仅记日志不阻塞（`push-delivery.service.ts:23-37`）。
  - 不完整处：① 双端密钥都来自环境变量，缺省时全链路静默 no-op（客户端 `jpush_gateway.dart:41`，服务端 `jpush.provider.ts:26-27`），而 `Lucent/deploy/` 内无任何 JPUSH 配置痕迹——当前部署大概率从未真正发出过一条推送；② 推送结果（成功/失败/到达）不进任何投递记录，见 F-4。
- 结论：保留。属运维缺口（密钥未入部署），上线前补齐即可，非代码造假。
- 小问题：部署环境补齐 `JPUSH_APP_KEY`/`JPUSH_MASTER_SECRET` 前，该能力对外等于不存在；这不构成"假宣传"，因为 UI 没有任何地方声称推送可用。
- 优先级：P1。

### F-4 提醒投递历史

- 现状：提醒详情页"提醒投递历史"面板（`Luminous/lib/features/medicine/presentation/pages/reminder/detail.dart:295`），数据来自 `GET /reminder-deliveries`（`Lucent/src/modules/medicine-reminders/reminder-deliveries.controller.ts:20-44`）。
- 实际作用：让用户核对"这条提醒到底发没发"。
- 实现真实性：部分实现。
  - 真实部分：调度器每分钟 BullMQ 任务真实写入投递行（`Lucent/src/modules/medicine-reminders/services/scheduler.service.ts:262-272`，先建站内信再建行，失败不留行以便重试），`cron-jobs.service.ts:135` 真实注册。
  - 失真部分：后端只会写 `channel: 'in_app'`、`status: 'delivered'` 一种行（`scheduler.service.ts:15-18`）。push 发送（同文件 :279-283）不产生任何投递行；SMS/email 通道在全代码库不存在任何 worker。而客户端为 `'local'/'push'/'email'/'sms'` 四个永不出现的通道备好了本地化标签（`Luminous/lib/features/medicine/presentation/utils/reminder_formatters.dart:92-100`，`lib/l10n/src/medicine_zh.arb:346-349`），真正出现的 `'in_app'` 却落入 `_ => value` 原样显示——用户看到的是英文字符串 "in_app"。
  - 状态侧同样：`'scheduled'/'failed'` 标签永不出现（失败路径重试而不落行）。
  - 文档漂移：`docs/00-current/Mock_Or_Deferred.md:59` 称"Worker 填充的提醒投递历史……尚未写入"已过时——in_app 行已在写入。
- 结论：改造。
- 改造方案：后端 scheduler 已落站内信（UserNotification），补 push 与本地投递的 `reminderDelivery` 落库——调度器里 push 发送后按结果补写 `channel: 'push'` 行（成功 delivered / 失败 failed），本地投递同样落库，列表即有真实数据；`deliveryChannelLabel` 增加 `'in_app' → 应用内通知` 等通道标签翻译（local/push/email/sms 标签保留为真实通道展示位）；把 `Mock_Or_Deferred.md` 的过时描述修正为现状。历史面板本身（按时间列出已投递事实）符合"可追溯证据"主张，保留。
- 优先级：P1。

### F-5 健康平台手动导入（HealthKit / Health Connect）

- 现状：Mine 页"账号与安全"区进入 `/health-sync`，选数据类型 + 时间范围（今天/3 天/7 天）→ 请求平台权限 → 预览（最多 20 条）→ 确认导入，结果页显示成功/跳过/失败计数。
- 实际作用：稀疏记录语义下最有价值的数据来源之一——把平台已有的步数/睡眠/心率变成记录，减少手工录入负担，直接服务"不把完整手工记录当产品成立前提"。
- 实现真实性：真实现。`health` 插件真实调用权限与读取（`Luminous/lib/features/health_data/data/datasources/health_platform.dart:71-184`），导入经指纹去重后真实写入 `DailyRecordRepository` 并发 DataChangeBus（`data/repositories/health_sync.dart:62-104`、`presentation/providers/health_sync_controller.dart:71-87`）；去重失败会中止导入而不是静默造重复数据（`health_sync.dart:148-155`），权限被拒/平台不可用均有显式状态。`pubspec.yaml:73` 依赖真实存在。
- 结论：保留。
- 小问题：预览页指标标题硬编码中文（`presentation/pages/health_sync.dart:381-409`），绕过 l10n；`HealthMetricType.height` 在页面类型列表中出现但 `_MetricTypeSection` 未列出可选项（实体里有、UI 不可选），属一致性小瑕疵。
- 优先级：P1。

### F-6 健康数据自动同步开关

- 现状：设置 → 隐私区"健康数据自动同步"开关，副标题宣称"App 进入前台时自动同步最近 24 小时的健康数据"。
- 实际作用：零。没有任何前台/后台执行器读取这个偏好。
- 实现真实性：假实现，但被诚实的禁用逻辑兜住了——
  - 执行器配置位硬编码 `false`：`Luminous/lib/features/health_data/presentation/providers/health_auto_sync.dart:29`（`bool healthAutoSyncExecutorConfigured(Ref ref) => false;`）。
  - 由此 availability 恒为 `notConfigured`，开关恒禁用、副标题显示"未配置"文案（`lib/features/settings/presentation/widgets/privacy_section.dart:34-43,124-137`），`toggle()` 在非 available 时直接 return（`health_auto_sync.dart:67-76`），`build()` 强制 false（:53-60）。
  - `PrefKeys.healthAutoSyncEnabled` 全代码库只有该 provider 自己读写（`lib/core/config/pref_keys.dart:128`），无任何消费方——即使将来有人把 `executorConfigured` 改成 true 而没有真接执行器，开关会变成"可打开但什么都不做"的纯假开关（潜在陷阱）。
- 结论：改造。
- 改造方案（已决策）：改为可选执行器——引入 workmanager 周期任务（每日一次）+ App 启动时前台增量同步，复用现有 `health_sync` 真实导入逻辑（指纹去重已实现），按平台授权增量拉取；默认关闭，首次开启给一次性授权解释文案；iOS 上 workmanager 走 BGTaskScheduler、后台窗口受限，以"启动时同步"为主、周期任务为辅；平台导入数据带 source 来源标签，覆盖率统计区分"平台来源/手记来源"，"平台无数据"不等于"未记录"。该产品主张"优先使用既有数据而非要求手工记录"，前台自动同步对稀疏记录场景价值真实。
- 优先级：P2。

### F-7 环境快照接口（Lucent environment 模块）

- 现状：`GET /api/v1/environment/snapshot?lat&lon`，公开接口，按纬度带返回花粉等级、UV 指数、AQI、温湿度。
- 实际作用：零。无任何消费方。
- 实现真实性：静态桩，已决策真实化——
  - 返回体是六个硬编码 profile，`dataSource: 'static'`，`updatedAt` 写死 `2026-06-06`（`Lucent/src/modules/environment/config/reference.ts:8,23-174,176-191`）；service 只是转发（`services/snapshot.service.ts:11-22`）。没有任何真实天气/花粉/AQI API 接入。
  - 客户端零调用：`Luminous/lib` 全局搜索无任何 environment/snapshot 消费代码；Today 环境卡片的整套字符串（`lib/l10n/src/today_zh.arb:10,143-153`，含"今天空气中花粉较多，建议外出佩戴口罩"）只有 ARB 定义、无任何 Dart 引用，是死字符串。
  - 侥幸之处：正因为没接线，这条假数据目前不会到达任何用户；一旦按原文案接上 Today 卡片，就是"把 2026-06-06 的编造花粉数据当成今日事实"的典型假实现，且带健康建议性质，风险高。
- 结论：改造。
- 改造方案（已决策）：后端 environment 模块重写——静态 reference 替换为高德天气/空气 API 客户端 + Redis 小时级缓存，`dataSource:'real'`、动态 updatedAt，key 走环境变量配置不硬编码；城市来源用户手动选择（免定位权限）；花粉/紫外线字段高德免费接口不含，标注"未实现"；消费面注册为助手工具（tool.service 增加 environment 工具），可选作为记录上下文快照，不做 Today 主卡；同步修正 `Mock_Or_Deferred.md` 里环境上下文连线条目的延后表述。模块代码与 Luminous 侧环境相关死字符串保留，等待真实数据源装配。
- 优先级：P1。

### F-8 产品事件埋点与漏斗

- 现状：客户端在四个真实成功边界上报事件（建议卡曝光、回顾页打开、就诊摘要预览/导出），离线进 pending_sync 队列、按 clientEventId 幂等重放；服务端另有 health-event 开始/结束、check-in、suggestion actioned、分享打开等服务端事件。读取面是 `GET /product-events/funnel`（AdminGuard，JWT 邮箱须等于 `ADMIN_EMAIL`）。
- 实际作用：验证"记录→建议→确认→回顾"核心漏斗是否成立的唯一度量手段——对竞赛转真实产品的阶段，这是判断产品生死的基础设施。
- 实现真实性：真实现。客户端（`Luminous/lib/core/analytics/product_event_service.dart:135-204`）fire-and-forget + 队列重放；调用点真实分布于 today 建议卡、report 页、导出动作（如 `lib/features/today/presentation/widgets/sections/suggestion_primary_card.dart:260`）。服务端写入幂等、防未来时间戳、规则码白名单（`Lucent/src/modules/product-events/services/events.service.ts:84-199`）；漏斗为纯聚合 SQL，小样本抑制（`services/funnel.service.ts:22,148-209`）。隐私设计（枚举封闭、无自由文本）与"证据可追溯"主张一致。
- 结论：保留。
- 小问题：漏斗的消费方式是"管理员拿 admin JWT 手动查 API"，没有面板或定期报表；埋点价值取决于是否真的有人看。`suggestion_impression` 的七个白名单规则码是双端各维护一份（`product_event.dart:9-17` 与 Lucent 常量），存在漂移风险，但服务端会 400 拒绝未知码，属于可接受的显式失败。
- 优先级：P1。

### F-9 App 壳与快捷键

- 现状：五 Tab `StatefulShellRoute` 壳，移动端底栏 + 桌面侧栏，`ShellDeferredContent` 延迟一帧构建重 tab；`core/shortcuts` 提供 Ctrl/Cmd+K/N/,/Shift+A/1-5 键盘快捷键。
- 实际作用：基础导航骨架。
- 实现真实性：真实现（`Luminous/lib/features/shell/presentation/page.dart`、`branch.dart`、`tab.dart`、`deferred_content.dart`、`desktop_tab_shell.dart`；`lib/core/shortcuts/shortcuts.dart:19-115`）。快捷键在移动端无键盘场景自然不生效，不是伪装功能。现有 Flutter 桌面端当前冻结，但未来是否以 Next.js Web + Tauri 2 承担大屏纵向阅读仍待独立调研，因此此处只记录现状，不作永久删除判断。
- 结论：保留。
- 小问题：无。
- 优先级：P2。

## 模块级结论

这一组横切能力整体质量高于预期：**通知收件箱、本地通知、手动健康导入、产品埋点四条主链路都是真实现**，且普遍带有幂等、去重、显式失败、隐私最小化等成熟设计；它们恰好构成愿景里"在合适时间主动提醒"和"验证核心漏斗"的地基，应全部保留。

两个必须处理的失真点：

1. **F-7 环境模块当前是静态桩**——静态硬编码 + 伪造的 `updatedAt`，且自带"花粉多请戴口罩"式健康建议文案。它今天无害只是因为没人接线；已决策真实化——接高德天气/空气 API（城市手动选择、免定位权限），花粉/紫外线字段标注"未实现"，前端以"环境上下文"进入助手工具与记录上下文，不作为主卡。改造，不删除。
2. **F-4 投递历史的多通道 UI 是假多样性**——四个通道标签、三个状态标签里，各只有一个会被使用，且真正使用的 `in_app` 反而没有翻译、原样裸奔。要么补 push 投递记录，要么砍掉死标签。

一处诚实但悬空的半成品：**F-6 自动同步开关**被 `executorConfigured => false` 正确禁用，没有欺骗用户，但"永久禁用的设置项 + 无人消费的偏好键"本身就是负债；已决策改为可选执行器——引入 workmanager 周期任务（每日一次）+ App 启动时前台增量同步，复用现有 health_sync 导入逻辑，默认关闭、首次开启给一次性授权解释。

冗余与缺口：投递链路的缺口在"push/本地通知无送达回执"（用户无法核对推送是否真发出）；JPush 密钥未进入部署配置，使 F-3 在当前环境形同未启用——这是运维缺口而非代码造假（上线前补齐部署密钥即可），但决定推送能力何时真实存在。文档侧 `Mock_Or_Deferred.md` 关于投递历史"尚未写入"的描述已过时，需随 F-4 一并修正。
