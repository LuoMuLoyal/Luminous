import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = AppSpacingTokens.x3l,
    this.iconSize = AppSpacingTokens.lg,
    this.shape = BoxShape.rectangle,
  });

  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppRadiusTokens.lg)
            : null,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}
