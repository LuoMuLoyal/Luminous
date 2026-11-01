import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/composition/today/suggestion.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/ai_summary.dart';
import 'package:luminous/features/review/presentation/providers/surface.dart';
import 'package:luminous/features/review/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period/ai_summary.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period/findings.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period/patterns.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period/readiness.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period/suggestion_history.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 周期视图组件：按选定区间（7/30 天）聚合的整段回顾。
///
/// 这些不是「旧版遗留」：review 页面同时存在两种视角——
/// - **事件视角**（`event.*` / `overview.*`）：围绕一次健康事件讲发生了什么；
/// - **周期视角**（本文件）：不管有没有事件，按区间统计趋势、发现与规律。
///
/// 两者是并列的产品形态，不是新旧替代关系。所以 id 用 `*.period` 而不是
/// `*.legacy`：组件面板里用户看到的是「周期发现」而不是「旧版发现」，也不会
/// 因为名字暗示「将被删除」而不敢使用。
///
/// 它们读的是同一组 surface provider（`reviewSurfaceStateProvider`），因此挂到
/// 别的 surface 上不需要新接线。
const reviewReadinessPeriodId = ComponentId('readiness.period');
const reviewFindingsPeriodId = ComponentId('findings.period');
const reviewAiSummaryPeriodId = ComponentId('ai_summary.period');
const reviewPatternsPeriodId = ComponentId('patterns.period');
const reviewSuggestionHistoryId = ComponentId('history.suggestion');

/// Ids of the periodic sections, in the period dashboard's render order.
const reviewPeriodComponentIds = <ComponentId>[
  reviewReadinessPeriodId,
  reviewFindingsPeriodId,
  reviewAiSummaryPeriodId,
  reviewPatternsPeriodId,
  reviewSuggestionHistoryId,
];

/// Registers the periodic sections into [registry].
void registerReviewPeriodComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _ReadinessPeriodComponent());
  registry.registerDescriptor(const _FindingsPeriodComponent());
  registry.registerDescriptor(const _AiSummaryPeriodComponent());
  registry.registerDescriptor(const _PatternsPeriodComponent());
  registry.registerDescriptor(const _SuggestionHistoryComponent());
}

/// Readiness of the period dashboard, mirroring the period view's rule.
ReviewReadinessStatus _readinessStatus(
  WidgetRef ref,
  ReviewDashboard dashboard,
) {
  if (ref.watch(reviewSurfacePreviewProvider)) {
    return ReviewReadinessStatus.signedOut;
  }
  final hasInsufficient = dashboard.metrics.any(
    (metric) => metric.status == ReviewStatus.insufficientData,
  );
  if (dashboard.metrics.isEmpty || hasInsufficient) {
    return ReviewReadinessStatus.insufficient;
  }
  return ReviewReadinessStatus.ready;
}

class _ReadinessPeriodComponent extends ComponentDescriptor<NoComponentConfig> {
  const _ReadinessPeriodComponent();

  @override
  ComponentId get id => reviewReadinessPeriodId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    final l10n = AppLocalizations.of(context)!;
    final readiness = _readinessStatus(ref, dashboard);
    final range = dashboard.range;

    return ReviewReadinessSection(
      status: readiness,
      generatedAtLabel: reportDashboardGeneratedAtLabel(
        context,
        dashboard.generatedAt,
      ),
      insufficientMetricCount: dashboard.metrics
          .where((metric) => metric.status == ReviewStatus.insufficientData)
          .length,
      needsAttentionMetricCount: dashboard.metrics
          .where((metric) => metric.status == ReviewStatus.needsAttention)
          .length,
      l10n: l10n,
      rangeLabel: switch (range) {
        ReviewDashboardRange.last7Days => l10n.reviewRangeLast7Days,
        ReviewDashboardRange.last30Days => l10n.reviewRangeLast30Days,
        ReviewDashboardRange.custom => l10n.reviewRangeCustom,
      },
      onSignIn: () => requestSignIn(context),
      onContinueRecord: () => context.push('/record/create'),
    );
  }
}

class _FindingsPeriodComponent extends ComponentDescriptor<NoComponentConfig> {
  const _FindingsPeriodComponent();

  @override
  ComponentId get id => reviewFindingsPeriodId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    return ReviewFindingsSection(
      findings: dashboard.findings,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

class _AiSummaryPeriodComponent extends ComponentDescriptor<NoComponentConfig> {
  const _AiSummaryPeriodComponent();

  @override
  ComponentId get id => reviewAiSummaryPeriodId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;

    final canAccessProtectedData = ref
        .watch(authSessionProvider)
        .canAccessProtectedData;
    final selectedRange = ref.watch(reviewAiSummarySelectedRangeProvider);
    final aiEnabled = ref.watch(
      userSettingsControllerProvider.select(
        (settings) => settings.asData?.value.aiSummariesEnabled,
      ),
    );
    return ReviewPeriodAiSummarySection(
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiEnabled,
      aiState: ref.watch(reviewAiSummaryControllerProvider(selectedRange)),
      selectedRange: selectedRange,
      onRangeChanged: (range) => ref
          .read(reviewAiSummarySelectedRangeProvider.notifier)
          .setRange(range),
      onGenerate: canAccessProtectedData
          ? () async {
              await ref
                  .read(
                    reviewAiSummaryControllerProvider(selectedRange).notifier,
                  )
                  .generate();
            }
          : null,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

class _PatternsPeriodComponent extends ComponentDescriptor<NoComponentConfig> {
  const _PatternsPeriodComponent();

  @override
  ComponentId get id => reviewPatternsPeriodId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    return ReviewPatternsSection(
      patterns: dashboard.patterns,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

class _SuggestionHistoryComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _SuggestionHistoryComponent();

  @override
  ComponentId get id => reviewSuggestionHistoryId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    if (!ref.watch(authSessionProvider).canAccessProtectedData) return null;

    final async = ref.watch(suggestionHistoryProvider);
    final items = async.value?.items;
    if (items == null) return null;

    // Same de-duplication and cap as the period view: newest state per
    // suggestion text, at most three rows.
    final byKey = <String, TodaySuggestionHistoryItem>{};
    for (final item in items) {
      final key = '${item.title}|${item.reason}|${item.type.name}';
      final existing = byKey[key];
      if (existing == null ||
          _lifecycleRank(item.lifecycleState) >
              _lifecycleRank(existing.lifecycleState)) {
        byKey[key] = item;
      }
    }
    return ReviewSuggestionHistorySection(
      suggestions: byKey.values.take(3).toList(growable: false),
      isLoading: async.isLoading,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

int _lifecycleRank(TodaySuggestionLifecycleState state) => switch (state) {
  TodaySuggestionLifecycleState.active => 3,
  TodaySuggestionLifecycleState.generated => 2,
  TodaySuggestionLifecycleState.fading => 1,
  TodaySuggestionLifecycleState.dismissed => 0,
  TodaySuggestionLifecycleState.expired => -1,
};
