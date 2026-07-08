# Active UI — Today

- Today 根页已按 `Product_Tab_Component_Blueprint` 重构为行动面板，首屏顺序为 `主建议卡 → 次建议区 → 今日摘要 → 观察项 → 轻动作`。
- 旧的 `TodayOverviewSection / TodayPrioritySection / TodayAiSummarySection / TodayRecommendationSection / TodayTodoSection` 已整体下线。
- 新增 `suggestion_section / summary_section / observation_section / quick_actions_section`，统一使用 Forui `FCard / FTile / FBadge / FButton` 组织页面。
- Today 主题语气跟随当前 Forui 内置主题族；默认使用 `blue` 家族，不再依赖手写 sky-blue 自定义色值。
- 顶部栏操作按钮使用 Forui `FTooltip` 提供语义提示。
- 顶部 `AI chat` 入口使用 Forui `secondary` 胶囊按钮，通知入口使用 `outline` 图标按钮，交互权重更清晰。
- 主建议卡承接当前最高优先的用药或饮水动作，卡内补齐 `证据 / 边界 / 主动作`。
  - 用药类建议使用 `TodayCardTone.urgent`（destructive 边框 + 淡红底色），饮水类使用 `AppColors.primary`。
  - 主卡图标使用 `gradient: true`，用药红色渐变、饮水蓝色渐变。
  - 主卡首屏只保留图标+标题+原因+进度条+主按钮，证据和边界收入 `FCollapsible` 折叠区。
  - 主卡底部有 `稍后处理` 和 `不适用` 两个 ghost 按钮（前端状态，后续接入后端反馈链路）。
- 次建议区使用 `FCard.raw` + `FTappable`，`TodayCardTone.soft` 与主卡形成层级差。
- 今日摘要把概览指标和 AI 解释收拢到同一张低权重卡，不再和主建议抢主位。
  - 摘要卡内用 `FDivider` 将指标行和 AI 叙述分隔。
  - AI 叙述默认折叠（最多 2 行 + 省略号），点击 `查看依据` 展开 bullets 和 confidenceNote。
  - 生成按钮移至卡片右下角，减少首屏视觉噪音。
  - 移除了 `更新于 {time}` 文案。
- 观察项从 `FTile` 改为自定义 `_ObservationTile`，使用 muted 图标色、无背景色。
  - 右侧 tag 从 `FBadge` 改为更小的灰色文字。
  - section subtitle `以下内容仅供参考，不构成待办`。
- 轻动作区改为 `FTileGroup` 分组入口，承接 `确认用药 / 快速记录 / 用药安全 / 提醒设置 / 健康档案`。
  - 确认用药副标题根据 `pendingCount` 动态生成：待确认时显示 `{count} 条待确认` + badge 数字，全部确认时显示 `今日用药已全部确认`。
- 记录密度提示条：当用户无任何记录时显示 `FAlert` 提示先记一条饮水或症状。
- 顶栏动态问候语根据用药待确认数和饮水剩余数动态生成上下文问候（早上→用药、下午→饮水、晚上→用药或全部完成）。
- 手动触发 Lucent-backed Today AI 分析生成。
- 卡片状态：signed-out / disabled / loading / success / error。
- AI summary 在首次生成 loading 时使用骨架占位，不再只显示文案。
- 真实增量摘要流：`/api/v1/user/today-analysis/generate/stream`。
- 流完成后渲染结构化 bullets / action / confidence。
- Proactive advice loading 改为 recommendation row skeleton；失败态缩成 inline retry，不再占用整张大错误卡。
- 睡眠 vital 行读取持久化睡眠记录的真实时长；无数据时回退 `--`。
- 使用中性错误文案，不再出现 `mock` 字样。

## 数据层

- Today 相关远程数据源（`TodayAiRemoteDataSource`、`RecommendationsRemoteDataSource`）通过 `generated/lucent_api` 的 Retrofit 客户端访问 Lucent API。
- DTO 访问模式为直接返回扁平 DTO（`response.data`），不再经过 `Response<T>` 包装。
- Enum 序列化使用 `.json` 属性（`@JsonEnum` 约定），不再使用旧 `.value` 模式。
- AI 摘要增量流通过 `LucentSseClient` + Dio 直接消费 SSE，不经过 Retrofit 客户端。
- OpenAPI 合同修复后，`nullable: true` 的 DTO 字段已全部补充显式 `type`，生成客户端不再出现 `dynamic` 字段。
