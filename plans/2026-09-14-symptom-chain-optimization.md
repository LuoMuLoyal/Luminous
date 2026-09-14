# 症状链路优化（数据契约 + 一次点击带严重度 + 目录扩展）

症状快速记录现在有两个会**直接坏**的缺陷（严重度对后端不可见、切换语言后弹窗变空），外加一处交互硬伤
（一次点击带不了严重度）。本计划先修数据契约与交互，再做目录扩展与设置面收口。

生命周期：执行完毕后删除本文件；诊断结论与外部依据沉淀到当日迁移日志，长期约束进
`lib/features/record/README.md`。

## 一、背景（已确诊）

### 缺陷 ①：严重度对后端不可见，`deteriorating_symptom` 实际是死规则

- 客户端：`domain/constants/fast_entry_choices.dart` 把严重度写进 **`value`**，且是本地化字符串
  （`value: l10n.recordFastChoiceSeverityMild` → "轻度"）；四个预置症状的 `payload` 为 `null`。
- 服务端：`Lucent/src/modules/today-suggestion/services/rules/lifestyle/deteriorating-trend.service.ts`
  的 `extractSeverity()` 只对 `value` 跑 `parseSeverity()`（认 `3/5`、`7/10`、裸数字），再对 **`note`** 做关键词
  匹配（加重 / 严重 / 中等 / 轻微），都没有则 `return 1`（默认最小严重度）。
- 结果：快速录入的每条症状记录一律得 1 分 → `checkDeterioration()` 要求严格递增 → 永远 false；
  `collectors/record.service.ts` 的 `observedValue = parseNumericValue(value)` 同样为 null →
  信号 `coverage.sufficient: false`。**症状维度的覆盖度与恶化趋势，从主路径进来的数据永远判不出来。**

### 缺陷 ②：切换语言后症状弹窗会变成空的

`symptomEnabledChoices` 存的是**本地化标题**：设置里取消勾选写入 `choice.title`（"头痛"），
`fast_entry_dialog.dart` 的 `_resolveChoices()` 又用 `enabled.contains(c.title)` 过滤。用户切到 English 后目录产出
"Headache"，与存档的 "头痛" 不匹配 → 过滤结果为空 → 弹窗一个症状 chip 都没有（该处没有空集兜底）。

前提是用户动过「显示哪些症状」这个列表（列表为空表示"全部启用"，不会触发）；也就是说一旦动过，换语言即失效。

同一根因还会让服务端 `byTitle` 分组把同一症状拆成两组（换语言前后的记录标题不同）。

### 缺陷 ③：一次点击带不了严重度

严重度是**全局默认值**而非本次选择：`_resolveChoices()` 把 `prefs.symptomDefaultSeverity` 盖到每个 chip 的
`value` 上。想记「重度头痛」必须先点一下（落库为默认的轻度），再进详情页改。

### 附带问题

- 多选批量保存 `registerUndo: (_) {}` → **批量没有撤销**（单点有）。
- 多选态下「取消」是退出多选，「更多」被隐藏（语义过载）。
- 长按设置弹窗与设置页把「默认严重度 + 启用哪些症状」各写一份，且用 Material `FilterChip`（Forui 项目里的
  迁移债）。
- 只有 4 个硬编码症状（头痛 / 胃痛 / 头晕 / 发热），其它症状只能走「更多」到创建页手填标题。

## 二、目标与非目标

**目标**

1. 症状与严重度以**稳定码**落库，服务端能读、跨语言不串味。
2. 一次点击即可记录「症状 + 严重度」；批量保存可撤销。
3. 目录可扩展，覆盖常见症状并允许「其它」自由输入。
4. 同类型的设置只存在一处，控件回到 Forui。

**非目标**

- 不动 NLP / AI 候选录入路径（`recordNlp*`）：它复用同一套 `RecordFastChoice`，本计划只保证码位一致。
- 不新增后端症状目录服务（目录先做客户端常量，见 Phase 3 的取舍）。
- 不改情绪与备注的形态（是否也迁到 sheet 见「待拍板」）。

## 三、方案

### Phase 1（P0）数据契约：症状与严重度落成稳定码

**payload**

```jsonc
{
  "symptom": "headache",        // 目录码；自定义/未知一律 "other"
  "severity": "moderate",       // mild | moderate | severe | unknown
  "customLabel": "偏头痛"        // 仅 symptom = "other" 时写，供展示兜底
}
```

- `severity` 复用 `health_context` 已有的 `mild/moderate/severe/unknown` 词汇（`HealthAllergySeverity`），不新造枚举；
  服务端映射 mild=1 / moderate=2 / severe=3，**`unknown` 不参与趋势判定**（`extractSeverity()` 返回 null，
  该条跳过，绝不回落到默认最小严重度 1）；`observedValue` 侧同样视为「用户明确说判不了」。
- 记录级 `title` / `value` **保留但降级为展示文案**（时间线、详情直接用，避免为渲染再改一圈）；
  `payload` 是唯一数据真相，任何规则/统计**不得**再解析 `title` / `value`。

**Luminous**

- `RecordFastChoice` 增加 `payload`（症状项填 `{symptom, severity}`）；`buildSymptom*` 统一出口，
  避免像现在这样在 `_resolveChoices()` 里临时给每个 chip 盖 `value`。
- `QuickEntryPreferences.symptomEnabledChoices` 改存**目录码**（`'headache'`）；
  旧值（本地化标题）不迁移——未上线，直接切（读到的未知码一律视为未启用）。
- 目录抽到 `domain/constants/`（Phase 3 扩充），`RecordFastChoice.title` 由码本地化得到。

**Lucent**

- `deteriorating-trend.service.ts`：`extractSeverity()` 改为优先读 `payload.severity`（码 → 数值映射），
  删除 `parseSeverity()` 的数字/关键词启发式（含对 `note` 的 `includes` 分支）。
- `collectors/record.service.ts`：`observedValue` 同样取 `payload.severity` 映射值。
- `daily-records` 校验器补症状 payload 校验（`symptom` 为字符串、`severity ∈ {mild,moderate,severe}`，
  两者可选但成对出现时可校验），DTO 描述串同步；`pnpm export:openapi`。
- 契约变更属破坏性：提交带 `BREAKING CHANGE` footer。

### Phase 2（P1）交互：一次点击带严重度 + 形态统一

- **形态**：症状快速记录由居中 `FDialog` 改为底部 sheet（`SheetSurface` + `SheetDragHandle` +
  `DraggableScrollableSheet`），与饮水/睡眠同一套外壳。理由：内容从「4 个 chip」变成
  「严重度行 + 9 个目录 chip + 多选态」，`FDialog` 放不下。
- **严重度行**：sheet 顶部一行严重度选择（轻度 / 中度 / 重度 / 无法判断），默认取 `symptomDefaultSeverity`，
  **作用于随后点选的那次记录**（以及批量那次）。「无法判断」用于「确实不舒服但说不清程度」，落
  `severity: 'unknown'`，不参与趋势判定（见 Phase 1）。
- **多选**：进入多选后底部按钮带数量（「记录 2 条」），批量成功后给**可撤销** toast
  （复用 `QuickEntryUndoService` 的批量语义）；「取消」在多选态只退出多选并可返回单选态。
- 图片附件、自由备注仍走「更多」→ 创建页。

### Phase 3（P2）目录扩展（源在后端）

- **Lucent 提供目录**：新增静态参考数据端点 `GET /daily-records/symptom-catalog`，返回
  `{ items: [{ code, label }] }`——后端定「有哪些症状、什么顺序」，`label` 按 `Accept-Language` 本地化。
  无用户维度，不是用户资源。
- **Luminous 消费目录**：目录 provider 拉取成功后渲染九宫格（头痛 / 胃痛 / 头晕 / 发热 / 恶心 / 咳嗽 / 乏力 /
  失眠 / 其它）；渲染文案优先用后端 `label`（后端新增症状不必等客户端发版），已知码回落到本地 ARB 文案，
  都拿不到时显示码本身。
- **离线/失败兜底**：客户端保留一份与后端同码的兜底副本（`domain/constants/symptom_catalog.dart`），
  拉取失败或未登录时用兜底渲染，保证快速记录不因网络不可用而失效。
- **「其它」就地输入**：选中后不立即落库，在网格**下方就地展开自由输入框**（自动聚焦，不弹第二个 sheet），
  输入非空才能保存（保存按钮置灰），保存为 `symptom: 'other'` + `customLabel: <输入>`，`title` 用输入原文；
  切走或收起 sheet 时输入框与草稿一起丢弃。

### Phase 4（P3）设置面收口 + Forui 化

- 设置页保留「默认严重度（四档）+ 显示哪些症状」两块（严重度用 Forui `FSelect`，症状启用改为 pill chip 行，
  与 review 的范围 chip 同款），删掉 Material `FilterChip`。
- 长按弹窗不再内联设置：只显示该类型的规则说明 + 「打开设置」入口（与睡眠长按的处理一致）。
- 启用列表按**码**勾选（Phase 1 已改），换语言不再失效。

## 四、改之后的文本图像

### 4.1 快速记录 · 症状（单选态）

```text
┌──────────────────────────────────────────────┐
│                    ▁▁▁▁                      │  ← SheetDragHandle（可上拖展开）
│  记录症状                                     │
│  2026-09-14                                  │
│                                              │
│  严重程度                                     │
│  ( 轻度 )  中度  重度  无法判断               │  ← 默认取设置项；作用于本次点选
│                                              │
│  点一个症状即保存                             │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │  头痛  │ │  胃痛  │ │  头晕  │            │
│  └────────┘ └────────┘ └────────┘            │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │  发热  │ │  恶心  │ │  咳嗽  │            │
│  └────────┘ └────────┘ └────────┘            │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │  乏力  │ │  失眠  │ │  其它  │            │
│  └────────┘ └────────┘ └────────┘            │
│                                              │
│  多选      更多      取消                     │
└──────────────────────────────────────────────┘
```

点「头痛」即落库：`title=头痛`、`value=轻度`、`payload={symptom:'headache', severity:'mild'}`，
toast「已保存 · 撤销」。

### 4.2 快速记录 · 症状（多选态）

```text
┌──────────────────────────────────────────────┐
│                    ▁▁▁▁                      │
│  记录症状                                     │
│  严重程度                                     │
│  轻度   ( 中度 )   重度   无法判断            │
│                                              │
│  选择要记录的症状（可多选）                    │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │✓ 头痛  │ │  胃痛  │ │✓ 头晕  │            │  ← 选中 = primary 实心
│  └────────┘ └────────┘ └────────┘            │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │  发热  │ │  恶心  │ │  咳嗽  │            │
│  └────────┘ └────────┘ └────────┘            │
│                                              │
│  返回                        记录 2 条         │  ← 批量成功可撤销
└──────────────────────────────────────────────┘
```

### 4.3 「其它」选中后就地展开输入框

```text
┌──────────────────────────────────────────────┐
│                    ▁▁▁▁                      │
│  记录症状                                     │
│  严重程度                                     │
│  轻度    ( 中度 )   重度   无法判断           │
│                                              │
│  ┌────────┐ ┌────────┐ ┌────────┐            │
│  │  乏力  │ │  失眠  │ │✓ 其它 │            │  ← 选中其它，不立即落库
│  └────────┘ └────────┘ └────────┘            │
│                                              │
│  症状名称                                     │
│  ┌────────────────────────────────────────┐  │  ← 网格下方就地展开、自动聚焦
│  │ 偏头痛                                 │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  返回                              保存       │  ← 输入为空时置灰
└──────────────────────────────────────────────┘
→ title=偏头痛、value=中度、payload={symptom:'other', customLabel:'偏头痛', severity:'moderate'}
```

### 4.4 长按症状瓦片（收口后）

```text
┌────────────────────────────────────┐
│  症状                               │
│  点一个症状即按所选严重度保存；       │
│  多选可一次记录多个症状。            │
│                      [打开设置]     │
└────────────────────────────────────┘
```

### 4.5 设置页 · 症状（收口后）

```text
快速记录设置
  默认严重程度                     中度 ›
  显示的症状
  [头痛] [胃痛] [头晕] [发热] [恶心]
  [咳嗽] [乏力] [失眠] [其它]        ← pill chip，选中态 = primary

默认严重程度可选项：轻度 / 中度 / 重度 / 无法判断
```

### 4.6 落库形态与读取方（改后）

```text
每日记录（写入）
  kind     symptom
  title    头痛            ← 展示文案（写入时语言），渲染用
  value    中度            ← 展示文案（写入时语言），仅渲染，规则不再解析
  payload  { "symptom": "headache", "severity": "moderate" }   ← 数据真相
           （severity 也可能是 "unknown"；symptom = "other" 时另带 customLabel）

Lucent 读取
  deteriorating-trend: extractSeverity() ← payload.severity（moderate → 2；unknown → 跳过该条）
  record collector    : observedValue    ← payload.severity 映射值（unknown → 无观测值）
  byTitle 分组         : 改为按 payload.symptom 分组（换语言不再拆组）

本地偏好
  symptomEnabledChoices  ["headache", "dizziness"]   ← 由本地化标题改为目录码
```

## 五、改动清单

### Luminous

- 新增 `domain/constants/symptom_catalog.dart`（码 + zh/en 文案 + 严重度码）；
- `domain/constants/fast_entry_choices.dart`：症状分支改为按目录生成，带 `payload`；
- `presentation/widgets/dialogs/fast_entry_dialog.dart`：症状分支改为 sheet（新文件
  `presentation/widgets/dialogs/symptom_quick_entry_sheet.dart`），严重度行（四档）+ 目录网格 + 「其它」就地输入框
  + 多选批量 + 撤销；通用 `RecordFastChoice` 路径保留给情绪/备注；
- `data/datasources/quick_entry_preferences.dart`：`symptomEnabledChoices` 存码；
- `presentation/widgets/dialogs/quick_type_settings_dialog.dart` 与
  `presentation/pages/quick_entry_settings.dart`：收口设置面、去 Material `FilterChip`；
- `presentation/widgets/shared/copy.dart`：症状/严重度文案按码解析；
- l10n：新增症状目录文案与「记录 N 条」等；删除被目录取代的零散文案；
- `lib/features/record/README.md`：不变量补「症状严重度真相在 payload，value/title 仅展示」。

### Lucent

- `today-suggestion/services/rules/lifestyle/deteriorating-trend.service.ts`：读 `payload.severity`，
  删启发式解析（含 `note` 关键词分支与 `parseSeverity()`）；
- `today-suggestion/services/collectors/record.service.ts`：`observedValue` 取 payload；
- `daily-records` 校验器 + DTO 描述串：症状 payload 校验；`pnpm export:openapi`；
- **新增症状目录端点**（`GET /daily-records/symptom-catalog`）：静态参考数据 DTO + i18n 文案 + spec，
  `pnpm export:openapi` 后再导出；
- 相关 spec（`deteriorating-trend.service.spec.ts`、`record.service.spec.ts`）与迁移日志。

## 六、测试计划

- Luminous：新增 `test/record/symptom_quick_entry_sheet_test.dart`（严重度行默认值与四档、点选落库的 payload 码、
  「其它」就地输入的空值禁用与保存内容、多选批量 + 撤销、切语言后目录与启用项仍匹配）；
  更新 `test/record/domain/fast_entry_choices_test.dart`（症状项带码）、
  `test/record/quick_entry_preferences_test.dart`（存码）、设置页用例；
- Lucent：`deteriorating-trend.service.spec.ts` 改为「payload.severity 递增 → 命中」与
  「仅 value 文案（无 payload）→ 不命中」，`record.service.spec.ts` 的 symptom 信号断言改读 payload；
- 收尾：`flutter analyze` + 定向套件；`pnpm typecheck` + 定向 vitest。

## 七、提交拆分（每阶段一个原子提交，各自独立可回滚）

1. `refactor(record): 症状与严重度落 payload 稳定码`（Luminous：目录码 + payload + prefs 存码 + 展示文案保持）
2. `refactor(today-suggestion)!: 症状严重度改读 payload 码,删除文本启发式`（Lucent，带 `BREAKING CHANGE`）
3. `feat(record): 症状快速记录改为底部 sheet,支持一次点击带严重度与批量撤销`
4. `feat(daily-records): 新增症状目录端点`（Lucent：静态参考数据 + DTO + spec + openapi 再导出）
5. `feat(record): 症状目录扩至常见症状,客户端消费目录并支持其它就地输入`
6. `refactor(record): 症状设置面收口并移除 Material FilterChip`
7. `docs(reference,logs): 登记症状链路约定与契约变更`

1 与 2 之间客户端已写新码、服务端尚未读——旧行为（启发式解析）在新码上退化为「读不出严重度」，与修复前等价，
因此可独立回滚。

## 八、风险与取舍

- **`title`/`value` 仍是本地化文案**：保留是为了不动时间线/详情的渲染路径；代价是「同一条记录换语言后展示
  文案不变」。若要求切换语言后历史记录也跟着变，需要把渲染改为「从 payload 码本地化」——留待后续波次。
- **目录放客户端**：9 个词不值得立后端资源；代价是新增症状要发版（与 `defaultQuickActions` 同一取舍）。
- **不迁移旧数据**：产品未上线，旧 `symptomEnabledChoices`（本地化标题）与旧记录不迁移。

## 九、已定

1. 症状目录取 9 项（头痛 / 胃痛 / 头晕 / 发热 / 恶心 / 咳嗽 / 乏力 / 失眠 / 其它）。
2. 「其它」选中后在症状网格**下方就地展开**自由输入框，不另开弹窗；输入为空时不可保存。
3. 严重度四档：轻度 / 中度 / 重度 / **无法判断**；`unknown` 不参与趋势判定（跳过而非记最小）。
4. **目录源在后端**（Lucent 新增目录端点），客户端保留同码兜底副本；契约该改就改。
5. 情绪与备注本轮不动（仍走各自的 `FDialog`），只做症状。
