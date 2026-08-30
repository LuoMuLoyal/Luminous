import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class SleepMergeSummaryRow extends StatelessWidget {
  const SleepMergeSummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(child: Text(value, style: typography.body.sm)),
      ],
    );
  }
}
