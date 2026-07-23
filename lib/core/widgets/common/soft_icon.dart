import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// 柔和色调的图标容器，用于 mine 模块的归档/状态行。
class SoftIcon extends StatelessWidget {
  const SoftIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44.0,
    this.iconSize = 22.0,
  });

  final IconData icon;
  final SemanticColor color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color.solid(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level4),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: resolvedColor, size: iconSize),
      ),
    );
  }
}
