# TODO 实施方案

> 基于 `Lucent/docs/TODO.md` 和 `Luminous/docs/TODO.md`（2026-06-29）中所有未完成项，逐项给出实施方案、依赖与预期效果，末尾附推荐执行顺序。

---

## 一、Lucent 后端（2 项）

### 1. Assistant RAG — pgvector 向量检索

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

### 2. Assistant RAG — alpaca_zh_demo 数据集评估

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

### 5. 环境驱动的 Today/Mine 建议

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

### 6. 语音 / 截图记录录入

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

### 7. 隐私保护诊所摘要

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

_最后更新：2026-06-29_
