# 餐食分析链路重构：一次多模态分析 + 按重要性排序的结论

> 状态：待执行（执行完毕后按仓库规则删除本文件，结论沉淀进 `docs/logs/migration-log/` 与 feature README）

## 一、背景（实测证伪的现状）

当前链路是「视觉识别菜品 → 菜品分解 → 成分接地对照食物成分表 → 算热量」：

```
POST /daily-records(meal, 1 张图) → markMealAnalysisQueued(analyzing)
  → queue → worker(幂等) → vision(识别菜品) → decomposition(模板/模型分解)
  → grounding(exact→alias→模糊，对照成分表) → 写 unconfirmed → 客户端确认 → 模板学习
```

**实测结论：这条链在真实照片上行不通**——菜品识别与成分接地的误差会在「对照成分表算热量」这一步被放大成没有意义的数字，
而维护一张能覆盖真实饮食的成分表/模板库本身也是不可持续的成本。已核实的硬缺陷（详见迁移日志与代码）：

| 缺陷 | 位置 | 影响 |
|---|---|---|
| JSON 解析失败降级成「空识别结果」 | `Lucent .../meal-analysis/vision.service.ts:69-73` | 写 `unconfirmed + coverage:'none'`，用户永远停在「估算中」，永不失败 |
| LLM 抛错无 catch、无 timeout | `worker.service.ts:103-106,115`、`vision.service.ts:44-47` | 重试耗尽后记录**永久 `analyzing`**；concurrency=1 时一次挂起堵整条队列 |
| 幂等只在调用前检查 | `worker.service.ts:56-58` | 分析期间用户再编辑 → 旧结果覆盖新 revision |
| `confirmed` 由客户端 payload 决定 | `records.service.ts:284-287` | 可对空分析/旧 revision 直接确认（还会触发模板学习） |
| `defaultRatio` 不参与营养计算 | `matcher.service.ts:168-171` vs `grounding.service.ts:198-243` | 两套互不相干的估算口径 |
| 列表接口 meal `payload` 恒为 null | `mapper.service.ts:116-121` | 时间线只能用热列，拿不到失败原因 |
| 下游从文本猜语义 | `today-suggestion/.../collectors/record.service.ts:202-207,350-379` | 咖啡因靠 title/note 关键词猜（与已删除的症状严重度启发式同病） |
| 契约陈旧 | `Lucent/test/contract/contract.e2e-spec.ts:582-583` | e2e 仍用 `payload:{mealType,items}` 形状 |

## 二、研究证据（外部）

- 多模态模型**直接估营养的准确度有限**，份量最不准：独立实测（[Lifehacker: AI 热量 App 比预期更糟](https://au.lifehacker.com/nutrition/114342/feature/i-used-ai-powered-calorie-counting-apps-and-they-were-even-worse-than-i-expected)）、
  跨来源系统评估（[ChatGPT-5 图像膳食能量与宏量营养素估计](https://repositorio.uneatlantico.es/17880/)、
  [对话式多模态 LLM 食物营养检索系统评估](https://vtechworks.lib.vt.edu/items/b67c2a61-f283-41ba-9602-9798306b9529)）。
  → 支持**给区间与档位、不给伪精确单值**。
- 产品侧做法参考：[SnapCalorie FAQ](https://www.snapcalorie.com/faq.html)（估算 + 人工校准路径）。
- 「AI 洞察卡」在健康产品里已有成型形态：[GlycemicGPT 的 `ai-insight-card.tsx`](https://github.com/lumose-health/GlycemicGPT/blob/main/apps/web/src/components/dashboard/ai-insight-card.tsx)；
  「自动营养汇总 + 可选 LLM 洞察」的需求讨论：[WellnessWingman #49](https://github.com/DigitumDei/WellnessWingman/issues/49)。

## 三、架构决策

### 决策 1：热量区间是**独立字段**，不进 `items` 数组

理由：类型不同（文本给人读、数值给机器算）；排序语义冲突（`items[0]` 是「最重要的一条」，热量放末尾等于自认最不重要，
放开头又挤掉真正的洞察）；UI 位置不同（区间是条目角标/详情卡，不是一句文案）；复用需要（助手/周报要按周聚合，从字符串再解析数值是反模式）。

形态：`{ min, max, unit: 'kcal', bucket: 'low'|'medium'|'high' }`，**不给单值**，`min<=max` 由服务端校验与纠正（含 clamp）。
模型若顺带产出热量相关的文字洞察（「这餐热量偏高」），那属于 `items`，与区间字段无关。

### 决策 2：`items` 是「按重要性排序的结论」，两段式文案

每项 `{ rank, kind, polarity, headline, detail }`：

- `rank` 从 1 连续（服务端规范化排序 + 裁剪，条数 clamp 3–5）；
- `kind` 用**封闭小词表**（carb / fat / protein / vegetable / fruit / fried / sugar / sodium / portion / balance / other），
  避免自由发挥导致下游无法使用；
- `polarity` = `good` / `watch` / `neutral`（列表与详情用颜色语义，不下医疗断言）；
- `headline` ≤ 18 字，给 **Record 列表条目那一行**；`detail` 一句话，给详情页与助手。
  （同一个数组同时服务「一行」与「一段」，靠字段长度分层，而不是靠消费方截断。）

### 决策 3：结构化是真相，文案是可重渲染的投影

`facets`（封闭词表，如 `{ fried: 'high', vegetable: 'high', carb: 'low' }`）是机器语义的唯一来源：规则、周报、图表读它，
**不再从 title/value/note 或文案里猜**。模型生成的 `headline/detail` 按请求语言生成并记 `locale`；
模型生成的 `headline/detail` 在那次分析的**当时语言**下生成并记 `locale`：切语言属罕见操作，**不回溯重生成、
也不提供重生成入口**（结构化 `facets` 与区间不受语言影响，规则与聚合照常）。

### 决策 4：分析必须会失败

超时（vision 调用必须有 timeout）、模型报错、JSON 解析失败，一律落 `analysis_failed` + `failureReason` 码（不再是「空结果 = 成功」）；
写回前复检 `sourceRevision`；`confirmed` 由服务端校验「分析已完成且属于当前 revision」，否则拒绝。
`analyzing` 加过期回收（超过 N 分钟视为失败，可重试）。详情页对 `analysis_failed` 提供**「重新分析」**入口
（重新入队 + `sourceRevision` 递增），否则删确认之后用户没有任何补救手段。

### 决策 5：删掉对照成分表那条链

`meal-dish/decomposition`、`meal-ingredient/grounding`、`meal-analysis/matcher` 的成分匹配与 `template-learning` 整体删除；
食物成分表在餐食链路上的使用一并去掉。产品未上线，不做历史数据迁移，不留兼容读取。
（重复餐食的成本下降由「每餐一次多模态调用」本身承担，模板学习不再是必需品。）

### 决策 6：删掉人工「确认」这一步

洞察文案与区间已经够用，确认动作不再有价值：状态收敛为 `analyzing | analyzed | analysis_failed`，
`confirmed` / `unconfirmed` 与 `mealAnalysisCoverage` 一并删除；编辑页只保留**可编辑的菜名列表**，
确认开关与详情页确认按钮消失；模板学习（只学 `confirmed`）随成分表链路一起删；下游（reports dashboard 计数、
assistant 的 `meal_estimate`/`meal_coverage` 标签、today-analysis 判定）统一改按
`analyzed / analysis_failed` + 热量档位统计。

### 新契约（草案）

```jsonc
payload.mealAnalysis = {
  "version": 2,
  "analysisStatus": "analyzing | analyzed | analysis_failed",
  "analyzedAt": "2026-09-15T12:31:04Z",
  "sourceRevision": 3,
  "model": "vision-role-name",
  "promptVersion": "meal-analysis.v2",
  "locale": "zh",
  "calorieRange": { "min": 520, "max": 780, "unit": "kcal", "bucket": "medium" },
  "dishes": [ { "name": "红烧肉", "source": "model" }, { "name": "青菜", "source": "user" } ],
  "items": [
    { "rank": 1, "kind": "fried",     "polarity": "watch", "headline": "油炸偏多",
      "detail": "午饭油炸食品摄入偏多，建议晚饭多摄入蔬菜" },
    { "rank": 2, "kind": "vegetable", "polarity": "good",  "headline": "蔬菜丰富",
      "detail": "蔬菜摄入量与种类都很丰富" },
    { "rank": 3, "kind": "carb",      "polarity": "watch", "headline": "碳水偏少",
      "detail": "晚饭碳水摄入量较少" }
  ],
  "facets": { "fried": "high", "vegetable": "high", "carb": "low", "protein": "ok" }
}
```

`dishes` 只存菜名（模型识别 + 用户改名，`source` 区分），**不存任何营养成分**；改菜名不重算已生成的
`items` / `calorieRange`（详情页对此有明确措辞；「用修正后的菜名做纯文本重算」列为后续可选）。

列表/条目所需的投影字段（解决「列表 payload 恒 null」）：保留 `mealAnalysisStatus/Coverage/UpdatedAt/FailureReason`，
**新增** `mealHeadline`（= `items[0].headline`）与 `mealCalorieMin/mealCalorieMax/mealCalorieBucket`。

### 消费视图

| 消费方 | 取什么 |
|---|---|
| Record 列表条目 | `mealHeadline`（一行）+ **粗化区间**（`约 500–800 kcal`，四舍五入到百位；`bucket` 供配色） |
| 记录详情页 | `items` 全部（rank 序，`good/watch` 配色）+ 区间卡 + **可编辑菜名列表** + 失败态（l10n 原因文案 + 重试） |
| assistant 工具 | `days` / `limit` 由**模型自定**（服务端封顶最近 15 天）的 `{date, mealType, calorieRange, items[]}` digest —— **不再重复识图** |
| today-suggestion 规则 | `facets` 封闭词表（替换咖啡因的 title/note 关键词启发式） |
| reports（dashboard / ai-summary） | 区间聚合（周/月）+ 高频 `kind` 统计 + items 摘录 |

## 四、改后的文本图像

### 4.1 Record 列表条目（一行洞察）

```text
┌──────────────────────────────────────────────┐
│ 🍽  午饭                       约 500–800 kcal│
│     油炸偏多                                  │
└──────────────────────────────────────────────┘
```

### 4.2 详情页（全部结论 + 区间卡）

```text
┌──────────────────────────────────────────────┐
│ 午饭 · 12:31                                  │
│ ┌──────────────────────────────────────────┐ │
│ │ 热量区间   520 – 780 kcal   （中等）      │ │
│ └──────────────────────────────────────────┘ │
│ 饮食分析                                      │
│ ⚠ 油炸偏多                                    │
│   午饭油炸食品摄入偏多，建议晚饭多摄入蔬菜     │
│ ✓ 蔬菜丰富                                    │
│   蔬菜摄入量与种类都很丰富                     │
│ ⚠ 碳水偏少                                    │
│   晚饭碳水摄入量较少                          │
│                                              │
│ 菜名（可编辑）                                │
│ 红烧肉 · 青菜                                 │
│                                              │
│ 分析失败时：分析失败 · 图片无法识别   [重新分析]│
└──────────────────────────────────────────────┘
```

### 4.3 assistant 读取（不再识图）

```text
tool: read_meal_analysis(days: 7)
→ [
    { date: "2026-09-15", mealType: "lunch",  calorieRange: { min: 520, max: 780 },
      items: [ { kind: "fried", polarity: "watch", headline: "油炸偏多",
                 detail: "午饭油炸食品摄入偏多，建议晚饭多摄入蔬菜" }, … ] },
    { date: "2026-09-14", mealType: "dinner", calorieRange: { min: 300, max: 460 },
      items: [ { kind: "carb", polarity: "watch", headline: "碳水偏少", … } ] }
  ]
```

## 五、改动清单

### Lucent

- `services/meal-analysis/vision.service.ts` → 改成**一次多模态分析**：输入图片（+ 餐次类型/时间等上下文），
  用结构化输出（JSON Schema）返回 `{ calorieRange, items[], facets }`；必须有 timeout 与错误上抛（不再吞成空结果）。
- `services/meal-analysis/worker.service.ts`：写回前复检 `sourceRevision`；失败落 `analysis_failed` + 原因码；
  `analyzing` 过期回收（队列/定时任务）。
- 删除 `services/meal-dish/*`、`services/meal-ingredient/*`、`services/meal-analysis/matcher.service.ts`、
  `services/meal-payload-writer.service.ts` 中成分/模板相关分支、`services/meal-dish/template-learning.service.ts`；
  清理 `meal-analysis.types.ts` 里 `recognizedDishes/resolvedIngredients/compositionMatches/nutritionEstimate` 的读写路径。
- `meal-analysis.types.ts`：新结构 + zod 校验（`common/validators/jsonb-schemas.ts`）+ 服务端规范化（rank 排序/裁剪、区间纠正）。
- `records.service.ts`：`confirmed` 服务端校验；热列投影新增 `mealHeadline`/`mealCalorie*`。
- DTO describe 补 meal payload 契约（`record-item.dto.ts` / `create-record.dto.ts` / `update-record.dto.ts`）；
  `pnpm export:openapi` + Prisma migration（新增热列）。
- ssistant 读取工具：meal digest（	ools/records/query.service.ts），工具参数含 days/limit（服务端封顶 15 天）。
- `today-suggestion`：咖啡因与饮食规则改读 `facets`（替换 title/note 关键词启发式）。
- `today-analysis` / `reports`：改读新结构与区间；失败文案进 i18n。
- 测试：vision（结构化输出、超时、坏 JSON 必须失败）、worker（revision 竞态、失败落库、过期回收）、
  records（confirmed 校验、热列投影）、assistant 工具（digest 形状）、契约/e2e shape 更新。

### Luminous

- 生成物：`dart run scripts/contract/bootstrap.dart`（新响应形状）。
- 列表/时间线：条目渲染 `mealHeadline` + 区间角标（替换 `record_mappers.dart:177` 的硬编码中文 `'识别菜品：'`）。
- 详情页：`items` 全量渲染（rank 序 + `good/watch` 语义色）+ 区间卡；失败态改用 l10n 原因文案（不再直出后端原串）。
- 编辑页只保留菜名编辑（去掉确认开关）；详情页去掉确认按钮、失败态加「重新分析」。
- 快速记录确认弹窗补必填校验（`meal_confirmation.dart` 当前可落空记录）。
- 清理：`fast_entry_choices.dart` 的四餐死配置、未使用的 `recordMealCountValue`/`recordMealLogging`、
  长按设置里 meal 文案错配的 `_ =>` 回落；确认逻辑两份实现合一。
- 测试：headline/区间渲染、items 全量、失败态文案、确认路径、时间线角标（`meal_analysis_poller.dart`、
  `quick_entry_meal.dart`、`meal_confirmation.dart` 目前零测试）。

## 六、阶段与提交拆分（每阶段一个原子提交，各自独立可回滚）

**P0 拆成两刀**（形状切换必须一次落完，但「产出侧」与「契约/投影侧」可以分开，两刀都能单独编译与回滚）：

- **P0-1｜产出侧切换（Lucent，BREAKING）**：`vision.service.ts` 改成一次多模态调用直出
  `{calorieRange, dishes, items, facets}`（结构化输出 + timeout + 错误上抛）；`worker.service.ts` 写回前复检
  `sourceRevision`、失败落 `analysis_failed`、超时回收；`meal-analysis.types.ts` 换 v2 结构（含 zod 校验与服务端
  规范化：rank 排序裁剪、区间纠正）；删除 `meal-dish/*`、`meal-ingredient/*`、`meal-analysis/matcher.service.ts`、
  模板学习与 `meal-payload-writer.service.ts` 的成分分支；`records.service.ts` 删掉 `confirmed` 分支（服务端不再接受
  客户端决定状态）；同步重写相关 `*.spec.ts`。
  **状态词表的 Prisma enum 迁移也属于这一刀**：产出侧从此只写 `analyzed`，词表不换则类型与数据库都对不上
  （旧的 `unconfirmed`/`confirmed` 就地映射为 `analyzed`）。
- **P0-2｜契约与投影侧（Lucent）**：Prisma 迁移新增 `mealHeadline` / `mealCalorieMin` / `mealCalorieMax` /
  `mealCalorieBucket`（删除 coverage 相关列与字段），`withMealHotFields` 投影新字段；DTO describe 补 meal payload
  契约；`pnpm export:openapi`。

1. efactor(daily-records)!: 餐食分析改由多模态一次产出区间与排序结论（P0-1：产出侧切换 + 删除成分表与确认链路，BREAKING）
2. efactor(daily-records): 餐食分析投影热列与 payload 契约（P0-2：Prisma 迁移 + 投影 + DTO/OpenAPI）
3. `feat(record): 列表与详情按需消费餐食结论`（Luminous：生成物 + 条目 headline/粗化区间 + 详情 items/菜名编辑/重试 + 失败文案 l10n）
4. `feat(assistant): 餐食分析 digest 工具,避免重复识图`（Lucent）
5. `refactor(today-suggestion): 饮食信号改读餐食 facets,删除文本启发式`（Lucent）
6. `refactor(record): 餐食确认与快速录入收口`（Luminous：必填校验、确认合一、清死配置与未用 l10n）
7. `docs(reference,logs): 登记餐食分析契约与约定`

## 七、风险与取舍

- **模型输出漂移**：靠 JSON Schema + 服务端规范化（排序/裁剪/缺字段降级）+ 「结构化是真相、文案是投影」把影响限制在文案层。
- **文案语言**：首版按分析时语言生成、不回溯重渲染；切语言只影响历史文案（结构化 facets 与区间不受影响）。
- **成本/延迟**：每餐一次多模态调用，替代「识别 + 分解 + 接地」多次调用与数据库匹配，总成本与尾延迟都更低。
- **伪精确**：一律区间 + 档位；UI 不显示单值热量。
- **数据迁移**：未上线，不迁移、不兼容；`version: 2` 只用于未来区分。
- **不再有成分级明细**：`nutritionEstimate`（宏量营养素克数）随之删除——若将来需要，按「模型直出 + 明确标注为估算」重做，而不是回到成分表。

## 八、已定（2026-09-15 复核，全部拍板）

1. **热量区间独立成字段**（不进 `items`），形态 `{min, max, unit, bucket}`，UI 不给单值。
2. **列表条目**：`mealHeadline` + **粗化区间**（四舍五入到百位，形如「约 500–800 kcal」）；`bucket` 只作配色语义。
3. **菜名列表可编辑**：`dishes[{name, source}]`（`source` = model/user），只存名字、不存营养成分；
   改菜名**不重算** `items`/`calorieRange`（后续可选：用修正后的菜名做纯文本重算）。
4. **文案语言**：按分析当时的用户语言生成并存 `locale`，不回溯重生成、不提供重生成入口。
5. **删掉人工确认**：状态收敛 `analyzing | analyzed | analysis_failed`，`confirmed`/`unconfirmed` 与
   `mealAnalysisCoverage` 删除，确认 UI 与模板学习删除，下游统一按新口径统计。
6. **失败可救**：`analysis_failed` 详情页提供「重新分析」（重新入队 + revision 递增）；`analyzing` 有超时回收。
7. **assistant 窗口**：`days`/`limit` 由模型决定，服务端封顶最近 15 天。
8. **删掉对照成分表那条链**：decomposition / grounding / matcher / template-learning 整体删除，不做兼容与迁移。
9. **消费方不变式**：列表接口必须能拿到 headline 与区间（投影字段），payload 不再只在详情接口返回。