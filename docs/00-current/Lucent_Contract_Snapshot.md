---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-11
---

# Lucent Contract Snapshot

Last updated: 2026-08-11 (Sparse Record Semantics observed metric contract)

## 基础

- API base：`/api/v1`
- 响应包络：`{ code, message, data }`
- 生成合同：`Lucent/docs/openapi.json`
- 生成客户端：`generated/lucent_api/`（`@openapitools/openapi-generator-cli` 7.22.0，generator `dart-dio`，`serializationLibrary=json_serializable`，`enumUnknownDefaultCase=true`）
- 重新生成流程：Lucent `pnpm export:openapi` → Luminous `dart run scripts/bootstrap_generated_sources.dart`（生成 Today Analysis、Report metric 与 Suggestion item 相关 model，并运行 build_runner）
- bootstrap 对 OpenAPI Generator 7.22.0 在 enum array 上错误生成的 `unknownEnumValue: List<Enum>...` 做确定性后处理；标量 enum fallback 保留，数组 enum 仍由 JSON 序列化按元素解析。
- 合同验证：`scripts/verify_lucent_openapi_sync.dart` 验证 OpenAPI 文件、generated client 布局以及 Today Analysis GET/refresh 方法

## 当前合同变更

- **药品详情 `drugInteractions`**：后端返回 `DrugbankDrugInteractionDto[]`（`drugbankId` + `description`），生成客户端 `MedicineDetailDataDtoDetail.drugInteractions` 为 `List<DrugbankDrugInteractionDto>?`。
- **数据导出创建 DTO**：`CreateDataExportRequestDto` 的 `kind`/`format`/`range` 枚举字段不再带 `default`，业务默认值由 `DataExportService` 层兜底；避免生成器生成非法枚举默认构造。
- **枚举未知值**：生成器开启 `enumUnknownDefaultCase=true`，所有枚举均含 `unknownDefaultOpenApi` fallback。
- **app-info 扩展**：`AppInfoDataDto` 新增 `latestVersion: string | null` 和 `downloadUrl: string | null` 字段，通过 `LATEST_VERSION` 和 `DOWNLOAD_URL` 环境变量配置。前端 About 页使用 `compareSemver()` 比较本地版本与 `latestVersion`，发现新版本时自动打开 `downloadUrl`。
- **推送设备合同移除**：Lucent 已移除旧的用户设备注册 API、`user_devices` 持久化模型及其 DTO。Luminous 通过 JPush SDK 绑定用户 UUID alias，生成客户端和 `LucentDioClient` 不再暴露 `UserDevicesApi`、`RegisterDeviceDto`、`DeviceResponseDto` 或 `UserDevicePlatform`。
- **Health Event Contract**：生成客户端新增 `HealthEventsApi`，覆盖 active/create/end/detail/list/check-in 六个操作，以及 `HealthEventStatus`（`active`/`ended`）和 `HealthEventOutcome`（`improved`/`unchanged`/`worsened`）。daily record 与 dose log DTO 同步携带可空 `healthEventId`；Luminous 的 `health_event` domain slice 通过 repository 适配器隔离这些生成类型，且对生成器的 nullable `Object?` 字段做运行时类型校验。
- **Proactive Suggestion Runtime Task 4**：`TodaySuggestionsDataDto` 新增并强制要求 `materializationStatus`（`empty`/`pending`/`ready`/`stale`/`failed`）、`sourceVersion`、可空 `computedAt` 和可空 `retryAfterSeconds`。Luminous 已从 Lucent OpenAPI 合同重新生成该 DTO 及其 `.g.dart`；Today 现有 domain mapper 暂不消费这些状态字段，待 Task 8 接入状态机。
- **Proactive Suggestion Runtime Task 7**：Today Analysis REST 合同现在返回显式 envelope DTO，GET/refresh/generate/async 的 `computedAt`、`retryAfterSeconds`、版本与物化状态字段均有明确 schema；生成 client 已包含 `TodayAnalysisApi` 的 GET/refresh 方法及对应模型。Today domain/UI 状态映射仍留给 Task 8。
- **Sparse Record Semantics Task 6**：Report metric、Today suggestion item 和 Today Analysis data 通过 OpenAPI 暴露同构 `observedMetric`：`value`（必返、可空）、`state`、`coverage`、`sources`、`observedCount`、`expectedCount`（必返、可空）、`windowStart`、`windowEnd`。Report 的旧 `value`/`unit`/`status`/`delta`/`direction`/`sparkline` 仅作 deprecated 兼容投影；generated client 已重新生成，domain mapper 尚未切换。

## Luminous 已使用的后端领域

- auth / account（含 OAuth: WeChat / QQ / Apple）
- user-scoped health context（身高/体重/过敏/疾病/当前用药）
- medicine search / detail
- current medicines
- dose logs（slot-aware 打卡）
- medicine reminders（schedule-only CRUD）
- daily records（含单图附件元数据）
- today suggestions（建议引擎 + 反馈 + AI 解释 + 历史回顾）
- today AI analysis（增量流摘要）
- environment snapshot
- user settings / preferences
- support resources / app info
- data export requests
- report dashboard（聚合 + score + findings + patterns + trends）
- medicine risk check（static + LLM 双检查，API 持久化）
- report AI summary（增量流）
- clinic summary（脱敏摘要 + PDF + 分享链接）
- notifications（列表/详情/已读/删除）
- legal documents（远程优先 + Markdown fallback）
- assistant（SSE 流式 + capabilities + 持久化对话）

## 关键合同细节

- **用药打卡**：`POST /api/v1/user/medicine-dose-logs/mark` 按提醒槽位幂等确认服药；`CreateDoseLogDto` / `DoseLogItemDto` 含 `reminderId` 与 `scheduledTime` 字段。Record 快速用药撤销使用既有 `DELETE /api/v1/user/medicine-dose-logs/{id}` 删除新建 log，或 `PATCH /api/v1/user/medicine-dose-logs/{id}` 恢复旧 status；本次未改变后端合同。前端在药品无附近提醒 slot 时，以当前 `HH:mm` 作为 `scheduledTime` 调用 `mark`，避免只传 `currentMedicineId` 触发 400。
- **服药稀疏语义**：Lucent Today/Report 以 `reminderId + scheduledFor + scheduledTime` 保持计划槽位独立；`planned` 在消费合同映射为 `unconfirmed`，taken、skipped、overdue-unconfirmed 分开计数。无 reminder 的临时 dose log 独立保存但不进入 adherence 分母；无计划窗口为 unknown。Flutter observed DTO/domain 迁移仍待后续合同阶段。
- **睡眠 episode 语义**：Lucent daily record payload 支持 `sleepType: nightSleep|nap`、`startedAt`、`endedAt`、`durationMinutes` 和可选 `quality`，旧 `startAt/endAt` 按 nightSleep 读取；Today collector 同时返回 night、nap、all-sleep 总量，重叠 episode 只产生 data-quality warning。Flutter 仍消费旧 scalar 合同，observed DTO/domain 迁移留到下一阶段。
- **睡眠快速记录**：未新增后端 API 或 DTO。Record 快速睡眠继续使用 daily records `create/delete` 合同；
  前端在 `DailyRecordKind.sleep.payload` 中写入临时 `sleepEvent=start/wake` fact，确认合并后写入既有标准
  `durationMinutes/startAt/endAt` sleep payload。
- **餐食快速记录**：未新增后端 API 或 DTO。Record 快速餐食继续使用 daily records 图片附件合同：
  `POST /api/v1/user/daily-records/attachments/images/presign-upload` 预签上传后，将返回的 attachment metadata
  放入 `DailyRecordCreateInput.attachments` 创建 `DailyRecordKind.meal`，后端 meal analysis 仍由既有 daily-record
  图片附件链路触发。
- **快速记录排序/帮助/角标**：阶段 6 仅修改本地 SharedPreferences 偏好、前端说明弹窗，以及基于现有
  Record dashboard summary/timeline 的水与睡眠角标渲染；未新增 Lucent API、DTO 或 OpenAPI 生成客户端变更。
- **长按类型弹窗与自定义图标**：阶段 7 为纯前端改动——长按改为逐类型 Forui 弹窗（water 设置 /
  meal 手动录入 / 其余类型规则说明），图标选择器迁移到快速记录设置页与创建/编辑表单；未新增 Lucent
  API、DTO 或 OpenAPI 生成客户端变更。
- **Medicine 主页空态**：未登录 preview 与已登录空药盒均复用现有 `MedicineWorkspace` 结构（`plan.items` 为空），空态文案与卡片由前端根据认证状态本地化渲染，未引入新合同字段。
- **用户数据边界**：用户业务数据在 `/api/v1/user/*` 下；账户资料/安全操作在 `/api/v1/account/*` 下。
- **SSE 流**：Today AI 分析 `/api/v1/user/today-analysis/generate/stream`、Report AI 摘要 `/api/v1/user/reports/summary/generate/stream`、Assistant `/api/v1/user/assistant/chat/stream`。通过 `LucentSseClient` + Dio 直接消费，不经过 Retrofit。
- **Today 摘要展示**：后端返回 `TodayDashboard` 的饮水、用药、生命体征等数据，前端 `view_models.dart` 组装摘要指标和五个快捷入口；合同不返回可直接渲染的 UI 条目数组。AI 摘要正文通过上述 Today AI SSE 按需生成。
- **公开路由**：`/legal` 和 `/reports/clinic-summary/shared/:token` 为公开访问（`@Public()` 装饰器）。
- **API 路径常量**：`core/network/api_paths.dart`（`LucentApiPaths`）集中管理所有 `/api/v1/...` 路径字符串。
- **用药风险检查**：`GET /api/v1/medicines/risk-check` 获取最新 static + llm 检查记录；`POST /api/v1/medicines/risk-check` 触发检查（body: `{ type: 'static' | 'llm' }`）。后端 `MedicineRiskCheckListener` 监听健康上下文/提醒变更事件自动 mark stale + debounce 静态检查。前端通过 `MedicineRiskCheckRemoteDataSource`（`data/datasources/risk_check_remote.dart`）封装 `LucentClient.medicines` API 调用 + `MedicineRiskCheckMapper` DTO 映射，repository 仅作薄包装委托。
