# Active UI — Medicine

- 活跃当前用药药盒。
- 根页首页已按 `Product_Tab_Component_Blueprint` 的 Medicine 职责收敛为四块：
  - 当前用药盒
  - 今日服用计划
  - 用药安全摘要
  - 用药操作
- 今日服用计划已切到 slot-aware 打卡链路：
  - 根页“已服用 / 跳过”现在调用 Lucent `POST /user/medicine-dose-logs/mark`。
  - 同一种药存在多个 reminder slot 时，每次只确认当前 pending 的那个槽位，不再按药品整天聚合覆盖。
  - Hero 的“今日剂次 / 依从率 / 下一剂”按 slot 统计，而不是按药品条目粗略统计。
- 根页视觉修正：
  - 今日服用计划中的状态 badge 已从 `FBadge.raw` 包装中抽离，改为直接控制前景 / 浅底 / 边框，避免“待服用”文字被吞掉后只剩蓝色圆角块。
  - 时间 pill 文本显式使用深色前景，不再吃到浅底上的低对比默认前景色。
  - 用药安全 `未覆盖 / 不确定` summary 在 secondary 场景下改用可读图标前景，不再出现左侧图标几乎发白看不见。
  - 顶部搜索框已改为固定 56px 高度，不再只靠 padding 撑视觉高度。
- 未登录时保留 preview workspace，并在顶部显示轻量登录提示；不再误落入“添加你的第一个药品”空药盒 CTA。
- 基于提醒的下一剂提示现在归入「今日服用计划」，不再挂在药盒主卡底部。
- Lucent schedule-only 提醒详情/创建/编辑/删除 UI。
- 可选起止日期窗口使用 Forui `FCalendar.grid`。
- 本地声音偏好。
- 按提醒计划同步的本地通知调度。
- SMS 不可用状态。
- 只读提醒投递历史展示。
- panel-backed 用药操作。
- 同日已服/跳过剂量日志。
- 真实当前用药风险检查页。
- 来自同一风险结果的首页安全摘要卡片，使用三层语义：
  - 已确认风险
  - 已确认安全但非绝对安全
  - 未覆盖 / 不确定
- 药品搜索结果的新增前保存风险预检查。
- 来源审核安全预览。
- 过敏安全检查。
- Medicine 根页已移除 `Reference notice` 与 `Safety tips` 主视图区块；这些内容不再占据首页主结构。

## 风险检查边界

- 边界刻意收窄但明确一致：
  - 评估当前用药 + 待添加候选。
  - 仅使用现有药品详情数据。
  - 当手动条目、缺失来源详情或完全未审核药品集合无法被检查时，展示共享 coverage summary。
  - 应用有界限的审核规则集进行过敏匹配（8 组跨语言 token map）。
  - 对审核过的 `cn` 成分字符串做重复成分检查，加上 DrugBank 同义词重叠检测。
  - 食物相互作用检测（酒精/咖啡因）。
  - DrugBank 来源的相互作用对检测。
- 风险结果携带 `coverageSummary` 字符串，用于可读性差距报告。
- 严重级别从结论层级派生，而非按上下文硬编码。
- 风险检查页与工作区安全面板采用两层展示：
  - 结构化结论标签（如「禁用」「慎用」）作为标题
  - context + medicine 作为正文
  - 来源证据文本作为详情
- 红旗升级使用显式线下就医操作文案：
  - `severeAllergy`：立即拨打急救电话
  - `informationGap`：尽快线下核实
- 测试：39 个 domain unit 覆盖核心匹配逻辑。

## 数据层

- 用药相关远程数据源（`DoseLogRemoteDataSource`、`ReminderRemoteDataSource`、`SafetyTipsRemoteDataSource`）通过 `generated/lucent_api` 的 Retrofit 客户端访问 Lucent API。
- DTO 访问模式为直接返回扁平 DTO（`response.data`），不再经过 `Response<T>` 包装。
- Enum 序列化使用 `.json` 属性（`@JsonEnum` 约定），不再使用旧 `.value` 模式。
- OpenAPI 合同修复后，`nullable: true` 的 DTO 字段已全部补充显式 `type`，生成客户端不再出现 `dynamic` 字段。
- `POST /user/medicine-dose-logs/mark` 的具名 DTO `MarkDoseLogDto` 直接作为 `@Body()` 参数传递。
- **ADR-0009 cache-first**: 服药日志读取已迁移为 cache-first 模式：
  - 新增 `CachedDoseLogDataSource` 包装 `DoseLogRemoteDataSource`，提供 cache-first 的 `fetchForDate` / `create` / `update` / `mark`。
  - `fetchForDate`: 先读本地 Drift 缓存（有则返回 + 后台刷新节流 60s），缓存空则走网络 + 写缓存。
  - `create` / `mark`: 远程成功后刷新该日期缓存。
  - `cachedDoseLogDataSourceProvider`（`@riverpod`）注入 `doseLogRemoteDataSourceProvider` + `medicineDoseLogDaoProvider`。
  - 消费方已全部迁移：`reminder_providers.dart`（`medicineTodayDoseLogsProvider`）、`medicine/presentation/pages/page.dart`（打卡操作）、`today/data/repositories/lucent_repository.dart`（Dashboard 用药统计）。
  - `cached_dose_log_data_source.dart` 通过 `export` 重新导出 `dose_log_remote_data_source.dart`，保持 `DoseLogStatus` / `DoseLogItem` 类型可从单一 import 访问。
