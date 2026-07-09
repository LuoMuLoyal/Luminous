# Today 主动建议引擎后端架构规划

> **目标**：把 Today 页「主/次建议卡」的生成逻辑从客户端硬编码迁移到后端统一裁决引擎，使其能够按 `Product_Tab_Component_Blueprint` 支持「明确风险 / 疑似漏服 / 恶化趋势 / 行为建议」四类卡片，同时保持规则可解释、可审计、AI 仅做解释层。
>
> **范围**：后端架构 + API 合同 + 与前端数据模型的对应关系；不涉及具体 UI 改动。
> **前置阅读**：`docs/01-product/Product_Tab_Component_Blueprint.md`、`docs/01-product/Product_AI_Design.md`、`docs/00-current/Active_UI_Today.md`。

---

## 1. 现状与痛点

当前 Today 的 `priorityItems` 由 `LucentTodayRepository.fetchDashboard()` 在前端硬编码组装，只产出两类：

- `TodayPriorityItemType.medication` — 待服药提醒
- `TodayPriorityItemType.water` — 饮水目标缺口

后端已有的相关能力：

- `POST /api/v1/user/today-analysis/generate` — AI 每日总结（summary + bullets + action + confidenceNote）
- `GET /api/v1/user/today-analysis/recommendations` — 随机今日健康推荐（仅用于观察项 fallback）

**痛点**：

1. 蓝图要求 Today 主/次卡能表达四类建议，但前端只有 2 个枚举分支，无法扩展。
2. 复杂 inference（如「恶化趋势」「行为建议」）需要跨多天、跨记录类型聚合，客户端拉取全部历史数据不现实。
3. 规则逻辑散落在前端，难以复用给 Report 历史建议回顾、通知文案生成、用药安全解释等其他表面。
4. 医疗/健康建议必须可解释、可审计，前端硬编码无法满足安全审校要求。

---

## 2. 设计原则

1. **规则优先，AI 仅解释**（对齐 `Product_AI_Design`）
   - 所有「是否出现建议」「优先级排序」由规则引擎决定。
   - LLM 只负责生成自然语言解释、证据摘要、边界文案，不参与医疗/安全判定。
2. **信号与裁决分离**
   - Signal：原始事实（记录、用药计划、风险检查结果）。
   - Candidate：规则命中后的候选建议。
   - Suggestion：经仲裁后返回给 Today 的最终卡片。
3. **可审计**
   - 每张卡片必须携带 `ruleId` / `ruleVersion` / `evidence` / `confidence`。
4. **向后兼容**
   - 新增接口，不破坏现有 `/today-analysis/generate` 和 `/today-analysis/recommendations`。
5. **分阶段落地**
   - 先做规则引擎 + 用药/饮水两类（替换前端硬编码），再逐步加入症状/睡眠/饮食趋势。

---

## 3. 核心架构：三层流水线

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Today Suggestion Pipeline                     │
├─────────────────────────────────────────────────────────────────────┤
│  Signal Layer                                                        │
│  ├── 用药信号：currentMedicines, reminders, doseLogs, riskCheck      │
│  ├── 记录信号：dailyRecords（water/sleep/meal/symptom/mood）         │
│  ├── 健康档案：allergies, conditions, profile                        │
│  └── 上下文：timeOfDay, weather/environment（可选）                  │
├─────────────────────────────────────────────────────────────────────┤
│  Candidate Layer（Rule Engine）                                      │
│  ├── RuleRegistry：每条规则 = match(signal) → Candidate              │
│  ├── 规则示例：                                                       │
│  │   • missed_dose_pending      → 疑似漏服 / 计划未处理              │
│  │   • confirmed_risk           → 明确风险（来自 risk check）         │
│  │   • deteriorating_symptom    → 症状恶化趋势                        │
│  │   • water_behind_target      → 饮水行为建议                        │
│  │   • sleep_shortfall          → 睡眠不足行为建议                    │
│  │   • low_risk_behavior        → 低风险生活方式建议                  │
│  └── 每条 Candidate 含：type, priorityScore, confidence, evidence[]   │
├─────────────────────────────────────────────────────────────────────┤
│  Arbitration Layer                                                   │
│  ├── 过滤：confidence < threshold 或用户已 dismiss 的 candidate      │
│  ├── 排序：urgency × confidence × userRelevance                      │
│  ├── 去重/合并：同类 candidate 合并，避免重复提醒                     │
│  └── 截断：1 张 primary + 最多 2 张 secondary，其余降级为 observation│
├─────────────────────────────────────────────────────────────────────┤
│  Presentation Layer（API Response）                                  │
│  └── List<TodaySuggestionDto> + metadata                             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. 数据模型

### 4.1 领域实体（后端内部）

```ts
// 信号封装，统一不同数据源的输入
interface SuggestionSignal {
  signalId: string;
  source: 'medication' | 'record' | 'risk_check' | 'profile' | 'environment';
  kind: string;           // 例如 'pending_dose', 'water_count', 'symptom_severity'
  recordedAt: Date;
  payload: Record<string, unknown>;
  userId: string;
}

// 候选建议
interface SuggestionCandidate {
  candidateId: string;
  ruleId: string;         // 可审计
  ruleVersion: string;
  type: SuggestionType;   // 见下
  title: string;          // 已本地化的简短标题
  reason: string;         // 为什么出现
  evidence: EvidenceItem[];
  boundary: string;       // 免责声明 / 限制
  primaryAction: SuggestionAction;
  secondaryActions?: SuggestionAction[];
  priorityScore: number;  // 0-1000
  confidence: 'high' | 'medium' | 'low';
  expiresAt?: Date;       // 建议有效期，用于自动 dismiss
}

enum SuggestionType {
  CONFIRMED_RISK = 'confirmed_risk',           // 明确风险
  MISSED_DOSE = 'missed_dose',                 // 疑似漏服 / 计划未处理
  DETERIORATING_TREND = 'deteriorating_trend', // 明显恶化趋势
  BEHAVIOR_ADVICE = 'behavior_advice',         // 低风险行为建议
}

interface EvidenceItem {
  kind: 'record' | 'reminder' | 'risk_check' | 'trend' | 'profile';
  label: string;
  value: string;
  recordId?: string;      // 可点击跳转到 Record 详情
  medicineId?: string;    // 可点击跳转到 Medicine
}

interface SuggestionAction {
  actionId: string;
  label: string;
  route: string;          // 深度链接，例如 '/medicine', '/record/create?kind=water'
  authRequired: boolean;
}
```

### 4.2 API Response DTO（给前端）

```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "generatedAt": "2026-07-09T12:30:00+08:00",
    "primary": {
      "id": "sug_xxx",
      "type": "missed_dose",
      "cardTone": "urgent",
      "icon": "pill",
      "title": "上午的阿托伐他汀尚未确认",
      "reason": "计划服药时间为 08:00，当前已超时 4 小时且未标记服用。",
      "evidence": [
        { "kind": "reminder", "label": "计划时间", "value": "08:00" },
        { "kind": "record", "label": "今日状态", "value": "未确认", "recordId": "..." }
      ],
      "boundary": "此提醒基于您的用药计划，不能替代医生或药师建议。",
      "primaryAction": { "label": "去确认", "route": "/medicine", "authRequired": true },
      "secondaryActions": [
        { "label": "跳过此次", "route": "/medicine?action=skip&id=...", "authRequired": true }
      ],
      "confidence": "high",
      "ruleId": "missed_dose_pending",
      "ruleVersion": "1.0.0"
    },
    "secondary": [
      {
        "id": "sug_yyy",
        "type": "behavior_advice",
        "cardTone": "soft",
        "icon": "droplets",
        "title": "今日饮水还差 2 杯",
        ...
      }
    ],
    "observations": [
      // 低置信度或排序靠后的 candidate，不进入主/次卡
    ]
  }
}
```

### 4.3 与前端实体的映射

| 后端 DTO | 前端实体 | 说明 |
|---|---|---|
| `primary` / `secondary[]` | `TodayPriorityItem` + `TodaySuggestionItem` | 扩展 `TodayPriorityItemType` 为 `medication / water / confirmedRisk / missedDose / deterioratingTrend / behaviorAdvice` |
| `observations` | `TodayRecommendation` | 低置信度内容继续走现有观察项区 |
| `evidence[]` | 主卡可折叠证据区 | 保持不变 |
| `boundary` | 主卡可折叠边界区 | 保持不变 |
| `primaryAction.route` | `context.go()` / `context.push()` | 前端解析深度链接 |

---

## 5. API 合同

### 5.1 新增接口

```http
GET /api/v1/user/today/suggestions
```

**Query Parameters**：

- `date` (optional, `YYYY-MM-DD`)：默认当天。
- `excludeIds` (optional, `string[]`)：用户已 dismiss 的建议 id，本次不再返回。
- `locale` (optional)：默认从 `Accept-Language` 读取，用于返回已本地化文案。

**Response**：见 4.2。

### 5.2 现有接口调整建议（非必须）

- `/today-analysis/generate` 继续负责 AI 每日总结（summary + bullets），不承载卡片裁决。
- `/today-analysis/recommendations` 可逐步废弃，由 `/today/suggestions` 的 `observations` 替代。
- 未来可考虑把 `/today/suggestions` 与 dashboard 聚合为一个 `GET /api/v1/user/today/dashboard` 端点，一次性返回 suggestions + summary + vitals，减少前端请求数。

---

## 6. 规则引擎示例

### 6.1 明确风险（confirmed_risk）

**信号来源**：Medicine 风险检查结果。

```
IF riskCheck.findings.length > 0
AND finding.severity IN ['high', 'critical']
AND finding.status == 'confirmed'
THEN create Candidate(CONFIRMED_RISK)
     priorityScore = 900 + severityBonus
     evidence = [finding.title, finding.medicines, finding.ruleReference]
     primaryAction = { route: '/medicine/risk-check', label: '查看风险解释' }
```

### 6.2 疑似漏服 / 计划未处理（missed_dose）

**信号来源**：reminders + doseLogs。

```
FOR each active reminder scheduled for today
  IF now > scheduledTime + gracePeriod (e.g. 30min)
  AND no doseLog for (medicineId, scheduledTime) with status taken/skipped
  THEN create Candidate(MISSED_DOSE)
       priorityScore = 800 + overdueMinutes/10
       evidence = [planTime, medicineName, lastTakenAt]
       primaryAction = { route: '/medicine', label: '去确认' }
```

### 6.3 明显恶化趋势（deteriorating_trend）

**信号来源**：symptom records（最近 N 天）。

```
FOR each symptom type recorded in last 7 days
  IF severity trend slope > threshold
  AND consecutiveDays >= 2
  THEN create Candidate(DETERIORATING_TREND)
       priorityScore = 700
       confidence = medium/high based on record density
       evidence = [latest severity, trend direction, days count]
       boundary = "请尽快线下就医或咨询医生。"
       primaryAction = { route: '/record/create?kind=symptom', label: '记录症状' }
```

### 6.4 低风险行为建议（behavior_advice）

**信号来源**：daily records + targets。

```
water_count = records.where(kind == 'water' and date == today).sum(amount)
IF water_count < target * 0.5 AND timeOfDay >= afternoon
THEN create Candidate(BEHAVIOR_ADVICE, subtype='water')
     priorityScore = 400
     evidence = [current cups, target cups]
     primaryAction = { route: '/record/create?kind=water', label: '去记录' }
```

---

## 7. 实现阶段

### Phase 1：规则引擎骨架 + 替换现有两类（2-3 周）

- 后端新增 `TodaySuggestionService` + `RuleRegistry` + 信号聚合器。
- 把当前前端硬编码的 `medication`、`water` 逻辑迁移为后端规则。
- 新增 `GET /api/v1/user/today/suggestions`。
- 前端新增 `TodaySuggestionsRemoteDataSource`，`LucentTodayRepository` 不再自己组装 `priorityItems`。
- 扩展 `TodayPriorityItemType` 以兼容后端 `type` 字段，但 UI 仍只渲染 medication/water 两类。

**验收标准**：

- 前后端请求成功，Today 主/次卡行为与现有硬编码一致。
- 所有建议卡片携带 `ruleId` / `evidence` / `boundary`。

### Phase 2：支持蓝图四类卡片（2-3 周）

- 后端新增 `confirmed_risk`、`deteriorating_trend`、`behavior_advice` 规则。
- 前端按蓝图扩展渲染： urgent tone 用于风险/漏服，soft tone 用于行为建议。
- 主卡支持多种 `cardTone`：
  - `urgent` — confirmed_risk / missed_dose
  - `warning` — deteriorating_trend
  - `emphasis` / `soft` — behavior_advice
- 完善 `evidence` 折叠区与 `boundary` 文案。

**验收标准**：

- 蓝图四类建议均可在 Today 首屏出现。
- 低置信度 candidate 自动降级到观察项区。

### Phase 3：AI 解释层接入（1-2 周）

- 对复杂 candidate（如 deteriorating_trend），后端可调用 LLM 生成 `reason` 和 `boundary` 的自然语言变体。
- 提供 `generateReason(suggestionId)` 接口，前端按需请求，不阻塞首屏。
- 所有 LLM 输出必须基于 `evidence[]`，禁止生成 evidence 之外的内容。

### Phase 4：反馈与持续优化（ ongoing ）

- 记录用户「稍后处理 / 不适用 / 已执行」反馈。
- 基于反馈调整规则优先级和 threshold。
- 支持 A/B 规则版本（`ruleVersion`）。

---

## 8. 前端需要配合的改动

1. **扩展枚举**
   ```dart
   enum TodayPriorityItemType {
     medication,
     water,
     confirmedRisk,
     missedDose,
     deterioratingTrend,
     behaviorAdvice,
   }
   ```

2. **移除前端硬编码组装逻辑**
   - `LucentTodayRepository.fetchDashboard()` 不再构造 `priorityItems`。
   - 新增 `TodaySuggestionsRemoteDataSource` 调用 `/today/suggestions`。

3. **渲染层按 `type` 分发**
   - `suggestion_section.dart` 中 `TodayPrimarySuggestionSection` / `TodaySecondarySuggestionsSection` 根据 `item.type` 选择颜色、图标、动作。
   - `TodayCardTone` 增加 `warning`。

4. **动作路由解析**
   - 后端返回 `route` 字符串（如 `/record/create?kind=water`），前端统一用 `GoRouter` 解析。

---

## 9. 安全、隐私与边界

1. **医疗免责声明**
   - 所有卡片 `boundary` 必须包含「不构成诊断/处方，必要时请咨询医生」。
2. **证据可溯源**
   - 每条 evidence 必须能映射回具体记录或规则来源，禁止黑盒结论。
3. **红线规则**
   - 禁止 LLM 直接给出「停药、加量、换药」建议。
   - 禁止 LLM 在未命中规则时虚构风险。
   - 红旗信号（高烧不退、呼吸困难、严重过敏）必须来自固定规则表和固定文案。
4. **隐私**
   - 规则引擎只使用用户已授权数据；未授权字段不参与 inference。
5. **可回滚**
   - 规则版本化，发布异常可快速回退到上一版 rule set。

---

## 10. 与现有后端的集成点

| 现有后端模块 | 新引擎如何使用 |
|---|---|
| `MedicineRiskCheckService` | 输出 `findings` 作为 `CONFIRMED_RISK` 信号 |
| `MedicineReminderService` + `DoseLogService` | 输出 `MISSED_DOSE` 信号 |
| `DailyRecordService` | 输出 water/sleep/meal/symptom/mood 信号 |
| `HealthContextService` | 输出 allergies/conditions/currentMedicines 信号 |
| `UserNotificationService` | 接收高优先级建议，生成 proactive 通知 |
| `TodayAnalysisService`（AI 摘要） | 继续独立运行；未来可消费 suggestion summary 作为 bullets 素材 |

---

## 11. 建议的目录结构（Lucent 后端）

```
src/
├── today/
│   ├── today-suggestion.controller.ts   # GET /today/suggestions
│   ├── today-suggestion.service.ts      # 编排 Signal → Candidate → Suggestion
│   ├── today-suggestion.module.ts
│   ├── dto/
│   │   ├── today-suggestion.dto.ts
│   │   ├── evidence-item.dto.ts
│   │   └── suggestion-action.dto.ts
│   ├── rules/
│   │   ├── rule.registry.ts
│   │   ├── rule.interface.ts
│   │   ├── missed-dose.rule.ts
│   │   ├── confirmed-risk.rule.ts
│   │   ├── deteriorating-symptom.rule.ts
│   │   ├── water-shortfall.rule.ts
│   │   └── sleep-shortfall.rule.ts
│   ├── signals/
│   │   ├── signal-collector.interface.ts
│   │   ├── medication-signal.collector.ts
│   │   ├── record-signal.collector.ts
│   │   └── profile-signal.collector.ts
│   └── arbitrators/
│       ├── suggestion.arbitrator.ts     # 排序、去重、截断
│       └── scoring.policy.ts
```

---

## 12. 结论

后端应采用 **「Signal → Candidate（规则引擎）→ Suggestion（仲裁器）」** 的三层流水线，而不是把建议逻辑继续放在前端或让 LLM 直接生成建议。

- **Phase 1 即可替换现有 medication/water 硬编码**，价值立即可见。
- **Phase 2 达成蓝图四类建议卡**，不依赖强 LLM 能力。
- **Phase 3 的 AI 层只做解释和文案润色**，与 `Product_AI_Design` 的「规则兜底 + AI 解释」原则一致。

这样后端能力可以逐步增强，前端今天就能按统一合同渲染，避免等产品/AI 成熟后再做一次性大改。
