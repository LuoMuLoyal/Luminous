import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A standard settings row that navigates to a sub-page.
///
/// Shows an optional [value] label and a chevron on the trailing side.
/// When [enabled] is false, the row is muted and taps are ignored.
class AppSettingsNavigationRow extends StatelessWidget {
  const AppSettingsNavigationRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
    this.enabled = true,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final row = FTile(
      enabled: enabled,
      onPress: enabled ? onTap : null,
      title: Text(title),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
      details: value == null || value!.isEmpty
          ? null
          : Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
      suffix: const Icon(FLucideIcons.chevronRight),
    );

    if (!showDivider) return row;
    return Column(
      children: [
        row,
        Divider(height: 1, color: colors.border),
      ],
    );
  }
}
