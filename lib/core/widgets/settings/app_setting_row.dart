import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class AppSettingRow extends StatelessWidget {
  const AppSettingRow({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.value,
    this.trailing,
    this.showChevron = false,
    this.showDivider = false,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final row = FTile(
      onPress: onTap,
      prefix: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      details: trailing == null || value == null || value!.isEmpty
          ? null
          : Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
      suffix: _buildSuffix(),
    );

    if (!showDivider) return row;
    return Column(
      children: [
        row,
        Divider(height: 1, color: colors.border),
      ],
    );
  }

  Widget? _buildSuffix() {
    if (trailing == null && !showChevron) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null) trailing!,
        if (showChevron) ...[
          if (trailing != null) const SizedBox(width: AppSpacingTokens.level2),
          const Icon(FLucideIcons.chevronRight),
        ],
      ],
    );
  }
}
