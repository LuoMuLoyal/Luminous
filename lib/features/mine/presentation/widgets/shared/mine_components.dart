import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineHeaderActionChip extends StatelessWidget {
  const MineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.typography,
    required this.surface,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: onTap == null
                  ? surface.canvas.withValues(alpha: 0.72)
                  : surface.canvas,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: surface.hairline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.sm),
              child: Icon(
                icon,
                size: 18,
                color: onTap == null
                    ? surface.body.withValues(alpha: 0.5)
                    : surface.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MineSettingRow extends StatelessWidget {
  const MineSettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.typography,
    required this.surface,
    this.value,
    required this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.sm,
            vertical: AppSpacingTokens.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: surface.body),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: typography.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  value!,
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
              ],
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(Icons.chevron_right_rounded, size: 18, color: surface.mute),
            ],
          ),
        ),
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}

class MineProgressRing extends StatelessWidget {
  const MineProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.icon = Icons.verified_user_outlined,
    this.size = 54,
  });

  final double progress;
  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Icon(icon, size: 22, color: color),
        ],
      ),
    );
  }
}

void showMineToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  AppToast.show(context, l10n.mineActionToast(action));
}
