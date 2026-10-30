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
import 'package:luminous/features/review/presentation/widgets/sections/legacy/ai_summary.dart'
    as legacy;
import 'package:luminous/features/review/presentation/widgets/sections/legacy/findings.dart';
import 'package:luminous/features/review/presentation/widgets/sections/legacy/patterns.dart';
import 'package:luminous/features/review/presentation/widgets/sections/legacy/readiness.dart';
import 'package:luminous/features/review/presentation/widgets/sections/legacy/suggestion_history.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Legacy (pre-event-first) review components.
///
/// These five sections belonged to the old period-dashboard page. They are
/// **registered and mountable** — the user may pick any of them in the surface
/// editor — but none of them is in `reviewSurfaceDefinition.defaultLayout`:
/// the default must stay byte-for-byte the current event-first page, so keeping
/// them out is what makes today's rendering a pure refactor.
///
/// They read from the same surface providers as the main-path components
/// (`reviewSurfaceStateProvider` for the period dashboard), so mounting one on
/// another surface later needs no new wiring.
///
/// Two of them share a class name with a main-path section
/// (`ReviewAiSummarySection`, `ReviewSuggestionHistorySection`); the import
/// prefix plus the `.legacy` id suffix keeps them apart.
const reviewAiSummaryLegacyId = ComponentId('ai_summary.legacy');
const reviewFindingsLegacyId = ComponentId('findings.legacy');
const reviewPatternsLegacyId = ComponentId('patterns.legacy');
const reviewReadinessLegacyId = ComponentId('readiness.legacy');
const reviewSuggestionHistoryLegacyId = ComponentId(
  'history.suggestion_legacy',
);

/// Ids of the legacy sections, in the old page's render order.
const reviewLegacyComponentIds = <ComponentId>[
  reviewReadinessLegacyId,
  reviewFindingsLegacyId,
  reviewAiSummaryLegacyId,
  reviewPatternsLegacyId,
  reviewSuggestionHistoryLegacyId,
];

/// Registers the legacy sections into [registry].
void registerReviewLegacyComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _LegacyReadinessComponent());
  registry.registerDescriptor(const _LegacyFindingsComponent());
  registry.registerDescriptor(const _LegacyAiSummaryComponent());
  registry.registerDescriptor(const _LegacyPatternsComponent());
  registry.registerDescriptor(const _LegacySuggestionHistoryComponent());
}

/// Readiness of the period dashboard, mirroring the old page's rule.
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

class _LegacyReadinessComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _LegacyReadinessComponent();

  @override
  ComponentId get id => reviewReadinessLegacyId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
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
      onSignIn: () => context.push(loginRouteForCurrentLocation(context)),
      onContinueRecord: () => context.push('/record/create'),
    );
  }
}

class _LegacyFindingsComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _LegacyFindingsComponent();

  @override
  ComponentId get id => reviewFindingsLegacyId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    return ReviewFindingsSection(
      findings: dashboard.findings,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

class _LegacyAiSummaryComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _LegacyAiSummaryComponent();

  @override
  ComponentId get id => reviewAiSummaryLegacyId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
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
    return legacy.ReviewAiSummarySection(
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
                  .read(reviewAiSummaryControllerProvider(selectedRange).notifier)
                  .generate();
            }
          : null,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

class _LegacyPatternsComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _LegacyPatternsComponent();

  @override
  ComponentId get id => reviewPatternsLegacyId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    return ReviewPatternsSection(
      patterns: dashboard.patterns,
      l10n: AppLocalizations.of(context)!,
    );
  }
}

class _LegacySuggestionHistoryComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _LegacySuggestionHistoryComponent();

  @override
  ComponentId get id => reviewSuggestionHistoryLegacyId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    if (!ref.watch(authSessionProvider).canAccessProtectedData) return null;

    final async = ref.watch(suggestionHistoryProvider);
    final items = async.value?.items;
    if (items == null) return null;

    // Same de-duplication and cap as the legacy page: newest state per
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
