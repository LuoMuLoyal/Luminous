import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// A wrapper that provides hover feedback on desktop layouts.
///
/// On screens with width >= [Breakpoints.desktop], this widget:
/// - Tracks mouse hover state via [MouseRegion].
/// - Animates the background color and border to a slightly brighter tone.
/// - Sets the mouse cursor to [SystemMouseCursors.click].
///
/// On mobile (width < [Breakpoints.desktop]) this widget is a pass-through
/// — the child is returned directly with no extra widget overhead.
///
/// Usage:
/// ```dart
/// DesktopHoverCard(
///   child: FCard(child: ...),
/// )
/// ```
class DesktopHoverCard extends StatefulWidget {
  const DesktopHoverCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  State<DesktopHoverCard> createState() => _DesktopHoverCardState();
}

class _DesktopHoverCardState extends State<DesktopHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.desktop) {
      return widget.child;
    }

    final radius = widget.borderRadius ?? RadiusTokens.level5;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DurationTokens.widgetQuick,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isHovered
                ? SemanticColor.primary.subtle(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            border: _isHovered
                ? Border.all(
                    color: SemanticColor.primary.border(context),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
