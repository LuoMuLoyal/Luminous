---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-02
---

# Product AI Design

本文件是 [[Product_Vision]] 拆分后的子文档。

相关子文档：
- [[Product_MVP_Scope]]
- [[04-archive/product/Product_Insights]]
- [[Product_Safety_Privacy]]
- [[Product_Information_Architecture]]

## AI 能力设计

AI 应该被放在“理解、总结、解释、提醒文案”层，而不是“诊断、处方、替代医生或药物风险判定”层。

- **自然语言转结构化记录** → `用户输入“今天头疼，早上喝了两杯水，晚上没睡好”，AI 拆成候选记录。用户确认前不写入正式记录。第一阶段只做文本输入到底部弹层候选确认，不在 MVP
  内承诺语音、截图或药物自动识别。` — 第一阶段做文本候选确认版
- **每日总结** → `汇总当天饮水、饮食、睡眠、症状、用药，指出最值得注意的 1 到 3 个点。只使用用户授权和已记录数据。` — 做
  - Today 首屏以轻量摘要承载指标和短叙述；未登录用户只看预览提示，不显示“今天还没有记录”或生成入口。登录后才允许按需触发 Today AI 增量流。
- **每周趋势分析** → `对比本周和上周，例如饮水增加、睡眠减少 11.2%、晚间咖啡因增多。只有记录密度足够且报告合同稳定时才生成真实趋势。` — 门控做
- **主动提醒文案生成** → `根据记录、提醒计划或规则生成更自然的提醒文案，而不是机械通知。` — 做
- **用药风险解释** → `风险判断来自规则库、药品说明书、可信药物数据或人工审校数据，AI 只负责解释原因和注意事项。` — 做，但必须有规则兜底
- **就诊摘要生成** → `生成给门诊、药师或医生看的近期摘要，用户可预览并选择隐藏敏感内容。真实分享/导出受隐私和报告合同门控。` — 门控做
- **红旗信号提示** → `只基于固定规则表和固定安全文案，对高烧不退、严重过敏、呼吸困难等记录提示尽快寻求线下帮助。AI 不自行判定紧急程度。` — 规则库完成后做
- **个性化目标建议** → `例如建议明天多喝水、早点睡、减少晚间咖啡因。建议必须绑定可观察记录，不从粗粒度饮食描述推断精确营养结论。` — 做
- **疾病判断** → `判断用户得了什么病。` — 不做
- **药量调整** → `建议加量、减量、停药。` — 不做
- **漏服后自动改服药时间** → `直接计算“下一次几点吃、晚上延后到几点”。` — 不做
- **自动处方** → `给出具体处方或替代医生开药。` — 不做

## 实现层约定

- 助手相关远程数据源 `AssistantRemoteDataSource` 通过 `generated/lucent_api` 的 Retrofit 客户端访问 Lucent API。
- SSE 流式助手请求通过 `LucentSseClient` + Dio 直接消费 `text/event-stream`，不经过 Retrofit 客户端。
- DTO 访问模式为直接返回扁平 DTO（`response.data`），不再经过 `Response<T>` 包装。
- Enum 序列化使用 `.json` 属性（`@JsonEnum` 约定），不再使用旧 `.value` 模式。
- `AssistantClearResultResponseDto` 等具名响应 DTO 在生成客户端中为强类型，`clearLatestConversation()` 直接访问 `response.data.cleared` 而非手动解析 `Map`。
- OpenAPI 合同修复后，`nullable: true` 的 DTO 字段已全部补充显式 `type`，生成客户端不再出现 `dynamic` 字段。
- **ADR-0009 缓存策略对 AI 数据的影响**:
  - **建议卡（Today Suggestions）**: 建议卡数据接入 cache-first 模式。网络成功后持久化到本地 Drift 缓存，网络失败时使用缓存兜底（stale-while-error）。这意味着用户在离线状态下仍能看到上一次获取的建议卡内容，但建议的时效性受限于缓存快照时间。AI 解释（`POST /today/suggestions/:id/explain`）不缓存，始终走网络按需加载。
  - **AI 摘要（Today Analysis）**: AI 摘要增量流（`/api/v1/user/today-analysis/generate/stream`）不缓存，每次生成都是实时 AI 调用。
  - **自然语言候选解析**: 候选解析（`POST /daily-records/candidates`）不缓存，每次提交都是实时 AI 调用。

