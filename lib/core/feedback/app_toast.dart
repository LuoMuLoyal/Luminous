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
  static String? _currentMessage;

  static Future<bool?> show(BuildContext context, String message) async {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return false;
    }

    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>();
    final backgroundColor = surface?.canvas ?? Colors.white;
    final textColor = theme.colorScheme.onSurface;
    // 放在状态栏 / 刘海 / 灵动岛安全区下方，避免与摄像头区域重叠。
    final topOffset =
        MediaQuery.viewPaddingOf(context).top + AppSpacingTokens.x4l;

    // 如果当前正在显示同一条消息，直接按最后一次触发重新计时，避免排队。
    if (_currentEntry != null && _currentMessage == message) {
      _currentTimer?.cancel();
      _currentTimer = Timer(const Duration(milliseconds: 1800), () {
        if (_currentMessage == message) {
          _removeCurrentToast();
        }
      });
      return true;
    }

    _removeCurrentToast();

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topOffset,
          left: AppSpacingTokens.md,
          right: AppSpacingTokens.md,
          child: _AppToastSurface(
            message: message,
            backgroundColor: backgroundColor,
            borderColor: surface?.hairline ?? const Color(0xFFE8E8E8),
            textColor: textColor,
            onClose: _removeCurrentToast,
          ),
        );
      },
    );

    _currentEntry = entry;
    _currentMessage = message;
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
    _currentMessage = null;
  }
}

class _AppToastSurface extends StatelessWidget {
  const _AppToastSurface({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onClose,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppRadiusTokens.full),
          boxShadow: AppShadowTokens.level2,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacingTokens.lg,
            top: AppSpacingTokens.sm,
            bottom: AppSpacingTokens.sm,
            right: AppSpacingTokens.xs,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTypographyTokens.mobile(textColor).bodySmStrong
                        .copyWith(
                          decoration: TextDecoration.none,
                          color: textColor,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.xs),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, size: 16, color: surface.body),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
