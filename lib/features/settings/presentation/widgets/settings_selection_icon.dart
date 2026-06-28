import 'package:flutter/material.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// A checkmark or empty circle used to indicate selection in settings lists.
///
/// Used by theme/language settings and other single-selection pages.
class SettingsSelectionIcon extends StatelessWidget {
  const SettingsSelectionIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Icon(
      selected ? Icons.check_rounded : Icons.circle_outlined,
      size: 18,
      color: selected ? theme.colorScheme.primary : surface.mute,
    );
  }
}
