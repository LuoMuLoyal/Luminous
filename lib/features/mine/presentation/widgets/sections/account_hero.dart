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
    final colors = context.theme.colors;

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
    final description = isPreview
        ? l10n.mineReadinessPreviewDescription
        : isIncomplete
        ? l10n.mineReadinessIncompleteDescription
        : l10n.mineReadinessReadyDescription;
    final actionLabel = isPreview
        ? l10n.authGoLogin
        : isIncomplete
        ? l10n.mineCompletenessGapAction
        : l10n.mineReadinessManageAction;

    return FCard.raw(
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
                        style: TypographyToken.level7
                            .display(context)
                            .copyWith(fontWeight: FontWeight.w800),
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
                                : l10n.mineReadinessSignedInBadge,
                            preview: isPreview,
                          ),
                          Text(
                            mineCopy(l10n, account.roleKey),
                            style: TypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.mutedForeground),
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
              style: TypographyToken.level6
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              description,
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(color: colors.mutedForeground, height: 1.45),
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              children: [
                Text(
                  mineCopy(l10n, dashboard.completion.titleKey),
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(width: Spacing.level2),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 22,
                    width: 42,
                    radius: RadiusTokens.level2,
                  ),
                  child: Text(
                    dashboard.completion.percentLabel,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(
                height: 8,
                radius: RadiusTokens.levelFull,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
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

  void _handlePrimaryAction(
    BuildContext context,
    bool isPreview,
    List<_ReadinessGap> gaps,
  ) {
    if (isPreview) {
      context.push(loginRouteForCurrentLocation(context));
      return;
    }
    final route = gaps.isNotEmpty
        ? gaps.first.route
        : AppRoutes.mineProfileEdit;
    pushAuthRequiredRoute(context, route);
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
              border: Border.all(color: colors.border),
            ),
            child: SizedBox.square(
              dimension: 64,
              child: Icon(
                FLucideIcons.userRound,
                color: colors.mutedForeground,
                size: 32,
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  FLucideIcons.pencil,
                  color: colors.primaryForeground,
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
  const _StateBadge({required this.label, required this.preview});

  final String label;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: preview ? FBadgeVariant.secondary : FBadgeVariant.primary,
      child: Text(
        label,
        style: TypographyToken.level3
            .body(context)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _ReadinessGapType { basicInfo, allergy, medicine }

class _ReadinessGap {
  const _ReadinessGap({required this.type, required this.route});

  final _ReadinessGapType type;
  final String route;

  String label(AppLocalizations l10n) {
    return switch (type) {
      _ReadinessGapType.basicInfo => l10n.mineCompletenessGapBasicInfo,
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
        route: AppRoutes.mineProfileEdit,
      ),
    if (profile.allergyCount == 0)
      const _ReadinessGap(
        type: _ReadinessGapType.allergy,
        route: AppRoutes.mineAllergyNew,
      ),
    if (profile.currentMedicineCount == 0)
      const _ReadinessGap(
        type: _ReadinessGapType.medicine,
        route: AppRoutes.mineMedicineNew,
      ),
  ];
}
