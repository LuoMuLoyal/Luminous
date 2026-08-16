# 扫码识别与搜索改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/scan-search-扫码与搜索.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 3 位。

## 一、目标与范围

范围:`Luminous/lib/features/scan/`、`Luminous/lib/features/search/`;后端对照 `Lucent/src/modules/medicines/`、`Lucent/src/modules/files/`。

已实施完毕（2026-08-16，见 `docs/03-logs/migration-log/2026-08-16.md`）：识别出口断链修复、假置信度移除、预检即时化与候选去重合并。剩余 F-2 移入 0.1.0 后 TODO（见 `docs/00-current/TODO.md`）。识别层本身(相机、OCR 引擎、LLM 链路、双源搜索)未重做。

## 二、保留不动(清单)

- F-8 关键词搜索(cn/drugbank 双源 + 400ms 防抖 + 5s 超时,模块立足之本;遗留小瑕疵:未知 source 被静默映射为 drugbank、UI 无分页加载,作为后续打磨,不列入本期改造项)。
- F-13 无结果工具(「清空关键词/切换数据源」真实恢复路径,无需改动)。
- 后端 `recognize/async` + `recognize/status/:jobId` 队列端点:无消费方但保留为未来能力,不删除、不留双轨；接入另建任务评估。

## 三、改造项(按优先级分组)

### P1

#### F-2 扫码结果匹配(条码精确命中，0.1.0 后 TODO)

- 现状:`LucentScanRepository.search`(`scan/data/repositories/scan.dart:24-40`)把条码原始值当 query 搜库,后端 `CnMedicinesService.buildWhere` 确实查 `barcode` 字段(`Lucent/src/modules/medicines/adapters/cn.service.ts:107`),匹配语义正确;但 `contains` 模糊匹配可能带出子串相同的其他条码(如 69 码前缀截断)。
- 改造方案:对纯数字 query 优先等值匹配 barcode 字段;前端候选列表利用后端 DTO 已有的 `matchedBy` 标注「条码精确命中」。
- 前后端分工:纯数字等值匹配整体移入 0.1.0 后 TODO，当前前后端均不追加特判。
- 依赖:无。

## 四、跨计划引用与依赖

- **移动端药品详情页**(F-3/F-6「查看说明书」次按钮的落点,后端 `getDetail` 已返回适应症/用法用量/禁忌/不良反应/相互作用等完整字段):已完成(medicine 计划 F-14,路由 `/medicine/detail/:source/:id`,现状见 `docs/00-current/Active_UI_Medicine.md`「药品详情页」节),本文不重复展开。
- **桌面/Web 形态挂起**(F-11 后续):Flutter Desktop 与 PC Flutter Web 不再扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。
- **本计划拥有并写全(已实施完毕)**:F-9 建档闭环(`createCurrentMedicine(source, sourceRefId, displayName)` + 风险预检弹窗 + `source:sourceRefId` 判重 + Toast「去设置提醒」直达 `/medicine/reminders/new?medicineId=<药箱记录id>`)与 F-3/F-6 断链机理(`id` vs `sourceRefId` 两个 id 空间)。闭环现统一位于 `Luminous/lib/features/search/presentation/widgets/shared/add_to_box.dart` 的 `addMedicineToBoxWithPrecheck`(搜索页、扫码结果 sheet、识别弹窗三处共用);后续计划如需引用识别出口闭环,以该实现为准。
- **后端依赖**(Lucent,本期只读确认、可能小改):`POST /medicines/risk-check` 入参形态、`recognizeMedicine` 返回字段、条码等值匹配与批量 query、分类聚合字段;如涉及 API 契约变更,走 `pnpm export:openapi` + `dart run scripts/bootstrap_generated_sources.dart` 流程。

## 五、本计划内执行顺序

1. F-9 已完成（2026-08-16，见迁移日志）。
2. F-3、F-1、F-6 已完成（2026-08-16，见迁移日志）。
3. F-4、F-5、F-10 已完成（2026-08-16，见迁移日志）。
4. F-7、F-11、F-12 已完成（2026-08-16，见迁移日志）；F-2 纯数字等值匹配移入 0.1.0 后 TODO（见 TODO.md）。

## 六、已决边界与延期项

- 候选本地按稳定药品 ID 去重并合并；不等待新增后端批量 query。AI 识别不显示伪造置信度，只说明需核对药品名、批准文号和规格；OCR/精确条码仅说明真实来源/匹配信息。
- 加药前风险预检是 0.1.0 前闭环；现有 `/medicines/risk-check` 不支持候选药品时新增合同，失败只给诚实的加入后检查提示。
- 纯数字查询不在当前前后端追加特判，移入 0.1.0 后 TODO，待有可验证的条码/批准文号语义再处理。桌面高级能力冻结。
- 新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
