import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

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
      child: FButton.raw(
        onPress: onTap,
        variant: FButtonVariant.outline,
        style: .delta(
          decoration: .delta([
            .all(
              .shapeDelta(
                color: onTap == null
                    ? colors.background.withValues(alpha: 0.72)
                    : colors.background,
                shape: CircleBorder(side: BorderSide(color: colors.border)),
              ),
            ),
          ]),
          contentStyle: .delta(
            padding: .value(const EdgeInsets.all(AppSpacingTokens.level3)),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? colors.mutedForeground.withValues(alpha: 0.5)
              : colors.foreground,
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
    final row = FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.foreground),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: AppSpacingTokens.level3),
              Text(
                value!,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
            const SizedBox(width: AppSpacingTokens.level2),
            Icon(
              FLucideIcons.chevronRight,
              size: 18,
              color: colors.mutedForeground,
            ),
          ],
        ),
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        AppDivider(color: colors.border),
      ],
    );
  }
}

void showMineToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  AppToast.show(context, l10n.mineActionToast(action));
}
