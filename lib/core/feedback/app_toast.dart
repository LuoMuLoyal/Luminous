import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_radius_tokens.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';
import 'package:luminous/core/design/app_shadow_tokens.dart';

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

    final colors = FTheme.of(context).colors;
    final backgroundColor = colors.card;
    final borderColor = colors.border;
    final textColor = colors.foreground;
    final iconColor = colors.mutedForeground;
    // 放在状态栏 / 刘海 / 灵动岛安全区下方，避免与摄像头区域重叠。
    final topOffset =
        MediaQuery.viewPaddingOf(context).top + AppSpacingTokens.level9;

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
          left: AppSpacingTokens.level4,
          right: AppSpacingTokens.level4,
          child: _AppToastSurface(
            message: message,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            textColor: textColor,
            iconColor: iconColor,
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
    required this.iconColor,
    required this.onClose,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
          boxShadow: AppShadowTokens.level2,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacingTokens.level5,
            top: AppSpacingTokens.level3,
            bottom: AppSpacingTokens.level3,
            right: AppSpacingTokens.level2,
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
                    style: textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.none,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level2),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(FLucideIcons.x, size: 16, color: iconColor),
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
