import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.axis = Axis.horizontal, this.color});

  final Axis axis;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FDivider(
      axis: axis,
      style: FDividerStyleDelta.delta(
        color: color ?? context.theme.colors.border,
        padding: const EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
      ),
    );
  }
}
