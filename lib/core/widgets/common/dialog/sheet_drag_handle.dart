import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Drag handle for bottom sheets.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Spacing.md),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: SemanticColor.neutral.border(context),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
        const SizedBox(height: Spacing.lg),
      ],
    );
  }
}

/// Paints the opaque sheet surface behind bottom-sheet content.
///
/// Forui's `showFSheet` provides only layout, gestures and the barrier — it
/// never paints a background for the sheet itself, so content placed directly
/// in a sheet builder renders on top of the dimmed page underneath. Every
/// `showFSheet` body must therefore be wrapped in this surface (or bring its
/// own opaque background).
///
/// Top corners stay rounded while the bottom edge runs past the viewport so the
/// sheet reads as edge-attached, matching Forui's own sheet previews.
class SheetSurface extends StatelessWidget {
  const SheetSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = context.theme.style.borderRadius.xl2;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.card,
        borderRadius: BorderRadius.only(
          topLeft: radius.topLeft,
          topRight: radius.topRight,
        ),
      ),
      child: child,
    );
  }
}
