import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

class MineStatusOverview extends StatelessWidget {
  const MineStatusOverview({super.key, required this.dashboard});

  final MineDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
      key: const Key('mine-status-overview'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level4,
        ),
        child: Row(
          children: [
            for (
              var index = 0;
              index < dashboard.alerts.length;
              index += 1
            ) ...[
              Expanded(
                child: _StatusOverviewItem(entry: dashboard.alerts[index]),
              ),
              if (index != dashboard.alerts.length - 1)
                Container(
                  width: 1,
                  height: 58,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.level2,
                  ),
                  color: colors.border,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusOverviewItem extends StatelessWidget {
  const _StatusOverviewItem({required this.entry});

  final MineStatusCard entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FTappable(
      onPress: () =>
          pushAuthRequiredRoute(context, _routeForStatus(entry.titleKey)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level1,
        ),
        child: Column(
          children: [
            SoftIcon(
              icon: entry.icon,
              color: entry.accent,
              size: 42,
              iconSize: 23,
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            Text(
              mineCopy(l10n, entry.titleKey),
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacingTokens.level1),
            AppSkeletonText(
              text: mineCopy(l10n, entry.subtitleKey),
              style: AppTypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              height: 14,
              widthFactor: 0.72,
            ),
            const SizedBox(height: AppSpacingTokens.level2),
            AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(
                height: 20,
                width: 44,
                radius: AppRadiusTokens.level2,
              ),
              child: _TinyBadge(
                label: mineCopy(l10n, entry.badgeKey),
                color: entry.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _routeForStatus(MineCopyKey titleKey) {
  return switch (titleKey) {
    MineCopyKey.alertAllergyTitle => AppRoutes.mineAllergyNew,
    MineCopyKey.alertMedicineTitle => AppRoutes.mineMedicineNew,
    MineCopyKey.alertPrivacyTitle || _ => AppRoutes.account,
  };
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label, required this.color});

  final String label;
  final AppColors color;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final resolvedColor = color.resolve(colors);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level2,
          vertical: AppSpacingTokens.level1,
        ),
        child: Text(
          label,
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(color: resolvedColor, fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
