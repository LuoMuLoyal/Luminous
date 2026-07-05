import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AppToast {
  const AppToast._();

  static FToasterEntry? _currentEntry;
  static Timer? _currentTimer;
  static String? _currentMessage;

  static Future<bool?> show(BuildContext context, String message) async {
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
        suffixBuilder: (context, entry) => FButton.icon(
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
      debugPrint('AppToast.show: FToaster unavailable: $e');
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
