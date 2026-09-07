import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';

/// Renders a labeled/value row list separated by [AppDivider]s.
class DetailRows extends StatelessWidget {
  const DetailRows({super.key, required this.rows});

  final List<DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < rows.length; index += 1) ...[
          DetailRow(data: rows[index]),
          if (index != rows.length - 1) const AppDivider(),
        ],
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.data});

  final DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: Spacing.level8 * 2,
              maxWidth: Spacing.level8 * 2 + Spacing.level4,
            ),
            child: Text(
              data.label,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Text(
              data.value,
              style: data.highlight
                  ? typography.display.lg.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SemanticColor.primary.solid(context),
                    )
                  : typography.body.md.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRowData {
  const DetailRowData(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;

  /// Renders the value at a larger, primary-colored size (receipt-style
  /// emphasis for the record's key number).
  final bool highlight;
}
