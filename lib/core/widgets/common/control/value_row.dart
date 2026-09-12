import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A settings-style list row: label on the left, current value on the right,
/// with a trailing chevron when tapping opens an editor.
///
/// This is the account/profile list idiom — the value is the Read side and the
/// tap is the Write side, so no field is rendered as an always-editable input.
class AppValueRow extends StatelessWidget {
  const AppValueRow({
    super.key,
    required this.label,
    required this.value,
    this.onPress,
    this.leading,
    this.trailing,
    this.valueColor,
    this.labelColor,
    this.isPlaceholder = false,
  });

  /// Left-hand label.
  final String label;

  /// Right-hand current value. Empty renders as a placeholder dash.
  final String value;

  /// Tapping the row opens the editor. Omit for a read-only row.
  final VoidCallback? onPress;

  /// Optional slot rendered left of the label (e.g. an avatar thumbnail).
  final Widget? leading;

  /// Optional slot rendered before the chevron (e.g. a status icon).
  final Widget? trailing;

  final Color? valueColor;
  final Color? labelColor;

  /// True when [value] is missing, so it renders muted as「未设置」-style copy.
  final bool isPlaceholder;

  /// Share of the row the value column may claim before it ellipsizes.
  static const _maxValueWidthFactor = 0.55;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final muted = SemanticColor.neutral.solid(context);

    final valueStyle = typography.body.md.copyWith(
      color: valueColor ?? (isPlaceholder ? muted : null),
    );

    final row = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: Spacing.lg)],
        // The label takes every pixel the value column does not need, so the
        // value and the chevron always sit flush right. The value column is
        // intrinsically sized (see [_maxValueWidthFactor] for its cap), which is
        // what keeps it from being squeezed to nothing on long labels.
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: typography.body.md.copyWith(
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(width: Spacing.lg),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) => IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * _maxValueWidthFactor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: valueStyle,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: Spacing.sm),
                      trailing!,
                    ],
                    if (onPress != null) ...[
                      const SizedBox(width: Spacing.sm),
                      Icon(
                        SemanticIcons.actionNext,
                        size: IconSizeTokens.md,
                        color: muted,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        child: row,
      ),
    );
  }
}
