# Medicine 用药管理模块 功能盘点与审计

> 范围：`Luminous/lib/features/medicine/`（presentation/data/domain 全层）＋联动页面
> `Luminous/lib/features/mine/presentation/pages/current_medicine_edit.dart`、`Luminous/lib/features/search/`（仅引用）；
> 后端 `Lucent/src/modules/medicine-reminders/`、`medicine-dose-logs/`、`medicines/`（含 risk/ 子目录）；
> 数据资产 `DrugDataBase/`（`ChineseDrugData_Master_V2.xlsx`、`drugbank_all_full_database.xml.zip` 等）。
> 参考文档：`Luminous/docs/01-product/Product_Vision.md`、`Luminous/docs/00-current/Active_UI_Medicine.md`、
> `Mock_Or_Deferred.md`、`Runtime_Snapshot.md`、`Lucent/docs/00-current/Active_Product_Loop.md`、
> `Lucent/docs/01-reference/contracts/data-sources*.md`。
> 计划文件按规则视为已执行完毕，仅按设计意图评估产品价值。
> 边界：扫码/搜索/加入药箱见 `02-功能盘点/scan-search-扫码与搜索.md`；本地通知网关/JPush/投递历史见
> `02-功能盘点/platform-通知与横切能力.md`；Today 建议卡/漏服规则/快速确认见 `02-功能盘点/today-今日建议.md`；
> 队列/Cron/LLM 底座见 `02-功能盘点/engineering-工程与后端平台.md` —— 本文件只审计用药模块专属功能点，交叉处引用结论。

## 功能点总览

| 功能点 | 一句话作用 | 真伪 | 结论 | 优先级 |
|---|---|---|---|---|
| F-1 用药主页四区块 dashboard | 当前用药盒/今日服用计划/安全摘要/操作四区，全部由真实 API 组装 | 真实现 | 保留 | P0 |
| F-2 药箱管理（药品档案） | currentMedicines 建档，Mine 档案增/改/删，无分组概念 | 真实现 | 保留 | P0 |
| F-3 今日计划 slot 打卡（已服/跳过） | mark API 按 reminder 槽位真实落库，slot 独立不聚合 | 真实现 | 保留 | P0 |
| F-4 剂量日志（落库+缓存+离线队列） | 后端 CRUD/mark 持久化，客户端 cache-first + pending sync 重放 | 真实现 | 保留 | P0 |
| F-5 依从性/今日剂次 Hero 指标 | 客户端按今日槽位自行计算，未接后端 observed metric 合同 | 部分实现 | 改造 | P1 |
| F-6 提醒创建/编辑/启停/删除 | 多时间槽提醒组，后端真实持久化 + 启停事件联动风险检查 | 真实现 | 保留 | P0 |
| F-7 本地通知同步调度 | 按提醒计划 7 天 horizon 重排本地通知，随设置/提醒变更 resync | 真实现 | 保留 | P0 |
| F-8 后端提醒调度与投递 | BullMQ 每分钟 cron，时区/星期/日期窗口判定，写 in-app 通知+投递记录+best-effort 推送 | 真实现 | 保留 | P0 |
| F-9 提醒投递历史（只读） | 详情页展示投递审计行，数据来自真实 userReminderDelivery | 部分实现 | 改造 | P2 |
| F-10 风险检查·静态规则引擎 | 过敏/相互作用/重复成分/食物相互作用/覆盖缺口/红旗，规则引擎真实执行 | 真实现 | 保留 | P0 |
| F-11 风险检查·LLM 分析 | 静态基线 + LLM 结构化输出，未配置显式 503，stale 如实标记 | 真实现 | 保留 | P1 |
| F-12 风险检查自动触发 | 健康上下文/提醒变更事件 → 标 stale + 5s debounce 自动静态检查 | 真实现 | 保留 | P0 |
| F-13 用药安全摘要卡（主页） | 风险等级/指标/告警芯片，数据全部来自后端检查记录 | 部分实现（告警数据恒空） | 改造 | P0 |
| F-14 药品详情与说明书 | 移动端无任何药品详情页，cn/drugbank 详情数据无消费出口 | 功能缺失 | 新建 | P1 |
| F-15 快捷操作区（4 入口） | 导航到添加/搜索/提醒/风险检查 | 真实现 | 保留 | P2 |
| F-16 safety tips（后端 API+客户端 provider） | 随机安全提示接口，客户端 provider 无任何 UI 消费方 | 死代码 | 改造/归档 | P2 |
| F-17 workspace 死字段 | promisePoints/alerts/metricDosesToday 从不渲染 | 死代码 | 改造/归档 | P2 |
| F-18 DoseLogStatus.missed 死枚举 | 前后端均无写入方，仅 UI switch 分支残留 | 死代码 | 改造/归档 | P2 |
| F-19 处方导入入口 | 仅 Toast 提示延后，无功能 | 假实现（诚实占位） | 改造 | P2 |
| F-20 SMS 提醒通道 | 设置行灰显"不可用"，无后端能力 | 部分实现（诚实降级） | 保留 | P3 |
| F-21 与 Today 建议卡联动 | 剂量日志事件驱动建议重算，漏服卡消费 reminder 槽位（见 `today-今日建议.md`） | 真实现 | 保留 | P0 |

## 逐功能分析

### F-1 用药主页四区块 dashboard

- 现状：`MedicinePage`（`medicine/presentation/pages/page.dart`）在 `DesktopTabShell`/移动壳内渲染
  `MedicineMobileDashboardView` 四区：当前用药盒（`mobile_drugbox.dart`）、今日服用计划（`mobile_records.dart`）、
  用药安全摘要（`mobile_safety.dart`）、用药操作（`mobile_quick_operations.dart`）。未登录走 `signedOutWorkspace`
  静态预览 + 顶部登录提示，不再伪装空药盒 CTA。
- 实际作用：模块的门面。`LucentMedicineWorkspaceRepository.fetchWorkspace()`（`data/repositories/lucent_workspace.dart`）
  并行拉取：健康上下文快照（currentMedicines）→ 当日剂量日志（真实 API）→ 活跃提醒（真实 API）→ 风险检查记录（真实 API），
  每路失败只降级对应区并记日志，不伪造数据。计划项按 `reminderId+scheduledTime` 槽位组装，同药多槽位各自独立状态。
- 实现真实性：真实现。四个数据源全部是真实后端调用，无占位数据；骨架屏、错误重试、空态齐全。
- 结论：保留。
- 改造：无结构性改动。桌面端（冻结平台）多列布局可不动。
- 优先级：P0。

### F-2 药箱管理（药品档案）

- 现状：药箱 = 健康上下文 `currentMedicines`（`isCurrent=true`）快照；"管理"入口走
  `Routes.mineMedicineNew` → `mine/presentation/pages/current_medicine_edit.dart`（增/改/删，手动建档
  source=manual）；Mine 档案区也列出当前用药。搜索/扫码“加入药箱”链路见 `scan-search-扫码与搜索.md` F-9。
- 实际作用：药品档案是提醒、风险检查、剂量日志、Today 建议的共同主语。手动添加的药品在后端风险检查中
  如实标记为 `manualEntry` 覆盖缺口，不冒充有说明书数据。
- 实现真实性：真实现。增删改走 health-context API 真实落库（`today-今日建议.md` F-20 已审计快照层）。
- 结论：保留。注意"分组"概念不存在（任务假设的药箱分组未实现，但对当前人群——短期事件期
  3~5 种药——分组不是必需，不补）。
- 改造：P2 可选：药箱项增加"停用/归档"语义（现在只能软删除），支撑短期事件结束后"停药"而不丢历史。
- 优先级：P0。

### F-3 今日计划 slot 打卡（已服/跳过）

- 现状：`_TodayPlanRow` 每行"已服用/跳过"按钮 → `MedicineDoseMarkRequest`（携带
  currentMedicineId+reminderId+scheduledTime）→ `CachedDoseLogDataSource.mark()` → `POST /user/medicine-dose-logs/mark`
  → 成功发射 `DataChangeTopic.doseLogs` 刷新主页。每行只确认当前 pending 槽位，不做整天聚合覆盖。
  药品操作区 `_DrugBoxReminderStrip` 只做信息摘要，不放按钮，避免同药两组按钮。
- 实际作用：核心打卡闭环。后端 `mark`（`medicine-dose-logs/services/dose-logs.service.ts:96-167`）校验
  reminder 归属（`reminderId` 必须属于该用户且与 currentMedicineId 一致），按 `(userId, reminderId, scheduledFor, scheduledTime)`
  定位已有日志做 upsert，临时记录（无 reminder）永不与槽位日志合并。
- 实现真实性：真实现。失败 Toast 且不伪造成功；网络失败入 pending sync 队列由 SyncWorker 指数退避重放
  （`dose_log_cached.dart` 的 `_enqueueWriteFailure` + `registerHandler('dose_log')`）。
- 结论：保留。
- 小问题：`_markDose` 直接 `mark()` 无二次确认，误触后无撤销入口（Record 页快速用药有撤销，主页无）。
  可加"撤销"toast action（P2）。
- 优先级：P0。

### F-4 剂量日志（落库+缓存+离线队列）

- 现状：后端 `UserMedicineDoseLog` 表完整 CRUD/mark；客户端 `CachedDoseLogDataSource` 读缓存（60s 节流后台刷新）→
  空则网络+写缓存；写操作远程成功后刷新缓存，DioException 时序列化原 HTTP 请求入 `pending_sync_queue` 并由
  `SyncWorker` 重放（`dose_log_cached.dart:131-276`）。写入同时发射 `DOSE_LOG_CHANGED` 事件使 Today 建议失效重算。
- 实际作用：剂量日志是依从性统计、Report 回顾、Today 漏服建议、健康事件关联的共同数据底座；离线可写、
  联网必达是"用户只留少量断续记录"定位的关键支撑。
- 实现真实性：真实现。槽位身份（reminderId+scheduledTime）严格校验；`planned` 状态为默认值而非伪数据。
- 结论：保留。
- 优先级：P0。

### F-5 依从性/今日剂次 Hero 指标

- 现状：`_DrugBoxReminderStrip` 显示"今日剂次/依从率/下一剂"（`mobile_drugbox.dart`），数值由
  `lucent_workspace.dart:135-171` 客户端计算：分母 = 今日全部提醒槽位数（无槽位记 1），分子 = 已确认（taken/skipped）槽位数。
- 实际作用：给用户一个当日进度感。但口径与后端稀疏语义不同：分母包含未来时段（上午 10 点看 8:00/12:00/20:00
  三个槽位，依从率 33%）、不区分"超时未确认"，后端今天已按 `planned→unconfirmed / taken / skipped / overdueUnconfirmed`
  建立了合同（Active_Product_Loop 已收口后端），而 Active_UI_Medicine 明示"Flutter observed metric 字段待后续合同同步阶段接入"。
- 实现真实性：部分实现。数据是真的，但语义与后端合同脱节，未来会出现"主页 33% 与 Report/Today 的 1/3 已确认、1 超时未确认"
  的口径打架。
- 结论：改造。分母统一为"已到期槽位"（已确认/已跳过/已超时），未确认≠漏服，与后端口径对齐。
- 改造方案：P1 前端 mapper 层按"已确认/已跳过/已超时"三态统计"已到期槽位"作分母（未确认≠漏服），未到期与无覆盖显示 `--`；P2 后端在 dose-logs 或 workspace 接口暴露当日 slot 统计对象（接 `ObservedMetric` 或与 Today collector 一致的槽位统计），消除两端口径漂移。
- 优先级：P1。

### F-6 提醒创建/编辑/启停/删除

- 现状：`MedicineReminderEditPage`（编辑/新建合一）+ `MedicineReminderDetailPage`。支持多时间槽（组操作：
  `saveGroup` 对现有槽位逐个 PATCH、超出的新建、多余的删除）、每日/每周/自定义星期、起止日期窗口（FCalendar）、
  备注、启停 switch（详情页直接 `saveGroup(isActive:...)` 不整页重编辑）。重复时间点去重 toast。
- 实际作用：提醒是"漏服确认"建议与投递调度的数据源。后端 `userMedicineReminder` 表真实持久化，
  创建/更新/删除均发射 `REMINDER_CHANGED`，驱动风险检查标 stale 与建议重算。
- 实现真实性：真实现。失败有专用 toast、错误描述非空；`medicineId` 缺失时自动选药箱第一种药渲染表单，无死端。
- 结论：保留。
- 小问题：同一药品的多个时间槽是 N 行独立记录 + 客户端组操作，槽位增删在弱网下可能部分成功
  （第 1 个 PATCH 成功、第 2 个失败 → 半保存），当前实现失败即整体返回 false 但不回滚已成功的槽位（P2 可接受，
  可改为后端提供整组 upsert）。
- 优先级：P0。

### F-7 本地通知同步调度

- 现状：`MedicineReminderNotificationCoordinator.resync()`（`presentation/providers/reminder_notification_coordinator.dart`）
  取消全部旧通知 → `MedicineReminderNotificationPlanner.plan()` 生成 7 天 horizon（≤60 条）计划 → `LocalNotificationGateway`
  逐条调度；受设置页提醒开关/通知权限/声音偏好/提前提醒分钟数/DND 时段/振动开关控制；`bootstrap.dart` 与设置变更时触发 resync。
- 实际作用：设备在线的准时提醒，不依赖服务器。这是平台审计（platform-capabilities F-2）"本地通知调度网关=真实现"的
  用药侧实现本体，此处确认其数据来自真实提醒列表。
- 实现真实性：真实现（平台审计已确认）。注：本地通知与后端 in-app 投递是两条独立链路，同一提醒在用户在线时
  可能"本地通知 + 站内信 + JPush"三路齐发——体验重复，属产品决策问题，见 F-8。
- 结论：保留。
- 优先级：P0。

### F-8 后端提醒调度与投递

- 现状：`ReminderSchedulerService`（`medicine-reminders/services/scheduler.service.ts`）由 BullMQ Repeatable Job
  （`* * * * *`）驱动，批量游标扫活跃提醒，按用户时区（缺省 Asia/Shanghai）判定时分/星期/起止日期，命中后：
  ① `createOrReplaceScoped` 写 in-app 通知（type=medicine_reminder）→ ② 成功后才 `createMany({skipDuplicates})`
  写 `userReminderDelivery`（`(userId,reminderId,scheduledFor)` 唯一约束去重，at-least-once）→ ③ best-effort JPush。
- 实际作用：跨设备/离线兜底提醒 + 投递审计。通知失败不写投递记录 → 下一 tick 重试，去重可靠。
- 实现真实性：真实现（队列底座见 engineering-backend F-2）。局限：push 通道不写投递记录（仅 in_app 写），
  与 Mock_Or_Deferred "Worker 填充投递历史" 一致，见 F-9。
- 结论：保留。提醒文案（"该吃药了：{label}"）硬编码中文在 `dispatchSingle` 内，未走 i18n——通知标题对英文用户
  不友好，P1 改造。
- 优先级：P0。

### F-9 提醒投递历史（只读）

- 现状：详情页 `ReminderDeliveryLogPanel`（`widgets/reminder/log_panels.dart`）拉 `GET /reminder-deliveries`
  （limit 20）按 reminderId 过滤展示，channel/status 徽标 + 展开收起。后端 `listDeliveries` 按用户过滤。
- 实际作用：向用户证明"系统确实提醒过"。当前只有 in_app 渠道有真实记录，本地通知与 JPush 无投递记录，
  历史上"本地已提醒但列表空白"会让用户困惑。platform-capabilities F-4 已给出"部分实现→改造"结论，
  此处引用：改造方向是客户端本地通知投递时补写（本地 delivery 记录或回写接口），并如实区分渠道。
- 实现真实性：部分实现（数据真实但不全）。
- 结论：改造。后端 scheduler 已落站内信（`UserNotification`）；补 push 与本地投递的 `reminderDelivery` 落库，列表即有真实数据（渠道如实区分）。
- 优先级：P2。

### F-10 风险检查·静态规则引擎

- 现状：后端 `MedicineRiskCheckService.evaluateStaticCheck()`（`medicines/services/risk/risk-check.service.ts:128-245`）
  从 DB 读用户过敏/疾病/当前用药 → 对每个可解析来源（cn/drugbank + sourceRefId）并行取详情（缓存 30min）→
  `RiskDetectionService.evaluateStaticRisk()` 执行四类规则：
  ① 过敏匹配（成分 token + 说明书 contraindications/precautions/ingredients 全文归一化命中）；
  ② 食物相互作用（foodInteractions 字段内 alcohol/酒、caffeine/咖啡/浓茶 关键词）；
  ③ 药物-药物相互作用（仅 DrugBank 来源：`drugInteractions` 的 drugbankId 互相指向即命中，取 description 为证据）；
  ④ 重复成分（规范化成分 token 交集，canonical map 16 个常见成分 + CN 成分文本）。
  另有覆盖缺口（manual/missingSourceRef/detailUnavailable 三因）与红旗（severeAllergy 立即就医、
  informationGap 尽快线下核实）。风险分 = findings 加权（high30/med15/info5 + 缺口×3 + 红旗 40/10），0-100 映射四档。
- 实际作用：产品主张"用药安全可信入口"的执行本体。数据真接 `DrugDataBase/`：`cnMedicineProduct` 由
  `ChineseDrugData_Master_V2.xlsx`（FullDrugDetail + 药品说明书数据库 yaozs 合并产物）导入，`drugbankDrug`
  由 drugbank_all_full_database.xml 导入（见 `Lucent/docs/01-reference/contracts/data-sources*.md`），
  非前端本地规则或静态表。规则全部带证据字段（说明书原文摘录），信息不足时显式"覆盖缺口"而非编造。
- 实现真实性：真实现。诚实边界：CN 来源不携带 drugInteractions 字段，两个国产药的相互作用不会命中
  （只有重复成分/过敏/食物规则覆盖），`coverageIssues` 如实呈现——这是"未审校相互作用不进 MVP"愿景的落地，
  不是造假。
- 结论：保留。
- 改造：P1 扩展 canonical 成分映射与 CN 相互作用数据（依赖未来人工审校批次）；P2 规则引擎单元覆盖率已高
  （spec 齐全），不必为当前用户量做性能预优化。
- 优先级：P0。

### F-11 风险检查·LLM 分析

- 现状：`runLlmCheck`：模型未配置直接 503（`EXTERNAL_SERVICE_ERROR`，客户端显示"AI 分析不可用"态）→
  先跑静态基线 → `RiskContextBuilderService` 组 LLM 上下文 → `MedicineRiskLlmGeneratorService`
  （zod 结构化 schema `risk-check.schema.ts`，analysis 角色）→ 输出 findings/recommendation/overallRecommendation
  持久化。客户端 "AI 分析" tab 处理空态 CTA/过期横幅（stale）/不可用态/总体建议卡。
- 实际作用：给静态检查补充跨药品关系解释与建议文案（LLM only 字段），有明确的"非诊断"边界。
- 实现真实性：真实现。LLM 输出受 schema 约束，`longTermUse`/`schedulingConflict` 两类 finding 仅 LLM 产出
  （静态引擎不产），证据字段由 LLM 描述填充——这是设计内行为。
- 结论：保留。
- 改造：P2 客户端 `_mapFindingType` 的 unknown 兜底映射到 `specialGroup` 语义易误导（未知类型变成"特殊人群"），
  后端 schema 枚举是闭集时理论不可达，但建议 unknown 兜底改为隐藏该条而非误标类别。
- 优先级：P1。

### F-12 风险检查自动触发

- 现状：`MedicineRiskCheckListener`（`services/risk/risk-check.listener.ts`）监听 `HEALTH_CONTEXT_CHANGED` /
  `REMINDER_CHANGED` → `markStale`（置 stale + 删缓存）→ 5s 每用户 debounce 自动跑静态检查；失败保留 stale，
  下次事件/手动触发重试。
- 实际作用：药箱/提醒一变，主页安全摘要自动"过期→重算"，保证"新增药品后先检查"这一产品主张真实发生，
  不依赖用户手动点。
- 实现真实性：真实现。
- 结论：保留。
- 小问题：进程内 `setTimeout` 不是持久化调度，API 实例重启后 pending timer 丢失（stale 已标，检查不跑，
  下次事件才补）——对当前单实例阶段可接受（P2）。
- 优先级：P0。

### F-13 用药安全摘要卡（主页）

- 现状：`mobile_safety.dart` 消费 `workspace.riskCheckRecords.bestRecord`（LLM 优先、静态兜底）渲染
  风险等级 summary + 三项指标（用药数/发现数/覆盖缺口）+ 最多 2 条告警芯片 + "+N" + 最后检查时间/stale 标记，
  空态为"暂无风险数据"卡片，整卡可点击进入风险检查页。
- 实际作用：把后端检查结果压缩为首页一屏内的信任信号，是"安全守护"心智的入口。
- 实现真实性：部分实现：主体字段来自后端检查记录（`medicineRiskCheckLastUpdated/Stale` 如实显示时间与过期态），但告警芯片的数据源 `workspace.alerts` 恒空（`lucent_workspace.dart:152` `alerts: const []`），告警不展示。
- 结论：改造。
- 改造方案：告警数据从后端风险检查结果（`riskCheckRecords`）实时聚合，或与用药安全摘要卡合并展示（告警芯片并入风险等级/指标同卡呈现），不再依赖恒空字段。
- 优先级：P0。

### F-14 药品详情与说明书（缺失）

- 现状：客户端没有任何移动端药品详情页。搜索/扫码结果在移动端无 tap 跳转（`search/.../results.dart` 仅桌面
  预览面板包 FTappable，而该面板内容造假已被 scan-search F-11 判改造/归档）；`/medicine/reminders/:medicineId`
  详情页只显示药品名 + 剂量文本；后端 cn/drugbank 详情（indications/ingredients/contraindications/precautions/
  adverseReactions/…）全部存在且被风险检查使用，但 C 端无出口。`DrugbankMedicineDetailDto.drugInteractions`
  曾因客户端无消费方而产生过类型崩溃 bug（2026-07-26 P0 修复），侧面证明"详情数据无 UI"。
- 实际作用：用户买了一盒药，想看"适应症/禁忌/不良反应/储存"没有入口——对"自己买药、担心乱用药"的目标用户
  这是核心诉求（产品愿景"用药安全"入口），当前只能通过 AI 助手间接获得。
- 实现真实性：功能缺失（数据真、页面无）。
- 结论：新建。移动端药品详情页复用现有 `GET /medicines/:id?source=`（含缓存），展示说明书字段 +
  加入药箱按钮 + 风险相关字段入口；可与 Reminder 详情页的药品卡合并跳转。桌面预览面板改造/归档或复用同一页面数据。
- 改造方案：P1 新建详情页（数据契约已齐，主要是 UI）；P2 把扫码结果"查看详情"按钮从死链改为真跳转
  （修复 scan-search F-3 断链）。
- 优先级：P1。

### F-15 快捷操作区（4 入口）

- 现状：`mobile_quick_operations.dart` 四行：添加药品/搜索药品/新建提醒/风险检查，均为导航。
- 实际作用：纯导航聚合，无独立逻辑。
- 实现真实性：真实现（入口目标全部存在，其中"添加药品"与"去设提醒"目标路由均有效）。
- 结论：保留。桌面端 `_defaultQuickActions` 中的"处方导入"入口见 F-19。
- 优先级：P2。

### F-16 safety tips（死代码）

- 现状：后端 `GET /medicines/safety-tips`（`medicineSafetyTip` 表随机 4 条，按语言）+ 客户端
  `SafetyTipsRemoteDataSource` + `medicineSafetyTipListProvider`（AsyncNotifier，支持 excludeIds 轮换）——
  grep 全仓无任何 widget 消费该 provider。
- 实际作用：无。曾为"安全提示卡片"设计，UI 侧从未接线。
- 实现真实性：死代码（两端实现完整但无出口）。
- 结论：改造/归档。接口与 provider 代码及注释保留，标注TODO。若未来要"随机安全贴士"，应在药品详情页内以审核内容卡片形式重做。
- 优先级：P2。

### F-17 workspace 死字段

- 现状：`MedicineWorkspace.promisePoints`（4 条承诺文案，永不渲染）、`alerts`（恒 `const []`，
  实际告警由 `medicineAlertsFromRiskCheck` 从风险记录派生）、`hero.metricDosesToday`（计算但从不展示，
  主页只显示 metricAdherence 与下一剂）。
- 实际作用：无。占位残留（可能来自早期 dashboard 原型）。
- 实现真实性：死代码。
- 结论：改造/归档。字段与其拷贝（`promisePoint*` 4 个 MedicineCopyKey 及 l10n 键）保留并标注TODO，避免后续误用；其中 `alerts` 恒空问题并入"用药安全摘要卡"改造（从后端风险检查结果实时聚合，见 F-13），不再按死字段清理。
- 优先级：P2。

### F-18 DoseLogStatus.missed 死枚举

- 现状：后端 Prisma `DoseLogStatus` 含 `missed`，客户端 `DoseLogStatus` 同样含 `missed` 且
  `log_panels.dart` 有 missed 的图标/文案分支；全仓无任何代码写入 missed（mark/create 只传 taken/skipped；
  漏服语义由 Today collector 的 `overdueUnconfirmed` 计算，不落库为 missed）。
- 实际作用：无。若未来要落"漏服"标记，应在后端 collector 侧产出，前端保持消费方即可。
- 实现真实性：死代码（防御性枚举值）。
- 结论：改造/归档。枚举保留为历史兼容（漏服状态由 `overdueUnconfirmed` 计算派生、不落库为 missed），代码与注释保留、标注不接入主路径；标注为TODO,若未来要落"漏服"标记，应在后端 collector 侧产出，前端保持消费方即可。
- 优先级：P2。

### F-19 处方导入入口

- 现状：快捷操作/扫码页保留"处方导入"图标入口，点击仅 Toast 提示延后；`Mock_Or_Deferred` 明确标记
  "Deferred by Product Brainstorm P0/P1"。
- 实际作用：占位导航，诚实地告知用户"暂不支持"。
- 实现真实性：假实现但诚实（有明确延后标记，不冒充可用）。
- 结论：改造。MVP 不做自动处方，入口改造为"手动添加药物"（扫码/搜索加入药箱已覆盖该意图），入口明示延后；OCR 处方识别保留为未来能力，不排期。
- 优先级：P2。

### F-20 SMS 提醒通道

- 现状：提醒详情/编辑页"提醒方式"行中 SMS 以 `UnavailableMethodRow`（半透明灰显 + "不可用"）渲染；
  后端无 SMS 能力。
- 实际作用：诚实展示能力边界，不误导用户以为可发短信。
- 实现真实性：部分实现（通道本身不存在，展示为不可用——行为正确）。
- 结论：保留（保持灰显，不排期）。短信对目标人群（短期事件、自行买药）无必要；通道保留，接线邮件/短信供应商属低优先级、不排期投入。
- 优先级：P3。

### F-21 与 Today 建议卡联动

- 现状：剂量日志写入发射 `DOSE_LOG_CHANGED` → 建议重算/Today Analysis 入队；漏服卡
  （missed-dose rule）消费 reminder 槽位 + dose log 投影（`overdueUnconfirmed`），"确认用药"快速入口复用
  同一条 mark 链路；详情见 `today-今日建议.md` F-1/F-12（不重复审计）。
- 实际作用：用药模块是 Today 主动建议卡最硬的数据源之一，闭环完整。
- 实现真实性：真实现。
- 结论：保留。`today-今日建议.md` 已指出 `skip_dose` 死参数应接成真实跳过动作（保留代码与入口、标注不排期）、不做删除，此处从用药侧确认：主页“跳过”按钮走 mark(skipped)
  是真实动作，与建议卡无冲突。
- 优先级：P0。

## 后端投入错配判断

- **提醒调度**：每分钟全表批量游标扫描活跃提醒（batch 500）。单用户提醒数 ≤ 数十，当前阶段量级下线性扫描
  完全可接受；未来若用户量上来，正确做法是给 `userMedicineReminder` 加 `(isActive, deletedAt, scheduledHour, scheduledMinute)`
  索引或改预计算调度表——但这是 P3 优化，不是当前错配。
- **投递双通道重复**：客户端本地通知与后端 in-app/JPush 独立调度同一提醒，在线用户可能三路齐收。这是产品层
  重复提醒体验问题，建议客户端 resync 与后端投递做"以本地通知为主、站内信为辅"的分工（本地通知命中即不再依赖
  服务器通知文案），P1 决策。
- **CN 药品数据管线**：`CnMedicineProduct` 表带整套 import-time 字段（bestMatchType/matchQuality* / topCandidateIds /
  leaflet 匹配质量），运行时仅用少量业务字段。这是为一次性的数据质量治理沉淀的资产，风险检查因此有真实说明书
  数据支撑，价值成立，不算错配；但后续不再需要维护匹配质量字段的消费代码。
- **safety-tips / 投递历史 worker / SMS**：safety-tips 接口属于"做了没用"的投入（F-16 归档保留、不接入主路径）；投递历史 worker
  与 SMS 属 P2/P3 待办（platform/engineering 审计已覆盖），与 C 端主线不冲突但近期不建议继续加码。
- **结论**：medicine 模块后端投入整体与 C 端匹配，无 SaaS 化等超前投入（SaaS/worker 分离等全局判断见
  `engineering-工程与后端平台.md`，本模块未额外引入）。

## 模块级结论

- **价值判断**：用药管理是 Luminous 当前数据链最完整、风险边界最明确的平级健康领域——档案（currentMedicines）→
  提醒（reminder 表）→ 调度（cron+本地通知）→ 打卡（dose log）→ 依从（sparse 语义）→ 风险（规则+LLM）→
  建议（Today）全链路闭环，且风险检查的数据底座真实来自 `DrugDataBase/`（国产药品说明书库 + DrugBank）。
  它在用户需要用药时提供高价值闭环，但不能因实现最完整而被提升为整个健康伙伴的地基；Today 还必须同等消费饮食、饮水、睡眠、心情和症状等证据。
  审计结论：21 个功能点中真实现 13 项、部分实现 4 项、死代码/缺失 4 项，无系统性造假。
- **整体改造建议（按优先级）**：
  1. P0 保留主线不动；F-16/F-17/F-18 三处死代码按归档处理（保留代码与注释，标注不接入主路径）。
  2. P1 补移动端药品详情/说明书页（F-14）——数据现成，这是当前最大产品缺口；统一依从性口径到后端
     sparse 合同（F-5）；提醒文案走 i18n（F-8）；定夺本地/远程提醒双通道分工（后端投入错配第 2 条）。
  3. P2 主页打卡加撤销（F-3）；提醒组保存半失败回滚（F-6）；投递历史补本地/push 渠道记录（F-9）；
     risk-check 客户端 unknown 枚举兜底去误导（F-11）；处方导入改造为"手动添加药物"入口（F-19）。
- **一句话**：本模块是健康伙伴中可信度要求最高的平级领域，方向正确、实现诚实，剩余工作不是返工而是"把已有数据资产变成用户
  看得见的页面"（详情页）与"口径统一"（依从性），以及归档少量残留死代码（保留代码、标注不接入主路径）。
