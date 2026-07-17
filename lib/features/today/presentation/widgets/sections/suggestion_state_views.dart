import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Empty state shown when no suggestion is available.
class SuggestionEmptyState extends StatelessWidget {
  const SuggestionEmptyState({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level6,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.sparkles,
              size: Spacing.level8,
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
    );
  }
}

/// Skeleton loading state for the primary suggestion section.
class SuggestionSkeleton extends StatelessWidget {
  const SuggestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: context.theme.colors.card,
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
          border: Border.all(color: context.theme.colors.border),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level6,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.circleAlert,
              size: Spacing.level8,
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
                FLucideIcons.circleAlert,
                size: Spacing.level6,
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
