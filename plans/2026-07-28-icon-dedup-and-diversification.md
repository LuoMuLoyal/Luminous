# 图标去重与多样化计划

## 原则

**能不重复就不重复。** 当两个场景的语义不同时，使用不同图标。只有语义完全相同（如"确认"永远是 `check`，"关闭"永远是 `x`）才允许重复。Tab 图标和内容层图标必须区分。

## 当前问题

全 app 使用了 152 种 FLucideIcons，但前 10 个图标占了近 200 次引用。同一图标被用于语义完全不同的场景，导致用户认知混淆。

### 高频图标使用次数

| 图标 | 次数 | 不同语义数 |
|------|------|-----------|
| `chevronRight` | 56 | 1（导航箭头，合理） |
| `circleAlert` | 34 | 7+ |
| `sparkles` | 17 | 5 |
| `pill` | 17 | 5 |
| `x` | 15 | 2（关闭/删除） |
| `notebookPen` | 14 | 3 |
| `droplets` | 14 | 1（饮水，合理） |
| `triangleAlert` | 13 | 3 |
| `userRound` | 12 | 4 |
| `lightbulb` | 12 | 3 |
| `badgeCheck` | 12 | 5 |
| `moon` / `moonStar` | 16 | 1（睡眠，但用了两个图标） |

### 可接受重复的图标

以下图标语义单一、通用，重复使用合理：

- `chevronRight` / `chevronLeft` — 导航方向箭头
- `chevronDown` / `chevronUp` — 展开/收起
- `check` — 确认/已选
- `x` — 关闭/删除
- `plus` — 新增
- `droplets` — 饮水
- `search` — 搜索
- `trash2` — 删除
- `lock` — 锁定
- `bell` — 通知

## 执行方案

### Phase 1 — 新建 `SemanticIcons` 语义图标注册表

文件：`lib/core/design/tokens/icon_tokens.dart`

```dart
/// 语义图标注册表
///
/// 所有业务代码应通过 [SemanticIcons] 引用图标，而非直接使用 [FLucideIcons]。
/// 这确保同一语义不会使用不同图标，不同语义不会使用相同图标。
abstract final class SemanticIcons {
  // ================================================================
  // 导航 — Tab 图标，与内容层图标严格区分
  // ================================================================
  static const tabToday = FLucideIcons.house;
  static const tabRecord = FLucideIcons.notebookPen;
  static const tabMedicine = FLucideIcons.pillBottle;  // ≠ 内容层 pill
  static const tabReport = FLucideIcons.chartColumn;
  static const tabMine = FLucideIcons.userRound;

  // ================================================================
  // AI — 入口 / 生成中 / 结果 / 建议 各用不同图标
  // ================================================================
  static const aiEntry = FLucideIcons.sparkles;         // AI 入口按钮
  static const aiAnalyzing = FLucideIcons.loaderCircle;  // AI 分析中
  static const aiGenerated = FLucideIcons.bot;           // AI 已生成结果
  static const aiSuggestion = FLucideIcons.brain;        // AI 建议/洞察
  static const aiTip = FLucideIcons.lightbulb;           // 通用提示/技巧

  // ================================================================
  // 健康记录类型 — 每种类型独立图标
  // ================================================================
  static const recordMedicine = FLucideIcons.pill;
  static const recordWater = FLucideIcons.droplets;
  static const recordMeal = FLucideIcons.utensils;
  static const recordSleep = FLucideIcons.moonStar;
  static const recordCaffeine = FLucideIcons.coffee;
  static const recordSymptom = FLucideIcons.thermometer;
  static const recordMood = FLucideIcons.smile;
  static const recordNote = FLucideIcons.fileText;        // ≠ notebookPen
  static const recordActivity = FLucideIcons.activity;
  static const recordWeight = FLucideIcons.scale;          // 需验证可用性

  // ================================================================
  // 通用状态
  // ================================================================
  static const statusError = FLucideIcons.circleAlert;
  static const statusWarning = FLucideIcons.triangleAlert;
  static const statusSuccess = FLucideIcons.circleCheck;
  static const statusInfo = FLucideIcons.info;
  static const statusPending = FLucideIcons.clock3;
  static const statusSkipped = FLucideIcons.ban;
  static const statusDone = FLucideIcons.check;
  static const statusAllDone = FLucideIcons.checkCheck;   // "全部完成"
  static const statusBlocked = FLucideIcons.lock;
  static const statusUnavailable = FLucideIcons.circleSlash;
  static const statusUnknown = FLucideIcons.fileQuestion;

  // ================================================================
  // 用药安全 — 风险等级、发现类型各用不同图标
  // ================================================================
  // 风险等级
  static const safetySafe = FLucideIcons.shieldCheck;
  static const safetyCaution = FLucideIcons.shieldAlert;
  static const safetyRisk = FLucideIcons.triangleAlert;   // ≠ circleAlert
  static const safetyDanger = FLucideIcons.siren;          // 红旗/严重

  // 发现类型
  static const safetyInteraction = FLucideIcons.arrowLeftRight;
  static const safetyAllergy = FLucideIcons.zap;
  static const safetyCoverage = FLucideIcons.searchX;
  static const safetyLongTerm = FLucideIcons.hourglass;
  static const safetySpecialGroup = FLucideIcons.baby;     // 孕妇/儿童/老人
  static const safetySchedulingConflict = FLucideIcons.calendarX2;

  // ================================================================
  // 报告 — 状态/趋势/指标各用不同图标
  // ================================================================
  static const reportReady = FLucideIcons.circleCheck;     // ≠ badgeCheck
  static const reportInsufficient = FLucideIcons.fileQuestion;
  static const reportTrend = FLucideIcons.trendingUp;
  static const reportAdherence = FLucideIcons.badgeCheck;  // 依从率专用
  static const reportInsight = FLucideIcons.lightbulb;
  static const reportDataMedication = FLucideIcons.pill;
  static const reportDataHydration = FLucideIcons.droplets;
  static const reportDataSleep = FLucideIcons.moonStar;
  static const reportDataCaffeine = FLucideIcons.coffee;
  static const reportDataSymptom = FLucideIcons.thermometer;
  static const reportExport = FLucideIcons.arrowDownToLine;
  static const reportHistory = FLucideIcons.history;

  // ================================================================
  // 用药执行 — 计划/提醒/打卡
  // ================================================================
  static const medicineDose = FLucideIcons.pill;
  static const medicineBottle = FLucideIcons.pillBottle;
  static const medicineKit = FLucideIcons.briefcaseMedical;
  static const doseSchedule = FLucideIcons.alarmClockCheck;
  static const doseSlot = FLucideIcons.clock3;
  static const doseTaken = FLucideIcons.check;
  static const doseSkipped = FLucideIcons.ban;
  static const dosePending = FLucideIcons.clock3;
  static const dosePlanned = FLucideIcons.calendarClock;

  // ================================================================
  // 通知
  // ================================================================
  static const notificationBell = FLucideIcons.bell;
  static const notificationDelivered = FLucideIcons.checkCheck;
  static const notificationFailed = FLucideIcons.circleX;   // ≠ circleAlert
  static const notificationPending = FLucideIcons.clock3;

  // ================================================================
  // 操作
  // ================================================================
  static const actionAdd = FLucideIcons.plus;
  static const actionAddCard = FLucideIcons.squarePlus;
  static const actionEdit = FLucideIcons.pencil;
  static const actionEditCard = FLucideIcons.squarePen;     // ≠ notebookPen
  static const actionDelete = FLucideIcons.trash2;
  static const actionSearch = FLucideIcons.search;
  static const actionClose = FLucideIcons.x;
  static const actionMore = FLucideIcons.ellipsis;
  static const actionNext = FLucideIcons.chevronRight;
  static const actionPrev = FLucideIcons.chevronLeft;
  static const actionExpand = FLucideIcons.chevronDown;
  static const actionCollapse = FLucideIcons.chevronUp;
  static const actionRefresh = FLucideIcons.refreshCw;
  static const actionReset = FLucideIcons.rotateCcw;
  static const actionShare = FLucideIcons.share2;
  static const actionCopy = FLucideIcons.copy;
  static const actionExport = FLucideIcons.arrowDownToLine;
  static const actionExternalLink = FLucideIcons.externalLink;
  static const actionSettings = FLucideIcons.settings;
  static const actionScan = FLucideIcons.scanLine;
  static const actionCamera = FLucideIcons.camera;
  static const actionMic = FLucideIcons.mic;
  static const actionImage = FLucideIcons.image;

  // ================================================================
  // 健康/档案
  // ================================================================
  static const profileUser = FLucideIcons.userCheck;       // ≠ tabMine userRound
  static const profileAllergy = FLucideIcons.zap;
  static const profileCondition = FLucideIcons.heartPulse;
  static const profileMedicine = FLucideIcons.briefcaseMedical;
  static const profileEmergency = FLucideIcons.siren;
  static const profileContact = FLucideIcons.phone;         // 需验证可用性
}
```

### Phase 2 — 按高频图标逐个拆分

#### Step 1：`sparkles` (17→1) — AI 语义拆分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| Today 助手入口按钮 | `SemanticIcons.aiEntry` (sparkles) — 保留 | `today/top_bar.dart` |
| NLP 输入栏入口 | `SemanticIcons.aiEntry` (sparkles) — 保留 | `record/quick_entry_panel.dart` |
| 报告 AI 总结按钮 | `SemanticIcons.aiEntry` (sparkles) — 保留 | `report/dashboard_view.dart` |
| AI 分析中 / loading | `SemanticIcons.aiAnalyzing` (loaderCircle) | `today/observation.dart`, `report/ai_summary.dart` |
| AI 已生成结果标记 | `SemanticIcons.aiGenerated` (bot) | `today/suggestion_state_views.dart`, `today/observation.dart`, `report/ai_summary.dart` |
| AI 建议/洞察 bullet | `SemanticIcons.aiSuggestion` (brain) | `today/view_models.dart`, `report/ai_summary.dart` |
| 通用 fallback | `SemanticIcons.aiEntry` (sparkles) | `suggestion_icon_mapping.dart` |
| Today 助手发送按钮空态 | `SemanticIcons.aiTip` (lightbulb) | `today/suggestion_state_views.dart` |

**结果**：sparkles 只保留 3 次（入口按钮），其余 14 次分散到 4 个不同图标。

#### Step 2：`circleAlert` (34→3) — 错误/告警语义拆分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| 通用错误状态页 | `SemanticIcons.statusError` (circleAlert) — 保留 | `core/widgets/state_views.dart` |
| 通知投递失败 | `SemanticIcons.notificationFailed` (circleX) | `notification/list_item.dart` |
| 风险检查 medium 级别 | `SemanticIcons.safetyCaution` (shieldAlert) | `medicine/copy.dart` |
| 风险检查 interaction 类型 | `SemanticIcons.safetyInteraction` (arrowLeftRight) | `medicine/copy.dart` |
| 报告数据不足 | `SemanticIcons.reportInsufficient` (fileQuestion) | `report/dashboard_view.dart` |
| 安全告警行 | `SemanticIcons.safetyCaution` (shieldAlert) | `medicine/mobile_safety.dart` |
| Record 解析失败 | `SemanticIcons.statusUnknown` (fileQuestion) | `record/nlp_retry_panel.dart` |
| 设置/帮助错误提示 | `SemanticIcons.statusError` (circleAlert) — 保留 | `settings/*.dart` |
| 搜索/扫码错误 | `SemanticIcons.statusError` (circleAlert) — 保留 | `search/*.dart`, `scan/*.dart` |
| 提醒投递失败 | `SemanticIcons.notificationFailed` (circleX) | `medicine/log_panels.dart` |

**结果**：circleAlert 从 34 次降到约 8 次，其余分散到 5 个不同图标。

#### Step 3：`badgeCheck` (12→1) — 成功/完成语义拆分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| 依从率指标 | `SemanticIcons.reportAdherence` (badgeCheck) — 保留 | `medicine/mobile_drugbox.dart` |
| 风险检查 safe 状态 | `SemanticIcons.safetySafe` (shieldCheck) | `medicine/copy.dart` |
| 报告 ready 状态 | `SemanticIcons.reportReady` (circleCheck) | `report/dashboard_view.dart` |
| 报告 medication insight | `SemanticIcons.reportDataMedication` (pill) | `report/dashboard_view.dart` |
| 通知已投递 | `SemanticIcons.notificationDelivered` (checkCheck) | `notification/list_item.dart` |
| 记录已完成 | `SemanticIcons.statusAllDone` (checkCheck) | `record/mobile_timeline.dart` |
| Today 主动建议已执行 | `SemanticIcons.statusDone` (check) | `today/view_models.dart` |

**结果**：badgeCheck 只保留 1 次（依从率专用）。

#### Step 4：`pill` (17→3) — 药品图标按场景区分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| Tab 用药 | `SemanticIcons.tabMedicine` (pillBottle) | `shell/tab.dart` |
| 用药列表行 / 今日计划行 | `SemanticIcons.medicineDose` (pill) — 保留 | `medicine/mobile_drugbox.dart`, `medicine/mobile_records.dart` |
| AI 分析 medication bullet | `SemanticIcons.medicineDose` (pill) — 保留 | `today/view_models.dart`, `report/ai_summary.dart` |
| 记录类型 medication | `SemanticIcons.recordMedicine` (pill) — 保留 | `record/mobile_timeline.dart` |
| 健康档案药品项 | `SemanticIcons.profileMedicine` (briefcaseMedical) | `mine/archive.dart` |
| 用药安全摘要 | `SemanticIcons.medicineKit` (briefcaseMedical) | `medicine/mobile_safety.dart` |

**结果**：pill 从 17 次降到约 8 次，tab 改用 pillBottle，档案改用 briefcaseMedical。

#### Step 5：`notebookPen` (14→2) — 记录/编辑区分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| Tab 记录 | `SemanticIcons.tabRecord` (notebookPen) — 保留 | `shell/tab.dart` |
| 记录类型 "note" | `SemanticIcons.recordNote` (fileText) | `record/mobile_timeline.dart`, `mine/archive.dart` |
| 新建记录入口 | `SemanticIcons.actionAddCard` (squarePlus) | `record/quick_entry_panel.dart`, `record/new_entry_panel.dart` |
| 设置编辑项 | `SemanticIcons.actionEditCard` (squarePen) | `settings/page.dart` |

**结果**：notebookPen 只保留 1 次（Tab），其余分散到 3 个不同图标。

#### Step 6：`userRound` (12→1) — 用户图标按场景区分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| Tab 我的 | `SemanticIcons.tabMine` (userRound) — 保留 | `shell/tab.dart` |
| 健康档案用户 | `SemanticIcons.profileUser` (userCheck) | `mine/account_hero.dart` |
| AI bullet user 类型 | `SemanticIcons.profileUser` (userCheck) | `today/view_models.dart`, `report/ai_summary.dart` |
| 设置项 | 按具体语义使用不同图标 | `settings/page.dart` |
| Suggestion icon mapping | `SemanticIcons.profileUser` (userCheck) | `suggestion_icon_mapping.dart` |

**结果**：userRound 只保留 1 次（Tab），其余改用 userCheck 或具体图标。

#### Step 7：`lightbulb` (12→2) — 建议类图标拆分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| 行为建议 bullet | `SemanticIcons.aiTip` (lightbulb) — 保留 | `today/view_models.dart` |
| 报告 insight | `SemanticIcons.reportInsight` (lightbulb) — 保留 | `report/dashboard_view.dart` |
| AI 建议 fallback | `SemanticIcons.aiSuggestion` (brain) | `today/observation.dart`, `suggestion_icon_mapping.dart` |
| Today 摘要提示 | `SemanticIcons.aiTip` (lightbulb) — 保留 | `today/summary.dart` |

**结果**：lightbulb 从 12 次降到约 6 次，AI 洞察改用 brain。

#### Step 8：`shieldCheck` (9→1) — 安全图标拆分

| 当前场景 | 替换为 | 文件 |
|---------|--------|------|
| 风险检查 safe 状态 | `SemanticIcons.safetySafe` (shieldCheck) — 保留 | `medicine/copy.dart` |
| 风险检查 specialGroup | `SemanticIcons.safetySpecialGroup` (baby) | `medicine/copy.dart` |
| 设置隐私项 | `SemanticIcons.statusBlocked` (lock) | `settings/page.dart` |
| 安全检查通过摘要 | `SemanticIcons.safetySafe` (shieldCheck) — 保留 | `medicine/mobile_safety.dart` |

**结果**：shieldCheck 从 9 次降到约 4 次。

#### Step 9：近义图标统一

| 语义 | 当前 | 统一为 | 操作 |
|------|------|--------|------|
| 睡眠 | `moon` + `moonStar` | `SemanticIcons.recordSleep` (moonStar) | 全局替换 `moon` → `moonStar`（`AppThemeModePreference.dark` 保留 `moon`） |
| 时钟/计划 | `clock` + `clock3` + `clock4` | `SemanticIcons.doseSlot` (clock3) | `clock` → `clock3`；`clock4` 为 Forui 内置，保留 |
| 饮食 | `utensils` + `cupSoda` | `SemanticIcons.recordMeal` (utensils) | `cupSoda` → `utensils` |
| 编辑 | `pencil` + `notebookPen` + `squarePen` | 按场景：`actionEdit`(pencil) / `actionEditCard`(squarePen) / `recordNote`(fileText) | 按语义归位 |
| 列表 | `clipboardList` + `list` + `layoutList` | `clipboardList` 用于任务列表，`layoutList` 用于记录时间线 | 按语义归位 |

### Phase 3 — 清理与验证

1. **搜索残留**：`rg "FLucideIcons\." lib/ --type dart | rg -v "icon_tokens.dart"` — 确认无直接引用
2. **flutter analyze**：确保无类型错误
3. **flutter test**：全量测试通过
4. **视觉走查**：在真机上逐页检查图标语义是否清晰、是否有视觉冲突

## 执行顺序

1. 新建 `lib/core/design/tokens/icon_tokens.dart`
2. Step 1：AI 拆分（sparkles）
3. Step 2：错误拆分（circleAlert）
4. Step 3：成功拆分（badgeCheck）
5. Step 4：药品拆分（pill）
6. Step 5：记录拆分（notebookPen）
7. Step 6：用户拆分（userRound）
8. Step 7：建议拆分（lightbulb）
9. Step 8：安全拆分（shieldCheck）
10. Step 9：近义统一
11. Phase 3：清理验证

每步完成后运行 `flutter analyze` + 相关测试。

## 预期效果

| 指标 | 当前 | 目标 |
|------|------|------|
| 唯一图标数 | 152 | ~180+ |
| 最高频图标（除导航/操作类） | circleAlert 34 | ≤ 8 |
| 语义混淆图标数 | 10+ | 0 |
| Tab 图标与内容图标重复 | 3 个 | 0 |

## 风险

- 部分图标可能在 Forui 0.24 中不存在（如 `baby`, `scale`, `phone`），需验证后选择替代。
- Forui 内置组件的图标（如 `FHeader` 的 back/close）通过 `FIcons` 主题管理，不在本次范围内。
- `suggestion_icon_mapping.dart` 的后端驱动图标映射保持不变，只是 fallback 和映射值更新。
- 替换后需视觉走查，确保新图标在 18px / 20px / 24px 尺寸下可读。
