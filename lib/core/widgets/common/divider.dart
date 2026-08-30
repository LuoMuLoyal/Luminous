import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Project-wide unified divider.
///
/// Based on [FDivider], uses theme [FColors.border] color by default and removes
/// default padding. Use [axis] to control horizontal/vertical direction, [width] to
/// override line thickness.
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.color,
    this.width,
  });

  /// Divider direction, defaults to horizontal.
  final Axis axis;

  /// Divider color, defaults to theme `border` color.
  final Color? color;

  /// Divider thickness (height when horizontal, width when vertical).
  ///
  /// When null, falls back to [FDivider] default style thickness.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return FDivider(
      axis: axis,
      style: FDividerStyleDelta.delta(
        color: color ?? SemanticColor.neutral.border(context),
        padding: const EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
        width: width,
      ),
    );
  }
}
