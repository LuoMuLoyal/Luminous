# Project Governance

Last updated: 2026-07-22 (CI/CD secrets 校验)

## 维护模式

- 单人维护者负责设计、开发、测试和部署决策。
- 无团队分工、无 PR 审查要求、无多方审批流程。

## 架构

- 模块化单体（NestJS modules）优先于微服务。
- 每个 Lucent `@Module` 边界清晰，未来可抽取，但当前无拆分计划。

## 测试工具链

- Lucent 使用 Vitest。
- Luminous 使用 Flutter 内置 test + Patrol 集成测试。

## 仓库布局

- 三个子仓库：`Lucent`（NestJS 后端）、`Luminous`（Flutter 客户端）、`Luminous-site`（Nuxt 竞赛/营销站）。
- 它们位于非 git 的工作区根目录下。
- 每个子仓库有自己的 `package.json` / `pubspec.yaml`、`node_modules` 和 git 历史。
- 跨项目合同由 Lucent 的 OpenAPI spec 持有。
- `Luminous/backend` — 遗留参考，不再使用。
- `DrugDataBase/` — 本地药品数据集，非源码。

## 产品表面

- 移动端是当前产品表面。
- 底部 tab 固定为 `today / record / medicine / report / mine`。
- Web 仅用于报告预览/导出和竞赛展示。
- `Luminous-site` 当前是竞赛/营销首页，不做签入式报告预览。
- 桌面视觉行为不是当前 UI 验收范围。

## 文档治理

- `docs/doc-map.yaml` + `scripts/check_doc_coverage.dart`：默认阻断模式——有代码变更但无 `docs/` 文件时 `exit(1)`；`--warning-only` 用于日常检查；`SKIP_DOC_CHECK=1` 可旁路。
- ARB 文件按功能模块拆分为 `lib/l10n/src/{fragment}_{locale}.arb`，通过 `scripts/arb_tools.dart` 合并。**绝对不要直接编辑 `app_zh.arb` / `app_en.arb`**。
- `lib/l10n/AGENTS.md` 是 l10n 目录的专用规则文件。

## CI/CD

- `luminous-cd.yml` 在 Flutter Web 构建前新增 secrets 存在性校验步骤，确保 `LUCENT_BASE_URL` 和 `SENTRY_DSN` 已配置，防止空字符串注入 `--dart-define`。
