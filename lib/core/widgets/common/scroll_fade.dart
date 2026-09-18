import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Adds a trailing fade to a horizontally scrolling row of chips or cards.
///
/// A horizontally scrollable strip whose last item is cut off at the viewport
/// edge gives no hint that more content exists. The fade marks the boundary so
/// the row reads as scrollable rather than clipped. Purely decorative: it does
/// not intercept hit tests, and it is skipped for right-to-left layouts where
/// the visual "more" edge is the other side.
class HorizontalScrollFade extends StatelessWidget {
  const HorizontalScrollFade({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;

  /// Colour the gradient fades to. Defaults to the scaffold background so the
  /// fade matches whatever the strip is drawn on.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (Directionality.of(context) == TextDirection.rtl) {
      return child;
    }

    final fadeTo = backgroundColor ?? context.theme.colors.background;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      // The shader callback runs during paint, where no `Directionality` is
      // available, so the gradient is built from a resolved begin/end here.
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [fadeTo, fadeTo, fadeTo.withValues(alpha: 0)],
        // Hold full opacity until the last stretch so only the disappearing
        // edge is affected.
        stops: const [0.0, 0.85, 1.0],
      ).createShader(bounds),
      child: child,
    );
  }
}
