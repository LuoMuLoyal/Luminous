import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A single metric cell for the risk-check metric grid.
///
/// Replaces the old [FCard]-wrapped [MedicineRiskMetricChip]. Each cell is a
/// flat container with an optional right divider, displaying a large value
/// and a muted label. The value colour is driven by [color].
class RiskMetricCell extends StatelessWidget {
  const RiskMetricCell({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
    this.showRightDivider = true,
  });

  final String label;
  final String value;
  final SemanticColor? color;
  final VoidCallback? onTap;
  final bool showRightDivider;

  @override
  Widget build(BuildContext context) {
    final cell = Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showRightDivider
              ? Border(right: BorderSide(color: context.theme.colors.border))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level3,
            vertical: Spacing.level2,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TypographyToken.level7
                    .display(context)
                    .copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      color: color?.solid(context),
                    ),
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                label,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: context.theme.colors.mutedForeground),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return cell;
    return FTappable(onPress: onTap, child: cell);
  }
}
