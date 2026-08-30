import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

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
            side: BorderSide(color: SemanticColor.neutral.border(context)),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
        labelTextStyle: .delta(color: SemanticColor.neutral.solid(context)),
      ),
      child: Text(label),
    );
  }
}
