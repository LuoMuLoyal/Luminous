import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

enum MedicineDoseAction { taken, skipped }

class MedicineHeaderActionChip extends StatelessWidget {
  const MedicineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final emphasisColor = context.theme.colors.primary;
    final colors = context.theme.colors;

    final background = emphasized ? emphasisColor : colors.background;
    final foreground = emphasized
        ? colors.primaryForeground
        : colors.foreground;

    return FButton.raw(
      onPress: onTap,
      variant: FButtonVariant.outline,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: background,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(
                  color: emphasized ? emphasisColor : colors.border,
                ),
                borderRadius: context.theme.style.borderRadius.pill,
              ),
            ),
          ),
        ]),
        contentStyle: const .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level3,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacingTokens.level2),
          Text(
            label,
            style: AppTypographyToken.level5
                .body(context)
                .copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
