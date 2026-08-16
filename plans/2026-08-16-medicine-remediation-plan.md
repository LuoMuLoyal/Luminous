# 用药管理(medicine)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `research/02-功能盘点/medicine-用药管理.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 2 位。

## 一、目标与范围

- 范围:`lib/features/medicine/`(presentation/data/domain 全层)+ `lib/features/mine/presentation/pages/current_medicine_edit.dart`;
  后端 `Lucent/src/modules/medicine-reminders/`、`medicine-dose-logs/`、`medicines/`(含 `risk/` 子目录)。
- 用药域全链路(档案 currentMedicines → 提醒 → 调度 → 打卡 dose log → 依从 → 风险 → Today 建议)已是真实闭环,
  本计划不返工,目标两件事:
  1. 依从性口径统一 P2:后端当日 slot 统计对象(F-5,前端 P1 mapper 已完成);
  2. 收尾 P2 小问题(F-11 unknown 兜底、F-19 入口改造、F-6 提醒组整组保存)。
- 边界:扫码/搜索与"加入药箱"链路见 scan-search 计划;本地通知网关公共底座见
  platform-notification-crosscutting 计划保留项(F-2),JPush 密钥与投递落库已由该计划完成(投递三通道见 Lucent ADR-0013;JPush 密钥部署见 Lucent deploy 配置与部署文档);Today 建议卡/漏服规则见 today 计划;队列/Cron 底座见
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

### 3.3 P2

**F-5 依从性口径统一 P2 后端统计对象(ObservedMetric 稀疏语义合同;本节为 today/record/report 计划的口径权威来源)**

- 统一口径(四方共用;P1 已落地于前端 mapper):分母 = **已到期槽位**(已确认/已跳过/已超时三类),分子 = 已确认槽位;**未确认 ≠ 漏服**,
  漏服语义由 `overdueUnconfirmed` 派生,不落库为 `missed`;未到期槽位不计入分母;无覆盖/无到期槽位显示 `--`。
- P1 已完成(前端 mapper,2026-08-16):`lucent_workspace.dart` 按到期三态统计(`isOverdue` 布尔建模、`_isSlotDue` 判定、分子=taken、
  无槽位药不计入分母、删除「无槽位记 1」),`mobile_shared.dart` 下一剂跳过 overdue 槽;时区沿用设备墙钟、不做 30 分钟宽限
  (宽限只影响后端漏服分类,不影响「到期」分母)。
- 剩余(P2,后端):在 dose-logs 或 workspace 接口暴露当日 slot 统计对象，采用 `ObservedMetric` 合同，消除两端口径漂移——
  注意后端 today collector 现按 `taken / expectedCount(全部计划槽位)` 计算(与已到期分母不一致,需一并对齐),时区对齐 profile timezone。
- 涉及:后端 `medicine-dose-logs/`(或 workspace 接口);前端届时切换数据源。
- 前后端分工:P1 前端先行(已完成);P2 后端补统计接口后前端切换数据源。
- 依赖:后端 Active_Product_Loop 已收口该合同；P2 在 0.1.0 前完成。

**F-6 提醒组保存半失败回滚（0.1.0 前）**

- 现状:同一药品多时间槽为 N 行独立记录,`saveGroup` 逐个 PATCH,弱网下可能部分成功(半保存),失败整体返回 false 但不回滚。
- 方案:后端提供整组 upsert 接口替代逐槽 PATCH;涉及 `Lucent/src/modules/medicine-reminders/` 与客户端编辑页保存链路。
- 分工:后端加接口,前端切换到整组提交。

**F-11 risk-check 客户端 unknown 枚举兜底去误导（0.1.0 前）**

- 现状:`_mapFindingType` 把未知 finding 类型兜底映射到 `specialGroup`(特殊人群),语义误导。
- 方案:unknown 兜底改为隐藏该条而非误标类别。纯前端。

**F-19 处方导入入口改造（0.1.0 前；处方 OCR 为 0.1.0 后）**

- 现状:快捷操作/扫码页"处方导入"入口点击仅 Toast 提示延后(诚实占位,`Mock_Or_Deferred` 有明确标记)。
- 方案:入口改造为"手动添加药物"(扫码/搜索加入药箱已覆盖该意图),入口明示延后;OCR 处方识别保留为未来能力,不排期。

**F-2 药箱项"停用/归档"语义(可选，0.1.0 后)**

- 现状:药箱项只能软删除,短期事件结束后"停药"会丢可见性。
- 方案:增加停用/归档状态,保留历史不出现在当前用药。涉及 health-context API 与药箱 UI。

## 四、跨计划引用与依赖

- **引用(他计划拥有)**:F-9 投递落库(已完成,方案与实现见 Lucent ADR-0013);
  队列/Cron 底座(BullMQ Repeatable Job)→ engineering-backend 计划;Today 漏服卡/建议重算细节 → today 计划。
- **被引用(本计划拥有)**:scan-search 计划引用本文的移动端药品详情页(已完成,路由 `/medicine/detail/:source/:id`,现状见 Active_UI_Medicine)作为识别结果卡/查看说明书落点;today/record/report 计划
  引用本文 F-5 的 ObservedMetric 稀疏语义口径;mine-settings 计划引用本文 F-7 的 LocalNotificationGateway 机制(睡眠提醒)。
- **桌面/Web 形态挂起项**(桌面预览面板处置等)不扩展 Flutter 产品面；独立 Next.js + Tauri MVP 于 0.1.0 后启动，本文不展开。
- 依赖关系:scan-search 的扫码结果"查看详情"真跳转依赖移动端药品详情页(已落地);F-5 P2 后端统计对象依赖合同同步阶段拍板。

## 五、本计划内执行顺序

1. P2:F-11、F-19 入口改造、F-6（均 0.1.0 前）→ F-2 停用/归档语义（0.1.0 后）。

## 六、已决边界与延期项

- `ObservedMetric` 由 Lucent 权威计算，须区分 `observed`、`unknown`、`degraded`、来源和覆盖率；未知不得映射为 0。客户端展示与后端合同均在 0.1.0 前完成。
- 本地通知展示以稳定通知实例 ID 幂等回写 `local/delivered`；JPush 只作本地失败/不可达回退。
- 处方 OCR、药箱停用/归档语义增强均为 0.1.0 后事项；SMS/邮件供应商仍保持灰显。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
