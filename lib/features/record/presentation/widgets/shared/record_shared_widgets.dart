import 'package:flutter/material.dart';

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
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
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
        child: VerticalDivider(width: 1, thickness: 1, color: color),
      ),
    );
  }
}
