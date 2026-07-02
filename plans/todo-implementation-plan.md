# TODO 实施方案

> 基于 `Lucent/docs/TODO.md` 和 `Luminous/docs/TODO.md`（2026-06-29）中所有未完成项，逐项给出实施方案、依赖与预期效果，末尾附推荐执行顺序。

---

## 一、Lucent 后端（2 项）

---

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

### 3. Red-flag 规则审计 + 帮助资源完善

**现状**：部分 red-flag 措辞硬编码，帮助资源入口仍需要继续审校。

**方案**：

1. 审计 `_specialGroupFindings()` 和 `_allergyFindings()` 的 risk 描述文案，确保医学表述准确
2. 对接 `support-resources` 后端真实数据，替换帮助入口中的 mock/占位行为
3. 帮助资源跳转链接更新为真实 URL

**引入依赖**：无（需运营提供准确文案和链接）

**预期效果**：

- 离线急救指引更准确
- 帮助资源可真实跳转

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
