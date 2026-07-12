# Project Governance

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

- 三个子仓库：`Lucent`、`Luminous`、`Luminous-site`。
- 它们位于非 git 的工作区根目录下。
- 每个子仓库有自己的 `package.json` / `pubspec.yaml`、`node_modules` 和 git 历史。
- 跨项目合同由 Lucent 的 OpenAPI spec 持有。
