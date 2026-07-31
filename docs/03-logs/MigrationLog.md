# Luminous Migration Log

Last updated: 2026-07-27

Records changes after the full reset only. Detailed entries are split by date under
`docs/03-logs/migration-log/`. Pre-2026-07 entries are archived under `docs/04-archive/migration-log/`.

Pre-reset history and inactive long-form docs were moved outside git to the workspace-level archive,
under the `docs-archive/2026-06-06-doc-cleanup` folder.

## How To Update

- Add new entries to `docs/03-logs/migration-log/YYYY-MM-DD.md`.
- If a date file does not exist yet, create it with the title `# Migration Log - YYYY-MM-DD`.
- Keep newest date files listed first in this index.
- Move older entries to `docs/04-archive/migration-log/` when they are no longer part of the active sprint.
- Use concrete dates. Do not move old history back into this index.

## Active Entries

- [2026-07-31](migration-log/2026-07-31.md) — 7-31 审查修复（血压 systolic/diastolic 配对逻辑从 Repository 移至 Mapper 利用原始 HealthDataType 精确区分 + 去重 pageSize 200→2000 + elk_icon_picker 版本约束 ^0.1.3）
- [2026-07-30](migration-log/2026-07-30.md) — Health Data Integration（health_data feature + vital/activity payload + OAuth 微博/谷歌 + OCR 防御 + Record source 字段）
- [2026-07-27](migration-log/2026-07-27.md) — 7-26 审查修复（_parseOptionalDateTime 防御性 FormatException 捕获 + changeEmail 复用 _parseOptionalDateTime + 网络错误时保留 session store）+ EnvelopeInterceptor 拦截器层统一校验业务 envelope
- [2026-07-18](migration-log/2026-07-18.md) — 审查修复（PrefKeys 遗漏 key 补齐 + SuggestionJsonCodec 缓存反序列化容错 + isPublicRoute 硬编码提取为常量集合）
- [2026-07-17](migration-log/2026-07-17.md) — 审查回查验证（luminous-review-2026-07-17.md 全部 5 项问题已修复验证）
- [2026-07-16](migration-log/2026-07-16.md) — SSE 错误映射去重 + 测试断言修复 + SemanticColor 暗色对比度 + Drift 缓存一致性
- [2026-07-15](migration-log/2026-07-15.md) — 7-15 审查遗留问题全部修复
- [2026-07-14](migration-log/2026-07-14.md) — 7-14 审查报告改写为 Bug 修复计划 + Bug 修复执行 + 测试补测（第七~十一批）+ 集成测试补充
- [2026-07-13](migration-log/2026-07-13.md) — 7-12 审查回查文档关闭（枚举命名重复问题不修复，审查计划文档删除）
- [2026-07-12](migration-log/2026-07-12.md) — 审查修复 + 历史兼容代码清理 + ARB 拆分 + 测试补测（第四批/第五批）+ Material Icons 清理 + Drift Web 适配 + Report 历史建议接入 + CI compact reporter + 文档口径同步 + 文档与代码偏差修复
- [2026-07-11](migration-log/2026-07-11.md) — 审查修复 + 测试补测（第一批~第三批）+ Patrol 统一迁移 + flutter_markdown_plus 升级 + Sentry 集成 + OAuth-only 注销 + 法律合规页面 + 网站法律页面补齐
- [2026-07-10](migration-log/2026-07-10.md) — 审查修复 + 测试补测（第四批/第五批）+ ADR-0006~0010 实施（riverpod_generator / authGuarded / 网络层拆分 / Result 类型 / Drift 离线缓存 / go_router_builder）+ UI 刷新计划完成
- [2026-07-09](migration-log/2026-07-09.md) — debugPrint → Talker 迁移 + 文档治理 + pre-push 钩子 + CI 简化 + 审查报告快速修复 + Today 建议引擎后端架构规划 + Today 建议引擎前端接入 Phase 1-9
- [2026-07-08](migration-log/2026-07-08.md) — OpenAPI 生成器迁移 + Today 重构 + 7.8 审查修复 + Medicine Phase 1 + slot-aware 打卡 + Record/Mine 收尾 + 生成物边界治理 + Git 钩子轻量化
- [2026-07-07](migration-log/2026-07-07.md) — 审查修复 + 开发者选项 + Talker 迁移 + 开源标准文档
- [2026-07-04](migration-log/2026-07-04.md) — Doc coverage warning automation + phase guide
- [2026-07-03](migration-log/2026-07-03.md) — Docs restructure + Forui debt closeout
- [2026-07-02](migration-log/2026-07-02.md)
- [2026-07-01](migration-log/2026-07-01.md)

## Archived Entries

Browse `docs/04-archive/migration-log/`.

## Quick Navigation by Topic

Major changes grouped by area:

- **Auth / OAuth** (WeChat, Apple, QQ login, security)
  - Key Dates: 05/30, 06/02, 06/10, 06/29
- **UI / Routing** (GoRouter, StatefulShellRoute, back button unification)
  - Key Dates: 06/04, 06/05, 06/07, 06/11, 06/26, 06/27, 06/28, 06/30
- **API / OpenAPI Client** (regeneration, contracts, network layer)
  - Key Dates: 06/01, 06/03, 06/06, 06/12, 06/13, 06/30, 07/08
- **Medicine** (search, dose logs, reminders, workspace)
  - Key Dates: 06/02, 06/04, 06/06, 06/09, 06/23, 06/25, 06/28, 07/08
- **Report** (dashboard, generation, export)
  - Key Dates: 06/06, 06/09, 06/19, 06/22
- **Today Dashboard** (analysis, recommendations, empty states, suggestion engine)
  - Key Dates: 06/07, 06/09, 06/10, 06/14, 06/28, 07/08, 07/09, 07/10, 07/11, 07/12
- **Daily Records** (fast entry, candidate generation, offline cache)
  - Key Dates: 06/09, 06/10, 06/12, 06/16, 06/20, 07/10, 07/11, 07/12
- **Settings / Mine** (profile, health context, preferences, legal)
  - Key Dates: 06/08, 06/12, 06/17, 06/26, 07/11, 07/12
- **Assistant** (AI chat, tool integration, Markdown rendering)
  - Key Dates: 06/15, 06/18, 06/30, 07/11
- **Tests** (unit, widget, integration, full-stack E2E, Patrol)
  - Key Dates: 06/06, 06/07, 06/11, 06/13, 06/30, 07/08, 07/09, 07/10, 07/11, 07/12
- **CI / Tooling** (melos, git hooks, GitHub Actions)
  - Key Dates: 06/05, 06/13, 06/30, 07/08, 07/11, 07/12
- **Docs / Governance** (migration log, guardrails, architecture, ROADMAP alignment)
  - Key Dates: 06/07, 06/08, 06/30, 07/03, 07/07, 07/08, 07/09, 07/12
- **Infrastructure** (Riverpod codegen, network layer, Drift, Sentry, routing)
  - Key Dates: 07/10, 07/11, 07/12
- **Localization** (ARB splitting, i18n)
  - Key Dates: 07/12
