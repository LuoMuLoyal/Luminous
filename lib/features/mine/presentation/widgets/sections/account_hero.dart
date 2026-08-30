import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineAccountHero extends StatelessWidget {
  const MineAccountHero({super.key, required this.dashboard});

  final MineDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final account = dashboard.account;
    final isPreview = !account.isAuthenticated;
    final name = account.displayName?.trim().isNotEmpty == true
        ? account.displayName?.trim() ?? ''
        : mineCopy(l10n, account.displayNameKey);
    final gaps = _deriveGaps(dashboard.profile);
    final gapCount = gaps.length;
    final isIncomplete = !isPreview && gapCount > 0;

    final title = isPreview
        ? l10n.mineReadinessPreviewTitle
        : isIncomplete
        ? l10n.mineReadinessIncompleteTitle(gapCount)
        : l10n.mineReadinessReadyTitle;
    final description = _buildDescription(l10n, isPreview, isIncomplete, gaps);
    final actionLabel = isPreview
        ? l10n.authGoLogin
        : isIncomplete
        ? l10n.mineCompletenessGapAction
        : l10n.mineReadinessManageAction;

    return FCard(
      key: const Key('mine-account-manage-link'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AvatarPlaceholder(),
                const SizedBox(width: Spacing.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.theme.typography.display.xl.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.level2),
                      Wrap(
                        spacing: Spacing.level2,
                        runSpacing: Spacing.level2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StateBadge(
                            label: isPreview
                                ? l10n.mineReadinessPreviewBadge
                                : account.emailVerified
                                ? l10n.mineAccountEmailVerified
                                : l10n.mineAccountEmailUnverified,
                            preview: isPreview,
                            verified: account.emailVerified,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              title,
              style: context.theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              description,
              style: context.theme.typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
                height: 1.45,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              children: [
                Text(
                  mineCopy(l10n, dashboard.completion.titleKey),
                  style: context.theme.typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(width: Spacing.level2),
                SkeletonSlot(
                  skeleton: InlineSkeletonBlock(
                    height: 22,
                    width: 42,
                    radius: context.theme.style.borderRadius.xs.topLeft.x,
                  ),
                  child: Text(
                    dashboard.completion.percentLabel,
                    style: context.theme.typography.body.md.copyWith(
                      color: SemanticColor.primary.solid(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            SkeletonSlot(
              skeleton: InlineSkeletonBlock(
                height: 8,
                radius: context.theme.style.borderRadius.pill.topLeft.x,
              ),
              child: ClipRRect(
                borderRadius: context.theme.style.borderRadius.pill,
                child: FDeterminateProgress(
                  value: dashboard.completion.progress,
                ),
              ),
            ),
            if (gaps.isNotEmpty) ...[
              const SizedBox(height: Spacing.level3),
              Wrap(
                spacing: Spacing.level2,
                runSpacing: Spacing.level2,
                children: [
                  for (final gap in gaps.take(2))
                    FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Text(gap.label(l10n)),
                    ),
                  if (gapCount > 2)
                    FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Text(l10n.mineReadinessGapMore(gapCount - 2)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: Spacing.level4),
            SizedBox(
              width: double.infinity,
              child: FButton(
                key: const Key('mine-readiness-action'),
                variant: isPreview
                    ? FButtonVariant.outline
                    : FButtonVariant.primary,
                onPress: () => _handlePrimaryAction(context, isPreview, gaps),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a dynamic description based on which specific gaps exist.
  String _buildDescription(
    AppLocalizations l10n,
    bool isPreview,
    bool isIncomplete,
    List<_ReadinessGap> gaps,
  ) {
    if (isPreview) {
      return l10n.mineReadinessPreviewDescription;
    }
    if (!isIncomplete) {
      return l10n.mineReadinessReadyDescription;
    }

    // If only one gap, show its specific description
    if (gaps.length == 1) {
      return switch (gaps.first.type) {
        _ReadinessGapType.basicInfo => l10n.mineReadinessGapDescBasicInfo,
        _ReadinessGapType.sexAtBirth => l10n.mineReadinessGapDescSexAtBirth,
        _ReadinessGapType.weight => l10n.mineReadinessGapDescWeight,
        _ReadinessGapType.allergy => l10n.mineReadinessGapDescAllergy,
        _ReadinessGapType.medicine => l10n.mineReadinessGapDescMedicine,
      };
    }

    // Multiple gaps — show a combined summary
    final labels = gaps.map((g) => g.label(l10n)).toList();
    if (labels.length <= 3) {
      return l10n.mineReadinessGapDescMultiple(labels.join('、'));
    }
    return l10n.mineReadinessGapDescMultiple(
      '${labels.sublist(0, 3).join('、')}等',
    );
  }

  void _handlePrimaryAction(
    BuildContext context,
    bool isPreview,
    List<_ReadinessGap> gaps,
  ) {
    if (isPreview) {
      unawaited(context.push(loginRouteForCurrentLocation(context)));
      return;
    }
    final route = gaps.isNotEmpty ? gaps.first.route : Routes.mineProfileEdit;
    unawaited(pushAuthRequiredRoute(context, route));
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return SizedBox.square(
      dimension: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: SemanticColor.neutral.border(context)),
            ),
            child: SizedBox.square(
              dimension: 64,
              child: Icon(
                SemanticIcons.profileUser,
                color: SemanticColor.neutral.solid(context),
                size: 32,
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SemanticColor.primary.solid(context),
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.level1),
                child: Icon(
                  SemanticIcons.actionEdit,
                  color: SemanticColor.primary.foreground(context),
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({
    required this.label,
    required this.preview,
    required this.verified,
  });

  final String label;
  final bool preview;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    // Preview badge: secondary variant (grey)
    if (preview) {
      return FBadge(
        variant: FBadgeVariant.secondary,
        child: Text(
          label,
          style: context.theme.typography.body.xs.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // Authenticated: show email verification status
    // Verified: primary (blue) with white text
    // Unverified: secondary with warning color text
    if (verified) {
      return FBadge(
        variant: FBadgeVariant.primary,
        child: Text(
          label,
          style: context.theme.typography.body.xs.copyWith(
            fontWeight: FontWeight.w700,
            color: SemanticColor.primary.foreground(context),
          ),
        ),
      );
    }

    return FBadge(
      variant: FBadgeVariant.secondary,
      child: Text(
        label,
        style: context.theme.typography.body.xs.copyWith(
          fontWeight: FontWeight.w700,
          color: SemanticColor.warning.solid(context),
        ),
      ),
    );
  }
}

enum _ReadinessGapType { basicInfo, sexAtBirth, weight, allergy, medicine }

class _ReadinessGap {
  const _ReadinessGap({required this.type, required this.route});

  final _ReadinessGapType type;
  final String route;

  String label(AppLocalizations l10n) {
    return switch (type) {
      _ReadinessGapType.basicInfo => l10n.mineCompletenessGapBasicInfo,
      _ReadinessGapType.sexAtBirth => l10n.mineCompletenessGapSexAtBirth,
      _ReadinessGapType.weight => l10n.mineCompletenessGapWeight,
      _ReadinessGapType.allergy => l10n.mineCompletenessGapAllergy,
      _ReadinessGapType.medicine => l10n.mineCompletenessGapMedicine,
    };
  }
}

List<_ReadinessGap> _deriveGaps(MineProfileSnapshot profile) {
  return [
    if (!profile.basicInfoCompleted)
      const _ReadinessGap(
        type: _ReadinessGapType.basicInfo,
        route: Routes.mineProfileEdit,
      ),
    if (profile.sexAtBirth == null)
      const _ReadinessGap(
        type: _ReadinessGapType.sexAtBirth,
        route: Routes.mineProfileEdit,
      ),
    if (profile.weightKg == null)
      const _ReadinessGap(
        type: _ReadinessGapType.weight,
        route: Routes.mineProfileEdit,
      ),
    if (profile.allergyCount == 0)
      const _ReadinessGap(
        type: _ReadinessGapType.allergy,
        route: Routes.mineAllergyNew,
      ),
    if (profile.currentMedicineCount == 0)
      const _ReadinessGap(
        type: _ReadinessGapType.medicine,
        route: Routes.mineMedicineNew,
      ),
  ];
}
