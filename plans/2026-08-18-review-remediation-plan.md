# Luminous 8-18 审查整改计划（确定性）

Created: 2026-08-18
Status: active

> 来源：`plans/luminous-review-2026-08-18.md`（审查报告，已对照 HEAD `9fefc0fd` 实际代码复核改写；复核结论优先，审查报告中的误报不返工）。
> 关联计划：[`2026-08-17-error-handling-reform-plan.md`](2026-08-17-error-handling-reform-plan.md) 阶段 3 已列出 8-18 审查的 `detail!`、`AppLocalizations.of(context)!`、regenerate 错误边界、会话重命名回滚——本计划用**现行约定**先行落地其中不依赖 Result 迁移的部分（崩溃隐患、并发守卫、死代码）；`LucentFailure`/fpdart 化仍归该门禁计划。

## 一、目标与范围

目标：把 8-18 审查报告的逐条意见落到确定性结论——真实问题修复、已修复项复核关闭、误报项记录原因；不改变 UI 行为、文案与 API 消费方式。

范围（均在本仓）：

- `lib/features/assistant/presentation/widgets/source_strip.dart`
- `lib/features/assistant/presentation/providers/conversation.dart`
- `lib/features/assistant/presentation/widgets/controls_sheet.dart`、`controls_sheet_opener.dart`（删除）
- `test/assistant/controller_test.dart`（拆分）
- `lib/features/record/presentation/widgets/dialogs/nlp_sheet.dart`、`lib/features/record/presentation/pages/create.dart`

不涉及：l10n 文案变更（ARB 键 `assistantControlsDrawerTitle` 删除死代码后仍有 `page_body.dart`/`status_bar.dart` 两处使用，保留）、OpenAPI 客户端、fpdart/`LucentFailure` 迁移。

## 二、条目处置表（审查 → 复核 → 决定）

| # | 审查条目 | 复核结论（HEAD `9fefc0fd`） | 处置 |
|---|---|---|---|
| 1 | `source_strip.dart` 12 处 `detail!` 非空断言 | 属实：12 处全部位于 `if (detail != null)` 分支内（L208 起）；另 L289/293 有 `detail!.disclaimer!` 双重断言（final 字段不可类型提升） | 修复：各 build 方法首行取局部变量（如 `final detail = this.detail;`）后再判空，删除全部 `detail!`/`disclaimer!`；补「detail 为 null 不渲染」「字段齐全渲染」测试 |
| 2 | `AppLocalizations.of(context)!` 强制解包 | 复核：全仓惯例（`lib/core` 11+ 处同款），应用仅支持 en/zh 且 MaterialApp 始终注入 delegates；测试经 `TestForuiRouterApp` 提供 localizations；仓库无 `context.l10n` 扩展 | 关闭：保持现状；未来引入 l10n 扩展时统一替换，另立任务 |
| 3 | `regenerateLastMessage` 无 try-catch | 复核：datasource 有意不吞错；`AssistantController.regenerateLastMessage`（`conversation.dart` 386–453 行）已用 `_classifySendError` 分类处理，测试覆盖「surfaces streaming errors」 | 关闭：错误边界在 controller 层已闭环，datasource 保持抛出语义 |
| 4 | `_formatGeneratedAt` 日期格式 locale 判断简单 | 属实但影响小：L326–336 用 `locale.startsWith('zh')`；应用支持语言恰为 en/zh | 修复：改 `locale.languageCode == 'zh'`（无行为变化，语义更准）；补 en/zh 两种格式测试 |
| 5 | 会话重命名乐观更新缺乏事务性 | 属实：L519–566 乐观更新 + 回滚 + rethrow（已有测试）；缺口为同会话并发重命名与刷新失败静默 | 修复：加 in-flight 守卫（同会话并发重命名直接忽略并记 debug，以首调用为准）；刷新失败补 debug 日志；补并发守卫测试 |
| 6 | `controls_sheet`/`controls_sheet_opener` 实验代码未移除 | 属实：两文件互相 import，全仓（lib/test/integration_test）无其他引用，纯死代码 | 修复：成对删除两个文件；`flutter analyze` 确认无悬挂引用；ARB 键保留（仍有 2 处使用） |
| 7 | `_dataAsOfText` 可简化 | 复核：L340–350 现状（note → version label → null）已符合建议语义，显式 if 比 helper 链更可读 | 关闭：不改 |
| 8 | `controller_test.dart` 过大（>2000 行） | 误报前提：实际 1390 行 / 26 个 test 单 group；但按功能 seam 拆分仍符合测试维护最佳实践 | 修复：纯搬移拆 3 文件（断言不变），见步骤 3 |
| 9 | `recent_searches.dart` 空 catch（08-16 遗留） | 已修复：三处 catch 均有 `talkerProvider` 日志（L45–54/63–67/76–80） | 关闭，不返工 |
| 10 | `medicine_search.dart` 孤儿代码 + debounce 魔法数字（08-16 遗留） | 已修复 debounce：命名常量 `_searchDebounceDuration`（L29）；`MedicineSearchCategory`/`MedicineSearchSafetyPreview` 为文档化延期（F-11/F-12，代码注释与 `Active_UI_Medicine.md` 一致） | 关闭：不返工；预览面板移除随 legacy 清理另行评估 |
| 11 | record 模块 Toast 未防护 6 处（08-17 遗留） | 部分修复：08-17 已补大部分；剩 3 处：`nlp_sheet.dart` L39–45（`ref.listen` 回调内 fire-and-forget，真实风险）、L47–51、`create.dart` L255–263（同步分支，低风险） | 修复：3 处补 `mounted` 守卫（ConsumerState 模式），与 08-17 已补模式一致 |
| 12 | `assistant_page.dart` 命名不一致（08-17 遗留） | 已修复：仓库无 `assistant_page.dart`；`AssistantPage` 位于 `presentation/pages/page.dart`，符合命名规则 3/6 | 关闭，不返工 |

## 三、执行步骤

### 步骤 1：崩溃与健壮性

1. **#1**：`source_strip.dart` 三处 build 路径局部变量解包（L39/203/370 附近），删除全部 `detail!` 与 `disclaimer!` 非空断言。
2. **#11**：`nlp_sheet.dart` L39–45 加 `if (!mounted) return;` 守卫；L47–51 与 `create.dart` L255–263 同步分支按同模式补守卫。

### 步骤 2：行为小修

3. **#4**：`_formatGeneratedAt` 改 `locale.languageCode == 'zh'`。
4. **#5**：`conversation.dart` rename 增加 in-flight 守卫（`Set<String>` 记录进行中会话，同 id 并发调用忽略并 debug 日志）；刷新失败 catch 补 debug 日志；回滚与 rethrow 语义不变。
5. **#6**：删除 `controls_sheet.dart` + `controls_sheet_opener.dart`，`flutter analyze` 验证零悬挂引用。

### 步骤 3：测试维护

6. **#1/#4/#5**：补对应测试（null 分支、en/zh 格式、并发守卫）。
7. **#8**：`controller_test.dart` 按 seam 拆为：
   - `controller_send_test.dart`：build / loadCapabilities / sendMessage / resendMessage / F-3 断流两组
   - `controller_regenerate_test.dart`：regenerateExpiredProposal / regenerateLastMessage 两组
   - `controller_conversation_test.dart`：confirmProposedAction / rename / delete / clear
   纯搬移，断言与 group 名不变。

### 步骤 4：验证与收尾

8. `flutter analyze`、`flutter test`、`dart run scripts/check_doc_coverage.dart --warning-only` 全绿。
9. 追加 `docs/03-logs/migration-log/2026-08-18.md`（范围与验证结论，不写需持续同步的精确数字）；删除本计划文件（实施完毕文件已删；审查报告 `plans/luminous-review-2026-08-18.md` 已随本次改写删除）；确认 `plans/README.md` 已更新。

## 四、硬规则

- 不改 UI 行为、不改文案、不改 API 消费方式、不引入新依赖。
- datasource 不吞错：错误边界保持在 controller/provider 层（#3 关闭依据）。
- 测试拆分只搬移不改断言；删除死代码前以 grep 证明零引用（已完成：全仓仅两文件互引）。
- 本计划无文案变更，不触碰 `lib/l10n/src/*.arb`。

## 五、验收标准

- 处置表 12 项全部关闭（修复 / 复核关闭 / 记录原因）。
- `flutter analyze` 零问题；`flutter test` 全绿；doc coverage 通过。
- grep 复核：`controls_sheet` 全仓零引用；`source_strip.dart` 无 `!` 非空断言残留。
- 拆分后 3 个测试文件用例总数与拆分前一致。

## 六、不做的事

- 不启动 fpdart / `LucentFailure` 迁移（`2026-08-17-error-handling-reform-plan.md` 门禁计划）。
- 不引入 `context.l10n` 扩展（全仓惯例保持 `AppLocalizations.of(context)!`）。
- 不删除 `MedicineSearchCategory` / `MedicineSearchSafetyPreview`（文档化延期，随 legacy 清理另行评估）。
- 不重写 `_dataAsOfText`、不改 `regenerateLastMessage` 的抛出语义。
