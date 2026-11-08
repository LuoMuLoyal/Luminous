# Luminous Plans

Use this directory for active, repo-local execution plans that are too detailed for
`docs/TODO.md`.

## What Goes Here

- multi-step implementation plans
- review/handoff checklists for a specific Luminous task
- temporary task docs that are still actively driving work

## What Does Not Go Here

- current product facts: no narrative docs — assert in tests, constrain in feature READMEs
- next work ordering for the repo as a whole: put that in `docs/TODO.md`
- historical change logs: put those in `docs/logs/migration-log/YYYY-MM-DD.md`
- completed plans that no longer drive work

## Naming

Use task-specific names such as:

```text
YYYY-MM-DD-short-task-name.md
```

## Lifecycle

1. Create or update the plan here while the task is active.
2. Execute the task and verify it.
3. Move stable decisions and outcomes into the owning docs.
4. Delete the plan file once it is no longer the active source of work.

## Current Plans

> 更新于 2026-10-31。每份计划的状态以文件自身头部的状态段为准；此处只列当前仍在驱动工作、
> 或已裁决暂缓但保留触发条件的计划。已执行完毕的计划按约定直接删除（文件已删），
> 历史记录见当日迁移日志。

| 计划 | 状态 | 备注 |
| --- | --- | --- |
| [`2026-10-31-ui-craft-gap-audit.md`](2026-10-31-ui-craft-gap-audit.md) | 待评审（问题清单已定稿） | 全 App 界面质量总账：**只写「错在哪 + 应该是什么样」，不写怎么改**。Nielsen **25/40**、技术五维 **10/20**、认知负荷 8 项里 4 项直接失败。三个 P0：新用户无进入路径（`onboardingCompleted` 客户端无写入方、健康上下文只在「我的 → 个人档案」被动等待）、点提醒通知不打开剂次确认（闭环断在「已送达」）、离线重放静默丢附件 / 离线编辑重放删本地行。P1 集中在五处：已入队写入被告诉成「未保存」（`pendingCount` 零调用方）、可访问性三缺（语义名 7/36、`liveRegion` 全库 0、系统字号被钳到 1.2）、反馈体系断了（同步层有结构，界面只有重试/丢弃）、领域无关原语层无人认领（34 种徽章 / 20+ 空态 / 8 个错误视图 / 7 种分组标题 / 5 套骨架）、排版靠手抄（`fontWeight:` 295 处、`letterSpacing: 0` 21 处）。**颜色/间距/圆角/字号四类已收干净**（`fontSize:` 全库 1 处），剩余逸出是三层不存在的 token（字重字距 / 控件几何 / 图标角色）。同时记录 `--clean-layers` 当前 **26 条红灯**、golden 为 0 |
| [`2026-10-31-openapi-codegen-migration.md`](2026-10-31-openapi-codegen-migration.md) | 未开工（评估结论已落地，待评审） | 生成器 `dart-dio` → **`degenerate` 0.5.0**（OAS 3.2 + 类型安全 SSE）。**实测修正旧结论**：openapi-generator 7.26.0 仍读不了 `openapi: 3.2.0`（`attribute openapi is unexpected`，`--skip-validate-spec` 会静默产出零文件），但 dart-dio 的 nullable bug 爆炸半径被高估（`$ref`+`required`+`anyOf[T,null]` 与 inline `type:[object,null]` 在 7.26.0 上均生成正确的 `T?`）。用真实契约实测 `degenerate`：440 文件 `dart analyze` 零 issues、往返/相等/缺 key 全正确。**关键缺陷**：`executeStreaming` 执行 `parseSseStream(bytes).map((e) => e.data)`，**丢弃 `event:` 名**，类型判别退化为按 payload 结构试解析 → `done` 帧 `{}` 直接 `No variant matched`。故 **P0 必须先做 SSE 帧协议自描述化**（每帧 data 加 `type`，业务语义不得再依赖 `event:` 名），再 P1 升 3.2 + 手工注入 `itemSchema`（NestJS 产不出），P2 换生成器（新旧产物并行 + 快照基线），P3 迁移 119 个引用文件，P4 删手写 SSE 与 build_runner 链路。**头号风险**：单人项目（153/157 commits 一人，5 stars，0.x，bus factor 1）→ 精确 pin + 产物入库可 vendor 对冲；**禁止启用生成器的 `AuthInterceptor`**（refresh 必须走单飞 `refreshSession()`，否则触发重放检测撤销整族） |
| [`2026-10-28-composable-tabs.md`](2026-10-28-composable-tabs.md) | 进行中（A1–A4 主干已通：五个表面登记 + 编排 UI + 响应式三档 + 跨表面挂载；A5–A7 未开始） | 目标级别 **L3：同一组件可挂到多个 tab**。三个维度正交：全局 `ComponentRegistry` + 每 surface 挂载清单 + 用户 `SurfaceLayout`；**组件 id 按域命名（`summary.metrics`/`dose.risk_overview`）不带 tab 前缀**（旧版 `<tab>.<component>` 等于禁止跨 tab 复用）；删 `ComponentZone`，首屏由默认布局前 N 项表达。**布局与 tab 配置以后端为权威 source of truth**：Lucent 新增 `GET /layouts` 与 `PUT /layouts/:surface`（`payload` 服务端不解释、只校验 `schemaVersion` 区间与 `version` 单调），客户端 drift `ui_layouts` 缓存表 + `pending_sync_queue` 离线队列 + 409 `ifVersion` 冲突以服务端为准，与 cache-first（ADR-0006）同构。依赖只加一个：`flutter_reorderable_grid_view ^5.7.0`（编排网格拖拽）；三档跨列改用 `Row` + `Expanded(flex: span)` 自实现（`flutter_layout_grid` 实测放弃：自动放置放不了跨列项，且子项被塞进内部 shrink-wrapping viewport，含 Forui `FBadge` 的卡片会崩）；其余用既有 riverpod/freezed/hive_ce/genui，**Forui 优先不做 Material**。阶段：A0 骨架+规则口径 → A1 现有组件全量登记（零视觉）→ A2 显隐/排序（含后端持久化）→ A3 尺寸档+强类型选项/变体 → **A4 跨表面挂载（L3 开关）** → A5 各 tab 补组件（用药 10 个已存在未调用端点 / 回顾单多维+legacy 并入 / 记录月历需 Lucent `GET /daily-records/month-overview` / 我的快捷操作库）→ A6 底部 tab 图标/名称/顺序（**上限 5 个，不可新增**）→ A7 每 tab 生成式组件（`genui` + Lucent `POST /layouts/:surface/generate` SSE）与 `assistant.chat`。**A0 先把 `clean_layers` 的 `cross_feature_import` 对齐 `AGENTS.md` 与 `layered_import` 已有的 providers 接缝豁免**，否则 L3 过不了门禁 |
| [`2026-10-27-local-storage-overhaul.md`](2026-10-27-local-storage-overhaul.md) | 未开工 | 三项独立整改：**P0** 补全 cache-first 覆盖面（23 个 repository 只有 4 个读缓存；`fetchSummary` 以「derived data」为由跳过缓存，导致首页首帧必出骨架屏）；**P1** shared_preferences → `hive_ce`（破坏性，不迁移旧偏好）；**P2** 引入 SQLCipher 加密本地库（破坏性，检测到明文库即删除重建）。同时删除误导性的 `PrefKeys.accessToken/refreshToken` 与 `SharedPrefsLucentSessionStore`。修订 ADR-0006 §4/§5 |
| [`2026-10-27-icon-family-consolidation-lucide.md`](2026-10-27-icon-family-consolidation-lucide.md) | 待评审 / 未开工 | iconMind 弃用，统一 Lucide 单族；实测 iconMind 资产墨迹极差 2.36 倍（Lucide 1.58 倍），导致 `size: 14` 实际画出 9.3~11.7px；迁移面仅 **5 个语义位 / 6 个调用点 / 2 个文件**；衬底（`SoftIcon` 44px 容器装 24px 字形）与 iconMind 无关，单列 P3 |
| [`2026-10-23-harmonyos-arkts-web-shell-plan.md`](2026-10-23-harmonyos-arkts-web-shell-plan.md) | 待评审 / 未开工 | 鸿蒙改走 **ArkTS 壳 + ArkWeb 渲染 Web 产物**（放弃 Flutter 鸿蒙 SDK 路线，原因见 `docs/archive/2026-10-23/2026-10-23.md`）；壳工程放 **`Luminous/ohos/`** 同仓（先例：`native/` 的 KMP Gradle 工程）；Dart 允许改接缝（不再要求零改动）；头号风险是 ArkWeb 是否暴露 `dart.library.js_interop`（决定 drift 能否用）与 `localStorage` 是否持久化（决定登录态）；Phase 0 打穿 U1~U8 |
| [`2026-10-21-ddd-refactor-frontend.md`](2026-10-21-ddd-refactor-frontend.md) | **已冻结**（规则部分落地，C2/C5 暂缓，见文档 §9 收口状态） | **原「标准 DDD 全套」作废**（聚合根/领域事件/上下文映射/ADR-0010 均剔除）。口径已裁定：**严格 Clean**（`presentation` 只依赖 `application`+`domain`，**含 providers 也永不 import `data/`**）+ **DDD-lite**（16 个 feature 全部建 `application/`，use case 按用户意图切）+ **无白名单、无基线对账**（规则一律 error）+ **任一目录裸文件 ≤ 8**。实测 743 个非生成文件 / 3329 条边：`presentation→data` 114 边 / 94 文件（providers 内 51/40）、`application→presentation` 21/9、`data→presentation` 4/3、`data→他 feature` 72/39、`core→feature` 11/6、`domain` 禁依赖 15 文件、超 8 的目录 12 个 / 49 文件。阶段 C0 门禁 → C1 domain → C2 application（最大，20–25 天）→ C3 data → C4 presentation → C6 core → C7 目录；C5 跨 feature 接缝（666 边 / 219 文件）只建模式不限期清理。**按层切 7 个 worktree（W0–W6），不按 feature 切**。收口：C0/C1/C3/C4/C6/C7 已清零并合入，`--clean-layers` 门禁常驻；C2 只完成 3/16（record/settings/today），C5 剩 51 条跨 feature 复用，两者暂缓，等组件化计划 A0/A4 定下新的编排层形态后按其形态重启 |
| [`2026-10-17-copy-length-governance.md`](2026-10-17-copy-length-governance.md) | 改写完成，审计超限 0 | 按 Apple HIG / NN-g 定槽位长度阈值（实作比规范严 20%）；53 个 key 已改写；剩余 widget 测试断言同步与 41 条人工复核 |
| [`2026-09-15-review-remediation-plan.md`](2026-09-15-review-remediation-plan.md) | 进行中 | 09-08~09-14 审查报告逐条修复；剩余顺序 §3-5 → §3-9（合同级）→ §4 共 20 项 → §5-2/3/4 → §6 |
| [`2026-09-07-record-mini-trend-plan.md`](2026-09-07-record-mini-trend-plan.md) | 未开工 | Wave 1 客户端聚合，不跨 feature 消费 review；与已删除的 review 页重组计划构成阶段 1 的另一半 |
| [`2026-09-02-agentic-proactive-evolution.md`](2026-09-02-agentic-proactive-evolution.md) | Phase 0 起未开工 | 配套 `Lucent/plans/2026-09-02-agentic-proactive-evolution.md` |
| [`2026-08-22-medium-to-large-migration-inventory.md`](2026-08-22-medium-to-large-migration-inventory.md) | 八项 Task 均未开工 | Task 3（架构门禁）已由 `tool/luminous_lints` 的 `layered_import` 规则部分承接（warn 观察模式） |
| [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md) | 已决事项权威源 | 优先于各 08-16 计划中尚未清理的旧「不确定点」表述 |

### 功能盘点改造计划（2026-08-16，共 8 份保留）

来源:`research/02-功能盘点/` 十份调研文档(已审阅;内容以各文档「逐功能分析」为准改写,
速览表/结尾汇总仅作参考)。跨功能域共用的内容只在顺序靠前的计划里写全,靠后的计划只做引用;
桌面/Web 产品方向以已接受的 ADR-0008 为准：Flutter Desktop 与 PC Flutter Web 停止产品扩展；
独立 Next.js + Tauri MVP 在 0.1.0 后启动。

2026-08-22 起，十份计划的 0.1.0 前工作视为完成并进入响应契约硬切窗口；保留的 0.1.0 后工作
继续执行，但不与本次契约迁移混合。全局执行顺序(靠前先执行)：

| 顺序 | 计划 | 剩余项 |
| --- | --- | --- |
| 1 | [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) | F-7 环境真实化、F-6 health_sync 自动同步（均 0.1.0 后）；投递三通道与 JPush 密钥已完成 |
| 2 | [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) | F-5 P2 后端统计对象（0.1.0 前）、F-2 停用/归档（0.1.0 后） |
| 3 | [`2026-08-16-scan-search-remediation-plan.md`](2026-08-16-scan-search-remediation-plan.md) | 本批任务全部完成；剩余 F-2 条码等值匹配（0.1.0 后） |
| 4 | [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md) | F-8 `remainingCount` 退役（0.1.0 前）、F-14 环境装配（0.1.0 后） |
| 5 | [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md) | P1-3 餐食分层、P1-4 vital 时间序列（0.1.0 后）；P2-3/P2-4 桌面高级能力冻结 |
| 6 | [`2026-08-16-health-event-remediation-plan.md`](2026-08-16-health-event-remediation-plan.md) | H-4 kind 筛选、weightKg 时间序列、conditions 上下文（均 0.1.0 后） |
| 7 | [`2026-08-16-report-remediation-plan.md`](2026-08-16-report-remediation-plan.md) | R-3/R-4 已完成；剩余 R-5 服务端 409 双保险（0.1.0 前）与 R-6 文档漂移 |
| 8 | [`2026-08-16-mine-settings-remediation-plan.md`](2026-08-16-mine-settings-remediation-plan.md) | P1-3 图片质量 / 仅 Wi-Fi 同步（0.1.0 后） |
| 9 | [`2026-08-16-engineering-backend-plan.md`](2026-08-16-engineering-backend-plan.md) | 基座保留；计划态投入（Worker 分离 / rnacos / SaaS / monorepo）暂缓，触发条件见 P2-A~D |
| 10 | [`2026-07-29-native-bridging-roadmap.md`](2026-07-29-native-bridging-roadmap.md) | 后台同步与推送两节已由通知横切计划接管；剩余 Live Activity / 快捷方式 / 桌面热键 |

### 方向性计划（非执行清单）

| 计划 | 状态 |
| --- | --- |
| [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md) | 方向已决策（ADR-0008 accepted），0.1.0 后启动 |
| [`2026-08-14-flutter-3.47-upgrade-plan.md`](2026-08-14-flutter-3.47-upgrade-plan.md) | 配置类改动已落地（`refactor` 分支）；全量测试被上游 `flutter/flutter#191095` 阻塞 |
| [`2026-07-10-legal-compliance-pages.md`](2026-07-10-legal-compliance-pages.md) | 仅剩 P2-1（ICP 备案号 + About 公司信息），等备案号 |

## 已执行完毕、文件已删的计划

- `2026-11-01-desktop-visual-direction.md`（桌面端视觉改造：响应式布局改用
  `fluid_adaptive`、三层底色、侧边栏分组、右侧详情面板、间距 24/20/14 与桌面行高、
  玻璃顶栏与窗口下限；同时修掉「桌面双列从未生效」与「尺寸胶囊深底深字」两个存量缺陷）。
  **遗留**：ADR-0008 修订提案（桌面端恢复为在产目标）已留档在
  `docs/logs/migration-log/2026-11-01.md`，尚未落地。

- `2026-10-20-native-bridge-pilots.md`（原生桥接试点：步数 KMP + 后台同步 workmanager，代码与 CI 已收尾；真机验证遗留见 `docs/TODO.md`）、`2026-10-18-assistant-chat-ui-migration.md`（flow_ui → flutter_gen_ai_chat_ui 渲染层替换）、`2026-10-16-client-capability-gaps.md`（深链 / OAuth 内嵌 WebView / 图片缩放 / 日历回写 / 许可清单）、`2026-09-07-review-page-restructure.md`（Review 页重组）、`2026-09-07-large-file-domain-splitting-plan.md`（大文件拆分）、`2026-09-06-account-profile-restructure.md`（账号体系重构）、`2026-08-31-doc-governance-overhaul-plan.md`（文档治理）、`2026-09-15-meal-analysis-rearchitecture.md`（餐食分析重构）、`2026-08-07-product-loop-program.md` 与 `2026-08-07-visit-summary-and-product-measurement.md`（事件主导产品闭环）、以及 08-16 那批里的「AI 助手改造计划」——结论已沉淀进 feature README、`docs/reference/` 与当日迁移日志。
