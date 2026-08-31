import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Drag handle for bottom sheets.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Spacing.level3),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: SemanticColor.neutral.border(context),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
        const SizedBox(height: Spacing.level4),
      ],
    );
  }
}
