import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({super.key, this.error, this.success});

  final String? error;
  final String? success;

  @override
  Widget build(BuildContext context) {
    final message = error?.isNotEmpty == true
        ? error
        : success?.isNotEmpty == true
        ? success
        : null;
    if (message == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isError = error?.isNotEmpty == true;
    final color = isError ? theme.colorScheme.error : surface.success;

    return Text(message, style: typography.bodySm.copyWith(color: color));
  }
}
