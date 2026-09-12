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

  /// Flex weights for the free-space split. Both buckets prefer their content's
  /// natural width; the ratio only decides who yields first when a row is too
  /// narrow (the value yields less, so short values like「已设置」never vanish).
  static const _labelFlex = 3;
  static const _valueFlex = 5;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final muted = SemanticColor.neutral.solid(context);

    final valueStyle = typography.body.md.copyWith(
      color: valueColor ?? (isPlaceholder ? muted : null),
    );

    // Split the label / value / chevron into buckets whose flex only applies to
    // *free* space: the label gets the largest share, the value claims what its
    // content needs (capped), and the chevron claims its own width. Because the
    // value bucket is right-aligned, its text lands against the chevron and the
    // chevron against the row's trailing edge — no intrinsic-width guesswork.
    final row = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: Spacing.lg)],
        Expanded(
          flex: _labelFlex,
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
          flex: _valueFlex,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: Spacing.sm), trailing!],
        if (onPress != null) ...[
          const SizedBox(width: Spacing.sm),
          Icon(SemanticIcons.actionNext, size: IconSizeTokens.md, color: muted),
        ],
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
