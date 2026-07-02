import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

/// A section label used above grouped settings rows.
///
/// Matches the standard app settings style: small, muted, uppercase-ish
/// caption placed with horizontal padding.
class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacingTokens.level3,
        right: AppSpacingTokens.level3,
        bottom: AppSpacingTokens.level2,
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
