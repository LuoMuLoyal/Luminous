import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final promptStyle = textTheme.bodySmall?.copyWith(
      color: colors.mutedForeground,
    );
    final linkStyle = textTheme.bodySmall?.copyWith(
      color: colors.primary,
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacingTokens.xs,
      children: [
        Text(
          prompt,
          style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
        ),
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
    final textTheme = Theme.of(context).textTheme;

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
            : SizedBox(
                height: _authControlHeight,
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
