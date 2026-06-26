import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/design/app_typography_tokens.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AuthFieldError extends StatelessWidget {
  const AuthFieldError(this.error, {super.key});

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacingTokens.xs,
        left: AppSpacingTokens.sm,
      ),
      child: Text(
        error!,
        style: AppTypographyTokens.mobile(
          surface.error,
        ).bodySm.copyWith(color: surface.error),
      ),
    );
  }
}
