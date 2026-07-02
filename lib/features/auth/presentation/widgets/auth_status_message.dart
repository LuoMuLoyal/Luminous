import 'package:flutter/material.dart';

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
    final textTheme = theme.textTheme;
    final isError = error?.isNotEmpty == true;
    final color = isError ? theme.colorScheme.error : const Color(0xFF16A34A);

    return Text(message, style: textTheme.bodySmall?.copyWith(color: color));
  }
}
