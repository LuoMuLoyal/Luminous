# 用药管理(medicine)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `research/02-功能盘点/medicine-用药管理.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 2 位。

## 一、目标与范围

- 范围:`lib/features/medicine/`(presentation/data/domain 全层)+ `lib/features/mine/presentation/pages/current_medicine_edit.dart`;
  后端 `Lucent/src/modules/medicine-reminders/`、`medicine-dose-logs/`、`medicines/`(含 `risk/` 子目录)。
- 用药域全链路(档案 currentMedicines → 提醒 → 调度 → 打卡 dose log → 依从 → 风险 → Today 建议)已是真实闭环,
  本计划不返工,目标四件事:
  1. 把已有药品数据资产变成用户看得见的页面——新建移动端药品详情/说明书页(F-14,当前最大产品缺口);
  2. 依从性口径统一,前后端对齐 ObservedMetric 稀疏语义合同(F-5);
  3. 修复主页安全摘要卡告警恒空问题(F-13);
  4. 收尾 P2 小问题、归档少量死代码。
- 边界:扫码/搜索与"加入药箱"链路见 scan-search 计划;本地通知网关公共底座、JPush、投递落库见
  platform-notification-crosscutting 计划;Today 建议卡/漏服规则见 today 计划;队列/Cron 底座见
  engineering-backend 计划。本计划只覆盖用药模块专属功能点,交叉处引用对应计划。

## 二、保留不动(清单)

以下功能点审计为真实现或行为正确,主线不动:

- F-1 用药主页四区块 dashboard(`MedicinePage` 四区全部由真实 API 组装,降级不伪造)。
- F-2 药箱管理(currentMedicines 档案增/改/删走 health-context API 真实落库;不补"分组"概念)。
- F-3 今日计划 slot 打卡(mark API 按槽位真实落库、失败入 pending sync 重放)。
- F-4 剂量日志(后端 CRUD/mark + 客户端 cache-first + `pending_sync_queue` 离线写队列)。
- F-6 提醒创建/编辑/启停/删除(多时间槽组操作 + `REMINDER_CHANGED` 事件联动)。
- F-7 本地通知同步调度(机制说明见下,供跨计划引用)。
- F-8 后端提醒调度与投递(BullMQ 每分钟 cron → in-app 通知 → `userReminderDelivery` → best-effort JPush)。
- F-10 风险检查·静态规则引擎(过敏/相互作用/重复成分/食物相互作用 + 覆盖缺口 + 红旗,数据真接 `DrugDataBase/`)。
- F-11 风险检查·LLM 分析(schema 约束结构化输出,未配置显式 503,stale 如实标记)。
- F-12 风险检查自动触发(事件 → 标 stale → 5s debounce 自动静态检查)。
- F-15 快捷操作区(4 入口纯导航,目标路由全部有效)。
- F-20 SMS 提醒通道(灰显"不可用"为诚实降级,保持现状不排期)。
- F-21 与 Today 建议卡联动(`DOSE_LOG_CHANGED` 驱动建议重算,漏服卡消费 reminder 槽位)。

### F-7 LocalNotificationGateway 本地通知同步调度机制(保留;本节供 mine 计划睡眠提醒引用)

- 现状:`MedicineReminderNotificationCoordinator.resync()`(`medicine/presentation/providers/reminder_notification_coordinator.dart`)
  取消全部旧通知 → `MedicineReminderNotificationPlanner.plan()` 生成 **7 天 horizon、上限 60 条** 的调度计划 →
  `LocalNotificationGateway` 逐条调度;`bootstrap.dart` 启动时与设置变更时触发 resync。
- 受控项:设置页提醒总开关、系统通知权限、声音偏好、提前提醒分钟数、DND 时段、振动开关。
- 数据来自真实提醒列表(平台审计 platform-capabilities F-2 已确认网关为真实现)。
- 通知分工已定:同一事件最多一次打扰；前台仅应用内提示，后台本地通知优先，失败或不可达才 JPush，站内信仅保留记录、不再额外弹出。复用本机制的模块(如睡眠提醒)应沿用同一协调器/计划器模式与 resync 触发点。

## 三、改造项(按优先级分组)

### 3.1 P0（0.1.0 前）

**F-13 用药安全摘要卡告警聚合(并入 F-17 `alerts` 恒空问题,不重复立项)**

- 现状:`mobile_safety.dart` 消费 `workspace.riskCheckRecords.bestRecord` 渲染风险等级/三项指标/告警芯片,但告警数据源
  `workspace.alerts` 恒为 `const []`(`lucent_workspace.dart:152`),告警芯片永远不展示。
- 方案:告警改由风险检查记录实时聚合——复用已有派生函数 `medicineAlertsFromRiskCheck` 从 `riskCheckRecords` 取数,
  告警芯片并入风险等级/指标同卡呈现;删除对 `alerts` 恒空字段的依赖。
- 涉及:`lib/features/medicine/presentation/widgets/mobile_safety.dart`、`lib/features/medicine/data/repositories/lucent_workspace.dart`。
- 前后端分工:纯前端改造,后端无改动。
- 依赖:无。

### 3.2 P1（0.1.0 前）

**F-14 移动端药品详情/说明书页(新建;本节为 scan-search 计划"识别结果卡/查看说明书"的落点)**

- 现状:客户端没有任何移动端药品详情页;搜索/扫码结果在移动端无 tap 跳转;`/medicine/reminders/:medicineId` 详情页
  只显示药品名+剂量文本;后端 cn/drugbank 详情(indications/ingredients/contraindications/precautions/adverseReactions 等)
  全部存在且已被风险检查使用,但 C 端无出口(`DrugbankMedicineDetailDto.drugInteractions` 曾因无消费方出过类型崩溃 bug)。
- 方案:
  1. 新建移动端药品详情页,数据复用现有 `GET /medicines/:id?source=`(含 30min 缓存),数据契约已齐,工作主要在 UI;
  2. 页面内容:说明书字段分区展示(适应症/成分/禁忌/注意事项/不良反应/储存等)+ "加入药箱"按钮 + 风险相关字段入口;
  3. 跳转接入:与 Reminder 详情页的药品卡合并跳转;P2 把扫码结果"查看详情"从死链改为真跳转(修复 scan-search F-3 断链);
  4. 桌面预览面板不扩展 Flutter 产品面；桌面高级能力冻结。
- 涉及:`lib/features/medicine/presentation/pages/`(新建详情页)、`lib/features/search/`(结果卡 tap 接线)、
  GoRouter 路由注册;后端无需改动。
- 前后端分工:纯前端。
- 依赖:无后端依赖;scan-search 计划的断链修复依赖本页先落地。

**F-5 依从性口径统一(ObservedMetric 稀疏语义合同;本节为 today/record/report 计划的口径权威来源)**

- 现状:`_DrugBoxReminderStrip` 的"今日剂次/依从率/下一剂"由 `lucent_workspace.dart:135-171` 客户端自行计算:
  分母=今日全部提醒槽位数(含未来时段,无槽位记 1),分子=已确认(taken/skipped)槽位数。与后端稀疏语义合同
  (`planned→unconfirmed / taken / skipped / overdueUnconfirmed`)脱节,上午看会显示"依从率 33%",与
  Report/Today 的"1/3 已确认、1 超时未确认"口径打架。
- 统一口径(四方共用):分母 = **已到期槽位**(已确认/已跳过/已超时三类),分子 = 已确认槽位;**未确认 ≠ 漏服**,
  漏服语义由 `overdueUnconfirmed` 派生,不落库为 `missed`;未到期槽位不计入分母;无覆盖/无到期槽位显示 `--`。
- 方案:
  1. P1(本计划):前端 mapper 层按上述三态统计改造,`mobile_drugbox.dart` 展示口径随之修正;
  2. P2(后端):在 dose-logs 或 workspace 接口暴露当日 slot 统计对象，采用 `ObservedMetric` 合同，消除两端口径漂移。
- 涉及:`lib/features/medicine/data/repositories/lucent_workspace.dart`、`lib/features/medicine/presentation/widgets/mobile_drugbox.dart`;
  后端 `medicine-dose-logs/`(P2 统计对象)。
- 前后端分工:P1 前端先行;P2 后端补统计接口后前端切换数据源。
- 依赖:后端 Active_Product_Loop 已收口该合同；Flutter 侧在 0.1.0 前接入。

**F-8 提醒文案 i18n**

- 现状:后端 `dispatchSingle` 内提醒文案("该吃药了:{label}")硬编码中文,未走 i18n,英文用户收到中文通知。
- 方案:通知标题/正文按用户语言偏好取文案;涉及 `medicine-reminders/services/scheduler.service.ts` 文案抽取。
- 前后端分工:纯后端。
- 依赖:无。

### 3.3 P2

**F-3 主页打卡撤销（0.1.0 前）**

- 现状:`_markDose` 直接 `mark()` 无二次确认,误触后主页无撤销入口(Record 页快速用药已有撤销)。
- 方案:打卡成功 Toast 加"撤销"action,反向调用 mark 恢复原状态。纯前端,涉及 `mobile_records.dart`。

**F-6 提醒组保存半失败回滚（0.1.0 前）**

- 现状:同一药品多时间槽为 N 行独立记录,`saveGroup` 逐个 PATCH,弱网下可能部分成功(半保存),失败整体返回 false 但不回滚。
- 方案:后端提供整组 upsert 接口替代逐槽 PATCH;涉及 `Lucent/src/modules/medicine-reminders/` 与客户端编辑页保存链路。
- 分工:后端加接口,前端切换到整组提交。

**F-9 提醒投递历史补渠道(引用，不展开，0.1.0 前)**

- 现状:`ReminderDeliveryLogPanel` 只读展示投递审计,但只有 in_app 渠道有真实记录,本地通知与 JPush 无投递记录。
- 方案:见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)
  的投递落库一节,本文不重复展开;本地通知展示后以稳定通知实例 ID 幂等回写 `local/delivered`，列表按渠道如实区分。

**F-11 risk-check 客户端 unknown 枚举兜底去误导（0.1.0 前）**

- 现状:`_mapFindingType` 把未知 finding 类型兜底映射到 `specialGroup`(特殊人群),语义误导。
- 方案:unknown 兜底改为隐藏该条而非误标类别。纯前端。

**F-16 / F-17 / F-18 死代码归档标注(动作仅为:保留代码与注释 + 标注不接入主路径，无实质改造，0.1.0 前)**

- F-16 safety tips:后端 `GET /medicines/safety-tips` + 客户端 `SafetyTipsRemoteDataSource` / `medicineSafetyTipListProvider`
  无 UI 消费方——接口与 provider 代码及注释保留,标注 TODO;未来若做"随机安全贴士"应在药品详情页内以审核内容卡片重做。
- F-17 workspace 死字段:`promisePoints`(含 4 个 `promisePoint*` MedicineCopyKey 及 l10n 键)、`hero.metricDosesToday`
  保留并标注 TODO,避免误用;`alerts` 恒空问题已并入 F-13(见 3.1),此处不再清理。
- F-18 `DoseLogStatus.missed`:前后端枚举保留为历史兼容,标注"不接入主路径;漏服状态由 `overdueUnconfirmed` 派生,
  未来若落漏服标记应在后端 collector 侧产出";`log_panels.dart` 的 missed 分支一并标注。
- 动作轻量,可与 P0 项顺手一起完成。

**F-19 处方导入入口改造（0.1.0 前；处方 OCR 为 0.1.0 后）**

- 现状:快捷操作/扫码页"处方导入"入口点击仅 Toast 提示延后(诚实占位,`Mock_Or_Deferred` 有明确标记)。
- 方案:入口改造为"手动添加药物"(扫码/搜索加入药箱已覆盖该意图),入口明示延后;OCR 处方识别保留为未来能力,不排期。

**F-2 药箱项"停用/归档"语义(可选，0.1.0 后)**

- 现状:药箱项只能软删除,短期事件结束后"停药"会丢可见性。
- 方案:增加停用/归档状态,保留历史不出现在当前用药。涉及 health-context API 与药箱 UI。

## 四、跨计划引用与依赖

- **引用(他计划拥有)**:F-9 投递落库 → [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md);
  队列/Cron 底座(BullMQ Repeatable Job)→ engineering-backend 计划;Today 漏服卡/建议重算细节 → today 计划。
- **被引用(本计划拥有)**:scan-search 计划引用本文 F-14 详情页作为识别结果卡/查看说明书落点;today/record/report 计划
  引用本文 F-5 的 ObservedMetric 稀疏语义口径;mine-settings 计划引用本文 F-7 的 LocalNotificationGateway 机制(睡眠提醒)。
- **桌面/Web 形态挂起项**(F-14 桌面预览面板处置等)不扩展 Flutter 产品面；独立 Next.js + Tauri MVP 于 0.1.0 后启动，本文不展开。
- 依赖关系:scan-search 的扫码结果"查看详情"真跳转依赖本计划 F-14 详情页先落地;F-5 P2 后端统计对象依赖合同同步阶段拍板。

## 五、本计划内执行顺序

1. P0:F-13 告警聚合改造（0.1.0 前，顺手完成 F-16/17/18 归档标注）。
2. P1:F-14 详情页（0.1.0 前，解锁 scan-search 断链修复）→ F-5 前端口径统一 → F-8 提醒文案 i18n。
3. P2:F-3、F-11、F-19 入口改造、F-6 与 F-9（均 0.1.0 前）→ F-2 停用/归档语义（0.1.0 后）。

## 六、已决边界与延期项

- `ObservedMetric` 由 Lucent 权威计算，须区分 `observed`、`unknown`、`degraded`、来源和覆盖率；未知不得映射为 0。客户端展示与后端合同均在 0.1.0 前完成。
- 本地通知展示以稳定通知实例 ID 幂等回写 `local/delivered`；JPush 只作本地失败/不可达回退。
- 处方 OCR、药箱停用/归档语义增强均为 0.1.0 后事项；SMS/邮件供应商仍保持灰显。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
