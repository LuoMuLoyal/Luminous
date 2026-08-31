# Luminous Docs

Luminous Flutter 客户端的文档 vault。本目录是产品、前端架构和工作流的权威来源。

## 快速导航

- [[00-current/Work_Phase_Guide]] — 阶段总纲：每个时期先做什么、暂时不做什么
- [[00-current/TODO]] — 剩余 P1/P2 缺口与延后项
- [[01-product/Product_Vision]] — 产品愿景总览
- [[01-product/Product_MVP_Scope]] — 首发版本范围
- [[01-product/Product_AI_Design]] — AI 能力设计
- [[01-product/Product_Safety_Privacy]] — 用药安全与 AI 隐私边界
- [[01-product/Product_Information_Architecture]] — 信息架构与竞赛叙事
- [[01-product/Product_Tab_Component_Blueprint]] — 五个 Tab 的组件级蓝图
- [[02-reference/architecture]] — 目录与模块结构总览
- [[02-reference/state-management]] — Riverpod 状态管理
- [[02-reference/routing]] — GoRouter 路由
- [[02-reference/data-layer]] — 数据层与 API 客户端
- [[02-reference/adr/README]] — 架构决策记录
- [[02-reference/how-to/README]] — 操作指南
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
- 完成使命的产品过程文档 → `04-archive/product/`；已实施的 spec → `04-archive/specs/`。

## 00-current 与 02-reference 边界

- `00-current/` = **易变状态**：当前实现进度、UI/数据/运行时的实时快照、待办与计划。它回答「现在是什么样」。会随代码频繁更新，`Current_State.md` 是唯一索引。
- `02-reference/` = **稳定事实**：架构、设计系统、数据层、路由、ADR、how-to。它回答「应该是什么样」。只在约定本身变化时才更新，不跟随实现细节抖动。
- 判断规则：内容会频繁变化（依赖版本、合同快照、UI 进度）→ 放 `00-current/`；内容是长期约定（架构、规范、决策）→ 放 `02-reference/`。
- **分工**：`02-reference/architecture.md` 描述稳定的架构与模块结构；`00-current/Runtime_Snapshot.md` 记录当前技术栈版本/依赖快照（易变），二者内容不重复——架构文档不写版本号，快照不写设计理由。
- 活跃状态文档超 250 行时应拆分子文件，用 wikilink 互连。

## 文档治理

- **单一来源**：术语见 [[Glossary]]，Forui 用法见 [[02-reference/Forui_Reference]]，OpenAPI 客户端流程见
  [[02-reference/OpenApi_Client]]，AI 开发工作流见 [[02-reference/AI_Development_Workflow]]。
- **活跃文档 ≤ 250 行**：超过时拆成子文件，用 wikilink 互连。
- **优先链接，避免重复**：同一条规则只写一次，其它地方用链接引用。
- **多用列表，少用表格**：表格只在需要横向对比时使用。
