---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-15
---

# Project Governance

Last updated: 2026-08-15 (当前发布表面与未来大屏候选)

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
- 它们位于非 git 的工作区根目录下。
- 每个子仓库有自己的 `package.json` / `pubspec.yaml`、`node_modules` 和 git 历史。
- 跨项目合同由 Lucent 的 OpenAPI spec 持有。
- `Luminous/backend` — 遗留参考，不再使用。
- `DrugDataBase/` — 本地药品数据集，非源码。

## 产品表面

- 移动端是当前产品表面。
- 底部 tab 保留 `today / record / medicine / report / mine` 五个运行时入口；产品方向将 `report` 的用户任务和名称改为“回顾”，代码尚未迁移。
- 现有 Flutter Web 应用保持当前维护边界；未来 Web 产品可能承担大屏纵向洞察，Next.js 是候选实现而非已定方案，完成独立调研前不扩展认证产品壳或追求功能对等。
- `Luminous-site` 当前是竞赛/营销首页，不做签入式报告预览。
- 现有 Flutter 桌面端保留，当前只维护共享代码回归；这不是永久放弃桌面产品。未来桌面产品初步考虑用 Tauri 2 承载 Web 大屏体验，但用户任务、数据边界和技术路线尚未决策。

## 文档治理

- `docs/doc-map.yaml` + `scripts/check_doc_coverage.dart`：阻断模式（pre-commit 实际启用，只评估暂存文件）——有代码变更但无 `docs/` 文件时 `exit(1)`；`--warning-only` 用于每日检查（保持警告模式，不阻断）；`SKIP_DOC_CHECK=1` 可旁路。
- `dart run scripts/check_doc_coverage.dart --verify`：校验 doc-map 引用存在、文档链接完整、front-matter 完整、90 天新鲜度（`status: frozen` 豁免）、活跃文档阅读入口（doc-map 规则或文档链接）、`lib/features/*` 覆盖完整性；已接入每日检查（阻断式）。
- `scripts/check_doc_links.dart --changed`：pre-commit 只检查变更文档的外链；变更集含文档删除/重命名时全量扫描以捕获指向已删文档的入链。
- 迁移日志条目描述变更范围与验证结论，不写需要持续同步的精确数字（如测试总数）。
- `scripts/verify_lucent_openapi_sync.dart` 校验 OpenAPI JSON 以及当前生成客户端入口
  `lib/lucent_api.dart`、`lib/src/api.dart`、`lib/src/deserialize.dart` 是否存在。
- ARB 文件按功能模块拆分为 `lib/l10n/src/{fragment}_{locale}.arb`，通过 `scripts/arb_tools.dart` 合并。**绝对不要直接编辑 `app_zh.arb` / `app_en.arb`**。
- `lib/l10n/AGENTS.md` 是 l10n 目录的专用规则文件。

## CI/CD

- `luminous-cd.yml` 在 Flutter Web 构建前新增 secrets 存在性校验步骤，确保 `LUCENT_BASE_URL` 和 `SENTRY_DSN` 已配置，防止空字符串注入 `--dart-define`。
- `luminous-cd.yml` 的 Flutter Web 发布构建为纯 dart2js + canvaskit（不用 `--wasm`：wasm 默认渲染器 skwasm 在移动浏览器有布局 bug，2026-07-23 修复记录），服务移动 web 主战场（安卓 Chrome / 鸿蒙过渡）；桌面/大屏 Web 冻结，不扩展构建形态。

## 2026-08-14 文档覆盖映射

- `docs/doc-map.yaml` 新增 `core-analytics` 规则（`lib/core/analytics/**` → 迁移日志 + Product_Safety_Privacy），产品测量代码纳入覆盖检查。
