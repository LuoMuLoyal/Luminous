import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// A section label used above grouped settings rows.
///
/// Matches the standard app settings style: small, muted, uppercase-ish
/// caption placed with horizontal padding.
class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = _typography(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacingTokens.sm,
        right: AppSpacingTokens.sm,
        bottom: AppSpacingTokens.xs,
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: surface.mute,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}
