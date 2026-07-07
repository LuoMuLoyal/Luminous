# Luminous Docs

Luminous Flutter 客户端的文档 vault。本目录是产品、前端架构和工作流的权威来源。

## 快速导航

- [[00-current/Current_State]] — 当前实现状态入口
- [[00-current/Work_Phase_Guide]] — 阶段总纲：每个时期先做什么、暂时不做什么
- [[00-current/Next_Plan]] — 下一步实现顺序
- [[00-current/TODO]] — 剩余 MVP 缺口与延后项
- [[01-product/Product_Vision]] — 产品愿景总览
- [[01-product/Product_MVP_Scope]] — MVP 范围
- [[01-product/Product_AI_Design]] — AI 能力设计
- [[01-product/Product_Insights]] — 每日总结、每周趋势与主动提醒
- [[01-product/Product_Safety_Privacy]] — 用药安全与 AI 隐私边界
- [[01-product/Product_Information_Architecture]] — 信息架构与竞赛叙事
- [[01-product/Product_Brainstorm_2026-07-07]] — 功能头脑风暴与调整建议
- [[02-reference/architecture]] — 目录与模块结构总览
- [[02-reference/state-management]] — Riverpod 状态管理
- [[02-reference/routing]] — GoRouter 路由
- [[02-reference/data-layer]] — 数据层与 API 客户端
- [[02-reference/adr/README]] — 架构决策记录
- [[02-reference/AI_Development_Workflow]] — AI 开发工作流、MCP 与 app-side AI seam
- [[03-logs/MigrationLog]] — 变更日志索引
- [[04-archive/current-state-archive]] — 已归档历史

## Obsidian 用法

1. 在 Obsidian 中选择「打开本地仓库」。
2. 选择 `Luminous/docs/` 作为 vault 根目录。
3. 新建笔记默认保存在 `00-current/`。

## 归档策略

- `04-archive/` 存放旧计划和已完成的 audit remediation，仅供考古。
- 活跃文档完成后应直接删除，不留 `✅` 或 `DONE` 标记。

## 文档治理

- **单一来源**：术语见 [[Glossary]]，Forui 用法见 [[02-reference/Forui_Reference]]，OpenAPI 客户端流程见
  [[02-reference/OpenApi_Client]]，AI 开发工作流见 [[02-reference/AI_Development_Workflow]]。
- **活跃文档 ≤ 250 行**：超过时拆成子文件，用 wikilink 互连。
- **优先链接，避免重复**：同一条规则只写一次，其它地方用链接引用。
- **多用列表，少用表格**：表格只在需要横向对比时使用。
