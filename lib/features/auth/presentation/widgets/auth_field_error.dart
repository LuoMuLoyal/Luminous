import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

class AuthFieldError extends StatelessWidget {
  const AuthFieldError(this.error, {super.key});

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacingTokens.xs,
        left: AppSpacingTokens.sm,
      ),
      child: Text(
        error!,
        style: textTheme.bodySmall?.copyWith(color: errorColor),
      ),
    );
  }
}
