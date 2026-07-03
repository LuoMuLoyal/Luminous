import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';

/// A thin wrapper around Forui's [FAvatar.raw] for circular icons and a
/// Forui-styled badge-like container for rectangular icons.
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
  final AppColors color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final resolvedColor = color.resolve(colors);

    if (shape == BoxShape.circle) {
      return FAvatar.raw(
        size: size,
        child: Icon(icon, color: resolvedColor, size: iconSize),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? resolvedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
      ),
      child: Center(
        child: Icon(icon, color: resolvedColor, size: iconSize),
      ),
    );
  }
}
