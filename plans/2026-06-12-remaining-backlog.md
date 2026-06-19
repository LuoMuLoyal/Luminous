# Goal

把当前仍然真实存在、且会影响后续业务推进的 backlog 收敛成一份新的执行计划，先补稳定性和范围一致性，再进入下一轮 AI 能力开发。

## Why Now

- 前一轮前端测试缺口已经补完，不应继续把“测试空白”留在 `Next_Plan.md` 里制造噪音。
- 当前剩余问题已经从“明显缺测试”变成“少量真实缺陷 + 若干范围未收口项 + 一些后端硬化项”。
- 如果不先收敛这些 backlog，后续月报 AI、自然语言记入、截图识别都会建立在不稳定或不一致的基础上。

## Scope

这轮只覆盖当前已确认仍然真实存在的 backlog：

1. Report weekly AI summary 空响应错误路径硬化
2. Lucent 配置与测试支持硬化
3. AI 进入下一阶段前的边界确认

不在这轮里处理：

- 新的 AI 功能开发
- 睡眠真实合同或健康平台接入
- 报告导出文件/下载链路
- OCR / 截图识别 / 自然语言记入实现
- GitHub Actions 引入移动端全链路 E2E

## Assumptions

- `Today AI` 与 `Report weekly AI summary` 的手动生成链路已经是当前可接受基线，不回退。
- `llm-runtime` 仍然只负责 provider/model 构建，不接管业务编排。
- sleep 在产品上仍然不是已交付真实能力，因此已完成的收口目标是“别伪装成真功能”，不是补功能。
- 这轮 backlog 可以跨 `Luminous` 与 `Lucent` 两个仓库推进，但提交仍然必须分仓库处理。

## Workstreams

### 1. Report AI Summary Stability

目标：修掉当前已确认的错误契约，把“空响应 -> TypeError”改成明确、可控的错误路径。

涉及文件：

- `Luminous/lib/features/report/data/datasources/report_ai_summary_remote_data_source.dart`
- `Luminous/test/report/report_ai_summary_remote_data_source_test.dart`
- 如有必要：
  - `Luminous/lib/features/report/presentation/providers/report_ai_summary_provider.dart`

具体动作：

- 为 weekly summary remote data source 增加空响应判空，而不是直接 `response.data!.data`
- 让异常类型和错误信息与现有网络层风格一致
- 更新测试，不再把 `TypeError` 当成正确行为

验证：

- `flutter test test/report/report_ai_summary_remote_data_source_test.dart`
- `flutter test test/report/report_ai_summary_provider_test.dart`
- `flutter analyze`

预期结果：

- weekly AI summary 遇到异常响应时走明确错误分支
- provider/UI 不再依赖运行时空断言崩溃

### 2. Sleep Scope Alignment (completed)

结果：已把 sleep 相关入口统一成“明确的 deferred/placeholder”，避免不同页面给出互相冲突的能力暗示。

涉及区域：

- `Luminous/lib/features/today/`
- `Luminous/lib/features/record/`
- `Luminous/lib/features/settings/`
- 对应 l10n / 页面测试

- Today sleep vital 现在回退到中性的 `--`，不再展示伪装成真实数据的数值。
- Record sleep quick actions / filters 已标记为 locked placeholder surfaces，并带有明确的未启用提示。
- Settings sleep reminder row 现在显示 local-only 标签，而不是 enabled/disabled 状态。
- 已通过受影响 widget/page tests 和 `flutter analyze` 验证。

### 3. Placeholder Copy Cleanup (completed)

结果：已去掉仍然会误导用户的假药名和 mock 文案。

涉及区域：

- `Luminous/lib/features/medicine/`
- `Luminous/lib/features/report/`
- 相关 ARB 文案和测试快照

具体动作：

- 搜索并清理假药名，如 `Metformin XR`、`Atorvastatin calcium`、`Omeprazole capsules`
- 优先改成通用占位标签、空状态文案或删除不必要示例
- 避免把 mock 字样重新暴露给正常用户路径
- 已通过 `rg`、受影响测试和 `flutter analyze` 验证

### 4. Lucent Config Hardening

目标：把明显不该长期留在代码里的 dev fallback 收掉，并让测试支持路径与正式 hashing 配置一致。

涉及文件：

- `Lucent` 配置模块、auth/security 相关配置
- `testing-support` 相关代码
- `Lucent/docs/environment.md`
- 如有必要：`.env.example` 或等价模板

具体动作：

- 删除代码级 JWT/admin secret fallback
- 把开发默认值移到 env 模板或文档，不留在运行时代码里
- 让 `testing-support` 与共享 `ARGON2_OPTIONS` 对齐
- 验证不会破坏本地开发和测试启动说明

验证：

- `pnpm --prefix Lucent test` 跑最小相关测试
- `pnpm --prefix Lucent build`
- 文档命令核对

预期结果：

- 配置默认值位置清晰
- 测试支持不再悄悄偏离正式密码哈希配置

### 5. AI Boundary Confirmation Before Next Slice ✅ (completed 2026-07-01)

决策文档：`Lucent/plans/2026-07-01-ai-boundary-confirmation.md`

目标：在开始月报 AI 之前，把“是否需要 agent / 是否要先抽共享 AI copy/prompt 模式”定下来，但不提前做大重构。

涉及文件：

- `Luminous/docs/Next_Plan.md`
- `Lucent/docs/TODO.md`
- 如需要，再补一份 Lucent repo 内 AI 专项计划

具体动作：

- 明确下一阶段仍以 bounded linear flows 为默认
- 只把真正需要 branching/tool use 的未来场景标记为 agent 候选
- 在 Lucent 中收敛一份共享 locale-aware prompt/copy pattern 的实施入口

验证：

- 文档一致性检查
- 后续月报 AI 任务能直接复用，不需要再争论一次架构边界

预期结果：

- 下一轮 AI 工作的入口清楚
- 不会把已上线 Today/weekly 流程为了“统一”而强行重构成 agent

## Recommended Order

1. Report AI summary stability
2. Lucent config hardening
3. AI boundary confirmation

## Observable Done State

- ✅ `Next_Plan.md` 不再继续列出已经完成的测试缺口
- weekly AI summary 的错误路径从“运行时崩”变成“明确可处理的失败”
- ✅ sleep placeholder 范围在 Today / Record / Settings 三处统一
- ✅ 用户可见 mock 药名文案被清掉
- ✅ Lucent 的 fallback secret / argon2 偏差被收口
- ✅ 后续可以在这个基础上开始 monthly AI summary，而不是继续清理前置噪音
- ✅ AI 架构边界已确认：monthly=bounded linear, agent 不扩界, 共享服务提取延后至 monthly 验证后
