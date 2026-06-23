import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

const double _authControlHeight = 56;

class AuthLoginActionRow extends StatelessWidget {
  const AuthLoginActionRow({
    super.key,
    required this.registerPrompt,
    required this.registerLabel,
    required this.onRegister,
    required this.forgotPasswordLabel,
    required this.onForgotPassword,
  });

  final String registerPrompt;
  final String registerLabel;
  final VoidCallback onRegister;
  final String forgotPasswordLabel;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final promptStyle = typography.bodySm.copyWith(color: surface.body);
    final linkStyle = typography.bodySm.copyWith(
      color: surface.link,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0,
            children: [
              Text(registerPrompt, style: promptStyle),
              TextButton(
                onPressed: onRegister,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(registerLabel, style: linkStyle),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(forgotPasswordLabel, style: linkStyle),
        ),
      ],
    );
  }
}

class AuthFooterAction extends StatelessWidget {
  const AuthFooterAction({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacingTokens.xs,
      children: [
        Text(prompt, style: typography.bodySm.copyWith(color: surface.body)),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xs,
            ),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onPrimary)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onPrimary);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(_authControlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: typography.buttonLg),
      ),
    );
  }
}
