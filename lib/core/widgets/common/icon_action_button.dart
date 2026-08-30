import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Icon button with tooltip, used for compact action entries in page top bars.
///
/// When [showBadge] is true, overlays a red dot on the top-right corner (for
/// unread message notifications and similar scenarios).
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton.icon(
            onPress: onTap,
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            child: Icon(icon, size: Spacing.level5),
          ),
          if (showBadge)
            Positioned(
              right: Spacing.level2,
              top: Spacing.level2,
              child: FBadge.raw(
                style: .delta(
                  decoration: .shapeDelta(
                    color: SemanticColor.destructive.solid(context),
                    shape: CircleBorder(
                      side: BorderSide(color: colors.background, width: 2),
                    ),
                  ),
                ),
                builder: (context, style) =>
                    const SizedBox.square(dimension: Spacing.level3),
              ),
            ),
        ],
      ),
    );
  }
}
