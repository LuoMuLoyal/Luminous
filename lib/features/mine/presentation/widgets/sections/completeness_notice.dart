import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Surfaces specific profile-completeness gaps and their safety impact.
///
/// Derives gaps from [MineProfileSnapshot] fields without requiring entity
/// changes. Only renders when at least one gap exists; returns
/// [SizedBox.shrink] when the profile is complete.
class MineCompletenessNotice extends StatelessWidget {
  const MineCompletenessNotice({super.key, required this.profile});

  final MineProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    final gaps = _deriveGaps(profile);
    if (gaps.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineCompletenessGapTitle),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FLucideIcons.circleAlert,
                      size: 16,
                      color: colors.destructive,
                    ),
                    const SizedBox(width: AppSpacingTokens.level2),
                    Expanded(
                      child: Text(
                        l10n.mineCompletenessGapSubtitle,
                        style: AppTypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level3),
                for (var i = 0; i < gaps.length; i++) ...[
                  if (i > 0) const AppDivider(),
                  _GapRow(gap: gaps[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Derives completeness gaps from existing [MineProfileSnapshot] fields.
  static List<_CompletenessGap> _deriveGaps(MineProfileSnapshot profile) {
    return [
      if (!profile.basicInfoCompleted)
        const _CompletenessGap(
          type: _GapType.basicInfo,
          route: AppRoutes.mineProfileEdit,
        ),
      if (profile.allergyCount == 0)
        const _CompletenessGap(
          type: _GapType.allergy,
          route: AppRoutes.mineAllergyNew,
        ),
      if (profile.currentMedicineCount == 0)
        const _CompletenessGap(
          type: _GapType.medicine,
          route: AppRoutes.mineMedicineNew,
        ),
    ];
  }
}

enum _GapType { basicInfo, allergy, medicine }

class _CompletenessGap {
  const _CompletenessGap({required this.type, required this.route});

  final _GapType type;
  final String route;
}

class _GapRow extends StatelessWidget {
  const _GapRow({required this.gap});

  final _CompletenessGap gap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final (icon, title, desc) = switch (gap.type) {
      _GapType.basicInfo => (
        FLucideIcons.badge,
        l10n.mineCompletenessGapBasicInfo,
        l10n.mineCompletenessGapBasicInfoDesc,
      ),
      _GapType.allergy => (
        FLucideIcons.droplets,
        l10n.mineCompletenessGapAllergy,
        l10n.mineCompletenessGapAllergyDesc,
      ),
      _GapType.medicine => (
        FLucideIcons.pill,
        l10n.mineCompletenessGapMedicine,
        l10n.mineCompletenessGapMedicineDesc,
      ),
    };

    return FTappable(
      onPress: () => pushAuthRequiredRoute(context, gap.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level3),
        child: Row(
          children: [
            SoftIcon(icon: icon, color: AppColors.destructive),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    desc,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(
                height: 28,
                width: 56,
                radius: AppRadiusTokens.level2,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level3,
                  vertical: AppSpacingTokens.level1,
                ),
                child: Text(
                  l10n.mineCompletenessGapAction,
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: colors.destructive,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
