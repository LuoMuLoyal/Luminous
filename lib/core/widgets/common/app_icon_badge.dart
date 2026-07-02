import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = AppSpacingTokens.level8,
    this.iconSize = AppSpacingTokens.level5,
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
    if (shape == BoxShape.circle) {
      return FAvatar.raw(
        size: size,
        child: Icon(icon, color: color, size: iconSize),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppRadiusTokens.level4)
            : null,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}
