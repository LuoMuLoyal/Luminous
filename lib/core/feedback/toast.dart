import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/logger/logger.dart';

class Toast {
  const Toast._();

  static FToasterEntry? _currentEntry;
  static Timer? _currentTimer;
  static String? _currentMessage;

  static Future<bool?> show(BuildContext context, String message) async {
    return _showInternal(context, message, null);
  }

  /// Shows a toast with an action button (replaces the default close button).
  static Future<bool?> showWithAction(
    BuildContext context,
    String message,
    String actionLabel,
    VoidCallback onAction,
  ) async {
    return _showInternal(
      context,
      message,
      _ActionConfig(actionLabel, onAction),
    );
  }

  static Future<bool?> _showInternal(
    BuildContext context,
    String message,
    _ActionConfig? action,
  ) async {
    // 如果当前正在显示同一条消息，直接按最后一次触发重新计时，避免排队。
    if (_currentMessage == message && _currentEntry?.showing == true) {
      _currentTimer?.cancel();
      _currentTimer = Timer(const Duration(milliseconds: 1800), () {
        if (_currentMessage == message) {
          _removeCurrentToast();
        }
      });
      return true;
    }

    _removeCurrentToast();

    _currentMessage = message;
    _currentTimer = Timer(const Duration(milliseconds: 1800), () {
      if (_currentMessage == message) {
        _removeCurrentToast();
      }
    });

    try {
      _currentEntry = showFToast(
        context: context,
        alignment: FToastAlignment.topCenter,
        duration: null,
        title: Text(message),
        suffixBuilder: action != null
            ? (context, entry) => FButton(
                variant: FButtonVariant.ghost,
                size: .sm,
                onPress: () {
                  entry.dismiss();
                  action.callback();
                },
                child: Text(action.label),
              )
            : (context, entry) => FButton.icon(
                variant: FButtonVariant.ghost,
                size: .sm,
                onPress: entry.dismiss,
                child: const Icon(FLucideIcons.x, size: 16),
              ),
        onDismiss: () {
          if (_currentMessage == message) {
            _reset();
          }
        },
      );
    } catch (e) {
      appTalker.error('Toast.show: FToaster unavailable: $e');
      _reset();
      return false;
    }

    return true;
  }

  static void _removeCurrentToast() {
    _currentTimer?.cancel();
    _currentTimer = null;
    _currentEntry?.dismiss();
    _currentEntry = null;
    _currentMessage = null;
  }

  static void _reset() {
    _currentTimer?.cancel();
    _currentTimer = null;
    _currentEntry = null;
    _currentMessage = null;
  }
}

class _ActionConfig {
  const _ActionConfig(this.label, this.callback);

  final String label;
  final VoidCallback callback;
}
