# 文档治理演进：从变更门禁到结果合规

> 创建于 2026-08-30。背景：`docs/doc-map.yaml` 手动维护的「代码路径 → 文档义务」映射（变更门禁）频繁误报，且每次目录改名/新增 feature 都依赖人工同步规则。本文档把文档治理从「过程门禁」迁移到「结果合规 + 单一事实源」，并给出分阶段迁移路径。

## 一、背景：现状机制与误报根因

当前机制：`scripts/check_doc_coverage.dart` 读取 `docs/doc-map.yaml`（手工维护的 code glob → `docs_required` / `docs_any_of` / `docs_info` 三级义务），根据 **git 变更文件集合**匹配规则，命中后要求提交附带对应文档（pre-commit 阻断）。`--verify` 另做结构校验（引用完整性、front-matter、新鲜度、feature 覆盖）。

该机制是典型的**过程门禁**：「你改了 X 目录，必须改 Y 文档」。过程推断必然误报，根因有四类：

| 根因 | 实例 |
|------|------|
| **规则与代码结构耦合**：目录改名/移动后规则失同步 | `report/` → `review/` 改名后 doc-map 规则仍指向 `lib/features/report/**`，`--verify` 报 `review: feature dir not covered`（2026-08-30 已人工修复） |
| **glob 粒度粗**：目录内任何文件变更触发同一组义务 | 改 review 下一个 util 与改整个页面，要求的文档相同；新增 `lib/features/x/README.md` 也被当作代码变更要求迁移日志 |
| **义务取决于「改了什么」而非「改了哪个目录」** | 改 l10n 文案不必然改 `Active_UI_*`；改路由不必然改 `routing.md`——按目录推断双向误报 |
| **人工维护滞后**：新目录、新约定靠人记得加规则 | `--verify` 的全覆盖检查只是事后报错，不能事前生成 |

## 二、问题本质：过程门禁 vs 结果合规

文档漂移的根源只有一个：**文档是代码的副本，副本与源必然漂移**。成熟方案只有两条路：

1. **消除副本**——能生成的文档不人工维护（单一事实源）
2. **校验结果而非过程**——不推断「你该改什么文档」，只校验「文档与代码是否一致」

本项目已有成熟样板：`scripts/verify_lucent_openapi_sync.dart`——CI 重新生成客户端并与代码 diff，**不一致就失败**，零误报（无推断，只校验结果）。本计划把该模式推广到全部派生文档，并逐步退役过程门禁。

## 三、终局架构（六支柱）

```
派生文档（token/路由/API/模块清单）   → 生成器 + CI diff 校验        [支柱 A]
代码旁文档（模块 README/doc comments） → 同目录同提交，义务自然消失   [支柱 B]
高频行为文档（UI 状态/文案）           → 测试/golden/ARB 取代        [支柱 C]
规范文档（ADR/架构/流程）              → 独立提案流程，不参与门禁     [支柱 D]
结构规则（分层/注册/命名）             → custom_lint IDE 实时反馈     [支柱 E]
低频叙事文档                          → freshness + 引用完整性兜底   [支柱 F]
```

**该架构中没有「变更门禁」这一层**：文档义务要么被生成消除（A）、要么被结构固化（B）、要么就近原子化（C）、要么独立治理（D）、要么前移到编码时刻（E）、要么降级为快照（F）。`doc-map.yaml` 最终退役或仅保留 `--verify` 的结构完整性检查。

### 支柱说明

- **A. 结果校验代替变更门禁（verify-sync 模式推广）**：`scripts/gen_docs.dart` 从代码生成 token 清单、路由表、feature 模块清单；CI 运行生成器后 `git diff --exit-code`。文档过期自动红，永远不误报（没有推断）。
- **B. 就近原则**：高频变化文档放代码旁边（`lib/features/x/README.md`、doc comments），与代码同一 diff 原子变更；`docs/00-current/Active_UI_*.md` 这类「远程副本」是漂移源，逐步淘汰。
- **C. 测试/契约取代叙事文档**：「现在是什么样」由 golden/widget 测试与 ARB 承担（可执行的行为文档）；Active_UI_* 降级为季度快照或删除。
- **D. 规范文档独立治理**：ADR/架构文档是「代码跟文档走」的方向，走独立提案流程，与「代码变更→文档义务」映射彻底解耦。
- **E. 结构规则实时化**：分层违规（data→data、presentation→presentation）、feature 缺 README、未注册路由等用 `custom_lint` / `analyzer_plugin` 在 IDE/analyze 中实时反馈（写代码时看到，而非提交时惊吓）。
- **F. 叙事文档兜底**：低频文档只做 freshness/引用完整性校验（`--verify` 现有能力），不强制随变更更新。

## 四、迁移路径

### Phase 1: 止误报（低风险，可立即执行）

- [ ] 1.1 `--verify` 升级：扫描 `lib/features/*` 与 doc-map 规则对比，**自动生成缺失规则草案**（含默认 docs_any_of），`--apply` 人工确认后写入——消灭「改名后规则失同步」类误报（report→review 实例自动化）
- [ ] 1.2 纯文档文件豁免：`lib/**/*.md` 不触发规则（新增 README 不再要求迁移日志）
- [ ] 1.3 `docs/` 内变更不要求迁移日志（文档自身的变更不产生文档义务）
- [ ] 1.4 验收：`--verify` 与 `--warning-only` 在既有变更集上零误报；`flutter analyze` 0 issue；doc-coverage 测试更新

### Phase 2: 派生文档生成化（中）

- [ ] 2.1 token 清单生成器：从 `lib/core/design/{spacing,icon_size,semantic_color*}.dart` 生成 Design_System.md 的 token 表
- [ ] 2.2 路由清单生成器：从各 feature `presentation/routes.dart` 生成路由索引
- [ ] 2.3 feature 模块清单生成器：扫描 `lib/features/*` 生成模块清单（职责、依赖、README 指引）
- [ ] 2.4 CI diff 校验：`scripts/gen_docs.dart` + `git diff --exit-code`（复用 verify_lucent_openapi_sync 模式），接入 daily checks 与 CI
- [ ] 2.5 doc-map 对应派生规则退役（Design_System token 段、路由相关 docs_any_of）
- [ ] 2.6 验收：改 token/路由后不跑生成器 CI 必红；不改代码则文档稳定；误报归零

### Phase 3: 实时规则与叙事文档降级（大）

- [ ] 3.1 `custom_lint` 起步：分层 import 规则（data→data、presentation→presentation）迁移为 analyzer 实时规则
- [ ] 3.2 feature 结构规则：缺 README、未注册 doc-map（若仍存在）→ IDE 提示
- [ ] 3.3 模块 doc comments 规范：新代码模块级 dartdoc 覆盖，评估 `dart doc` 站点化
- [ ] 3.4 Active_UI_* 降级：逐个评估由 golden/测试/ARB 取代或转为季度快照；删除或归档后 doc-map 对应规则同步退役
- [ ] 3.5 doc-map 退役评估：仅保留 `--verify` 结构检查（引用完整性/front-matter/freshness），删除 `--staged` 变更门禁；pre-commit 钩子相应简化
- [ ] 3.6 验收：pre-commit 无门禁误报；结构/分层规则在 IDE 实时生效；`--verify` 通过

## 五、不做的事

- **不再优化 doc-map 匹配逻辑**（类别规则、commit scope 驱动等）：都是过程门禁的改良，方向错误
- **不为新 feature 继续手工加 doc-map 规则**：由 1.1 的草案生成替代
- **不保留「变更必须改文档」的提交阻断**：最终形态下派生文档由 diff 校验兜底，叙事文档不强求
- **不把测试写进文档**：反向——文档内容若已被测试断言，删除文档而非复制测试
- **不引入第三方文档平台**：生成器 + Markdown + git 即完成闭环（Docs as Code），无需 Confluence/Notion 类设施

## 六、风险与注意事项

1. **生成器与代码的同步义务**：生成器本身要纳入 daily checks（生成物 diff 校验），避免「生成器过期」成为新的漂移源
2. **custom_lint 依赖**：需评估新增依赖（custom_lint）对 pubspec/CI 的影响；也可用 `analyzer_plugin` 无新运行时依赖实现
3. **Phase 3 范围大**：Active_UI_* 降级涉及既有文档读者（产品/测试），逐个评估、可中途停
4. **pre-commit 简化影响**：删除 `--staged` 门禁前，先确认 `--verify` 结构检查与 CI diff 校验已覆盖其保护价值
5. **与现有工作流兼容**：`run_daily_checks.dart`、`git_hook.dart`、`tooling_workflows.dart` 的改动需同步文档（AGENTS.md 的 doc 规则段落）
6. **plans/README.md 索引**：本计划完成后按惯例删除本文并更新索引

## 七、验收总览

- Phase 1 落地后：当前所有已知误报场景（README 触发、docs 内变更、目录改名）不再出现
- Phase 2 落地后：token/路由/模块清单类文档零人工维护
- Phase 3 落地后：`doc-map.yaml` 的变更门禁语义消失，仅剩结构校验；分层等规则 IDE 实时生效
