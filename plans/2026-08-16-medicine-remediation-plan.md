# 用药管理(medicine)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `research/02-功能盘点/medicine-用药管理.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 2 位。

## 一、剩余改造项

### F-5 依从性口径统一 P2 后端统计对象(ObservedMetric 稀疏语义合同;本节为 today/record/report 计划的口径权威来源)

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

### F-2 药箱项"停用/归档"语义(可选，0.1.0 后)

- 现状:药箱项只能软删除,短期事件结束后"停药"会丢可见性。
- 方案:增加停用/归档状态,保留历史不出现在当前用药。涉及 health-context API 与药箱 UI。

## 二、跨计划引用与依赖

- **引用(他计划拥有)**:F-9 投递落库(已完成,方案与实现见 Lucent ADR-0013);
  队列/Cron 底座(BullMQ Repeatable Job)→ engineering-backend 计划;Today 漏服卡/建议重算细节 → today 计划。
- **被引用(本计划拥有)**:scan-search 计划引用本文的移动端药品详情页(已完成,路由 `/medicine/detail/:source/:id`,现状见 Active_UI_Medicine)作为识别结果卡/查看说明书落点;today/record/report 计划
  引用本文 F-5 的 ObservedMetric 稀疏语义口径;mine-settings 计划引用本文 F-7 的 LocalNotificationGateway 机制(睡眠提醒)。
- **桌面/Web 形态挂起项**(桌面预览面板处置等)不扩展 Flutter 产品面；独立 Next.js + Tauri MVP 于 0.1.0 后启动，本文不展开。
- 依赖关系:scan-search 的扫码结果"查看详情"真跳转依赖移动端药品详情页(已落地);F-5 P2 后端统计对象依赖合同同步阶段拍板。

## 三、本计划内执行顺序

1. F-5 P2 后端统计对象（0.1.0 前）。
2. F-2 停用/归档语义（0.1.0 后）。

## 四、已决边界与延期项

- `ObservedMetric` 由 Lucent 权威计算，须区分 `observed`、`unknown`、`degraded`、来源和覆盖率；未知不得映射为 0。客户端展示与后端合同均在 0.1.0 前完成。
- 本地通知展示以稳定通知实例 ID 幂等回写 `local/delivered`；JPush 只作本地失败/不可达回退。
- 处方 OCR、药箱停用/归档语义增强均为 0.1.0 后事项；SMS/邮件供应商仍保持灰显。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
