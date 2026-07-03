import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

class RecordIndentedDivider extends StatelessWidget {
  const RecordIndentedDivider({
    super.key,
    required this.color,
    required this.indent,
    this.endIndent = 0,
  });

  final Color color;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return AppDivider(color: color);
  }
}

class RecordShortVerticalDivider extends StatelessWidget {
  const RecordShortVerticalDivider({
    super.key,
    required this.color,
    required this.height,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        child: AppDivider(axis: Axis.vertical, color: color),
      ),
    );
  }
}
