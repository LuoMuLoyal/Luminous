import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
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
    final colors = context.theme.colors;
    final suggestionAsync = ref.watch(todaySuggestionProvider);
    final fallback = _fallbackObservations(context, l10n);

    return TodaySection(
      title: l10n.todayObservationSectionTitle,
      subtitle: l10n.todayObservationSubtitle,
      child: FCard(
        key: const Key('today-observation-card'),
        style: todayCardStyle(context),
        child: suggestionAsync.when(
          data: (bundle) {
            final observations = bundle?.observations ?? const [];
            final items = [
              ...fallback,
              ...observations
                  .take(3)
                  .map((card) => _mapObservation(context, l10n, card)),
            ];

            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(Spacing.level4),
                child: Text(
                  l10n.todayObservationEmptyState,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _ObservationTile(item: items[i]),
                  if (i < items.length - 1)
                    Divider(height: 1, thickness: 1, color: colors.border),
                ],
              ],
            );
          },
          loading: () => const _ObservationLoadingState(),
          error: (_, __) => _ObservationErrorState(
            onRetry: () => ref.invalidate(todaySuggestionProvider),
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
          confidence: TodaySuggestionConfidence.low,
          onPress: () => openRoute(context, '/record/create?kind=sleep'),
        ),
      ];
    }

    return const [];
  }

  _ObservationItem _mapObservation(
    BuildContext context,
    AppLocalizations l10n,
    TodaySuggestionCard card,
  ) {
    return _ObservationItem(
      icon: _iconFor(card.icon),
      title: card.title,
      subtitle: card.reason,
      tag: _tagForConfidence(l10n, card.confidence),
      confidence: card.confidence,
      onPress: () => openRoute(context, card.primaryAction.route),
    );
  }
}

/// A de-emphasized tile for observations. Uses muted colors and no icon
/// background to visually differentiate from actionable suggestions.
class _ObservationTile extends StatelessWidget {
  const _ObservationTile({required this.item});

  final _ObservationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: item.onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level3,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: Spacing.level5,
              color: colors.mutedForeground,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    item.subtitle,
                    style: TypographyToken.level2
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.level2),
            _ConfidenceBadge(label: item.tag, confidence: item.confidence),
            if (item.onPress != null) ...[
              const SizedBox(width: Spacing.level2),
              Icon(
                FLucideIcons.chevronRight,
                size: Spacing.level4,
                color: colors.mutedForeground,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ObservationLoadingState extends StatelessWidget {
  const _ObservationLoadingState();

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.all(Spacing.level4),
        child: Column(
          children: [
            _ObservationSkeletonRow(),
            SizedBox(height: Spacing.level3),
            _ObservationSkeletonRow(),
          ],
        ),
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
            borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
          ),
          child: const SizedBox.square(dimension: Spacing.level6),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(RadiusTokens.level2),
                ),
              ),
              const SizedBox(height: Spacing.level2),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(RadiusTokens.level2),
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
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.all(Spacing.level4),
      child: Row(
        children: [
          Icon(FLucideIcons.circleAlert, color: colors.destructive),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(
              l10n.todayObservationErrorTitle,
              style: TypographyToken.level4
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
    required this.confidence,
    this.onPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final TodaySuggestionConfidence confidence;
  final VoidCallback? onPress;
}

/// Confidence-level badge for observation tiles.
///
/// Uses [FBadge] with different variants to visually distinguish confidence
/// levels:
/// - high → primary (solid, draws attention)
/// - medium → secondary (muted, less prominent)
/// - low → outline (minimal, de-emphasized)
class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.label, required this.confidence});

  final String label;
  final TodaySuggestionConfidence confidence;

  @override
  Widget build(BuildContext context) {
    final variant = switch (confidence) {
      TodaySuggestionConfidence.high => FBadgeVariant.primary,
      TodaySuggestionConfidence.medium => FBadgeVariant.secondary,
      TodaySuggestionConfidence.low => FBadgeVariant.outline,
    };

    return FBadge(
      variant: variant,
      child: Text(
        label,
        style: TypographyToken.level3
            .body(context)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

String _tagForConfidence(
  AppLocalizations l10n,
  TodaySuggestionConfidence confidence,
) {
  return switch (confidence) {
    TodaySuggestionConfidence.high => l10n.todayObservationReviewTag,
    TodaySuggestionConfidence.medium =>
      l10n.todayObservationMediumConfidenceTag,
    TodaySuggestionConfidence.low => l10n.todayObservationLowConfidenceTag,
  };
}

IconData _iconFor(String icon) {
  return switch (icon) {
    'droplets' => FLucideIcons.droplets,
    'moon' => FLucideIcons.moon,
    'activity' => FLucideIcons.activity,
    'coffee' => FLucideIcons.coffee,
    'user' => FLucideIcons.userRound,
    'clipboard' => FLucideIcons.clipboardList,
    'alert-triangle' => FLucideIcons.triangleAlert,
    'pill' => FLucideIcons.pill,
    'trending-up' => FLucideIcons.trendingUp,
    'lightbulb' => FLucideIcons.lightbulb,
    'info' => FLucideIcons.info,
    _ => FLucideIcons.sparkles,
  };
}
