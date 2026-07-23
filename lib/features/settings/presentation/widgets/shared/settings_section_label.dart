import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// 设置子页面的分组标题文本。
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.level2),
      child: Text(
        label,
        style: TypographyToken.level3
            .body(context)
            .copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
