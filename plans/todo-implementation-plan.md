# TODO 实施方案

> 基于 `Lucent/docs/TODO.md` 和 `Luminous/docs/TODO.md`（2026-06-29）中所有未完成项，逐项给出实施方案、依赖与预期效果，末尾附推荐执行顺序。

---

## 一、Lucent 后端（5 项）

### 1. Report Export — 异步 Worker

**现状**：`data-export` 模块在 HTTP 请求线程中同步生成 PDF。BullMQ 已在 `mail-queue.service.ts` 中引入，Redis 连接可用。大报告（多周、多药品）可能阻塞请求超时。

**方案**：

1. 新建 `src/modules/data-export/services/data-export-queue.service.ts`
   - 复用现有 Redis 连接创建 `Queue` 和 `Worker`
   - Job data: `{ exportRequestId: string }`
2. 修改 `DataExportController`
   - `POST /api/v1/data-export/reports` 改为立即返回 `{ exportId, status: 'queued' }`
   - 不再 await PDF 生成
3. Worker 逻辑
   - 从 DB 加载 export request → 调用现有 `ReportExportPdfService.generatePdf()` → 写入文件 → 更新 DB 状态为 `completed` / `failed`
   - 可选：完成后通过 `NotificationsService` 推送通知
4. 前端适配
   - `DataExportPage` 轮询 export 状态，完成后展示下载链接

**引入依赖**：无（bullmq 已在 `package.json`）

**预期效果**：
- HTTP 请求 ≤ 200ms 返回，不再超时
- 失败自动重试（BullMQ 内置）
- 用户可关闭页面，完成后收到通知

---

### 2. Report Export — 结构化段落与图表

**现状**：当前 PDF 模板以文字为主，缺少可视化图表。

**方案**：

1. 改造 `ReportExportPdfService`
   - 按 section 分页：封面 → 综合评分 → 关键指标 → AI 总结 → 发现 → 趋势 → 导出说明
   - 每页添加页眉/页脚（日期、页码）
2. 图表生成
   - 引入 `chart.js` + `chartjs-node-canvas`（Node 端生成 PNG）
   - 趋势 section 嵌入折线图（睡眠/用药/饮水）
   - 指标 section 嵌入雷达图（药物安全、生活方式、症状）
3. 配置化：`ReportExportConfig` 控制包含哪些 section

**引入依赖**：`chart.js`、`chartjs-node-canvas`、`@types/chart.js`

**预期效果**：
- 医生可读性显著提升
- 视觉化展示健康趋势和风险分布

---

### 3. Assistant RAG — pgvector 向量检索

**现状**：

- `assistant-tool-leaflet-read.service.ts` 用 Prisma `contains`（SQL `LIKE`）做关键词匹配 + `chunkIndex` 顺序取 chunk。无 embedding、无向量检索。
- `medicineLeafletChunk` 表无 `embedding` 列，仅存储文本 chunk。
- Embedding 配置（`AI_EMBEDDING_API_KEY`、`AI_EMBEDDING_BASE_URL`、`AI_EMBEDDING_MODEL`）已在 `ai.config.ts` 和 `env-keys.enum.ts` 中定义，但未被 assistant 模块使用。
- 项目已深度使用 LangGraph：`StateGraph` + `Annotation` 构建编排图，`@langchain/openai` 提供 `ChatOpenAI`。工具系统为自定义 server-side dispatch（非 LangChain `DynamicStructuredTool`）。

**方案**：

1. 数据库层 — pgvector 扩展
   - PostgreSQL 启用 `CREATE EXTENSION vector`
   - `MedicineLeafletChunk` 表新增 `embedding vector(1536)` 字段
   - 建 IVF-Flat 索引加速检索
2. Embedding 生成 — 复用已有配置
   - 使用已配置的 embedding API（`AI_EMBEDDING_MODEL` 等环境变量）生成向量
   - 数据导入脚本 `rebuild-leaflet-index.ts` 增加 embedding 生成步骤：对每个 chunk 调用 API → 写入 `embedding` 列
   - 运行时：新增/更新 chunk 时同步生成 embedding
3. 检索实现 — 对接现有工具调度体系
   - 在 `assistant-tool-leaflet-read.service.ts` 中新增 `searchByVector()` 方法
   - 对 user query 调用 embedding API → 得到 query vector
   - 执行 pgvector 余弦距离查询：`SELECT * FROM medicine_leaflet_chunk ORDER BY embedding <=> $1 LIMIT $2`
   - 保留现有 `resolveProduct()` + LIKE 匹配作为 recall（product 解析仍用关键词，chunk 检索切换为向量）
   - 混合策略：向量检索取 top-5 → 若分数过低（< 0.7）降级回关键词 fallback
4. 工具注册无变化
   - `get_medicine_leaflet_context` 工具的外部接口不变
   - 仅内部实现从 LIKE 切换为 pgvector 余弦距离
   - `AssistantToolService` 的 switch dispatch、`AssistantRuntimeService` 的 graph 编排均无需修改
5. 后续可选 — LangGraph Retriever 集成
   - 当前工具系统为自定义 dispatch，不需要 LangChain Retriever 抽象
   - 若未来将工具迁移为 LangChain `DynamicStructuredTool`，可利用 `PGVectorStore.asRetriever()` 作为标准 retriever 直接注入 graph

**引入依赖**：`pgvector` 扩展（PostgreSQL）、`@langchain/community`（可选，仅在后续升级时用 `PGVectorStore`）

**预期效果**：
- 从精确匹配提升到语义匹配：用户问"布洛芬伤胃吗"能匹配到"布洛芬缓释胶囊-注意事项-胃肠道反应"
- 与现有 LangGraph 编排体系无缝集成，不改变工具接口和 graph 结构
- embedding 配置复用，无额外 API key 管理成本

---

### 4. Assistant RAG — alpaca_zh_demo 数据集评估

**现状**：`DrugDataBase/医疗问答数据集一共135万条/数据集/alpaca_zh_demo.json` 包含 1.36M 条中文医疗问答。当前未导入，仅记录为待评估。

**方案**：

1. 数据采样与过滤
   - 随机采样 500-1000 条，人工审核质量
   - 编写过滤脚本：去广告、去个人经验、去非医学闲聊
2. 小批量导入 + 向量化验证
   - 导入过滤后的子集到 `AssistantQaCorpus` 表，同步生成 embedding
   - 评估向量检索准确率（人工标注 50 条 query，看 top-3 召回是否有用）
3. 决策
   - 若 Top-3 准确率 ≥ 70%，制定全量导入方案
   - 若准确率低，放弃或仅保留高质量子集

**引入依赖**：依赖第 3 项的 pgvector + embedding 基础设施

**预期效果**：
- 决策是否投入做医疗问答 RAG
- 为后续"Agent 辅助就医发现"提供语料基础

---

### 5. Auth — 2FA（TOTP）

**现状**：密码登录无二次验证。用户可在设置中变更密码/邮箱，但无额外安全层。

**方案**：

1. 绑定流程
   - `POST /api/v1/auth/2fa/generate`：生成 TOTP secret → 生成 `otpauth://` URI → 返回 QR 码（base64 PNG）
   - `POST /api/v1/auth/2fa/confirm`：用户输入当前 TOTP → 验证通过 → 标记 `twoFactorEnabled = true`
2. 登录流程改造
   - `login()` 在密码验证通过后检查 `user.twoFactorEnabled`
   - 若开启，返回 `{ requiresTwoFactor: true, tempToken }`（临时 token，仅用于 2FA 验证，有效期 5 分钟）
   - 前端收到后跳转 2FA 输入页
   - `POST /api/v1/auth/2fa/verify`：校验 TOTP + tempToken → 签发正式 token pair
3. 恢复码
   - 生成 8 个一次性恢复码（`crypto.randomBytes(4).toString('hex')`）
   - `POST /api/v1/auth/2fa/recover`：用恢复码绕过 TOTP
4. 数据库
   - `User` 表新增字段：`twoFactorEnabled`、`twoFactorSecret`、`twoFactorRecoveryCodes`

**引入依赖**：`otplib`、`qrcode`

**预期效果**：
- 账号安全升级，防密码泄露后被盗
- 支持 Google Authenticator / Authy 等标准 TOTP App

---

### 6. Auth — 更多 OAuth Provider

**现状**：仅支持微信（Web + Mobile）。

**方案**：

1. 抽象 `OAuthProvider` 接口
   ```typescript
   interface OAuthProvider {
     readonly provider: OAuthProviderType;
     fetchProfile(code: string): Promise<OAuthProfile>;
   }
   ```
2. 实现 `AppleOAuthProvider`
   - 使用 `apple-signin-auth` 验证 identity token（JWT）
   - 获取 `sub`、`email`、`name`
3. 实现 `GoogleOAuthProvider`
   - 标准 OAuth 2.0 code flow → token → userinfo
   - 使用 `google-auth-library`
4. 注册到 `AuthModule`，按 provider 类型路由
5. 前端：`Luminous` auth 页面增加 Apple / Google 登录按钮

**引入依赖**：`google-auth-library`、`apple-signin-auth`

**预期效果**：
- 支持 Apple / Google 一键登录
- Android 和 iOS 均可使用平台原生登录体验

---

## 二、Luminous 前端（11 项）

### 延后项（3）— 明确不做

| 项 | 延后原因 |
|----|----------|
| `formz` 表单校验替代 | 当前 `AppToast` 校验模式工作正常，引入 `formz` 增加依赖但无用户体验改进 |
| `intl.DateFormat` 替代 ISO 字符串 | `padLeft` 格式是后端线协议约定，`DateFormat` 无法替代 |
| 默认 padding md→lg | 当前与 `AppLayoutTokens.cardPadding` 一致，修改会导致多处布局溢出 |

### Not MVP（7）— 明确不做

女性健康、运动恢复、专科健康包、智能设备、家庭档案、皮肤识别、Desktop-first workflows。这些是产品路线图上的远期功能，不在当前 MVP 范围内。

---

### ✅ 已完成移出

- ~~Lightweight assistant~~（2026-06-29 确认：完整实现，含 6 个权限开关、SSE 流式 Markdown、工具调用+提案确认）

---

### 1. 药品规则扩展

**现状**：`medicine_risk_checker.dart` 包含基础禁忌/慎用/咨询医生关键词分类和固定 red-flag 规则。

**方案**：
- 扩充 `_contraindicatedKeywords` / `_avoidKeywords` / `_cautionKeywords` 词表
- 增加更多中文同义表述
- 扩展 `_specialGroupFindings()`：增加肾功能、肝功能分级判断
- 可选：将规则外置为 JSON 配置文件，支持热更新

**引入依赖**：无

**预期效果**：覆盖更多药品说明书中的风险表述，减少漏报

---

### 2. 交叉数据源归一化

**现状**：CN 药品说明书和 DrugBank 各自独立匹配。CN 成分名（如"对乙酰氨基酚"）无法关联到 DrugBank 的相互作用数据。

**方案**：
- 扩充 `ingredient_canonicalizer.dart` 中 `_cnToDrugbankMap`
- 手工维护 CN 成分名 → DrugBank ID 映射表（核心药品约 200 对）
- 工具脚本辅助：对 CN 药品成分做字符串相似度匹配 DrugBank 名称，人工确认

**引入依赖**：无

**预期效果**：
- CN 药品能触发 DrugBank 级别的相互作用检测
- 覆盖中西药联合用药场景

---

### 3. Red-flag 规则审计 + 校园/帮助资源完善

**现状**：部分 red-flag 措辞硬编码，校园资源入口部分为 mock。

**方案**：
1. 审计 `_specialGroupFindings()` 和 `_allergyFindings()` 的 risk 描述文案，确保医学表述准确
2. 对接 `support-resources` 后端真实数据，替换 mock 入口
3. 校园服务跳转链接更新为真实 URL

**引入依赖**：无（需运营提供准确文案和链接）

**预期效果**：
- 离线急救指引更准确
- 校园/帮助资源可真实跳转

---

### 4. Agent 辅助就医发现

**现状**：Assistant 无地理位置感知，无法推荐附近医院/药店。

**方案**：
1. 后端新增 `find_nearby_care` tool
   - 接收 `{ latitude, longitude, type: 'hospital' | 'pharmacy' }`
   - 调用高德/百度地图 Place API 搜索周边
2. 前端 Assistant 提案卡片新增 `NavigateToCare` 类型
   - 展示医院名称、距离、地址
   - 点击跳转系统地图导航
3. 权限：需用户授权位置信息

**引入依赖**：高德地图 API key 或百度地图 API key（后端配置）

**预期效果**：
- 用户问"附近有什么医院"时，Assistant 返回真实 POI 列表
- 一键跳转导航

---

### 5. 药品安全规则深度覆盖

**现状**：规则覆盖数量和深度有限。

**方案**：与第 1 项协同推进，重点增加：
- 肝肾功能不全分级（轻度/中度/重度）
- 特定疾病禁忌（如青光眼禁用阿托品类）

**引入依赖**：需医学审核

**预期效果**：
- 从"禁忌/慎用"二分类升级到多维风险评估
- 展示分级原因（如"肝功能中度不全者慎用"）

---

### 6. Report/Export 收尾清理

**现状**：前端文案有个别不一致（状态标签、过期文案），部分边界情况未覆盖。

**方案**：
1. 统一导出状态标签（生成中 / 已完成 / 已过期 / 失败）
2. 过期链接处理：下载链接过期后展示"重新生成"按钮
3. 真环境验收：用真实数据跑一次完整流程（生成 → 下载 → 查看）
4. 不重新打开后端导出范围（除非发现 real bug）

**引入依赖**：无

**预期效果**：
- 导出体验打磨到可上线标准
- 文案一致，边界情况有兜底

---

### 7. 提醒投递历史

**现状**：`medicine-reminders` 只管理当前提醒规则和状态，无历史记录。

**方案**：
1. 后端：新建 `ReminderDeliveryLog` 表
   - 字段：`id`、`reminderId`、`userId`、`channel`（local/push/SMS）、`status`（sent/failed）、`deliveredAt`
2. Worker：每次投递后写入 log
3. 前端：提醒详情页新增投递历史时间线
4. API：`GET /api/v1/medicine-reminders/:id/delivery-logs`

**引入依赖**：无（Prisma migration + 后端逻辑）

**预期效果**：
- 用户可查看每一条提醒是否成功投递
- 调试推送问题时有关键数据

---

### 8. 环境驱动的 Today/Mine 建议

**现状**：Today 建议是固定规则生成，不感知外部环境。

**方案**：
1. 后端新增 `GET /api/v1/environment/suggestions`
   - 接收前端传来的城市/坐标
   - 调用天气 API 获取当前天气（温度、湿度、AQI）
   - 根据规则返回个性化建议（如高温→多喝水、AQI 高→减少户外）
2. 前端 Today 建议 section 优先展示环境建议
3. 权限：需用户授权位置

**引入依赖**：天气 API key（和风天气 / OpenWeatherMap）

**预期效果**：
- Today 页面显示"今日高温 35°C，注意补水和防暑"
- 提升产品智能化感知

---

### 9. 条码 / OCR / 拍照识别

**现状**：仅 UI 入口占位（快捷操作中的"扫药盒"、"拍处方"），无实际实现。

**方案**：
1. 条码扫描
   - 引入 `mobile_scanner`，扫描药品条码（EAN-13 / GS1）
   - 匹配后端药品数据库（CN 药品批准文号或 EAN 码）
   - 匹配成功 → 跳转药品详情；失败 → 提示手动搜索
2. OCR 处方识别
   - 引入 `google_mlkit_text_recognition`
   - 拍照 → OCR 提取文字 → 正则匹配药品名、用法用量
   - 匹配到的药品 → 自动填入加药表单
3. 仅支持移动端，桌面端隐藏入口

**引入依赖**：`mobile_scanner`、`google_mlkit_text_recognition`

**预期效果**：
- 扫药盒直接查看药品安全和相互作用
- 拍处方自动解析药品名，减少手动输入

---

### 10. 语音 / 截图记录录入

**现状**：无。

**方案**：
1. 语音录入
   - 引入 `speech_to_text`
   - 用户口述 → 转文字 → 调用 NLP 解析（复用 `record_nlp_controller`）
   - 解析结果预览 → 确认创建记录
2. 截图录入
   - 图片 → `google_mlkit_text_recognition` OCR → 同 NLP pipeline
3. 入口：Record 页面快捷操作区

**引入依赖**：`speech_to_text`、`google_mlkit_text_recognition`

**预期效果**：
- 自然语言录入日常健康记录
- 降低记录门槛（不用打字）

---

### 11. 隐私保护诊所摘要

**现状**：无。

**方案**：
1. 后端新增 `POST /api/v1/reports/clinic-summary/preview`
   - 基于 Report 数据生成脱敏版摘要
   - 脱敏规则：隐藏真实姓名、邮箱、手机号；用药数据保留通用名
   - 输出按 section 分组：基本信息、用药概要、关键发现、建议
2. 前端新增"分享给医生"入口
   - 预览 → 可选导出 PDF 或生成分享链接（24h 有效）
3. 安全：分享链接仅包含脱敏数据，不携带 token

**引入依赖**：无（后端逻辑扩展）

**预期效果**：
- 用户可安全分享健康摘要给医生
- 隐私可控，到期自动失效

---

### 12. 真实认证 Web 报告预览

**现状**：`Luminous-site/` 是 Nuxt 竞赛/营销主页，无登录态。

**方案**：
1. `Luminous-site/` 增加登录页 → Lucent API 认证
2. 认证后跳转 `/report/:id` 预览页
3. 读取 Lucent Report API，渲染与 App 一致的报告视图
4. 支持导出 PDF（复用 Lucent PDF 生成 + 前端触发下载）

**引入依赖**：无（Luminous-site 已有 Nuxt 基础）

**预期效果**：
- PC 端可查看和下载健康报告
- 不再仅依赖 App 内查看

---

## 三、推荐执行顺序

| 优先级 | 归属 | 项 | 理由 |
|--------|------|-----|------|
| **P0** | Lucent | Auth 2FA | 安全升级，范围可控（3-4 天），依赖仅 `otplib` + `qrcode` |
| **P0** | Luminous | Report 收尾清理 | 纯前端（1-2 天），无风险，打磨上线体验 |
| **P1** | Lucent | Report Worker | 已有 BullMQ 基础设施（2-3 天），工程价值高 |
| **P1** | Luminous | 条码/OCR | 用户感知强（3-4 天），有成熟 Flutter 包 |
| **P1** | Luminous | 药品规则扩展 | 纯规则数据（1-2 天），直接提升安全覆盖 |
| **P2** | Lucent | Assistant RAG pgvector | pgvector 扩展（PostgreSQL），embedding 配置已有，工具接口不变 |
| **P2** | Luminous | 交叉数据源归一化 | 需手工标注映射表（2-3 天），后续持续维护 |
| **P2** | Luminous | 语音/截图录入 | 依赖包成熟（3-4 天），但 NLP 准确性待验证 |
| **P3** | Lucent | Report 图表 | 需引入 `chart.js`（3-4 天），依赖 P1 Worker |
| **P3** | Lucent | OAuth Provider 扩展 | 需第三方开发者账号配置（2-3 天/平台） |
| **P3** | Luminous | Agent 就医发现 | 需地图 API key 和位置权限（3-4 天） |
| **P3** | Luminous | 环境驱动建议 | 需天气 API key（2-3 天） |
| **P3** | Luminous | 提醒投递历史 | 需后端新表 + worker（3-4 天） |
| **P4** | Luminous | 隐私诊所摘要 | 范围大，涉及前后端（5-7 天） |
| **P4** | Luminous | Web 报告预览 | 跨项目（`Luminous-site/`），（5-7 天） |
| **P4** | Lucent | alpaca 数据集评估 | 纯评估（1-2 天），无用户可见产出 |

---

## 四、不纳入实施计划的项

| 归属 | 项 | 原因 |
|------|-----|------|
| Luminous | 延后 ×3 | 已有明确原因延后 |
| Luminous | Not MVP ×7 | 产品路线图远期功能 |

---

*最后更新：2026-06-29*
