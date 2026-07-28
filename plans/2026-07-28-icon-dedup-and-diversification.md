# 图标去重与多样化计划

## 背景

当前 app 使用了 152 种不同的 FLucideIcons，但少数图标被过度复用于语义完全不同的场景，导致用户产生认知歧义。以下是问题最严重的图标。

## 当前问题清单（按严重度排序）

### P0 — 语义混淆（同一图标表达完全不同含义）

| 图标 | 使用次数 | 问题 |
|------|---------|------|
| `sparkles` | 17 | 同时表示 AI 摘要入口、AI 建议卡、AI 分析 bullet、AI 生成中、NLP 入口、报告 AI 总结、Today 助手按钮。用户看到 sparkles 无法区分是"AI 入口"还是"AI 已生成"还是"建议" |
| `circleAlert` | 34 | 同时表示：通用错误状态、风险检查 medium 级别、风险检查 interaction 类型、报告数据不足、提醒投递失败、安全告警、record 解析失败。34 次中至少 6 种不同语义 |
| `badgeCheck` | 12 | 同时表示：依从率指标、风险检查 safe 状态、报告 ready 状态、报告 medication insight、通知已投递、记录已完成。同一"成功/完成"语义被泛化到不相关场景 |
| `shieldCheck` | 9 | 同时表示：安全检查通过、风险检查 specialGroup 类型、风险检查安全状态、设置隐私项。语义边界模糊 |
| `pill` | 17 | 同时表示 tab 药品图标、药品列表行、AI 分析 medication bullet、记录类型用药、健康档案药品项。tab 图标和内容图标重复使用同一图标，层级感消失 |

### P1 — 近义图标不统一（同一语义用了多个图标）

| 语义 | 使用的图标 | 文件 |
|------|-----------|------|
| 睡眠 | `moon`(11) + `moonStar`(5) | `view_models.dart` 用 `moonStar`；`report` 系列、`record` 系列、`suggestion_icon_mapping` 用 `moon`。应统一为一个 |
| 时间/计划 | `clock`(6) + `clock3`(7) + `clock4`(3) | 三种时钟图标混用。`clock3` 用于提醒时间标签和风险检查 timing；`clock` 用于计划状态和长期用药；`clock4` 用于 Forui 内置 |
| 饮食 | `utensils`(9) + `cupSoda`(1) | Today 的 AI bullet 饮食用 `cupSoda`，记录页用 `utensils` |

### P2 — 功能图标复用于不相关场景

| 图标 | 问题 |
|------|------|
| `userRound` (12) | tab "我的"图标 + 健康档案项 + AI bullet user 类型 + 设置项。tab 图标应与内容图标区分 |
| `notebookPen` (14) | tab "记录"图标 + 记录相关设置项 + 通用编辑。tab 图标复用到内容层 |
| `pill` (17) | tab "用药"图标 + 用药列表行 + AI bullet + 记录类型 + 健康档案。tab 图标复用到内容层 |

## 执行方案

### Phase 1 — 建立图标语义映射表

在 `lib/core/design/tokens/icon_tokens.dart` 新建一个语义图标注册表，将图标按语义分组，禁止业务代码直接引用 `FLucideIcons.xxx`。

```dart
/// 语义图标注册表
///
/// 所有业务代码应通过 [SemanticIcons] 引用图标，而非直接使用 [FLucideIcons]。
/// 这确保同一语义不会使用不同图标，不同语义不会使用相同图标。
abstract final class SemanticIcons {
  // === 导航 ===
  static const tabToday = FLucideIcons.house;
  static const tabRecord = FLucideIcons.notebookPen;
  static const tabMedicine = FLucideIcons.pillBottle; // 区别于内容层药品图标
  static const tabReport = FLucideIcons.chartColumn;
  static const tabMine = FLucideIcons.userRound;

  // === AI / 智能功能 ===
  static const aiEntry = FLucideIcons.sparkles;       // AI 入口（按钮/输入栏）
  static const aiGenerated = FLucideIcons.wand2;       // AI 已生成（结果标记）
  static const aiAnalyzing = FLucideIcons.loaderCircle; // AI 分析中（加载）
  static const aiSuggestion = FLucideIcons.lightbulb;  // 建议内容

  // === 健康 / 记录 ===
  static const recordMedicine = FLucideIcons.pill;
  static const recordWater = FLucideIcons.droplets;
  static const recordMeal = FLucideIcons.utensils;
  static const recordSleep = FLucideIcons.moonStar;    // 统一用 moonStar
  static const recordCaffeine = FLucideIcons.coffee;
  static const recordSymptom = FLucideIcons.thermometer;
  static const recordMood = FLucideIcons.smile;
  static const recordNote = FLucideIcons.stickyNote;

  // === 状态 ===
  static const statusError = FLucideIcons.circleAlert;
  static const statusWarning = FLucideIcons.triangleAlert;
  static const statusSuccess = FLucideIcons.circleCheck;
  static const statusInfo = FLucideIcons.circleHelp;
  static const statusPending = FLucideIcons.clock3;
  static const statusSkipped = FLucideIcons.ban;
  static const statusDone = FLucideIcons.check;

  // === 用药安全 ===
  static const safetySafe = FLucideIcons.shieldCheck;
  static const safetyCaution = FLucideIcons.shieldAlert;
  static const safetyRisk = FLucideIcons.circleAlert;  // 风险
  static const safetyDanger = FLucideIcons.siren;       // 红旗/严重
  static const safetyInteraction = FLucideIcons.arrowLeftRight; // 交互
  static const safetyAllergy = FLucideIcons.zap;        // 过敏
  static const safetyCoverage = FLucideIcons.searchX;   // 覆盖缺口
  static const safetyLongTerm = FLucideIcons.hourglass;  // 长期用药
  static const safetySpecialGroup = FLucideIcons.users;  // 特殊人群

  // === 报告 ===
  static const reportReady = FLucideIcons.circleCheck;
  static const reportInsufficient = FLucideIcons.chartNoAxesColumn; // 数据不足
  static const reportTrend = FLucideIcons.trendingUp;
  static const reportAdherence = FLucideIcons.badgeCheck; // 依从率专用

  // === 操作 ===
  static const actionAdd = FLucideIcons.plus;
  static const actionEdit = FLucideIcons.pencil;
  static const actionDelete = FLucideIcons.trash2;
  static const actionSearch = FLucideIcons.search;
  static const actionClose = FLucideIcons.x;
  static const actionMore = FLucideIcons.ellipsis;
  static const actionNext = FLucideIcons.chevronRight;
  static const actionPrev = FLucideIcons.chevronLeft;
  static const actionExpand = FLucideIcons.chevronDown;
  static const actionCollapse = FLucideIcons.chevronUp;
  static const actionRefresh = FLucideIcons.refreshCw;
  static const actionShare = FLucideIcons.share2;
  static const actionCopy = FLucideIcons.copy;
  static const actionLock = FLucideIcons.lock;
}
```

### Phase 2 — 按优先级替换

#### Step 1：AI 语义拆分（影响最大）

将 `sparkles` 的 17 次使用按语义拆分：

| 当前 | 替换为 | 涉及文件 |
|------|--------|---------|
| AI 入口按钮（Today 助手栏、NLP 输入栏、报告 AI 按钮） | `SemanticIcons.aiEntry` (sparkles) — 保留 | `today/top_bar.dart`, `record/quick_entry_panel.dart`, `report/dashboard_view.dart` |
| AI 已生成结果标记 | `SemanticIcons.aiGenerated` (wand2) | `today/suggestion_state_views.dart`, `today/observation.dart`, `report/ai_summary.dart` |
| AI 分析中 / loading | `SemanticIcons.aiAnalyzing` (loaderCircle) — 已部分使用 | `today/observation.dart` |
| AI 建议内容 bullet | `SemanticIcons.aiSuggestion` (lightbulb) — 已部分使用 | `today/view_models.dart`, `report/ai_summary.dart` |
| 通用 fallback | `SemanticIcons.aiEntry` (sparkles) | `suggestion_icon_mapping.dart` |

#### Step 2：错误 / 告警语义拆分

将 `circleAlert` 的 34 次使用按语义拆分：

| 当前语义 | 替换为 | 涉及文件 |
|---------|--------|---------|
| 通用错误状态 | `SemanticIcons.statusError` (circleAlert) — 保留 | `core/widgets/state_views.dart` 等 |
| 风险检查 medium 级别 | `SemanticIcons.safetyCaution` (shieldAlert) | `medicine/copy.dart`, `medicine/risk_finding_tile.dart` |
| 风险检查 interaction 类型 | `SemanticIcons.safetyInteraction` (arrowLeftRight) | `medicine/copy.dart` |
| 报告数据不足 | `SemanticIcons.reportInsufficient` (chartNoAxesColumn) | `report/dashboard_view.dart` |
| 通知投递失败 | `SemanticIcons.statusError` (circleAlert) — 保留 | `notification/list_item.dart` |
| 安全告警行 | `SemanticIcons.safetyCaution` (shieldAlert) | `medicine/mobile_safety.dart` |

#### Step 3：成功 / 完成语义拆分

将 `badgeCheck` 的 12 次使用按语义拆分：

| 当前语义 | 替换为 |
|---------|--------|
| 依从率指标 | `SemanticIcons.reportAdherence` (badgeCheck) — 保留 |
| 风险检查 safe 状态 | `SemanticIcons.safetySafe` (shieldCheck) |
| 报告 ready 状态 | `SemanticIcons.reportReady` (circleCheck) |
| 报告 medication insight | `SemanticIcons.recordMedicine` (pill) |
| 通知已投递 | `SemanticIcons.statusDone` (check) |
| 记录已完成 | `SemanticIcons.statusDone` (check) |

#### Step 4：Tab 图标与内容图标区分

| Tab | 当前 | 替换方案 |
|-----|------|---------|
| Medicine tab | `pill` | `pillBottle`（药瓶，区别于内容层的 `pill` 药片） |
| Record tab | `notebookPen` | 保留（但内容层编辑改用 `squarePen`） |
| Today tab | `house` | 保留 |
| Mine tab | `userRound` | 保留（但内容层用户相关改用 `userCog` / `contact`） |

#### Step 5：近义图标统一

| 语义 | 统一为 | 操作 |
|------|--------|------|
| 睡眠 | `moonStar` | 全局替换 `moon` → `moonStar`（except `AppThemeModePreference.dark` 保留 `moon`） |
| 时钟/计划 | `clock3` | 风险检查和提醒相关统一为 `clock3`；Forui 内置 `clock4` 保留 |
| 饮食 | `utensils` | Today AI bullet 的 `cupSoda` 改为 `utensils` |

### Phase 3 — 清理与验证

1. **搜索残留**：`rg "FLucideIcons\." lib/ --type dart | rg -v "icon_tokens.dart"` — 确认无直接引用
2. **flutter analyze**：确保无类型错误
3. **flutter test**：全量测试通过
4. **视觉走查**：在真机上逐页检查图标语义是否清晰

## 执行顺序

1. 新建 `lib/core/design/tokens/icon_tokens.dart`
2. Phase 2 Step 1（AI 拆分）
3. Phase 2 Step 2（错误拆分）
4. Phase 2 Step 3（成功拆分）
5. Phase 2 Step 4（Tab 区分）
6. Phase 2 Step 5（近义统一）
7. Phase 3（清理验证）

每步完成后运行 `flutter analyze` + `flutter test`。

## 风险

- Forui 内置组件的图标（如 `FHeader` 的 back/close）不需要改，它们通过 `FIcons` 主题管理，不在本次范围内。
- `suggestion_icon_mapping.dart` 的后端驱动图标映射保持不变，只是 fallback 和映射值可能更新。
- 部分图标可能在 Forui 0.24 中不存在（如 `wand2`, `arrowLeftRight`, `chartNoAxesColumn`），需验证后选择替代。
