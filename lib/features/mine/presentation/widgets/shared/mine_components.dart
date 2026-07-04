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
    return FTooltip(
      tipBuilder: (context, controller) => Text(label),
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
          contentStyle: const .delta(
            padding: .value(EdgeInsets.all(AppSpacingTokens.level3)),
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

void showMineToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  AppToast.show(context, l10n.mineActionToast(action));
}
