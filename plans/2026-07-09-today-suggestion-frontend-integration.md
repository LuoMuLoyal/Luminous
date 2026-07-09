# Today 建议引擎前端接入计划

> **目标**：把 Today 页主/次建议卡、观察项区从前端硬编码切换到后端 `GET /api/v1/user/today/suggestions` 真实数据，同时接入反馈、AI 解释、历史回顾三个辅助端点。
>
> **后端合同**：见 `Lucent/docs/00-current/Today_Suggestion_Engine.md` 和 `Lucent/src/modules/today-suggestion/` 实际代码。
> **后端规划**：见 `plans/2026-07-09-today-suggestion-engine-backend.md`（已全部实现，Phase 1–6 完成）。
>
> **前置阅读**：`Luminous/AGENTS.md`、`Luminous/docs/00-current/Active_UI_Today.md`、`Luminous/docs/00-current/Mock_Or_Deferred.md`。

---

## 0. 现状诊断

### 0.1 后端已就绪

4 个 API 端点全部实现（`Lucent/src/modules/today-suggestion/today-suggestion.controller.ts`）：

| 端点 | 方法 | 用途 |
|---|---|---|
| `/api/v1/user/today/suggestions` | GET | 获取今日建议卡（primary + secondary[] + observations[]） |
| `/api/v1/user/today/suggestions/:id/feedback` | POST | 提交建议卡反馈 |
| `/api/v1/user/today/suggestions/:id/explain` | POST | 获取 AI 增强解释 |
| `/api/v1/user/today/suggestions/history` | GET | 获取建议历史（供 Report 页） |

后端 `SuggestionItemDto` 完整字段：`id`、`type`（5 类）、`cardTone`（5 种）、`icon`、`title`、`reason`、`evidence[]`（结构化）、`boundary`、`primaryAction`、`secondaryActions?`、`confidence`、`ruleId`、`ruleVersion`、`triggerType`、`lifecycleState`、`notificationEligible?`、`feedbackOptions?`、`subtype?`。

### 0.2 前端当前痛点

| 问题 | 现状 | 影响 |
|---|---|---|
| 生成客户端缺少 `TodaySuggestionApi` | `LucentClient` 只有 `todayAnalysisApi`，无 `todaySuggestionApi` | 无法调用后端建议接口 |
| `TodayPriorityItemType` 枚举只有 2 类 | `{ medication, water }` | 后端返回 5 类卡片无法映射 |
| `LucentTodayRepository` 硬编码 `priorityItems` | 本地从 health-context + dose-logs + reminders 拼装用药/饮水两条 | 不走后端裁决引擎 |
| `buildSuggestionItems()` 用 l10n 硬编码文案 | 标题/原因/证据/边界全部来自 ARB | 后端 `title`/`reason`/`evidence`/`boundary` 被忽略 |
| `TodaySuggestionItem` view model 字段不足 | 缺 `id`、结构化 `evidence`、`primaryAction`/`secondaryActions`、`feedbackOptions`、`lifecycleState`、`confidence` | 无法承载后端完整卡片信息 |
| `_SuggestionFeedbackRow` 按钮全部空回调 | `onPress: () {}` | 用户反馈无法提交到后端 |
| `_openSuggestion()` 硬编码路由 | `switch (item.type)` → `context.go(AppRoutes.medicine)` / `context.push('?kind=water')` | 后端 `primaryAction.route` 深度链接被忽略 |
| 观察项区调旧 `/today-analysis/recommendations` | `todayRecommendationsProvider` → `TodayAnalysisApi` | 后端建议引擎 `observations` 未被使用 |
| `TodayCardTone` 缺 `warning` | 只有 `{ emphasis, urgent, soft, neutral }` | 后端返回 `warning` tone 无法映射 |
| 证据区是单字符串 | `final String evidence` | 后端返回 `EvidenceItemDto[]` 结构化列表 |

### 0.3 涉及文件清单

```
受影响文件（按改动量排序）：
├── generated/lucent_api/                          # 重新生成
├── lib/core/network/
│   ├── dio_client.dart                            # 新增 getter
│   └── network_providers.dart                     # 新增 provider
├── lib/features/today/
│   ├── domain/entities/
│   │   ├── suggestion.dart                        # 新建
│   │   └── dashboard.dart                         # TodayPriorityItemType 标记 deprecated
│   ├── data/
│   │   ├── datasources/
│   │   │   └── suggestion_remote_data_source.dart # 新建
│   │   └── repositories/
│   │       └── lucent_repository.dart             # 移除 priorityItems 硬编码
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── suggestion_provider.dart           # 新建
│   │   └── widgets/
│   │       ├── shared/
│   │       │   ├── view_models.dart               # 重构 TodaySuggestionItem
│   │       │   └── card_style.dart                # 新增 warning tone
│   │       └── sections/
│   │           ├── suggestion_section.dart        # 重构主卡/次卡
│   │           └── observation_section.dart       # 切换数据源
├── lib/l10n/
│   ├── app_zh.arb                                 # 新增 keys
│   └── app_en.arb
└── test/today/                                    # 更新测试
```

---

## 1. 阶段划分

### Phase 1：生成客户端 + 网络层接入

**目标**：让 Flutter 端能通过类型安全的 Retrofit 客户端调用后端建议 API。

#### 1.1 导出 OpenAPI + 重新生成客户端

```powershell
cd Lucent
pnpm export:openapi

cd ../Luminous/generated/lucent_api
dart run build_runner build
cd ../..
```

**预期生成物**：
- `generated/lucent_api/lib/api/clients/today_suggestion_api.dart` — Retrofit 客户端
- `generated/lucent_api/lib/api/models/suggestion_item_dto.dart`
- `generated/lucent_api/lib/api/models/evidence_item_dto.dart`
- `generated/lucent_api/lib/api/models/suggestion_action_dto.dart`
- `generated/lucent_api/lib/api/models/today_suggestions_response_dto.dart`
- `generated/lucent_api/lib/api/models/suggestion_feedback_dto.dart`
- `generated/lucent_api/lib/api/models/suggestion_feedback_response_dto.dart`
- `generated/lucent_api/lib/api/models/suggestion_explanation_response_dto.dart`
- `generated/lucent_api/lib/api/models/suggestion_history_item_dto.dart`
- `generated/lucent_api/lib/api/models/suggestion_history_response_dto.dart`
- `LucentClient` 新增 `todaySuggestion` getter

#### 1.2 注册 `TodaySuggestionApi` 到网络层

**`lib/core/network/dio_client.dart`** — 在 `LucentDioClient` 中新增：

```dart
TodaySuggestionApi get todaySuggestionApi => _client.todaySuggestion;
```

**`lib/core/network/network_providers.dart`** — 新增：

```dart
final lucentTodaySuggestionApiProvider = Provider<TodaySuggestionApi>((ref) {
  return ref.watch(lucentDioClientProvider).todaySuggestionApi;
});
```

**验收标准**：
- `flutter analyze` 通过
- `LucentClient` 包含 `todaySuggestion` getter
- `lucentTodaySuggestionApiProvider` 可在测试中 override

---

### Phase 2：Domain 层 + Data 层

**目标**：建立前端域实体和远程数据源，将后端 DTO 映射为前端域模型。

#### 2.1 创建 suggestion domain entities

**新文件 `lib/features/today/domain/entities/suggestion.dart`**

使用 freezed 定义以下实体和枚举：

```dart
// === 枚举 ===

enum TodaySuggestionType {
  compliance,
  behaviorAdvice,
  trend,
  coverage,
  confirmedRisk;

  static TodaySuggestionType fromString(String value) { ... }
}

enum TodaySuggestionCardTone {
  urgent,
  warning,
  emphasis,
  soft,
  neutral;

  static TodaySuggestionCardTone fromString(String value) { ... }

  /// 映射到现有 TodayCardTone（用于 card_style.dart）
  TodayCardTone toCardTone() => switch (this) {
    TodaySuggestionCardTone.urgent => TodayCardTone.urgent,
    TodaySuggestionCardTone.warning => TodayCardTone.warning,
    TodaySuggestionCardTone.emphasis => TodayCardTone.emphasis,
    TodaySuggestionCardTone.soft => TodayCardTone.soft,
    TodaySuggestionCardTone.neutral => TodayCardTone.neutral,
  };
}

enum TodaySuggestionConfidence { high, medium, low }

enum TodaySuggestionLifecycleState {
  generated,
  active,
  fading,
  expired,
  dismissed;

  bool get isFading => this == TodaySuggestionLifecycleState.fading;
}

enum TodaySuggestionFeedback {
  accepted,
  later,
  notApplicable,
  suppress;

  String get jsonValue => switch (this) {
    TodaySuggestionFeedback.accepted => 'accepted',
    TodaySuggestionFeedback.later => 'later',
    TodaySuggestionFeedback.notApplicable => 'not_applicable',
    TodaySuggestionFeedback.suppress => 'suppress',
  };
}

// === 值对象 ===

@freezed
abstract class TodaySuggestionEvidence with _$TodaySuggestionEvidence {
  const factory TodaySuggestionEvidence({
    required String kind,    // 'record' | 'reminder' | 'risk_check' | 'trend' | 'profile' | 'baseline'
    required String label,
    required String value,
    String? recordId,
    String? medicineId,
  }) = _TodaySuggestionEvidence;
}

@freezed
abstract class TodaySuggestionAction with _$TodaySuggestionAction {
  const factory TodaySuggestionAction({
    required String actionId,
    required String label,
    required String route,
    required bool authRequired,
  }) = _TodaySuggestionAction;
}

// === 核心实体 ===

@freezed
abstract class TodaySuggestionCard with _$TodaySuggestionCard {
  const factory TodaySuggestionCard({
    required String id,
    required TodaySuggestionType type,
    required TodaySuggestionCardTone cardTone,
    required IconData icon,              // 已映射的 IconData
    required String title,
    required String reason,
    required List<TodaySuggestionEvidence> evidence,
    required String boundary,
    required TodaySuggestionAction primaryAction,
    List<TodaySuggestionAction>? secondaryActions,
    required TodaySuggestionConfidence confidence,
    required String ruleId,
    required String ruleVersion,
    required String triggerType,         // 'event' | 'timer'
    required TodaySuggestionLifecycleState lifecycleState,
    bool? notificationEligible,
    List<TodaySuggestionFeedback>? feedbackOptions,
    String? subtype,
  }) = _TodaySuggestionCard;
}

@freezed
abstract class TodaySuggestionsResponse with _$TodaySuggestionsResponse {
  const factory TodaySuggestionsResponse({
    required DateTime generatedAt,
    TodaySuggestionCard? primary,
    @Default([]) List<TodaySuggestionCard> secondary,
    @Default([]) List<TodaySuggestionCard> observations,
  }) = _TodaySuggestionsResponse;
}

// === 反馈结果 ===

@freezed
abstract class TodaySuggestionFeedbackResult with _$TodaySuggestionFeedbackResult {
  const factory TodaySuggestionFeedbackResult({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
    required String appliedEffect,  // 'boosted_type' | 'delayed_until' | 'suppressed_type' | 'noted'
    DateTime? expiresAt,
  }) = _TodaySuggestionFeedbackResult;
}

// === AI 解释 ===

@freezed
abstract class TodaySuggestionExplanation with _$TodaySuggestionExplanation {
  const factory TodaySuggestionExplanation({
    required String suggestionId,
    required String reason,
    required String boundary,
    required bool aiGenerated,
    String? locale,
  }) = _TodaySuggestionExplanation;
}
```

**图标映射工具函数**（同文件或 `view_models.dart` 中）：

```dart
/// 后端 `icon` 字符串 → Flutter IconData 映射
IconData mapSuggestionIcon(String icon) => switch (icon) {
  'pill' => FLucideIcons.pill,
  'droplets' => FLucideIcons.droplets,
  'moonStar' => FLucideIcons.moonStar,
  'trendingUp' => FLucideIcons.trendingUp,
  'shieldPlus' => FLucideIcons.shieldPlus,
  'info' => FLucideIcons.info,
  'alertTriangle' => FLucideIcons.triangleAlert,
  'bed' => FLucideIcons.bed,
  'cupSoda' => FLucideIcons.cupSoda,
  'brain' => FLucideIcons.brain,
  'heart' => FLucideIcons.heart,
  'activity' => FLucideIcons.activity,
  _ => FLucideIcons.lightbulb,  // 默认
};
```

#### 2.2 创建 suggestion remote data source

**新文件 `lib/features/today/data/datasources/suggestion_remote_data_source.dart`**

```dart
class TodaySuggestionRemoteDataSource {
  const TodaySuggestionRemoteDataSource({required this.api});

  final TodaySuggestionApi api;

  /// GET /api/v1/user/today/suggestions
  Future<TodaySuggestionsResponse> fetchSuggestions({
    String? date,
    List<String>? excludeIds,
  }) async {
    final response = await api.todaySuggestionControllerGetSuggestionsV1(
      date: date,
      excludeIds: excludeIds,
    );
    return _mapResponse(response);
  }

  /// POST /api/v1/user/today/suggestions/:id/feedback
  Future<TodaySuggestionFeedbackResult> submitFeedback({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
  }) async {
    final response = await api.todaySuggestionControllerSubmitFeedbackV1(
      id: suggestionId,
      body: SuggestionFeedbackDto(feedback: feedback.jsonValue),
    );
    return _mapFeedbackResult(response);
  }

  /// POST /api/v1/user/today/suggestions/:id/explain
  Future<TodaySuggestionExplanation> explain({
    required String suggestionId,
  }) async {
    final response = await api.todaySuggestionControllerExplainV1(
      id: suggestionId,
    );
    return _mapExplanation(response);
  }

  // === DTO → Domain 映射 ===

  TodaySuggestionsResponse _mapResponse(TodaySuggestionsResponseDto dto) { ... }
  TodaySuggestionCard _mapCard(SuggestionItemDto dto) { ... }
  TodaySuggestionEvidence _mapEvidence(EvidenceItemDto dto) { ... }
  TodaySuggestionAction _mapAction(SuggestionActionDto dto) { ... }
  TodaySuggestionFeedbackResult _mapFeedbackResult(...) { ... }
  TodaySuggestionExplanation _mapExplanation(...) { ... }
}
```

**注意**：生成的 Retrofit 方法名和参数签名取决于 OpenAPI 导出结果，实际方法名以生成代码为准。DTO → Domain 映射全部在此层完成，上层不接触生成 DTO。

#### 2.3 从 `LucentTodayRepository` 移除硬编码 priorityItems

**`lib/features/today/data/repositories/lucent_repository.dart`**：

- `fetchDashboard()` 不再构建 `priorityItems` 列表
- `priorityItems` 设为 `const []`
- 水量/用药的 summary 数据保留在 dashboard 中（供概览指标行 `buildOverviewItems()` 和轻动作区 `buildQuickActionItems()` 使用）
- `todayDayMomentFromHour` 等辅助函数保留
- 保留 `signedOutDashboard` getter

**`lib/features/today/domain/entities/dashboard.dart`**：

- `TodayPriorityItemType` 枚举标记 `@Deprecated('Use TodaySuggestionType instead')`
- `TodayPriorityItem` 类标记 `@Deprecated('Replaced by TodaySuggestionCard from suggestion API')`
- 不删除（避免大面积编译错误），但注释说明已弃用
- `TodayDashboard.priorityItems` 字段标记 `@Deprecated`

**验收标准**：
- `suggestion.dart` 实体可通过 `dart run build_runner build` 生成 freezed 代码
- `suggestion_remote_data_source.dart` DTO → Domain 映射正确
- `lucent_repository.dart` 不再构建 `priorityItems`
- `flutter analyze` 通过（允许 deprecated 警告）

---

### Phase 3：Provider 层

**目标**：建立 Riverpod provider 管理建议数据生命周期（拉取、反馈、dismiss、AI 解释）。

#### 3.1 创建 suggestion provider

**新文件 `lib/features/today/presentation/providers/suggestion_provider.dart`**

```dart
/// 远程数据源 provider
final todaySuggestionRemoteDataSourceProvider =
    Provider<TodaySuggestionRemoteDataSource>((ref) {
  return TodaySuggestionRemoteDataSource(
    api: ref.watch(lucentTodaySuggestionApiProvider),
  );
});

/// Today 建议数据 provider
/// 管理建议卡片的拉取、dismiss、反馈后刷新
final todaySuggestionProvider =
    AsyncNotifierProvider<TodaySuggestionNotifier, TodaySuggestionsResponse>(
  TodaySuggestionNotifier.new,
);

class TodaySuggestionNotifier
    extends AsyncNotifier<TodaySuggestionsResponse> {
  /// 用户已 dismiss 的建议 ID 列表
  final List<String> _dismissedIds = [];

  @override
  Future<TodaySuggestionsResponse> build() async {
    return _fetch();
  }

  Future<TodaySuggestionsResponse> _fetch() async {
    final dataSource = ref.read(todaySuggestionRemoteDataSourceProvider);
    return dataSource.fetchSuggestions(excludeIds: _dismissedIds);
  }

  /// 提交反馈
  Future<void> submitFeedback({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
  }) async {
    final dataSource = ref.read(todaySuggestionRemoteDataSourceProvider);
    await dataSource.submitFeedback(
      suggestionId: suggestionId,
      feedback: feedback,
    );

    // 反馈后刷新建议列表（后端会根据反馈调整后续出卡）
    // suppress 反馈需要把该 ID 加入 excludeIds
    if (feedback == TodaySuggestionFeedback.suppress) {
      _dismissedIds.add(suggestionId);
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Dismiss 一张卡（等同 later 反馈 + 加入 excludeIds）
  Future<void> dismiss(String suggestionId) async {
    _dismissedIds.add(suggestionId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// 手动刷新
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// AI 解释 provider（按需请求）
final suggestionExplanationProvider =
    FutureProvider.family<TodaySuggestionExplanation, String>(
  (ref, suggestionId) async {
    final dataSource = ref.watch(todaySuggestionRemoteDataSourceProvider);
    return dataSource.explain(suggestionId: suggestionId);
  },
);
```

#### 3.2 未登录态处理

`todaySuggestionProvider` 需要检查 `authSessionProvider`，未登录时返回空 `TodaySuggestionsResponse`：

```dart
@override
Future<TodaySuggestionsResponse> build() async {
  final session = ref.watch(authSessionProvider);
  if (!session.canAccessProtectedData) {
    return const TodaySuggestionsResponse(
      generatedAt: ..., // null 或默认值
    );
  }
  return _fetch();
}
```

**验收标准**：
- `todaySuggestionProvider` 可正常拉取后端数据
- `submitFeedback` 成功后自动刷新建议列表
- `dismiss` 把 ID 加入 excludeIds 并重新拉取
- 未登录态返回空 response，不抛异常
- `suggestionExplanationProvider` 按 suggestionId 按需请求

---

### Phase 4：Presentation 层 — 主卡 + 次卡重构

**目标**：建议卡片区从 `dashboard.priorityItems` 切换到 `todaySuggestionProvider` 数据。

#### 4.1 扩展 `TodayCardTone`

**`lib/features/today/presentation/widgets/shared/card_style.dart`**：

```dart
enum TodayCardTone { emphasis, urgent, warning, soft, neutral }
```

新增 `warning` 分支：

```dart
TodayCardTone.warning => (
  colors.warning.withValues(alpha: 0.3),   // 或用 destructive 的变体
  colors.warning.withValues(alpha: 0.04),
),
```

> 注：Forui `FColors` 有 `warning` 属性。如果当前主题没有 `warning`，可用 `colors.primary` 的偏橙色变体或直接复用 `destructive` 的低透明度。

#### 4.2 重构 `TodaySuggestionItem` view model

**`lib/features/today/presentation/widgets/shared/view_models.dart`**：

现有 `TodaySuggestionItem` 改为从 `TodaySuggestionCard` 构建：

```dart
/// 从后端 SuggestionCard 构建 view model
TodaySuggestionItem fromSuggestionCard(TodaySuggestionCard card) {
  return TodaySuggestionItem(
    id: card.id,
    type: card.type,
    cardTone: card.cardTone,
    icon: card.icon,
    title: card.title,
    reason: card.reason,
    evidence: card.evidence,          // List<TodaySuggestionEvidence>
    boundary: card.boundary,
    primaryAction: card.primaryAction,
    secondaryActions: card.secondaryActions,
    feedbackOptions: card.feedbackOptions,
    lifecycleState: card.lifecycleState,
    confidence: card.confidence,
    subtype: card.subtype,
  );
}
```

`TodaySuggestionItem` 字段更新：

| 旧字段 | 新字段 | 说明 |
|---|---|---|
| `final Key key` | 删除（用 `id` 代替） | |
| `final TodayPriorityItemType type` | `final TodaySuggestionType type` | 5 类枚举 |
| `final IconData icon` | 不变 | |
| `final SemanticColor color` | 删除（颜色由 `cardTone` 决定） | |
| `final String title` | 不变 | 来源从 l10n → 后端 |
| `final String reason` | 不变 | 来源从 l10n → 后端 |
| `final String evidence` | `final List<TodaySuggestionEvidence> evidence` | 结构化列表 |
| `final String boundary` | 不变 | 来源从 l10n → 后端 |
| `final String action` | `final TodaySuggestionAction primaryAction` | 含 route + label |
| — | `final List<TodaySuggestionAction>? secondaryActions` | 新增 |
| — | `final List<TodaySuggestionFeedback>? feedbackOptions` | 新增 |
| — | `final TodaySuggestionLifecycleState lifecycleState` | 新增 |
| — | `final TodaySuggestionConfidence confidence` | 新增 |
| — | `final String? subtype` | 新增 |
| — | `final String id` | 新增（反馈用） |
| — | `final TodaySuggestionCardTone cardTone` | 新增（替代 getter） |
| `final double? progress` | 保留 | 仅 water subtype 有，从 dashboard.water.progress 传入 |

`buildSuggestionItems()` 函数弃用，改为从 `TodaySuggestionsResponse` 直接取 `primary` 和 `secondary`。

#### 4.3 重构 `TodayPrimarySuggestionSection`

**`lib/features/today/presentation/widgets/sections/suggestion_section.dart`**：

从 `StatefulWidget` 改为 `ConsumerStatefulWidget`：

```dart
class TodayPrimarySuggestionSection extends ConsumerStatefulWidget {
  const TodayPrimarySuggestionSection({super.key});

  @override
  ConsumerState<TodayPrimarySuggestionSection> createState() =>
      _TodayPrimarySuggestionSectionState();
}
```

`build()` 方法：

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final suggestionAsync = ref.watch(todaySuggestionProvider);

  return TodaySection(
    title: l10n.todayPrimarySuggestionSectionTitle,
    child: suggestionAsync.when(
      data: (response) {
        final primary = response.primary;
        if (primary == null) {
          return _emptyState(context, l10n);
        }
        return _buildCard(context, l10n, ref, primary);
      },
      loading: () => _suggestionSkeleton(context),
      error: (_, __) => _suggestionError(context, l10n, ref),
    ),
  );
}
```

主卡渲染变化：

| 区域 | 旧 | 新 |
|---|---|---|
| 卡片样式 | `primary.cardTone`（2 种） | `primary.cardTone.toCardTone()`（5 种，含 `warning`） |
| 图标 | `primary.icon` + `color` | `primary.icon`（已映射 IconData），颜色由 tone 决定 |
| 标题 | l10n 硬编码 | `primary.title`（后端文案） |
| 原因 | l10n 硬编码 | `primary.reason`（后端文案） |
| 进度条 | `primary.progress` | 仅 `subtype == 'water'` 时从 `dashboard.water.progress` 传入 |
| 证据折叠区 | 单字符串 `primary.evidence` | `for (final e in primary.evidence) _SuggestionMetaBlock(label: e.label, value: e.value)` |
| 边界折叠区 | `primary.boundary` | `primary.boundary`（后端文案） |
| 主按钮 | `_openSuggestion()` 硬编码路由 | `primary.primaryAction.label` + `_navigate(primary.primaryAction.route)` |
| 反馈按钮 | 空回调 `onPress: () {}` | `_SuggestionFeedbackRow` 接入真实 API |
| 生命周期 | 无 | `lifecycleState.isFading` → `Opacity(opacity: 0.6)` |
| 空态 | 无（总是有两条） | `primary == null` 时显示空态提示 |
| AI 解释 | 无 | 折叠区内新增「AI 解释」按钮（可选，Phase 5） |

导航函数：

```dart
void _navigate(BuildContext context, String route) {
  // 后端 route 格式: '/medicine', '/record/create?kind=water', '/mine/health-context'
  if (route.contains('?')) {
    context.push(route);
  } else {
    context.go(route);
  }
}
```

#### 4.4 重构 `TodaySecondarySuggestionsSection`

从 `StatelessWidget` 改为 `ConsumerWidget`：

```dart
class TodaySecondarySuggestionsSection extends ConsumerWidget {
  const TodaySecondarySuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestionAsync = ref.watch(todaySuggestionProvider);

    return suggestionAsync.when(
      data: (response) {
        final items = response.secondary;
        if (items.isEmpty) return const SizedBox.shrink();
        // ... 渲染 FCard.raw + FTappable 列表
        // _openSuggestion → _navigate(item.primaryAction.route)
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

次卡区不再从 `dashboard.priorityItems.skip(1).take(2)` 取，而是直接从 `response.secondary` 取（后端已截断为最多 2 张）。

#### 4.5 更新 `dashboard_view.dart` 传参

`TodayPrimarySuggestionSection` 和 `TodaySecondarySuggestionsSection` 不再需要 `dashboard` 参数（改为从 provider 取数据）。但保留 `dashboard` 参数用于进度条水量数据：

```dart
// 如果 primary card 的 subtype == 'water'，进度条从 dashboard 取
TodayPrimarySuggestionSection(dashboard: dashboard),
TodaySecondarySuggestionsSection(),
```

**验收标准**：
- 主卡从 `todaySuggestionProvider` 取数据，不再从 `dashboard.priorityItems` 构建
- 主卡标题/原因/证据/边界全部来自后端
- 主卡按钮路由来自 `primaryAction.route`
- 主卡 `fading` 状态有视觉降级
- 次卡区从 `response.secondary` 取数据
- `primary == null` 时显示空态
- `flutter analyze` 通过

---

### Phase 5：反馈 + AI 解释接入

**目标**：反馈按钮接入真实 API，AI 解释按需加载。

#### 5.1 重构 `_SuggestionFeedbackRow`

从 `StatelessWidget` 改为 `ConsumerStatefulWidget`：

```dart
class _SuggestionFeedbackRow extends ConsumerStatefulWidget {
  const _SuggestionFeedbackRow({
    required this.suggestionId,
    required this.feedbackOptions,
  });

  final String suggestionId;
  final List<TodaySuggestionFeedback>? feedbackOptions;
}
```

渲染逻辑：

- 根据 `feedbackOptions` 动态渲染按钮（后端返回哪些就显示哪些）
- 如果 `feedbackOptions` 为 null 或空，不显示反馈行
- 按钮顺序：`accepted` → `later` → `notApplicable` → `suppress`

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final options = widget.feedbackOptions;
  if (options == null || options.isEmpty) return const SizedBox.shrink();

  return Row(
    children: [
      for (final option in options) ...[
        FButton(
          onPress: _isSubmitting ? null : () => _submit(option),
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          child: Text(_labelFor(l10n, option)),
        ),
        const SizedBox(width: Spacing.level2),
      ],
    ],
  );
}

Future<void> _submit(TodaySuggestionFeedback feedback) async {
  setState(() => _isSubmitting = true);
  try {
    await ref.read(todaySuggestionProvider.notifier).submitFeedback(
      suggestionId: widget.suggestionId,
      feedback: feedback,
    );
    if (mounted) {
      AppToast.show(context, l10n.todaySuggestionFeedbackSuccess);
    }
  } catch (e) {
    if (mounted) {
      AppToast.show(context, l10n.todaySuggestionFeedbackError);
    }
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}
```

反馈按钮文案映射：

| 枚举 | 中文 | 英文 | ARB key |
|---|---|---|---|
| `accepted` | 已采纳 | Accepted | `todaySuggestionAcceptedAction` |
| `later` | 稍后处理 | Later | `todaySuggestionLaterAction`（已存在） |
| `notApplicable` | 不适用 | Not applicable | `todaySuggestionNotApplicableAction`（已存在） |
| `suppress` | 不再看到 | Don't show again | `todaySuggestionSuppressAction` |

#### 5.2 AI 解释按钮

在主卡折叠区（证据/边界之后）新增「AI 解释」按钮：

```dart
// 折叠区内
const SizedBox(height: Spacing.level3),
_SuggestionAiExplainButton(suggestionId: primary.id),
```

`_SuggestionAiExplainButton` 是 `ConsumerWidget`：

```dart
class _SuggestionAiExplainButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explanationAsync = ref.watch(
      suggestionExplanationProvider(widget.suggestionId),
    );

    return explanationAsync.when(
      data: (explanation) => explanation.aiGenerated
          ? _AiExplainContent(explanation: explanation)
          : const SizedBox.shrink(),  // AI 未生成，回退到原始文案
      loading: () => Row(
        children: [
          const SizedBox(
            width: Spacing.level4,
            height: Spacing.level4,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Spacing.level2),
          Text(l10n.todaySuggestionAiExplainLoading),
        ],
      ),
      error: (_, __) => FButton(
        onPress: () => ref.invalidate(
          suggestionExplanationProvider(widget.suggestionId),
        ),
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.xs,
        child: Text(l10n.todaySuggestionAiExplainRetry),
      ),
      // 未请求时显示触发按钮
      // ...
    );
  }
}
```

AI 解释设计为**按需触发**：
1. 用户展开证据折叠区后，看到「AI 解释」按钮
2. 点击后调用 `POST /:id/explain`
3. 返回后用 AI 增强的 `reason` / `boundary` 替换原始文案
4. 如果 `aiGenerated == false`，不替换（模型未配置，回退到规则文案）
5. 不阻塞首屏

#### 5.3 新增 ARB l10n keys

**`lib/l10n/app_zh.arb` + `app_en.arb`** 新增：

```json
"todaySuggestionAcceptedAction": "已采纳",
"todaySuggestionSuppressAction": "不再看到",
"todaySuggestionFeedbackSuccess": "反馈已提交",
"todaySuggestionFeedbackError": "反馈提交失败，请稍后再试",
"todaySuggestionAiExplainAction": "AI 解释",
"todaySuggestionAiExplainLoading": "正在生成 AI 解释…",
"todaySuggestionAiExplainRetry": "重试",
"todaySuggestionEmptyTitle": "今日暂无建议",
"todaySuggestionEmptySubtitle": "记录更多数据后将会生成个性化建议",
"todaySuggestionLoadingHint": "正在获取今日建议…",
"todaySuggestionErrorHint": "建议加载失败，请稍后重试"
```

运行 `flutter gen-l10n` 生成。

**验收标准**：
- 反馈按钮根据 `feedbackOptions` 动态渲染
- 点击反馈后调用 API 并刷新建议列表
- 反馈成功/失败有 toast 提示
- 提交中按钮禁用防重复
- AI 解释按需加载，不阻塞首屏
- AI 解释失败可重试
- 所有新文案通过 ARB，无硬编码

---

### Phase 6：观察项区重构

**目标**：观察项区从旧 `todayRecommendationsProvider` 切换到 `todaySuggestionProvider` 的 `observations`。

#### 6.1 重构 `TodayObservationSection`

**`lib/features/today/presentation/widgets/sections/observation_section.dart`**：

数据源切换：

```dart
// 旧
final recommendationsAsync = ref.watch(todayRecommendationsProvider);

// 新
final suggestionAsync = ref.watch(todaySuggestionProvider);
```

`_mapObservation()` 从 `TodaySuggestionCard` 映射到 `_ObservationItem`：

```dart
_ObservationItem _mapObservation(
  BuildContext context,
  AppLocalizations l10n,
  TodaySuggestionCard card,
) {
  return _ObservationItem(
    icon: card.icon,
    title: card.title,
    subtitle: card.reason,
    tag: _tagForConfidence(l10n, card.confidence),
    onPress: () => _navigate(context, card.primaryAction.route),
  );
}
```

保留 `_fallbackObservations()` 逻辑（如睡眠缺失提示），作为后端 observations 的补充。

#### 6.2 废弃旧 recommendations provider

- `todayRecommendationsProvider` 标记 `@Deprecated`
- `recommendations_remote_data_source.dart` 标记 `@Deprecated`
- 不删除（避免大面积编译错误），但注释说明已弃用
- 后续可考虑完全移除

**验收标准**：
- 观察项区从 `todaySuggestionProvider.observations` 取数据
- `_fallbackObservations()` 保留作为补充
- 旧 `todayRecommendationsProvider` 标记 deprecated
- `flutter analyze` 通过

---

### Phase 7：`dashboard_view.dart` + 页面集成

**目标**：更新页面布局传参，确保 suggestion provider 和 dashboard provider 协同工作。

#### 7.1 更新 `dashboard_view.dart`

`TodayPrimarySuggestionSection` 和 `TodaySecondarySuggestionsSection` 不再从 `dashboard` 取建议数据。但 `dashboard` 仍需传入用于：
- 概览指标行（`buildOverviewItems`）
- 轻动作区（`buildQuickActionItems`）
- 记录密度提示（`shouldShowRecordHint`）
- 顶栏问候语（`greetingSubtitle`）
- 水量进度条（仅 `subtype == 'water'` 的建议卡需要）

```dart
// _MobileTodayDashboard
TodayPrimarySuggestionSection(dashboard: dashboard),
TodaySecondarySuggestionsSection(),
TodaySummarySection(dashboard: dashboard),
TodayObservationSection(dashboard: dashboard),
TodayQuickActionsSection(dashboard: dashboard),
```

#### 7.2 刷新逻辑

`TodayPage._refreshDashboard` 同时刷新 dashboard 和 suggestions：

```dart
Future<void> _refreshAll(WidgetRef ref) async {
  ref.invalidate(todayDashboardProvider);
  ref.invalidate(todaySuggestionProvider);
  await Future.wait([
    ref.read(todayDashboardProvider.future),
    ref.read(todaySuggestionProvider.future),
  ]);
}
```

#### 7.3 错误降级策略

| Provider 状态 | 主卡区 | 次卡区 | 观察项区 |
|---|---|---|---|
| loading | 骨架占位 | 隐藏 | 骨架占位 |
| error | inline retry | 隐藏 | inline retry |
| data (primary == null) | 空态提示 | 隐藏 | 正常渲染 observations |
| data (secondary == []) | 正常 | 隐藏 | 正常 |
| data (observations == []) | 正常 | 正常 | fallback + 空态 |

Dashboard provider 和 suggestion provider **独立管理错误**：
- Dashboard 加载失败 → 整页错误视图（保持现有行为）
- Suggestion 加载失败 → 建议区显示 inline retry，其他区域正常

**验收标准**：
- 页面刷新同时刷新 dashboard 和 suggestions
- 各区域独立处理 loading/error/data 状态
- `flutter analyze` 通过
- 现有页面测试不破坏

---

### Phase 8：测试

**目标**：覆盖新增的数据层、provider 层和 UI 层。

#### 8.1 更新测试辅助

**`test/today/test_helpers.dart`** 新增：

```dart
/// 静态建议 response，用于测试
const testSuggestionsResponse = TodaySuggestionsResponse(
  generatedAt: ..., // 固定时间
  primary: TodaySuggestionCard(
    id: 'sug_test_001',
    type: TodaySuggestionType.compliance,
    cardTone: TodaySuggestionCardTone.urgent,
    icon: FLucideIcons.pill,
    title: '上午的阿托伐他汀尚未确认',
    reason: '计划服药时间为 08:00，当前已超时 4 小时且未标记服用。',
    evidence: [
      TodaySuggestionEvidence(kind: 'reminder', label: '计划时间', value: '08:00'),
      TodaySuggestionEvidence(kind: 'record', label: '今日状态', value: '未确认'),
    ],
    boundary: '此提醒基于您的用药计划，不能替代医生或药师建议。',
    primaryAction: TodaySuggestionAction(
      actionId: 'go_confirm',
      label: '去确认',
      route: '/medicine',
      authRequired: true,
    ),
    confidence: TodaySuggestionConfidence.high,
    ruleId: 'missed_dose_pending',
    ruleVersion: '1.0.0',
    triggerType: 'event',
    lifecycleState: TodaySuggestionLifecycleState.active,
    feedbackOptions: [
      TodaySuggestionFeedback.accepted,
      TodaySuggestionFeedback.later,
      TodaySuggestionFeedback.notApplicable,
    ],
  ),
  secondary: [
    TodaySuggestionCard(
      id: 'sug_test_002',
      type: TodaySuggestionType.behaviorAdvice,
      cardTone: TodaySuggestionCardTone.soft,
      icon: FLucideIcons.droplets,
      title: '今日饮水还差 2 杯',
      reason: '已完成 6/8，少量多次更好。',
      evidence: [...],
      boundary: '...',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_record',
        label: '去记录',
        route: '/record/create?kind=water',
        authRequired: true,
      ),
      confidence: TodaySuggestionConfidence.medium,
      ruleId: 'water_behind_target',
      ruleVersion: '1.0.0',
      triggerType: 'timer',
      lifecycleState: TodaySuggestionLifecycleState.active,
      feedbackOptions: [
        TodaySuggestionFeedback.accepted,
        TodaySuggestionFeedback.later,
        TodaySuggestionFeedback.notApplicable,
        TodaySuggestionFeedback.suppress,
      ],
      subtype: 'water',
    ),
  ],
  observations: [
    TodaySuggestionCard(
      id: 'sug_test_003',
      type: TodaySuggestionType.coverage,
      cardTone: TodaySuggestionCardTone.neutral,
      icon: FLucideIcons.info,
      title: '睡眠数据不足，暂无法生成睡眠趋势建议',
      reason: '需要至少 3 天连续睡眠记录才能建立基线。',
      evidence: [],
      boundary: '...',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_record_sleep',
        label: '记录睡眠',
        route: '/record/create?kind=sleep',
        authRequired: true,
      ),
      confidence: TodaySuggestionConfidence.high,
      ruleId: 'coverage_explanation',
      ruleVersion: '1.0.0',
      triggerType: 'timer',
      lifecycleState: TodaySuggestionLifecycleState.active,
    ),
  ],
);

/// 静态 suggestion notifier，用于测试
class StaticTodaySuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionsResponse> build() async {
    return testSuggestionsResponse;
  }
}

/// 空建议 notifier
class EmptyTodaySuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionsResponse> build() async {
    return TodaySuggestionsResponse(generatedAt: DateTime(2026, 7, 9));
  }
}
```

#### 8.2 新增测试文件

| 文件 | 覆盖范围 |
|---|---|
| `test/today/suggestion_remote_data_source_test.dart` | DTO → Domain 映射 |
| `test/today/suggestion_provider_test.dart` | fetch、dismiss、submitFeedback 行为 |
| `test/today/suggestion_section_test.dart` | 主卡/次卡渲染、空态、错误态 |
| `test/today/observation_section_test.dart` | 观察项从 suggestions 取数据 |

#### 8.3 更新现有测试

**`test/today/page_test.dart`**：

- `_signedInTodayApp()` 新增 `todaySuggestionProvider` override
- 所有使用 `todayRecommendationsProvider` override 的地方改为 `todaySuggestionProvider` override
- `_LoadingRecommendationsNotifier` / `_EmptyRecommendationsNotifier` 替换为对应的 suggestion notifier

**`test/today/dashboard_provider_test.dart`**：

- 验证 `priorityItems` 不再被硬编码填充
- 验证 dashboard 仍返回正确的水量/用药 summary

**`test/today/repository_test.dart`**：

- 验证 `LucentTodayRepository.fetchDashboard()` 返回空 `priorityItems`

**验收标准**：
- `flutter test` 全部通过
- `flutter test test/today/` 覆盖新增代码
- `flutter analyze` 无错误

---

### Phase 9：文档更新

**目标**：同步所有受影响文档。

#### 9.1 更新 `Active_UI_Today.md`

- 主建议卡数据源改为 `todaySuggestionProvider`（`GET /today/suggestions`）
- 主卡支持 5 类建议类型、5 种 cardTone
- 证据区改为结构化列表（`EvidenceItemDto[]`）
- 反馈按钮接入 `POST /today/suggestions/:id/feedback`
- AI 解释按钮接入 `POST /today/suggestions/:id/explain`
- 观察项数据源改为 `todaySuggestionProvider.observations`
- 旧 `todayRecommendationsProvider` 标记 deprecated
- `priorityItems` 标记 deprecated

#### 9.2 更新 `Mock_Or_Deferred.md`

- 移除 "Today 主动建议卡片后端统一裁决引擎" 延后项

#### 9.3 更新 `TODO.md`

- 删除 "Today 主动建议卡片后端统一裁决引擎" 条目
- 删除蓝图差距盘点中 "Today — 延后" section

#### 9.4 追加 migration log

**`docs/03-logs/migration-log/2026-07-09.md`** 追加：

```
## Today 建议引擎前端接入

- 重新生成 API 客户端，新增 `TodaySuggestionApi`
- 新增 `suggestion.dart` domain entities（5 类卡片类型、5 种 tone、反馈/解释/生命周期枚举）
- 新增 `suggestion_remote_data_source.dart`，DTO → Domain 映射
- 新增 `suggestion_provider.dart`（`todaySuggestionProvider` + `suggestionExplanationProvider`）
- 重构 `suggestion_section.dart` 主卡/次卡，数据源切换到后端建议引擎
- 反馈按钮接入 `POST /today/suggestions/:id/feedback`
- AI 解释按钮接入 `POST /today/suggestions/:id/explain`
- 观察项区数据源切换到 `todaySuggestionProvider.observations`
- `LucentTodayRepository` 移除 `priorityItems` 硬编码
- `TodayCardTone` 新增 `warning` 变体
- `TodayPriorityItemType` / `TodayPriorityItem` 标记 deprecated
- 新增 ARB l10n keys（反馈操作、AI 解释、空态等）
- 测试更新
```

#### 9.5 更新 `Current_State.md`

- 基线摘要追加："Today 主/次建议卡已接入 Lucent 建议引擎，支持 5 类卡片 + 反馈 + AI 解释"

---

## 2. 关键设计决策

### 2.1 数据源分离

| Provider | 数据来源 | 用途 |
|---|---|---|
| `todayDashboardProvider` | `LucentTodayRepository.fetchDashboard()` | 概览指标、轻动作、问候语、水量进度 |
| `todaySuggestionProvider` | `GET /today/suggestions` | 主卡、次卡、观察项 |
| `todayAiAnalysisControllerProvider` | `POST /today-analysis/generate/stream` | AI 每日摘要（不变） |

Dashboard 和 Suggestions **独立管理**，各自有独立的 loading/error/data 状态。页面刷新时同时 invalidate 两个 provider。

### 2.2 `TodayCardTone` 对齐

后端返回 5 种 tone：`urgent`、`warning`、`emphasis`、`soft`、`neutral`。

前端 `TodayCardTone` 当前只有 4 种（缺 `warning`），需要新增。映射关系：

| 后端 tone | 前端 `TodayCardTone` | 视觉 |
|---|---|---|
| `urgent` | `urgent` | destructive 边框 + 淡红底色 |
| `warning` | `warning` | warning 边框 + 淡黄/橙底色 |
| `emphasis` | `emphasis` | primary 边框 + card 底色 |
| `soft` | `soft` | border 边框 + card 底色 |
| `neutral` | `neutral` | border 边框 + card 底色 |

### 2.3 导航策略

后端 `primaryAction.route` 返回深度链接字符串（如 `/medicine`、`/record/create?kind=water`、`/mine/health-context`）。

前端导航规则：
- 包含 `?` → `context.push(route)`（带 query 参数，通常是记录创建页）
- 不包含 `?` → `context.go(route)`（tab 切换或顶层页面）

### 2.4 进度条处理

后端 `SuggestionItemDto` 没有进度条字段。`behavior_advice` 类型的 `subtype == 'water'` 建议卡需要进度条。

方案：主卡组件接收 `dashboard` 参数，当 `card.subtype == 'water'` 时从 `dashboard.water.progress` 获取进度值。

### 2.5 反馈后刷新策略

| 反馈类型 | 本地动作 | 刷新行为 |
|---|---|---|
| `accepted` | 无特殊本地动作 | invalidate provider 重新拉取 |
| `later` | 无特殊本地动作 | invalidate provider 重新拉取 |
| `notApplicable` | 无特殊本地动作 | invalidate provider 重新拉取 |
| `suppress` | 把 suggestionId 加入 `_dismissedIds` | invalidate provider 重新拉取（该卡不再返回） |

### 2.6 AI 解释触发时机

- **不自动触发**：首屏渲染不需要 AI 解释
- **用户主动触发**：用户展开证据折叠区后，看到「AI 解释」按钮
- **按需请求**：点击后调 `POST /:id/explain`
- **回退安全**：`aiGenerated == false` 时不替换原始文案
- **错误重试**：AI 解释失败可重试
- **不持久化**：AI 解释结果存在 provider family 中，页面刷新后重新请求

### 2.7 未登录态处理

- `todaySuggestionProvider` 在未登录态返回空 `TodaySuggestionsResponse`
- 主卡区显示空态（或隐藏）
- 次卡区隐藏
- 观察项区显示 fallback 项
- 不调用后端 API

### 2.8 `TodayPriorityItemType` / `TodayPriorityItem` 废弃策略

- 标记 `@Deprecated`，不删除
- `TodayDashboard.priorityItems` 设为空列表 `const []`
- 后续可在独立 PR 中完全移除

---

## 3. 文件变更明细

### 新建文件

| 文件路径 | 内容 |
|---|---|
| `lib/features/today/domain/entities/suggestion.dart` | 域实体和枚举 |
| `lib/features/today/domain/entities/suggestion.freezed.dart` | freezed 生成 |
| `lib/features/today/data/datasources/suggestion_remote_data_source.dart` | 远程数据源 |
| `lib/features/today/presentation/providers/suggestion_provider.dart` | Riverpod provider |
| `test/today/suggestion_remote_data_source_test.dart` | 数据源测试 |
| `test/today/suggestion_provider_test.dart` | provider 测试 |
| `test/today/suggestion_section_test.dart` | UI 测试 |
| `test/today/observation_section_test.dart` | 观察项测试 |

### 修改文件

| 文件路径 | 改动摘要 |
|---|---|
| `generated/lucent_api/` | 重新生成（新增 `TodaySuggestionApi` + models） |
| `lib/core/network/dio_client.dart` | 新增 `todaySuggestionApi` getter |
| `lib/core/network/network_providers.dart` | 新增 `lucentTodaySuggestionApiProvider` |
| `lib/features/today/domain/entities/dashboard.dart` | `TodayPriorityItemType` / `TodayPriorityItem` 标记 deprecated |
| `lib/features/today/data/repositories/lucent_repository.dart` | 移除 `priorityItems` 硬编码，设为空列表 |
| `lib/features/today/presentation/widgets/shared/view_models.dart` | 重构 `TodaySuggestionItem`，新增 `fromSuggestionCard()` |
| `lib/features/today/presentation/widgets/shared/card_style.dart` | 新增 `TodayCardTone.warning` |
| `lib/features/today/presentation/widgets/sections/suggestion_section.dart` | 重构主卡/次卡，切换数据源，接入反馈+AI解释 |
| `lib/features/today/presentation/widgets/sections/observation_section.dart` | 切换数据源到 `todaySuggestionProvider.observations` |
| `lib/features/today/presentation/widgets/views/dashboard_view.dart` | 更新传参，刷新逻辑 |
| `lib/features/today/presentation/pages/page.dart` | 刷新同时 invalidate dashboard + suggestions |
| `lib/features/today/presentation/providers/recommendations_provider.dart` | 标记 `@Deprecated` |
| `lib/features/today/data/datasources/recommendations_remote_data_source.dart` | 标记 `@Deprecated` |
| `lib/l10n/app_zh.arb` | 新增 suggestion 相关 keys |
| `lib/l10n/app_en.arb` | 新增 suggestion 相关 keys |
| `test/today/test_helpers.dart` | 新增 suggestion 测试辅助 |
| `test/today/page_test.dart` | 更新 provider override |
| `test/today/dashboard_provider_test.dart` | 验证 priorityItems 为空 |
| `test/today/repository_test.dart` | 验证 priorityItems 为空 |
| `docs/00-current/Active_UI_Today.md` | 更新建议区/观察项数据源说明 |
| `docs/00-current/Mock_Or_Deferred.md` | 移除建议引擎延后项 |
| `docs/00-current/TODO.md` | 删除建议引擎 TODO |
| `docs/00-current/Current_State.md` | 追加基线摘要 |
| `docs/03-logs/migration-log/2026-07-09.md` | 追加变更记录 |

---

## 4. 执行顺序

```
Phase 1: 生成客户端 + 网络层
    ↓
Phase 2: Domain + Data 层
    ↓
Phase 3: Provider 层
    ↓
Phase 4: 主卡 + 次卡重构 ←——— 最核心
    ↓
Phase 5: 反馈 + AI 解释
    ↓
Phase 6: 观察项重构
    ↓
Phase 7: 页面集成
    ↓
Phase 8: 测试
    ↓
Phase 9: 文档
```

每个 Phase 完成后运行 `flutter analyze` + 相关测试。Phase 8 完成后运行 `flutter test`。

---

## 5. 验收标准

### 功能验收

- [ ] `GET /today/suggestions` 返回的主卡正确渲染（5 类卡片 × 5 种 tone）
- [ ] 主卡标题/原因/证据/边界文案来自后端
- [ ] 主卡证据区为结构化列表（label: value）
- [ ] 主卡按钮路由来自 `primaryAction.route`
- [ ] 主卡 `fading` 状态有视觉降级
- [ ] 次卡区从 `response.secondary` 取数据
- [ ] 观察项区从 `response.observations` 取数据
- [ ] `primary == null` 时主卡区显示空态
- [ ] 反馈按钮根据 `feedbackOptions` 动态渲染
- [ ] 反馈提交后建议列表自动刷新
- [ ] `suppress` 反馈后该卡不再出现
- [ ] AI 解释按需加载，不阻塞首屏
- [ ] AI 解释失败可重试
- [ ] 未登录态不调用建议 API
- [ ] 页面刷新同时刷新 dashboard + suggestions

### 技术验收

- [ ] `flutter analyze` 无错误
- [ ] `flutter test` 全部通过
- [ ] `flutter gen-l10n` 成功
- [ ] `dart run build_runner build` 成功
- [ ] 无硬编码用户可见文案（全部走 ARB）
- [ ] 无 `CircularProgressIndicator`（loading 用骨架占位）
- [ ] 错误态使用 inline retry 或 `AppStateErrorView`
- [ ] 轻量反馈使用 `AppToast`

### 文档验收

- [ ] `Active_UI_Today.md` 已更新
- [ ] `Mock_Or_Deferred.md` 已更新
- [ ] `TODO.md` 已更新
- [ ] `Current_State.md` 已更新
- [ ] `migration-log/2026-07-09.md` 已追加
