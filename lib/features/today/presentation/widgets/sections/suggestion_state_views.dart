import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Empty state shown when no suggestion is available.
class SuggestionEmptyState extends StatelessWidget {
  const SuggestionEmptyState({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: todayCardStyle(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level6,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SemanticIcons.aiEntry,
                size: IconSizeTokens.level6,
                color: context.theme.colors.mutedForeground,
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.todaySuggestionEmptyTitle,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.todaySuggestionEmptySubtitle,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: context.theme.colors.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading state for the primary suggestion section.
///
/// Mirrors the real [SuggestionPrimaryCard] structure: header area with
/// icon + title lines, body with reason lines, and an action row.
class SuggestionSkeleton extends StatelessWidget {
  const SuggestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return SkeletonShimmer(
      child: FCard(
        style: todayCardStyle(context),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon + title
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(RadiusTokens.level3),
                    ),
                    child: const SizedBox.square(dimension: Spacing.level7),
                  ),
                  const SizedBox(width: Spacing.level3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.level2,
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.level2),
                        Container(
                          height: 12,
                          width: 120,
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.level2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level4),
              // Reason lines
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(RadiusTokens.level2),
                ),
              ),
              const SizedBox(height: Spacing.level2),
              Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(RadiusTokens.level2),
                ),
              ),
              const SizedBox(height: Spacing.level5),
              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(
                        RadiusTokens.levelFull,
                      ),
                    ),
                    child: const SizedBox(width: 80, height: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state for the primary suggestion section.
class SuggestionErrorState extends StatelessWidget {
  const SuggestionErrorState({
    super.key,
    required this.l10n,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: todayCardStyle(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level6,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SemanticIcons.statusError,
                size: IconSizeTokens.level6,
                color: context.theme.colors.mutedForeground,
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.todaySuggestionErrorHint,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(color: context.theme.colors.mutedForeground),
              ),
              const SizedBox(height: Spacing.level3),
              FButton(
                onPress: onRetry,
                variant: FButtonVariant.secondary,
                size: FButtonSizeVariant.sm,
                child: Text(l10n.todaySuggestionRetryAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight status notice shown below a retained suggestion card.
class SuggestionMaterializationNotice extends StatelessWidget {
  const SuggestionMaterializationNotice({
    super.key,
    required this.status,
    required this.computedAt,
    required this.l10n,
    this.onRetry,
  });

  final TodaySuggestionMaterializationStatus status;
  final DateTime? computedAt;
  final AppLocalizations l10n;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final message = switch (status) {
      TodaySuggestionMaterializationStatus.pending =>
        l10n.todaySuggestionLoadingHint,
      TodaySuggestionMaterializationStatus.stale =>
        computedAt != null
            ? l10n.todayUpdatedAt(
                DateFormat.Hm(l10n.localeName).format(computedAt!.toLocal()),
              )
            : l10n.todaySuggestionLoadingHint,
      TodaySuggestionMaterializationStatus.failed =>
        l10n.todaySuggestionErrorHint,
      _ => null,
    };

    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.level2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TypographyToken.level2
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
          if (status == TodaySuggestionMaterializationStatus.failed &&
              onRetry != null) ...[
            const SizedBox(width: Spacing.level2),
            FButton(
              onPress: onRetry,
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.xs,
              child: Text(l10n.todaySuggestionRetryAction),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact error state for the secondary suggestions section.
class SecondarySuggestionErrorState extends StatelessWidget {
  const SecondarySuggestionErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TodaySection(
      title: l10n.todaySecondarySuggestionSectionTitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level5,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SemanticIcons.statusError,
                size: IconSizeTokens.level4,
                color: context.theme.colors.mutedForeground,
              ),
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.todaySuggestionSecondaryErrorHint,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: context.theme.colors.mutedForeground),
              ),
              const SizedBox(height: Spacing.level2),
              FButton(
                onPress: onRetry,
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.xs,
                child: Text(l10n.todaySuggestionRetryAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading state for the secondary suggestions section.
///
/// Renders 1-2 placeholder rows matching the real secondary suggestion card
/// structure so the loading-to-loaded transition doesn't cause a layout jump.
class SecondarySuggestionSkeleton extends StatelessWidget {
  const SecondarySuggestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return TodaySection(
      title: AppLocalizations.of(context)!.todaySecondarySuggestionSectionTitle,
      child: SkeletonShimmer(
        child: Column(
          children: [
            for (var i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(height: Spacing.level3),
              FCard(
                style: todayCardStyle(context, tone: TodayCardTone.soft),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.level3,
                          ),
                        ),
                        child: const SizedBox.square(dimension: Spacing.level7),
                      ),
                      const SizedBox(width: Spacing.level3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: colors.secondary,
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.level2,
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.level2),
                            Container(
                              height: 12,
                              width: 140,
                              decoration: BoxDecoration(
                                color: colors.secondary,
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.level2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
