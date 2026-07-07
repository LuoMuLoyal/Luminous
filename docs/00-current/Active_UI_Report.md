# Active UI — Report

- Lucent-backed report dashboard。
- 真实 medication / water / sleep 聚合。
- 用户可选范围：`last_7_days` / `last_30_days` / `custom`。
- 自定义范围使用 Forui `FCalendar.grid` 日期范围选择器。
- 合同驱动的 findings / patterns 文本。
- 移动端报告页已重构为 readiness-first 状态页：
  - 顶部只保留标题 + 时间范围。
  - 首屏单一 `readiness` 主卡合并登录门槛、数据不足、生成总结、同步、数据更新时间。
  - `generatedAt` 已从 Lucent report dashboard DTO 映射到前端 domain，用于显示“当前显示的数据更新于 …”。
- 移动端预览层只保留：
  - 报告预览评分
  - 健康趋势预览
  - 重点发现
- 移动端完整层仅在 `已登录 + 数据足够` 时显示：
  - AI 总结
  - 导出摘要
  - 健康模式分析
- 未登录态现在返回真实的前端预览 dashboard，而不是空白 `signedOut()` 占位；不再用大型登录提示块拦截整页。
- 手动 AI 摘要生成，真实增量流：
  - `/api/v1/user/reports/summary/generate/stream`
- 本地 signed-out / disabled / loading / success / error AI 摘要状态。
- 卡片内 `近 7 天 / 近 30 天` AI 摘要切换，带按范围缓存状态。
- 移动端 AI 摘要控件保留换行安全布局，但已下沉到完整层。
- 移动端下拉刷新 + readiness 主卡内显式同步操作。
- 移动端已移除首屏独立 snapshot 状态卡、独立数据不足横幅、趋势区重复时间范围控制和首屏指标四宫格。

## 导出动作

四个导出动作已接入：

- `给校医院` — hospital PDF
- `月度报告` — monthly PDF
- `打印预览` — print PDF
- `分享给医生` — clinic share link（Redis 24h TTL + 原生 OS 分享面板）
- 导出卡片显示进行中的进度与有界状态文案。
- 移动端在未登录或数据不足时不再渲染整组导出卡，只显示轻量锁定说明。
- Mine/Settings 仍使用同一真实数据导出请求流。
- 隐私设置由 Mine/Settings 持有。
