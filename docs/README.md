# Luminous Docs

docs/ 的唯一索引:只回答「去哪找什么」。阅读规则与文档规则以仓库根 `AGENTS.md` 为准。

## 存活文档

- [Project Governance](explanation/project-governance.md) — 治理机制与阶段总纲(explanation/)
- [AI Development Workflow](explanation/ai-development-workflow.md) — MCP、app-side AI seam、flag、CI env(explanation/)

- [Product Vision](product/product-vision.md) — 产品愿景(product/)
- [Product Mvp Scope](product/product-mvp-scope.md) — 0.1.0 范围与 AI 能力边界(product/)
- [Product Information Architecture](product/product-information-architecture.md) — 五 Tab 职责与内容放置规则(product/)
- [Product Safety Privacy](product/product-safety-privacy.md) — 用药安全与 AI 隐私边界(product/)

- [Architecture](reference/architecture.md) — 目录与分层(reference/)
- [State Management](reference/state-management.md) — Riverpod 约定与 DataChangeBus(reference/)
- [Data Layer](reference/data-layer.md) — 网络栈、错误映射与本地持久化(reference/)
- [Routing](reference/routing.md) — 路由约定(reference/)
- [Design System](reference/design-system.md) — token 体系与组件规范(reference/)
- [Forui Reference](reference/forui-reference.md) — Forui 本地约定(reference/)
- [Localization](reference/localization.md) — l10n 工作流与分片划分(reference/)
- [OpenAPI Client](reference/openapi-client.md) — API 客户端合同规则(reference/)
- [Glossary](reference/glossary.md) — 术语表(reference/)
- [ADR](reference/adr/README.md) — 架构决策记录,存量只读(reference/adr/)
- generated/ — 机器生成清单(design tokens / routes / features),禁手编,变更由 CI diff 校验(reference/generated/)

- [Add New Feature](howto/add-new-feature.md) — 新建 feature(howto/)
- [Add Localization](howto/add-localization.md) — 新增文案(howto/)
- [Regenerate Api Client](howto/regenerate-api-client.md) — 再生成 API 客户端(howto/)

- [TODO](TODO.md) — 延后项与缺口跟踪;硬生命周期:完成即删行(docs/ 根)
- [MigrationLog](logs/MigrationLog.md) — 变更日志入口,逐日条目在 `logs/migration-log/`(logs/)
- [Removed_From_Active_Scope](archive/Removed_From_Active_Scope.md) — 归档范围说明(archive/)

`doc-map.yaml` 是变更覆盖映射,由 `scripts/docs/verify.dart` 消费。

## 放置规则

- explanation/ 回答「为什么这样设计」;product/ 回答「产品域事实」;reference/ 回答
  「应该是什么样」;howto/ 回答「怎么做」;logs/ 只追加;archive/ 只进不出。
- 不新增手写「现状叙事」文档(`Active_*` / `*_Snapshot` 式);断言进测试,约束进
  feature README,决策进 adr/,过程进 plans/。
- 新增文档必须放对目录并带 front-matter(`status` / `owner` / `updated`);读完没有
  行动价值的文档不值得存在。
