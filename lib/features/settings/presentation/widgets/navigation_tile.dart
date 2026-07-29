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
    this.subtitle,
    this.value,
    this.tileKey,
    required this.onTap,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final String? value;
  final Key? tileKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTile(
      key: tileKey,
      title: Text(title),
      subtitle: () {
        final s = subtitle;
        return s == null || s.isEmpty ? null : Text(s);
      }(),
      prefix: icon != null ? Icon(icon, size: IconSizeTokens.level3) : null,
      details: () {
        final v = value;
        return v == null || v.isEmpty ? null : Text(v);
      }(),
      suffix: const Icon(SemanticIcons.actionNext),
      onPress: onTap,
    );
  }
}
