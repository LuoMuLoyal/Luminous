# Lucent Contract Snapshot

Last updated: 2026-07-27

## 基础

- API base：`/api/v1`
- 响应包络：`{ code, message, data }`
- 生成合同：`Lucent/docs/openapi.json`
- 生成客户端：`generated/lucent_api/`（`@openapitools/openapi-generator-cli` 7.22.0，generator `dart-dio`，`serializationLibrary=json_serializable`，`enumUnknownDefaultCase=true`）
- 重新生成流程：Lucent `pnpm export:openapi` → Luminous `openapi-generator-cli generate -i ../Lucent/docs/openapi.json -g dart-dio -o generated/lucent_api -c config.json` → `dart run tool/bootstrap_generated_sources.dart`
- 合同验证：`tool/verify_lucent_openapi_sync.dart` 验证 `generated/lucent_api/` 与 `Lucent/docs/openapi.json` 同步

## 当前合同变更

- **药品详情 `drugInteractions`**：后端返回 `DrugbankDrugInteractionDto[]`（`drugbankId` + `description`），生成客户端 `MedicineDetailDataDtoDetail.drugInteractions` 为 `List<DrugbankDrugInteractionDto>?`。
- **数据导出创建 DTO**：`CreateDataExportRequestDto` 的 `kind`/`format`/`range` 枚举字段不再带 `default`，业务默认值由 `DataExportService` 层兜底；避免生成器生成非法枚举默认构造。
- **枚举未知值**：生成器开启 `enumUnknownDefaultCase=true`，所有枚举均含 `unknownDefaultOpenApi` fallback。
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

- **用药打卡**：`POST /api/v1/user/medicine-dose-logs/mark` 按提醒槽位幂等确认服药；`CreateDoseLogDto` / `DoseLogItemDto` 含 `reminderId` 与 `scheduledTime` 字段。
- **Medicine 主页空态**：未登录 preview 与已登录空药盒均复用现有 `MedicineWorkspace` 结构（`plan.items` 为空），空态文案与卡片由前端根据认证状态本地化渲染，未引入新合同字段。
- **用户数据边界**：用户业务数据在 `/api/v1/user/*` 下；账户资料/安全操作在 `/api/v1/account/*` 下。
- **SSE 流**：Today AI 分析 `/api/v1/user/today-analysis/generate/stream`、Report AI 摘要 `/api/v1/user/reports/summary/generate/stream`、Assistant `/api/v1/user/assistant/chat/stream`。通过 `LucentSseClient` + Dio 直接消费，不经过 Retrofit。
- **Today 摘要展示**：后端返回 `TodayDashboard` 的饮水、用药、生命体征等数据，前端 `view_models.dart` 组装摘要指标和五个快捷入口；合同不返回可直接渲染的 UI 条目数组。AI 摘要正文通过上述 Today AI SSE 按需生成。
- **公开路由**：`/legal` 和 `/reports/clinic-summary/shared/:token` 为公开访问（`@Public()` 装饰器）。
- **API 路径常量**：`core/network/api_paths.dart`（`LucentApiPaths`）集中管理所有 `/api/v1/...` 路径字符串。
- **用药风险检查**：`GET /api/v1/medicines/risk-check` 获取最新 static + llm 检查记录；`POST /api/v1/medicines/risk-check` 触发检查（body: `{ type: 'static' | 'llm' }`）。后端 `MedicineRiskCheckListener` 监听健康上下文/提醒变更事件自动 mark stale + debounce 静态检查。前端通过 `MedicineRiskCheckRemoteDataSource`（`data/datasources/risk_check_remote.dart`）封装 `LucentClient.medicines` API 调用 + `MedicineRiskCheckMapper` DTO 映射，repository 仅作薄包装委托。
