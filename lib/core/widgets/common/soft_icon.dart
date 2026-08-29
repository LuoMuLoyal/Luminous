import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:luminous/core/design/design.dart';

/// Visual variant for [SoftIcon].
enum SoftIconVariant {
  /// Very faint background (alpha 0.04–0.06). Default — softer than [tint].
  subtle,

  /// Gradient background using [GradientTokens.semanticFill]. Rich visual weight.
  gradient,

  /// Tinted background (alpha 0.08–0.12). Legacy muted behavior.
  tint,
}

/// Soft-tinted icon container with rounded background.
///
/// Used in mine module's archive/status rows and notification tiles.
/// The [variant] parameter controls background intensity:
/// - [SoftIconVariant.subtle] (default): faintest background, for general use.
/// - [SoftIconVariant.gradient]: rich gradient fill, for hero/featured items.
/// - [SoftIconVariant.tint]: legacy muted background, for backward compat.
///
/// When [duotone] is true and [icon] is an [FPhosphorDuotoneIconData],
/// the icon is rendered with [FPhosphorDuotoneIcon] for two-layer depth.
class SoftIcon extends StatelessWidget {
  const SoftIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44.0,
    this.iconSize = IconSizeTokens.level4,
    this.variant = SoftIconVariant.subtle,
    this.duotone = false,
  });

  /// Icon to display. When [duotone] is true, this should be an
  /// [FPhosphorDuotoneIconData] from [FPhosphorDuotoneIcons].
  final Object icon;

  final SemanticColor color;

  /// Container size.
  final double size;

  /// Icon size, defaults to [IconSizeTokens.level4] (24px).
  final double iconSize;

  /// Background variant.
  final SoftIconVariant variant;

  /// Whether to render the icon as a Phosphor duotone icon.
  /// When true, [icon] must be an [FPhosphorDuotoneIconData].
  final bool duotone;

  @override
  Widget build(BuildContext context) {
    final palette = color.palette(context);

    final Color background;
    switch (variant) {
      case SoftIconVariant.subtle:
        background = palette.subtle;
      case SoftIconVariant.gradient:
        background = GradientTokens.semanticFill(
          palette,
        ).colors.first.withValues(alpha: 0.15);
      case SoftIconVariant.tint:
        background = palette.muted;
    }

    final resolvedColor = color.solid(context);

    Widget iconWidget;
    if (duotone && icon is FPhosphorDuotoneIconData) {
      iconWidget = FPhosphorDuotoneIcon(
        icon as FPhosphorDuotoneIconData,
        size: iconSize,
        color: resolvedColor,
      );
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: resolvedColor, size: iconSize);
    } else {
      // duotone=true but icon is not FPhosphorDuotoneIconData, or
      // duotone=false but icon is not a regular IconData — fail explicitly.
      assert(
        false,
        'SoftIcon: icon must be IconData (when duotone=false) or '
        'FPhosphorDuotoneIconData (when duotone=true). Got: ${icon.runtimeType}',
      );
      iconWidget = Icon(
        SemanticIcons.actionHelp,
        color: resolvedColor,
        size: iconSize,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RadiusTokens.level4),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: iconWidget),
      ),
    );
  }
}
