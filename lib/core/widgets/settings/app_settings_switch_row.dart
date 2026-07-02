import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A standard settings row with a title, optional subtitle, and a trailing
/// [Switch]. The whole row is tappable to toggle the switch.
///
/// When [enabled] is false, the row is visually muted and taps are ignored.
class AppSettingsSwitchRow extends StatelessWidget {
  const AppSettingsSwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final row = FTile(
      enabled: enabled,
      onPress: enabled ? () => onChanged(!value) : null,
      title: Text(title),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
      suffix: FSwitch(
        value: value,
        enabled: enabled,
        onChange: enabled ? onChanged : null,
      ),
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
