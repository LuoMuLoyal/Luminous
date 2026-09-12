import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A navigation tile used across settings sections.
///
/// Displays a title, optional subtitle, optional leading icon, optional
/// trailing value text, and a trailing chevron icon.
class SettingsNavigationTile extends StatelessWidget with FTileMixin {
  const SettingsNavigationTile({
    super.key,
    required this.title,
    this.icon,
    this.svgIcon,
    this.subtitle,
    this.value,
    this.tileKey,
    required this.onTap,
  });

  final String title;
  final IconData? icon;

  /// Optional SVG glyph (iconMind AI 语义图标) shown instead of [icon] when
  /// set.
  final Widget Function(Color color, double size)? svgIcon;
  final String? subtitle;
  final String? value;
  final Key? tileKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = SemanticColor.neutral.solid(context);
    final svgBuilder = svgIcon;
    return FTile(
      key: tileKey,
      title: Text(title),
      subtitle: () {
        final s = subtitle;
        return s == null || s.isEmpty ? null : Text(s);
      }(),
      prefix: svgBuilder != null
          ? svgBuilder(color, IconSizeTokens.md)
          : icon != null
          ? Icon(icon, size: IconSizeTokens.md)
          : null,
      details: () {
        final v = value;
        return v == null || v.isEmpty ? null : Text(v);
      }(),
      suffix: const Icon(SemanticIcons.actionNext),
      onPress: onTap,
    );
  }
}
