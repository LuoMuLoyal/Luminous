---
title: "Luminous 项目文档中心"
tags:
  - moc
aliases:
  - 文档中心
  - Home
created: 2026-05-26
---

# Luminous 项目文档中心

本目录是项目规范、迁移计划、接口对齐和路演材料的归档入口。涉及架构或迁移决策时，优先以这里的文档为准。

## 文档索引

- [[RefactorPlan]]：当前 Flutter 优化、状态迁移和 Lucent 后端演进的主计划。
- [[knowledge-data-platform-plan]]：Luminous 侧的知识库产品/客户端边界摘要；后端导入细节见 `../Lucent/docs/data-sources.md`。
- [[backend-nestjs-pgsql-migration-plan]]：Luminous 侧的 Lucent 后端迁移协调摘要；后端详细路线见 `../Lucent/docs/migration-roadmap.md`。
- [[flutter-followup-improvement-plan]]：Flutter 侧硬编码收口、GetX 迁移、Lucent client 切换和后续拆分步骤。
- [[Promise]]：Personal Health Copilot 的产品愿景、端侧职责和阶段路线。
- [[migration_log]]：GetX/Layer-based 向 Riverpod/GoRouter/Feature-first 迁移的执行记录。
- [[backend-api]]：Legacy Express 后端 API 参考文档（原 `lib-docs/` 目录）。
- `privacy-policy.txt`：隐私政策文本。

## 迁移执行约束

- 迁移按小步推进，一次只做一块可验证的状态或结构调整，不追求一口气完成。
- 新增迁移代码要有意识落到目标结构：共享基础能力放 `lib/core/`，跨业务复用 UI 放 `lib/shared/`，业务模块放 `lib/features/`。
- 控制文件规模：单文件最好 300 行以内，300-600 行可接受，超过 600 行时优先拆分再继续扩展。
- 迁移涉及行为变化时，同步更新测试与这里的相关文档。
- 外部大体量数据源只在文档中记录路径和导入规则，不进入 Git；当前新知识库规划以 [[knowledge-data-platform-plan]] 为准。
- 目标后端在 `Lucent/` submodule；旧 `backend/` Express 只用于低优先级参考和线上旧服务联调，不再作为新功能落点。
- 目标数据源位于 `D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase`，包含中文 `FullDrugDetail.xlsx` 与英文 DrugBank 文件。导入策略未完全定稿前，只在 Lucent/PostgreSQL 规划中处理，不写入 Flutter assets。

## 文档边界

- Luminous `README.md`：项目入口、运行方式、子项目关系。
- Luminous `docs/`：Flutter 迁移、客户端边界、跨项目协调和 legacy API 参考。
- Lucent `README.md`：目标后端入口。
- Lucent `docs/`：API 协议、数据导入、数据库、后端模块和迁移路线。
