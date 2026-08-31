# Luminous Docs

docs/ 的唯一索引:只回答「去哪找什么」。阅读规则与文档规则以仓库根 `AGENTS.md` 为准。

## 存活文档

- [[Project_Governance]] — 治理机制与阶段总纲(explanation/)
- [[AI_Development_Workflow]] — MCP、app-side AI seam、flag、CI env(explanation/)

- [[Product_Vision]] — 产品愿景(product/)
- [[Product_MVP_Scope]] — 0.1.0 范围与 AI 能力边界(product/)
- [[Product_Information_Architecture]] — 五 Tab 职责与内容放置规则(product/)
- [[Product_Safety_Privacy]] — 用药安全与 AI 隐私边界(product/)

- [[architecture]] — 目录与分层(reference/)
- [[state-management]] — Riverpod 约定与 DataChangeBus(reference/)
- [[data-layer]] — 网络栈、错误映射与本地持久化(reference/)
- [[routing]] — 路由约定(reference/)
- [[Design_System]] — token 体系与组件规范(reference/)
- [[Forui_Reference]] — Forui 本地约定(reference/)
- [[Localization]] — l10n 工作流与分片划分(reference/)
- [[OpenApi_Client]] — API 客户端合同规则(reference/)
- [[Glossary]] — 术语表(reference/)
- [[reference/adr/README|ADR]] — 架构决策记录,存量只读(reference/adr/)

- [[add-new-feature]] — 新建 feature(howto/)
- [[add-localization]] — 新增文案(howto/)
- [[regenerate-api-client]] — 再生成 API 客户端(howto/)

- [[TODO]] — 延后项与缺口跟踪;硬生命周期:完成即删行(docs/ 根)
- [[MigrationLog]] — 变更日志入口,逐日条目在 `logs/migration-log/`(logs/)
- [[Removed_From_Active_Scope]] — 归档范围说明(archive/)

`doc-map.yaml` 是变更覆盖映射,由 `scripts/check_doc_coverage.dart` 消费。

## 放置规则

- explanation/ 回答「为什么这样设计」;product/ 回答「产品域事实」;reference/ 回答
  「应该是什么样」;howto/ 回答「怎么做」;logs/ 只追加;archive/ 只进不出。
- 不新增手写「现状叙事」文档(`Active_*` / `*_Snapshot` 式);断言进测试,约束进
  feature README,决策进 adr/,过程进 plans/。
- 新增文档必须放对目录并带 front-matter(`status` / `owner` / `updated`);读完没有
  行动价值的文档不值得存在。
