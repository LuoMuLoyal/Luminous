# Active UI — Today

- 压缩健康概览。
- repository 提供的用药/饮水优先级列表。
- 用药任务。
- 饮水任务（带数量目标）。
- UI 层自定义待办。
- 手动触发 Lucent-backed Today AI 分析生成。
- 卡片状态：signed-out / disabled / loading / success / error。
- 真实增量摘要流：`/api/v1/user/today-analysis/generate/stream`。
- 流完成后渲染结构化 bullets / action / confidence。
- 即时风险与主动建议。
- 睡眠 vital 行读取持久化睡眠记录的真实时长；无数据时回退 `--`。
- 使用中性错误文案，不再出现 `mock` 字样。
