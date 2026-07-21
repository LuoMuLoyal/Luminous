import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AssistantToolChip extends StatelessWidget {
  const AssistantToolChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FBadge(
      variant: FBadgeVariant.secondary,
      style: .delta(
        decoration: .shapeDelta(
          color: colors.secondary,
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
        labelTextStyle: .delta(color: colors.mutedForeground),
      ),
      child: Text(label),
    );
  }
}
