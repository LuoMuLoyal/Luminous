import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/recommendation.dart';
import 'package:luminous/features/today/presentation/providers/recommendations_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayObservationSection extends ConsumerWidget {
  const TodayObservationSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recommendationsAsync = ref.watch(todayRecommendationsProvider);
    final fallback = _fallbackObservations(context, l10n);

    return TodaySection(
      title: l10n.todayObservationSectionTitle,
      child: FCard.raw(
        key: const Key('today-observation-card'),
        style: todayCardStyle(context),
        child: recommendationsAsync.when(
          data: (recommendations) {
            final items = [
              ...fallback,
              ...recommendations
                  .take(2)
                  .map((item) => _mapObservation(context, l10n, item)),
            ];

            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacingTokens.level4),
                child: Text(
                  l10n.todayObservationEmptyState,
                  style: AppTypographyToken.level4
                      .body(context)
                      .copyWith(color: context.theme.colors.mutedForeground),
                ),
              );
            }

            return Column(
              children: [
                for (final item in items)
                  FTile(
                    prefix: Icon(item.icon, size: AppSpacingTokens.level5),
                    title: Text(item.title),
                    subtitle: Text(item.subtitle),
                    suffix: FBadge(
                      variant: FBadgeVariant.outline,
                      child: Text(item.tag),
                    ),
                    onPress: item.onPress,
                  ),
              ],
            );
          },
          loading: () => const _ObservationLoadingState(),
          error: (_, __) => _ObservationErrorState(
            onRetry: () =>
                ref.read(todayRecommendationsProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  List<_ObservationItem> _fallbackObservations(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (!hasMeaningfulVitalValue(dashboard.vitals, TodayVitalType.sleep)) {
      return [
        _ObservationItem(
          icon: FLucideIcons.moonStar,
          title: l10n.todayObservationSleepMissingTitle,
          subtitle: l10n.todayObservationSleepMissingSubtitle,
          tag: l10n.todayObservationLowConfidenceTag,
          onPress: () => context.push('${AppRoutes.recordCreate}?kind=sleep'),
        ),
      ];
    }

    return const [];
  }

  _ObservationItem _mapObservation(
    BuildContext context,
    AppLocalizations l10n,
    TodayRecommendation recommendation,
  ) {
    final category = recommendation.category ?? 'habit';

    return switch (category) {
      'medicine' => _ObservationItem(
        icon: FLucideIcons.shieldPlus,
        title: recommendation.text,
        subtitle: l10n.todayObservationMedicineNote,
        tag: l10n.todayObservationReviewTag,
        onPress: () => context.go(AppRoutes.medicine),
      ),
      'sleep' => _ObservationItem(
        icon: FLucideIcons.moonStar,
        title: recommendation.text,
        subtitle: l10n.todayObservationSleepNote,
        tag: l10n.todayObservationLowConfidenceTag,
        onPress: () => context.push('${AppRoutes.recordCreate}?kind=sleep'),
      ),
      'report' => _ObservationItem(
        icon: FLucideIcons.chartColumnBig,
        title: recommendation.text,
        subtitle: l10n.todayObservationReportNote,
        tag: l10n.todayObservationReviewTag,
        onPress: () => context.go(AppRoutes.report),
      ),
      _ => _ObservationItem(
        icon: FLucideIcons.filePenLine,
        title: recommendation.text,
        subtitle: l10n.todayObservationRecordNote,
        tag: l10n.todayObservationLowConfidenceTag,
        onPress: () => context.go(AppRoutes.record),
      ),
    };
  }
}

class _ObservationLoadingState extends StatelessWidget {
  const _ObservationLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacingTokens.level4),
      child: Column(
        children: [
          _ObservationSkeletonRow(),
          SizedBox(height: AppSpacingTokens.level3),
          _ObservationSkeletonRow(),
        ],
      ),
    );
  }
}

class _ObservationSkeletonRow extends StatelessWidget {
  const _ObservationSkeletonRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
          ),
          child: const SizedBox.square(dimension: AppSpacingTokens.level6),
        ),
        const SizedBox(width: AppSpacingTokens.level3),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ObservationErrorState extends StatelessWidget {
  const _ObservationErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.level4),
      child: Row(
        children: [
          const Icon(FLucideIcons.circleAlert),
          const SizedBox(width: AppSpacingTokens.level3),
          Expanded(
            child: Text(
              l10n.todayObservationErrorTitle,
              style: AppTypographyToken.level4
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          FButton(
            onPress: onRetry,
            variant: FButtonVariant.secondary,
            size: FButtonSizeVariant.xs,
            child: Text(l10n.todayRetryAction),
          ),
        ],
      ),
    );
  }
}

class _ObservationItem {
  const _ObservationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.onPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final VoidCallback? onPress;
}
