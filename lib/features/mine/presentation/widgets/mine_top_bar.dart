import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineTopBar extends StatelessWidget {
  const MineTopBar({super.key, required this.onNotificationsTap, required this.onSettingsTap});

  final VoidCallback onNotificationsTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.tabMine,
            style: typography.displayXl.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        _IconActionButton(
          tooltip: l10n.mineHeaderNotifications,
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          showBadge: true,
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        _IconActionButton(
          key: const Key('mine-settings-action'),
          tooltip: l10n.mineHeaderSettings,
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({super.key, required this.tooltip, required this.icon, required this.onTap, this.showBadge = false});
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: SizedBox.square(
            dimension: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.onSurface),
                if (showBadge)
                  Positioned(
                    right: AppSpacingTokens.xs,
                    top: AppSpacingTokens.xs,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: surface.canvas, width: 2),
                      ),
                      child: const SizedBox.square(dimension: 10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
