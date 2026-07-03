# Active UI — Report

- Lucent-backed report dashboard。
- 真实 medication / water / sleep 聚合。
- 用户可选范围：`last_7_days` / `last_30_days` / `custom`。
- 使用平台日期范围选择器。
- 合同驱动的 findings / patterns 文本。
- 手动 AI 摘要生成，真实增量流：
  - `/api/v1/user/reports/summary/generate/stream`
- 本地 signed-out / disabled / loading / success / error AI 摘要状态。
- 卡片内 `近 7 天 / 近 30 天` AI 摘要切换，带按范围缓存状态。
- 移动端安全的 AI 摘要控件换行 header 布局。
- 移动端下拉刷新 + 显式同步操作。
- 收紧的移动端报告布局，平衡的 2x2 指标网格。
- 基于 report score 的真实派生第四指标卡。
- 更轻量的 signed-out 内联提示，替代大型警告块。

## 导出动作

四个导出动作已接入：

- `给校医院` — hospital PDF
- `月度报告` — monthly PDF
- `打印预览` — print PDF
- `分享给医生` — clinic share link（Redis 24h TTL + 原生 OS 分享面板）
- 导出卡片显示进行中的进度与有界状态文案。
- Mine/Settings 仍使用同一真实数据导出请求流。
- 隐私设置由 Mine/Settings 持有。
