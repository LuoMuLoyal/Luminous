---
status: active
owner: frontend
updated: 2026-09-02
---

# Project Governance

## 维护模式

- 单人维护者负责设计、开发、测试和部署决策。
- 无团队分工、无 PR 审查要求、无多方审批流程。

## 架构

- 模块化单体（NestJS modules）优先于微服务。
- 每个 Lucent `@Module` 边界清晰，未来可抽取，但当前无拆分计划。

## 测试工具链

- Lucent 使用 Vitest。
- Luminous 使用 Flutter 内置 test + integration_test 集成测试。

## 仓库布局

- 三个子仓库：`Lucent`（NestJS 后端）、`Luminous`（Flutter 客户端）、`Luminous-site`（Nuxt 竞赛/营销站）。
- 它们位于非 git 的工作区根目录下，各自有 `package.json` / `pubspec.yaml`、`node_modules` 和 git 历史。
- 跨项目合同由 Lucent 的 OpenAPI spec 持有。
- `Luminous/backend` — 遗留参考，不再使用。
- `DrugDataBase/` — 本地药品数据集，非源码。

## 产品表面

- 移动端是当前产品表面。
- 底部 tab 为 `today / record / medicine / review / mine` 五个运行时入口；`report` 的用户任务和名称已改为「回顾」（review，`lib/features/review/`、`Routes.review`），`/report` 保留为兼容路由。
- 现有 Flutter Web 应用保持当前维护边界；未来 Web 产品可能承担大屏纵向洞察，Next.js 是候选实现而非已定方案，完成独立调研前不扩展认证产品壳或追求功能对等。
- `Luminous-site` 当前是竞赛/营销首页，不做签入式报告预览。
- 现有 Flutter 桌面端保留，当前只维护共享代码回归；这不是永久放弃桌面产品。未来桌面产品初步考虑用 Tauri 2 承载 Web 大屏体验，但用户任务、数据边界和技术路线尚未决策。

## 工作阶段总纲

本节决定每个时期先做什么、暂时不做什么；短期任务放 `plans/`，完成后删除。

### 使用规则

- 同一时间只激活一个主要阶段。
- 阶段切换依赖可观察结果，不依赖主观感觉。
- 出现 P0 问题时暂停当前阶段先处理。
- 完成阶段任务后追加迁移日志，稳定约束沉淀到测试与对应 feature 的 README。

### 优先级定义

- **P0**：用户可见破损、overflow、崩溃、核心流程不可用、测试门失败。
- **P1**：影响演示可信度的问题——假数据、登录态/空态混乱、硬编码日期、文案未本地化。
- **P2**：长期维护债——Provider 重整、路由拆分、Clock 注入、组件抽象整理、UI 一致性。
- **P3**：扩展探索——新能力、新输入形态、地图/外部服务、非核心垂直场景。

### 当前阶段：0.1.0 发布验证

- 目标：完成现有版本的真实联调、发布验证和 `0.1.0` 正式发布；优先修复阻断联调、验证或发布的问题。
- 联调期间不启动健康事件 schema、主动建议重构、数据口径迁移或 Review 重做。
- 门禁命令：

```powershell
flutter analyze
flutter test
dart run scripts/workflows/daily.dart
```

- 需要真实端到端信心时运行 `dart run scripts/workflows/fullstack.dart`。
- 发布前检查：
  - 文档与发布材料不把产品闭环方向写成已实现能力。
  - 活跃 `plans/` 中没有已完成但未删除的计划。
  - 不把 P2/P3 能力写成当前 P0/P1 承诺。

### 后续阶段：P2/P3 扩展探索

- 进入条件：P0+P1 移动端闭环稳定，且每个场景有产品决策、后端合同和验证方式。

## 文档治理

- `docs/doc-map.yaml` + `scripts/docs/verify.dart`：阻断模式（pre-commit 实际启用，只评估暂存文件）——有代码变更但无 `docs/` 文件时 `exit(1)`；`--warning-only` 用于每日检查（保持警告模式，不阻断）；`SKIP_DOC_CHECK=1` 可旁路。feature 改名/新增时须同步对应规则的 `code` glob。
- `dart run scripts/docs/verify.dart --verify`：校验 doc-map 引用存在、文档链接完整、front-matter 完整、90 天新鲜度（`status: frozen` 豁免）、活跃文档阅读入口（doc-map 规则或文档链接）、`lib/features/*` 覆盖完整性；已接入每日检查（阻断式）。
- `scripts/docs/links.dart --changed`：pre-commit 只检查变更文档的外链；变更集含文档删除/重命名时全量扫描以捕获指向已删文档的入链。
- 七条自定义 lint 规则（`tool/luminous_lints`）的规则清单与豁免路径以 `AGENTS.md` 的 "Custom Lint Rules" 一节为准；`links.dart` 的 `exemptRepoPaths` 豁免面保持最小——当前仅剩 archive 归档文档的 `auth_form_mixin` 旧路径一条，待归档文档下次触碰时随路径与退役 wikilink 一并修正后删除（见 `docs/TODO.md`）。
- 迁移日志条目描述变更范围与验证结论，不写需要持续同步的精确数字（如测试总数）。
- `scripts/contract/verify_openapi.dart` 校验 Lucent OpenAPI JSON 与生成客户端 `generated/lucent_api/` 布局（入口文件与 Today Analysis API 关键端点存在）。
- ARB 文件按功能模块拆分为 `lib/l10n/src/{fragment}_{locale}.arb`，通过 `scripts/l10n/arb_tools.dart` 合并。**绝对不要直接编辑 `app_zh.arb` / `app_en.arb`**。
- `lib/l10n/AGENTS.md` 是 l10n 目录的专用规则文件。

## CI/CD

- `luminous-cd.yml` 在 Flutter Web 构建前校验 secrets 存在性：`LUCENT_BASE_URL` 必填非空，防止空字符串注入 `--dart-define`。
- `luminous-cd.yml` 的 Flutter Web 发布构建为纯 dart2js + canvaskit（不用 `--wasm`：wasm 默认渲染器 skwasm 在移动浏览器有布局 bug），服务移动 web 主战场（安卓 Chrome / 鸿蒙过渡）；桌面/大屏 Web 冻结，不扩展构建形态。
- 环境变量明细见 [AI_Development_Workflow](ai-development-workflow.md)。
