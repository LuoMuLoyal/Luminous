import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineHeaderActionChip extends StatelessWidget {
  const MineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
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
                  ? colors.background.withValues(alpha: 0.72)
                  : colors.background,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.sm),
              child: Icon(
                icon,
                size: 18,
                color: onTap == null
                    ? colors.mutedForeground.withValues(alpha: 0.5)
                    : colors.foreground,
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
    this.value,
    required this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
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
              Icon(icon, size: 18, color: colors.foreground),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  value!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                FLucideIcons.chevronRight,
                size: 18,
                color: colors.mutedForeground,
              ),
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
        Divider(height: 1, color: colors.border),
      ],
    );
  }
}

class MineProgressRing extends StatelessWidget {
  const MineProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.icon = FLucideIcons.badgeCheck,
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
