# 扫码识别与搜索改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `Luminous/research/02-功能盘点/scan-search-扫码与搜索.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 3 位。

## 一、剩余改造项

### F-2 扫码结果匹配(条码精确命中，0.1.0 后 TODO)

- 现状:`LucentScanRepository.search`(`scan/data/repositories/scan.dart:24-40`)把条码原始值当 query 搜库,后端 `CnMedicinesService.buildWhere` 确实查 `barcode` 字段(`Lucent/src/modules/medicines/adapters/cn.service.ts:107`),匹配语义正确;但 `contains` 模糊匹配可能带出子串相同的其他条码(如 69 码前缀截断)。
- 改造方案:对纯数字 query 优先等值匹配 barcode 字段;前端候选列表利用后端 DTO 已有的 `matchedBy` 标注「条码精确命中」。
- 前后端分工:纯数字等值匹配整体移入 0.1.0 后 TODO，当前前后端均不追加特判。
- 依赖:无。

## 二、已决边界与延期项

- 候选本地按稳定药品 ID 去重并合并；不等待新增后端批量 query。AI 识别不显示伪造置信度，只说明需核对药品名、批准文号和规格；OCR/精确条码仅说明真实来源/匹配信息。
- 加药前风险预检是 0.1.0 前闭环；现有 `/medicines/risk-check` 不支持候选药品时新增合同，失败只给诚实的加入后检查提示。
- 纯数字查询不在当前前后端追加特判，移入 0.1.0 后 TODO，待有可验证的条码/批准文号语义再处理。桌面高级能力冻结。
- 新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
