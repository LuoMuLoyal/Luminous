import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_radius_tokens.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/design/app_shadow_tokens.dart';
import 'package:luminous/core/design/app_typography_tokens.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppToast {
  const AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _currentTimer;

  static Future<bool?> show(BuildContext context, String message) async {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return false;
    }

    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>();
    final backgroundColor = surface?.canvas ?? Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final topOffset = MediaQuery.paddingOf(context).top + AppSpacingTokens.xl;

    _removeCurrentToast();

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topOffset,
          left: 24,
          right: 24,
          child: IgnorePointer(
            child: _AppToastSurface(
              message: message,
              backgroundColor: backgroundColor,
              borderColor: surface?.hairline ?? const Color(0xFFE8E8E8),
              textColor: textColor,
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);
    _currentTimer = Timer(const Duration(milliseconds: 1800), () {
      if (identical(_currentEntry, entry)) {
        _removeCurrentToast();
      }
    });

    return true;
  }

  static void _removeCurrentToast() {
    _currentTimer?.cancel();
    _currentTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AppToastSurface extends StatelessWidget {
  const _AppToastSurface({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadiusTokens.full),
        boxShadow: AppShadowTokens.level2,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.lg,
          vertical: AppSpacingTokens.sm,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypographyTokens.mobile(textColor).bodySmStrong.copyWith(
              decoration: TextDecoration.none,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
