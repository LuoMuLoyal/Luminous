# 文档治理演进：文档面审计先行 + 结果合规

> 创建于 2026-08-30，同日重写为 v2。v1 聚焦「同步机制」；经评审与业界实践对照，确认更根本的问题是**文档面从未做过存在性审计**——同步做得再好，同步的可能是本不该手写维护的内容。v2 将文档面审计提前为 Phase 0，并记录用户决策。v1 中验证有效的机制（生成器、结果校验、custom_lint、doc-map 退役）全部保留并修订。

## 一、背景与问题重定义

### 1.1 表层问题：过程门禁的误报

当前机制：`scripts/check_doc_coverage.dart` 读取 `docs/doc-map.yaml`（手工维护的 code glob → `docs_required` / `docs_any_of` / `docs_info` 三级义务），按 git 变更文件集合匹配规则命中义务（pre-commit 阻断），`--verify` 另做结构校验。这是典型**过程门禁**：「改了 X 目录必须改 Y 文档」，过程推断必然误报，根因四类：

| 根因 | 实例 |
|------|------|
| 规则与代码结构耦合：改名后规则失同步 | `report/` → `review/` 改名后规则仍指 `lib/features/report/**`（2026-08-30 已人工修复） |
| glob 粒度粗：目录内任何变更触发同一组义务 | 改一个 util 与改整个页面义务相同；新增 `lib/features/x/README.md` 也被当作代码变更要求迁移日志 |
| 义务取决于「改了什么」而非「实质」 | 改 l10n 文案不必然改 `Active_UI_*`；按目录推断双向误报 |
| 人工维护滞后 | `--verify` 全覆盖检查只是事后报错，不能事前生成 |

### 1.2 业界参照（v2 新增）

大项目「文档不漂移」的一致做法：

- **参考文档 100% 生成**：Rust rustdoc、Go godoc、NumPy docstrings、Kubernetes API reference。没有大项目手写 token 表、路由表、模块清单——那是代码的投影，手写即漂移。
- **文档断言要么可执行、要么删**：Rust doctest 把文档中的代码块在 `cargo test` 中编译执行，接口一变示例即红。推论：**不能被机器验证的断言，注定漂移**。
- **大项目几乎不存在「现状叙事」文档**：现状 = 代码 + 生成的 reference + golden/测试。它们维护的是决策（ADR/KEP）、流程（CONTRIBUTING）、教程（少而精）。
- **变更记录就是 git**：Conventional Commits + 自动 CHANGELOG（release-please 等），没有第二个记账本。
- **Diátaxis 四分法**（教程/操作指南/参考/解释，diataxis.fr；另见《Software Engineering at Google》文档篇）：按读者需求组织文档，而非按代码目录组织义务映射——后者正是业界已放弃的形态。

### 1.3 本项目的「圈内束缚」（对照确认）

- `docs/00-current/Active_UI_*.md` 5 篇「现状叙事」文档：断言与 golden/widget 测试大面积重叠，业界不存在此形态。
- Obsidian PKM 形态（front-matter `owner`/`quadrant`、MOC 索引、编号目录）被搬进代码仓库，而 Obsidian 实际打开频率极低（2026-08-30 确认）。
- 治理机制重复建设：Lucent(TS) 与 Luminous(Dart) 两套 doc-map 合计 48 条规则近 700 行；两仓治理策略面临分叉。
- **规则数量是文档面大小的函数**：AGENTS.md 90+ 行文档规则、doc-map 30 条规则，本质是文档面过大的投影。治本不是让规则更聪明，是让规则失去大部分约束对象。

## 二、问题本质与原则

文档漂移的根源只有一个：**文档是代码的副本，副本与源必然漂移**。成熟方案两条路：消除副本（生成化 / 单一事实源）；校验结果而非过程（零推断）。

v2 新增原则：**先做存在性审计，再做同步基建**。顺序颠倒会把生成器建在应删文档上。

### 六支柱（修订）

```
A. 派生文档（token/路由/模块清单）  → 生成器 + CI diff 校验，零手写
B. 代码旁文档（模块 README/doc comments） → 就近原则，同 diff 原子变更
C. 高频行为文档（UI 状态/文案）      → 测试/golden/ARB 承接，文档删除
D. 决策与变更记录                    → plans（事前裁决）+ 迁移日志（事后事实），不建第三本账
E. 结构规则（分层/注册/命名）        → custom_lint IDE 实时反馈
F. 低频叙事文档                      → freshness + 引用完整性 + 正文路径校验兜底，只减不增
```

终局架构中没有「变更门禁」层：义务要么被生成消除（A）、被结构固化（B）、被测试承接（C）、有独立归宿（D）、前移到编码时刻（E）、降级为快照（F）。`doc-map.yaml` 最终退役，仅保留 `--verify` 结构检查。

## 三、已确认决策（2026-08-30，用户拍板）

1. **迁移日志保留必写义务**：回溯价值明确。改进仅限降低写作成本（Phase 1.4，可选）。不引入 ADR 第三本账——决策记录 = plans（事前）+ 迁移日志（事后）。
2. **front-matter 保留时间字段**：`updated` 必留；`created` 由 git 历史推导，不新增字段；`quadrant`/`audience` 等 Obsidian 导航字段进入 Phase 0 评估。
3. **冻结手写「现状叙事」文档的新增**。
4. **迁移路径顺序**：Phase 0 → 1 → 2 → 3，Phase 0 优先于一切同步机制建设。
5. **docs 目录去编号重建**：按读者需求（Diátaxis）语义组织，目标结构见 Phase 0「目标结构」小节；设计不参考 Lucent 现有 docs 形态。
6. **Lucent 不在本次范围**：Phase 3.4 的 Lucent 对齐另行立项，执行时以同一套原则从头设计，不参照其现有结构。

## 四、迁移路径

### Phase 0: 文档面存在性审计（v2 新增，最优先）

#### 目标结构（v2 设计，不参考 Lucent 现有形态）

```text
Luminous/docs/
  README.md          # 唯一索引（每个子目录一行说明 + 存活文档列表）——替代 _MOC.md / Current_State.md 索引职能
  explanation/       # 解释：「为什么」（治理、愿景、架构原则）——低频稳定，无门禁，updated 兜底
  product/           # 产品域：IA、范围、安全隐私——低频，与代码节奏无关，updated 兜底
  reference/         # 参考：「是什么」——生成优先；手写解读用 generated region 与生成区块共存
    adr/             # 存量 ADR 平移（不可变，只读；决策 1 后不再新增）
    generated/       # 全生成区（Phase 2 产物，文件头 auto-generated 标记，diff 校验兜底）
  howto/             # 操作指南：「怎么做」——少而精，新增须过四问；正文路径校验兜底
  logs/
    migration-log/   # 保留（决策 1）；MigrationLog.md 索引随迁
  archive/           # 原 04-archive 整体平移，此后只进不出，不维护
```

设计要点：去 `0X-` 编号前缀（Obsidian 排序形态），**目录名即腐烂策略**——explanation/product 不参与门禁，reference 生成优先，howto 正文校验，logs 只追加，archive 只进不出。`Glossary.md` → reference/；02-reference 内一次性分析/迁移过程文档（architecture-upgrade-analysis、Design_System_Migration 等）由审计表裁决，archive 候选；`.obsidian/` 为编辑器配置非文档，随 Obsidian 使用情况决定，本计划不动；逐篇归属由 0.1 审计表裁决，以上仅目录骨架与迁移方向。

- [ ] 0.1 逐篇四问审计：谁读？读完做什么？断言能否机器校验？腐烂速度？产出审计表（docs 内每篇一行：读者 / 用途 / 断言承接 / 裁决）
- [ ] 0.2 现状叙事与快照文档裁决（00-current 内 7 篇：`Active_Mobile_UI`、`Active_UI_*` 5 篇、`Desktop_UI`；含 `Lucent_Contract_Snapshot`、`Runtime_Snapshot` 等快照类）：默认方向删除或归档（golden/测试/生成物已承接断言，契约以 openapi.json 为单一事实源）；有保留价值的降为低频快照
- [ ] 0.3 front-matter 精简：去除 `quadrant` 等导航字段（评估后执行）；**先改 `check_doc_coverage.dart` 的 front-matter 校验逻辑，再改文档**，避免检查器先红
- [ ] 0.4 索引与状态文件归并：`Current_State.md`、`_MOC.md` 的索引职能并入重写的 `docs/README.md`（唯一索引）；`Next_Plan.md`、`TODO.md` 与 `plans/` 职能重叠，评估归并
- [ ] 0.5 AGENTS.md 文档规则段与 doc-map 规则按审计结果同步缩减
- [ ] 0.6 docs 目录重建（去编号）：按上方「目标结构」执行。顺序：先改检查器硬编码（`_collectVaultLinkedPaths` 的 `03-logs/`、`04-archive/` 前缀豁免、「move to 04-archive」文案、front-matter 目录 scope、`00-current/TODO.md` 注释），再 `git mv` 平移存活文档（保留历史），删除 `_MOC.md` 与编号目录壳
- [ ] 0.7 验收：文档面篇数较审计前 -50%（以审计表为准）；被删断言 100% 有测试/生成物承接；全仓无 `0X-` 编号路径引用残留（AGENTS.md、doc-map、检查器、文档互链）；所有删除 git 可回滚，有疑义先归档再评估

### Phase 1: 止误报（重排，纯减法先行）

- [ ] 1.1 纯减法豁免（v1 1.2/1.3 合并先行）：`lib/**/*.md` 与 `docs/` 内变更不触发 docs-tooling 规则
- [ ] 1.2 正文路径校验（v2 新增）：`--verify` 增加「文档正文引用的 `lib/**`、`docs/**` 路径存在性校验」，零误报；直接消除 review 改名类漂移（AGENTS.md `/report`、CLAUDE.md tab 实例）
- [ ] 1.3 缺失规则草案自动生成（v1 1.1，降级为可选）：仅在 1.1 落地后误报仍高频时投入——给将退役的 doc-map 写自动化性价比低
- [ ] 1.4 迁移日志成本优化（可选）：commit message 驱动的日志草稿脚手架（解析 Conventional Commits 的 type(scope)+摘要生成条目骨架，人工补验证结论）；必写义务不变
- [ ] 1.5 验收：`--verify` 与 `--warning-only` 在既有变更集上零 required 误报；`flutter analyze` 0 issue；doc-coverage 测试更新

### Phase 2: 派生文档生成化（修订）

- [ ] 2.1 **generated region 标记机制（v2 新增，先行）**：`<!-- gen:<name>:start/end -->` 约定，生成器只重写区块内内容，手写解读（token 取用约定、分层职责）永不覆盖
- [ ] 2.2 token 清单生成器：`lib/core/design/{spacing,icon_size,semantic_color*}.dart` → `Design_System.md` token 段
- [ ] 2.3 路由清单生成器（**源修订**）：从 `lib/app/router.g.dart`（go_router_builder 产物，单一事实源）生成路由索引；弃用 v1「扫描各 feature routes.dart」方案——避免生成器自身成为新漂移源
- [ ] 2.4 feature 模块清单生成器（不变）：扫描 `lib/features/*` 生成模块清单
- [ ] 2.5 生成 + `git diff --exit-code` 校验，接入 daily checks 与 CI。**修正预期**：`verify_lucent_openapi_sync.dart` 实际只做存在性/布局校验，完整 diff 闭环需新写，非直接复用
- [ ] 2.6 doc-map 对应派生规则退役（Design_System token 段、路由相关 docs_any_of）
- [ ] 2.7 验收：改 token/路由后不跑生成器 CI 必红；不改代码则文档稳定；误报归零

### Phase 3: 实时规则与退役（对齐修订）

- [ ] 3.1 `custom_lint` 分层 import 规则（data→data、presentation→presentation）迁移为 analyzer 实时规则（`analyzer_plugin` 为无新依赖备选）
- [ ] 3.2 feature 结构规则：缺 README 等 → IDE 提示
- [ ] 3.3 模块 doc comments 规范：新代码模块级 dartdoc 覆盖，评估 `dart doc` 站点化
- [ ] 3.4 **Lucent 对齐（另行立项，不在本计划执行范围）**：Luminous 全部落地后，以同一套原则（四问审计、Diátaxis 目录、生成优先）对 Lucent docs 从头设计，**不参照其现有形态**；TS 实现，共享方法论不共享代码
- [ ] 3.5 doc-map 退役评估：仅保留 `--verify` 结构检查（引用完整性/front-matter/freshness/正文路径），删除 `--staged` 变更门禁，pre-commit 简化；退役前 `--warning-only` 并行观察两周
- [ ] 3.6 验收：pre-commit 无门禁误报；结构/分层规则 IDE 实时生效；`--verify` 通过；Lucent 对齐方案立项

## 五、不做的事（更新）

- **不再优化 doc-map 匹配逻辑**（类别规则、commit scope 驱动等）：都是过程门禁的改良，方向错误
- **不为新 feature 手工加 doc-map 规则**（1.3 可选草案除外）
- **不保留「变更必须改文档」的提交阻断**（最终形态下由 diff 校验与结构检查兜底）
- **不把测试写进文档**：文档内容若已被测试断言，删除文档而非复制测试
- **不引入第三方文档平台**：生成器 + Markdown + git 完成闭环
- **冻结新增手写「现状叙事」文档**（决策 3）
- **不引入 ADR 第三本账**：决策记录 = plans + 迁移日志（决策 1）
- **plans 与迁移日志不互相复制内容**：plan 只记规划与裁决，日志只记事实与验证

## 六、风险与注意事项（更新）

1. **生成器与代码的同步义务**：生成器纳入 daily checks（生成物 diff 校验），避免「生成器过期」成为新漂移源
2. **custom_lint 依赖**：评估对 pubspec/CI 影响；`analyzer_plugin` 为无新运行时依赖备选
3. **Phase 0 删除的可回滚性**：git 历史可恢复；有疑义先归档 `04-archive`
4. **front-matter 精简联动**：先改 `check_doc_coverage.dart` 校验逻辑再改文档
5. **生成器脚本自身是 code**：其变更照常触发迁移日志义务（不豁免）
6. **pre-commit 简化**：删除 `--staged` 门禁前确认 `--verify` 结构检查 + CI diff 校验已覆盖其保护价值，先并行观察两周
7. **与现有工作流兼容**：`run_daily_checks.dart`、`git_hook.dart`、`tooling_workflows.dart` 改动需同步 AGENTS.md doc 规则段
8. **plans/README.md 索引**：计划完成后按惯例删除本文并更新索引

## 七、验收总览

- Phase 0 后：审计表完成，文档面 -50%，被删断言 100% 承接，规则同步缩减，docs 目录去编号重建完成（README 唯一索引）
- Phase 1 后：当前所有已知误报场景（README 触发、docs 内变更、目录改名）消失，正文路径校验上线
- Phase 2 后：token/路由/模块清单类文档零人工维护，generated region 机制运行
- Phase 3 后：`doc-map.yaml` 变更门禁语义消失仅剩结构校验；分层规则 IDE 实时生效；Lucent 对齐立项
