import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Lightweight source badge shown next to the detail title.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: 1,
        ),
        child: Text(
          label,
          style: context.theme.typography.body.xs3.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ),
    );
  }
}
