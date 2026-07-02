import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.lg,
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
                    horizontal: AppSpacingTokens.xs,
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
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            pushAuthRequiredRoute(context, _routeForStatus(entry.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xxs),
          child: Column(
            children: [
              _SoftIcon(
                icon: entry.icon,
                color: entry.accent,
                size: 42,
                iconSize: 23,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                mineCopy(l10n, entry.titleKey),
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: mineCopy(l10n, entry.subtitleKey),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                height: 14,
                widthFactor: 0.72,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              AppSkeletonSlot(
                skeleton: const AppInlineSkeletonBlock(
                  height: 20,
                  width: 44,
                  radius: AppRadiusTokens.sm,
                ),
                child: _TinyBadge(
                  label: mineCopy(l10n, entry.badgeKey),
                  color: entry.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _routeForStatus(MineCopyKey titleKey) {
  return switch (titleKey) {
    MineCopyKey.alertAllergyTitle => '/mine/allergy/new',
    MineCopyKey.alertMedicineTitle => '/mine/medicine/new',
    MineCopyKey.alertPrivacyTitle || _ => '/account',
  };
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
