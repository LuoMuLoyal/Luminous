# Active UI — Medicine

Last updated: 2026-07-18

## 页面结构

根页首页按 Medicine 职责收敛为四块：

1. 当前用药盒
2. 今日服用计划
3. 用药安全摘要
4. 用药操作

未登录时保留 preview workspace + 顶部轻量登录提示，不再误入"添加你的第一个药品"空药盒 CTA。

## 今日服用计划

- slot-aware 打卡链路："已服用 / 跳过"调用 Lucent `POST /user/medicine-dose-logs/mark`。
- 同一种药存在多个 reminder slot 时，每次只确认当前 pending 槽位，不再按药品整天聚合覆盖。
- Hero 的"今日剂次 / 依从率 / 下一剂"按 slot 统计。
- 状态 badge 直接控制前景/浅底/边框，不再用 `FBadge.raw` 包装。
- 时间 pill 文本显式使用深色前景。
- 依从率 detail 使用专用 l10n 键（`medicineAdherenceDetail`），不再误用"待服用"。

## 通知铃铛

- `_MedicineNotificationButton` 为 `ConsumerWidget`，watch `notificationUnreadCountProvider` 条件渲染红点。
- 铃铛点击路由从 `/medicine/reminders/new` 改为 `/medicine/reminders`。

## 用药安全摘要

- 使用三层语义：已确认风险 / 已确认安全但非绝对安全 / 未覆盖或不确定。
- 风险检查页 `_TierBanner` 三级颜色：warning 档 `SemanticColor.warning`（黄）、success 档 `SemanticColor.success`（绿）、destructive 档 `SemanticColor.destructive`（红）。
- 红旗横幅（`risk_red_flag.dart`）全部使用 `SemanticColor.destructive`（背景/边框/图标/标题/action 文案 5 处）。
- 红旗升级使用显式线下就医操作文案：`severeAllergy` → 立即拨打急救电话；`informationGap` → 尽快线下核实。

## 风险检查边界

- 评估当前用药 + 待添加候选，仅使用现有药品详情数据。
- 应用有界限的审核规则集进行过敏匹配（8 组跨语言 token map）。
- 对审核过的 `cn` 成分字符串做重复成分检查 + DrugBank 同义词重叠检测。
- 食物相互作用检测（酒精/咖啡因）。
- DrugBank 来源的相互作用对检测。
- 风险结果携带 `coverageSummary` 字符串，严重级别从结论层级派生。
- 两层展示：结构化结论标签（标题）+ context + medicine（正文）+ 来源证据文本（详情）。

## 药品搜索与扫描

- 搜索结果的新增前保存风险预检查。
- 来源审核安全预览。
- 过敏安全检查。
- 药品拍照识别（药盒 AI 识别）和条码扫描已在移动端暴露。
- 处方导入/OCR 处方识别仍延后（底层枚举保留但仅 Toast 提示）。
- 扫码页全部硬编码中文已迁入 l10n 键。
- `MedicineMatchType.name` 英文枚举直出改为 `_matchTypeLabel` + l10n 映射。

## 提醒

- Lucent schedule-only 提醒详情/创建/编辑/删除 UI。
- 可选起止日期窗口使用 Forui `FCalendar.grid`。
- 本地声音偏好。
- 按提醒计划同步的本地通知调度。
- SMS 不可用状态。
- 只读提醒投递历史展示。
- 通知权限 `permanentlyDenied` 状态时自动调用 `openAppSettings()` 跳转系统设置。

## 数据层

- `DoseLogRemoteDataSource`/`ReminderRemoteDataSource` 通过 `generated/lucent_api` Retrofit 客户端访问。
- `MarkDoseLogDto` 直接作为 `@Body()` 参数传递。
- **ADR-0009 cache-first**: `CachedDoseLogDataSource` 包装 `DoseLogRemoteDataSource`：
  - `fetchForDate`: 先读缓存（节流 60s）→ 缓存空则走网络 + 写缓存。
  - `create`/`update`/`mark`: 远程成功后刷新缓存；`DioException` 时入队 `pending_sync_queue`（entityType=`dose_log`），注册 SyncWorker handler 重放后按 `scheduledFor` 刷新缓存。
- 消费方已全部迁移。
