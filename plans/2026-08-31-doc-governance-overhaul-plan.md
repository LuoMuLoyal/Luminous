# Luminous 文档治理改进计划 — 2026-08-31

> 生命周期:本文件位于 `plans/*.md`,计划执行完毕后按惯例整体删除并更新本目录 README 索引。
> 范围:仅 Luminous。与 Lucent 同日计划(plans/2026-08-31-doc-governance-overhaul-plan.md)
> 共享方法论,不共享代码(一 Dart 一 TS,各按生态落地)。
> 血统说明:本计划接替 `2026-08-30-doc-governance-evolution.md` 的未执行设计(该文件已从
> 工作区删除、未提交,git 历史可溯)。v1/v2 中验证有效的机制(生成器、generated region、
> custom_lint、doc-map 退役、四问审计、去编号重建)全部继承;并沿用
> `2026-08-30-directory-structure-cleanup.md` 已实践过的"审计 → 清单 → 批次 → DoD"格式。

## 1. 背景与问题本质

- 现行 `scripts/check_doc_coverage.dart` + `docs/doc-map.yaml`(约 30 条规则)是**过程门禁**:
  "改了 X 目录必须 touch Y 文档"。touch 合规 ≠ 内容正确。已知误报实例:`report/` →
  `review/` 改名后规则失同步(08-30 人工修复);新增 `lib/features/x/README.md` 也被当作
  代码变更要求迁移日志;glob 粒度粗导致改一个 util 与改整个页面义务相同。
- 更根本:**文档面从未做过存在性审计**。00-current 15 个文件中大量"现状叙事"
  (Active_UI_* 五篇等),其断言与 golden/widget 测试大面积重叠——业界不存在此形态。
- Obsidian PKM 形态残留:front-matter `quadrant`/`audience`、`_MOC.md`、`0X-` 编号目录;
  Obsidian 实际打开频率极低(08-30 确认)。
- 两仓 doc-map 合计 40+ 条规则、近 700 行,治理重复建设。**规则数量是文档面大小的函数**:
  治本不是让规则更聪明,是让规则失去大部分约束对象。
- 文档漂移的根源只有一个:文档是代码的副本。出路两条:消除副本(生成化 / 单一事实源);
  校验结果而非过程。**不能被机器验证的断言,注定漂移。**
- 约束层实证依据:`review/07-06 → 08-20` 共 42 份 Luminous 增量审查、397 条问题标题聚类,
  见 §7 引言表。

**已确认决策**(2026-08-31,与维护者对齐;与 Lucent 侧一致):

1. AI 指令单一来源:`Luminous/AGENTS.md` 唯一权威,CLAUDE.md / GEMINI.md /
   copilot-instructions.md 指针化。
2. 模块文档权威文件用 `README.md`,与代码同址;迁移日志保留按日粒度。
3. 模块级文档一次性全量下沉,不做长双轨。
4. 采纳 Phase 0 四问审计 + docs 去编号重建(接替 v2 意图)。
5. 决策记录 = plans(事前)+ 迁移日志(事后);既有 `adr/` 8 篇只读保留(不可变,
   只允许 supersede),不再平行新增账本。
6. front-matter:`updated` 必留;`quadrant`/`audience` 等 Obsidian 导航字段去除
   (先改检查器);`created` 由 git 历史推导,不新增字段。
7. 冻结手写"现状叙事"文档的新增。

## 2. 治理模型

### 2.1 六向处置(审计裁决词汇)

| 处置 | 含义 | Luminous 落点 |
| --- | --- | --- |
| 生成消除 | 内容是代码投影,由生成器产出 | token 清单、路由索引、feature 清单、l10n(ARB)、openapi 客户端 |
| 结构固化 | 内容是模块意图,与代码同址 | feature/core `README.md`(AI 改码时按需读取) |
| 测试承接 | 断言可机器验证,文档归档而非复制测试 | golden/widget 测试(承接 UI 现状断言)、e2e |
| 独立归宿 | 决策与变更各有唯一账本 | ADR(只读存量)、迁移日志、plans |
| 前移编码时刻 | 约束在写码时由 lint/IDE 反馈 | custom_lint / analysis_options 收紧 |
| 降级快照 | 低频叙事,仅 updated 兜底,只减不增 | explanation/、product/ |

### 2.2 目标 docs 结构(去编号,Diátaxis;目录名即腐烂策略)

```text
Luminous/docs/
  README.md          # 唯一索引(每子目录一行说明 + 存活文档列表),取代 _MOC/Current_State 索引职能
  explanation/       # 为什么:治理、架构原则——低频稳定,无门禁,updated 兜底
  product/           # 产品域:IA、范围、安全隐私——低频,与代码节奏无关
  reference/         # 是什么:生成优先;手写解读与生成区块共存
    adr/             # 存量 8 篇平移(不可变)
    generated/       # 全生成区(auto-generated 文件头,CI diff 校验兜底)
  howto/             # 怎么做:少而精,新增须过四问;正文路径校验兜底
  logs/
    migration-log/   # 保留按日;MigrationLog.md 索引随迁
  archive/           # 原 04-archive 整体平移,只进不出
```

`Glossary.md` → `reference/`;`.obsidian/` 为编辑器配置,本计划不动。

## 3. 执行总则

- 顺序:Phase 0 → 1 → 2 → 3 → 4;**先审计,后基建;先改检查器,再改文档**。
- 每 Phase 独立 commit(`type(scope): 中文摘要`),按纪律追加当日迁移日志条目。
- 生成器取数源只允许机器真相:`router.g.dart`(go_router_builder 产物)、
  `lib/core/design` token 源文件、目录枚举、`generated/lucent_api`——禁止扫描手写
  routes.dart 或文档。
- 每批次收尾 grep 全仓旧路径引用清零(AGENTS、doc-map、检查器、文档互链、
  workspace 根、Lumos-docs)。
- 文档处置统一归档:Phase 0 裁决为“删”的文档一律迁入 `archive/`(只进不出),
  不做物理删除;空目录壳等非文档清理除外。

## 4. Phase 0 — 文档面存在性审计(最优先)

范围:`docs/` 全部非生成文档(00-current 15、01-product 6、02-reference 约 15 + adr 8 +
how-to 5、README、_MOC、Glossary)、AI 指令四件套、plans 索引。ADR 与迁移日志预置保留。

四问:谁读?读完做什么?断言能否被机器校验(由谁承接)?腐烂速度?

预置方向(最终以审计表裁决为准):

- `00-current` 现状叙事七篇(Active_Mobile_UI、Active_UI_* 五篇、Desktop_UI 已 frozen):
  默认归档,断言由 golden/widget 测试承接,残余约束下沉 feature README;
- `Runtime_Snapshot` → 归档(pubspec/toolchain 为真相);`Lucent_Contract_Snapshot` →
  归档(openapi.json + generated client 为真相);`Mock_Or_Deferred` → archive 或 TODO 承接;
- `Work_Phase_Guide` → explanation/ 或归档;`Project_Governance` → explanation/;
- `Next_Plan`/`TODO` 与 `plans/` 职能重叠 → 归并评估(TODO 保留硬生命周期);
- `Current_State`/`_MOC` 索引职能并入重写的 `docs/README.md`;
- `01-product` 6 篇 → `product/`,逐篇四问(Tab_Component_Blueprint 疑似组件投影,
  生成化候选);
- `02-reference`:`Localization.md`(517 行)键清单是 gen-l10n 投影 → 砍为手写解读 +
  生成区块或归档;`Design_System`/`Design_System_Components` → token 段生成消除 + 手写
  解读保留;`Forui_Reference` → 只留本地约定,上游文档是真相;`AI_Development_Workflow`
  → explanation/ 或 AGENTS 承接;`Project_Guardrails` → 可执行约束承接 + 残余进 AGENTS;
  一次性迁移分析(architecture-upgrade-analysis、Design_System_Migration、
  Auth_Forui_Migration_Pattern)→ archive;
- `how-to/` 5 篇 → `howto/`,逐篇四问。

硬目标:存活文档面篇数较审计前 **-50%**(ADR、迁移日志、生成物、archive/ 均不计);
被归档/被下沉断言 100% 有承接(golden/widget 测试、生成物、feature README)。

- [ ] 0.1 逐篇四问审计,产出审计表(§11)
- [ ] 0.2 00-current 与 02-reference 按预置方向逐篇裁决
- [ ] 0.3 先改检查器:`check_doc_coverage.dart` 的目录 scope、`_collectVaultLinkedPaths`
      的 `03-logs/`/`04-archive/` 前缀豁免、front-matter 校验(去 quadrant/audience)、
      `git_hook.dart`/`run_daily_checks.dart`/`tooling_workflows.dart` 路径
- [ ] 0.4 AGENTS.md 文档规则段(90+ 行)按审计结果同步缩减

## 5. Phase 1 — 指令单一来源(约半天)

- [ ] 1.1 `AGENTS.md` 唯一规则源;`CLAUDE.md`、`GEMINI.md`、
      `.github/copilot-instructions.md` 各改为 `@AGENTS.md` 一行引用 + ≤2 行工具专属说明
- [ ] 1.2 验收:除 AGENTS.md 外仓库内无第二份规则正文副本

## 6. Phase 2 — docs 去编号重建 + 生成化 + feature README(约 2–3 天)

- [ ] 2.1 docs 重建:按 §2.2 执行——`git mv` 平移存活文档(保留历史)→ `_MOC.md`
      归档、移除空编号目录壳 → `docs/README.md` 重写为唯一索引
- [ ] 2.2 generated region 机制先行:`<!-- gen:<name>:start/end -->` 约定,生成器只重写
      区块内内容,手写解读永不覆盖
- [ ] 2.3 三个生成器(数据源均为机器真相):token 清单(`lib/core/design` token 源文件
      → `reference/generated/`);路由索引(`lib/app/router.g.dart`);feature 清单
      (目录枚举)。生成纳入 `run_daily_checks`,CI `git diff --exit-code` 校验,
      过期即红
- [ ] 2.4 feature README 全量:`lib/features/` 17 个(现仅 health_context、today 有),
      模板五段(≤60 行):职责与边界 / 对外契约(路由、导出 provider)/ 不变量 /
      依赖禁区 / 陷阱与决策(链 ADR);core 21 个子目录按四问筛选——有实质约定的
      (network、router、design、database、ai、feedback、i18n、errors 等)写,
      纯聚合目录免;每份 README 旁放一行式 `AGENTS.md`(`@README.md`)
- [ ] 2.5 联动清零:workspace 根 AGENTS/CLAUDE 中涉及本仓文档路径的引用(站点目录
      相关由另行计划统一处理,本计划不涉及)、`Lumos-docs/scripts/sync-docs.ts`、Lucent 侧
      引用,grep 旧路径清零
- [ ] 2.6 验收:全仓无 `0X-` 引用残留;存活文档面 -50%;README 缺失/超长进检查器

## 7. Phase 3 — 可执行约束(约 2–3 天,增量可插拔)

实证依据:42 份 Luminous 审查报告 397 条标题聚类,高频类别与防护映射:

| # | 问题类别 | 频率 | 代表案例 | 防护 |
| --- | --- | --- | --- | --- |
| 1 | 强制解包/空安全:`response.data!`、`firstWhere` 无 `orElse`、不安全 `as` | ~15 天 | `response.data!` 57 处专项(08-08)、Enum 解析无 orElse 10 处、router 参数强解包(08-19) | custom_lint:datasource 层禁 `!`;firstWhere 必须 orElse |
| 2 | 静默吞错/空 catch | ~10 天 | `catch (_)` 12 处(08-08)、token 刷新静默(08-14)、PushCoordinator 静默 | 空 catch 必须注释/日志(自定义 lint) |
| 3 | 重复造轮子 | 每报必有专章 | SSE 错误映射 ×3 连续多日、CustomTransitionPage ×5、`parseTimeOfDay`、输入 trim ×8 | AGENTS"先查 core"硬规则 + README 公共能力清单 |
| 4 | 魔法数字/硬编码 | ~8 天 | 超时/断点/schemaVersion/`DateTime(2020)`/提醒窗口 | `no-magic-numbers` 等价自定义 lint,先 warn |
| 5 | 生命周期/资源泄漏 | ~5 天 | TapGestureRecognizer 泄漏、ScrollController 未 dispose、Timer 未查 isActive | 内置 lints 收紧 + 约定 |
| 6 | 枚举/映射静默错标 | ~4 天 | `_mapPatternKind` 默认 medication、`_mapRange` 默认 last7Days | Enum 解析必须显式处理未知值 |
| 7 | 导航 API 不一致 | ~4 天 | 导航风格混用、`Navigator.pop` 路由错误、AppRoutes 未完全替换 | 禁直用 Navigator(除 core/router) |
| 8 | build 副作用/ref.read in build | ~4 天 | `_syncFromFirstPage` build 副作用(08-19 连续两报) | 约定进 README + review 清单 |
| 9 | 测试质量 | 背景性 | 覆盖率 ~33%、e2e 硬编码 ID | e2e 约定 + golden 承接 |

落地(每条先 warn 观察一周再转 error):

- **A. custom_lint / analyzer_plugin**:分层 import 规则(data→data、
  presentation→presentation;features 互不 import 除 barrel;core 禁 import features);
  禁直用 Navigator/GetX;`firstWhere` 必须 `orElse`;data 层禁 `response.data!`;
  空 catch 必须注释;Enum 解析必须显式处理未知值;`DateTime.parse` 必须走安全封装。
  `analyzer_plugin` 为无新依赖备选。
- **B. analysis_options 收紧**(审查记录的维护隐患 M3"规则较宽松"):
  `avoid_print`、`unawaited_futures`、`discarded_futures`、
  `use_build_context_synchronously`(Toast action 无 mounted 保护实例,08-16)。
- **C. 脚本检查**:正文路径存在性校验——扩展 `check_doc_links.dart`:文档正文引用的
  `lib/**`、`docs/**`、`plans/**` 路径必须存在(零误报,消灭改名类漂移);
  feature README ≤60 行断言。
- **D. 测试承接约定**:UI 现状断言一律 golden/widget 测试,不写进文档;e2e 不硬编码
  ID(08-20 实例)。

## 8. Phase 4 — doc-map 退役(约半天 + 两周观察)

- [ ] 4.1 `check_doc_coverage.dart` 删除"变更路径 → 必须 touch 映射文档"的 pre-commit
      阻断;先降级 `--report` 仅报告,**并行观察两周**确认 `--verify` 结构检查 +
      正文路径校验覆盖其保护价值后移除
- [ ] 4.2 `doc-map.yaml` 退役:仅保留 `--verify`(front-matter、90 天新鲜度、引用
      完整性、正文路径);`check_doc_links.dart` 承担正文路径校验
- [ ] 4.3 pre-push 汇总更新:`flutter analyze`(含 custom_lint)+ `flutter test` +
      生成器 diff 校验 + docs `--verify`;`run_daily_checks.dart`/`git_hook.dart`/
      `tooling_workflows.dart` 同步
- [ ] 4.4 验收:改动单个 feature 代码不再触发任何文档 touch 要求;90 天巡检与正文
      路径校验照常工作

## 9. 不做的事

- 不优化 doc-map 匹配逻辑(类别规则、commit scope 驱动等)——过程门禁改良,方向错误;
- 不为新 feature 手工加 doc-map 规则;
- 不把测试写进文档——已被 golden/widget 测试断言的内容归档而非复制;
- 不手写 l10n 键清单(ARB + gen-l10n 是唯一真相)、不手写 token 表、不为 OpenAPI 手写
  端点文档;
- 不引入第三方文档平台——生成器 + Markdown + git 闭环;
- 冻结新增手写"现状叙事"文档;
- plans 与迁移日志不互相复制:plan 只记规划与裁决,日志只记事实与验证;
- 不引入 ADR 第三本账(存量 adr/ 只读保留);不引入 Riverpod/GoRouter 之外的
  新状态或导航方案相关的文档承诺;
- Lucent 不在本次范围(其计划同日另行立项)。

## 10. 验收总览

- Phase 0:审计表完成;存活文档面 -50%;被归档断言 100% 承接;AGENTS 规则段同步缩减;
- Phase 1:指令文件唯一性成立;
- Phase 2:docs 去编号重建完成、README 唯一索引、feature README 全量、三个生成器 +
  generated region 运行、联动路径清零;
- Phase 3:custom_lint 与收紧后的 analysis_options 全绿(豁免均有注释理由);正文路径
  校验上线;
- Phase 4:变更门禁语义消失,`--verify` 保留,两周观察通过;
- 回滚:各 Phase 独立 commit 可单独 revert;新规则均以 warn 起步;归档操作均保留
  git 历史可回溯,复位只需从 archive/ 迁回。

## 11. 审计表(Phase 0 填充)

| 文档 | 读者 | 读完做什么 | 断言承接 | 裁决 |
| --- | --- | --- | --- | --- |
| (Phase 0 逐篇填充) | | | | |
