---
status: active
owner: frontend
updated: 2026-08-31
---

# Product Safety And Privacy

本文件是 [[Product_Vision]] 拆分后的子文档。

相关子文档：
- [[Product_MVP_Scope]]
- [[archive/product/Product_Insights]]
- [[Product_Information_Architecture]]

## 用药安全边界

用药安全仍然是 Luminous 的可信基础，但必须把 AI 放在正确位置。

推荐设计：

- 药物相互作用、重复成分、过敏禁忌、酒精/咖啡因冲突等风险判断，必须来自规则库、药品说明书、公开可信资料或人工审校数据。
- AI 负责把风险解释成用户能理解的话。
- 每条风险解释尽量展示来源、适用条件和不确定性。
- 如果信息不足，系统应该说“不确定”，并引导用户咨询医生或药师。
- Phase 1 不自动合并中文商品药和 DrugBank 药物实体。跨来源匹配、重复成分识别和相互作用扩展必须等成分归一化或人工审校数据稳定后再进入真实判断链路。

漏服场景的边界：

- 可以提醒用户“疑似漏服，请确认是否已经服药”。
- 可以记录漏服事件。
- 可以展示药品说明书中已有的漏服处理说明。
- 可以提醒用户不要自行加量或合并服用。
- 不应由 AI 自动决定新的服药时间、剂量或医嘱变化。

红旗信号的边界：

- 可以用固定规则表识别明确高风险表达，例如呼吸困难、严重过敏反应、高烧持续不退、意识异常等。
- 命中规则后只能提示“建议尽快寻求线下医疗帮助”。
- 不应由 AI 自行判断紧急程度、分诊等级、疾病名称或是否可以继续观察。
- 如果红旗规则、资源来源或固定安全文案没有完成审校，只能作为静态演示，不作为真实用户能力。
- 当前 MVP 不把这条能力作为完成标准。

## AI 与隐私边界

AI 总结、报告摘要和诊所/药师摘要都必须遵守最小必要原则。

- 用户未授权时，不把个人健康记录发送给 AI 或生成对外摘要。
- 摘要生成前应让用户预览，分享或导出前必须由用户确认。
- 过敏史、当前用药、症状、心理/情绪状态、备注和图片附件等敏感字段应支持隐藏或脱敏。
- AI 输出只能引用用户已记录、已授权或有来源支撑的信息；不能补写用户没有记录的事实。
- 就诊摘要、PDF 和分享链接属于“回顾 > 更多”中的次级出口；用户必须先预览并确认，不能把生成或分享成功解释为医生已经查看或采纳。


## 产品事件测量

客户端测量边界：

- 客户端只上报四个事件：`suggestion_impression`（surface=today + 白名单规则码，session 去重）、`review_opened`（surface=review，session 去重）、`visit_summary_previewed` / `visit_summary_exported`（surface=more，success/failure 边界）。
- 上报内容仅含 name/surface/result/eventStatus(健康事件专用)/suggestionRuleCode(7 个白名单码)/appVersion/platform/occurredAt/clientEventId，无 metadata、无自由文本；离线事件入队本地 pending-sync 队列重试，clientEventId 幂等。载荷由封闭 sealed union（`lib/core/analytics/product_event.dart`）结构上限定，无法表达症状、标题、备注、记录值、PDF URL 或分享 token。
- 服务端权威事件（health_event_*、suggestion_actioned、visit_summary_share_*）由服务端记录，客户端不得上报；share 创建/打开/撤销不落客户端事件。
- 管理员漏斗（`GET /api/v1/user/product-events/funnel`）只输出核心/optional 计数，无 userId、规则码或健康内容；原始事件保留 90 天（见 `Lucent/docs/reference/data-retention.md`）。
- 客户端不上报失败绝不打断用户主流程（fire-and-forget + 队列重试）；上报日志只含事件名与错误信息，不含载荷内容。

## 分享与字段级隐私 UX

- 就诊摘要字段级隐私选择：六项字段（事件概况/症状变化/用药槽位/饮水/睡眠/备注），**自由文本备注默认不选**；未选字段在 preview、PDF 与分享中都不存在（服务端单一过滤视图）。
- 分享创建前展示 7 天有效期与「链接持有者可查看」提示，不暗示医生已收到；创建后属主可复制链接或撤销；公开分享页与 PDF 不要求登录，撤销后一律 404。
- 分享记录只存 token 哈希，明文 token 创建时返回一次；分享管理面板只显示属主自己的记录（创建/到期/访问次数/最近访问/已撤销态），无任何访问者身份信息。
- 入口与文案：就诊摘要入口为「就诊时按需使用」，分享按钮为「分享摘要」——导出/分享成功不等于医生查看或用户获益（测量口径同此）。
