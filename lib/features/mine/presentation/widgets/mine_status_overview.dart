import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineStatusOverview extends StatelessWidget {
  const MineStatusOverview({
    super.key,
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final MineDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      surface: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.lg,
      ),
      child: Row(
        children: [
          for (var index = 0; index < dashboard.alerts.length; index += 1) ...[
            Expanded(
              child: _StatusOverviewItem(
                entry: dashboard.alerts[index],
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ),
            if (index != dashboard.alerts.length - 1)
              Container(
                width: 1,
                height: 58,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.xs,
                ),
                color: surface.hairline,
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusOverviewItem extends StatelessWidget {
  const _StatusOverviewItem({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final MineStatusCard entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
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
                style: typography.bodySmStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: mineCopy(l10n, entry.subtitleKey),
                style: typography.caption.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
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
                  typography: typography,
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
  Widget build(BuildContext context) => DecoratedBox(
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

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({
    required this.label,
    required this.color,
    required this.typography,
  });
  final String label;
  final Color color;
  final AppTypographyScale typography;
  @override
  Widget build(BuildContext context) => DecoratedBox(
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
        style: typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
