import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A checkmark or empty circle used to indicate selection in settings lists.
///
/// Used by theme/language settings and other single-selection pages.
class SettingsSelectionIcon extends StatelessWidget {
  const SettingsSelectionIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Opacity(
      opacity: selected ? 1 : 0,
      child: Icon(FLucideIcons.check, size: 18, color: colors.primary),
    );
  }
}
