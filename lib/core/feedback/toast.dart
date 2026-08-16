import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';

class Toast {
  const Toast._();

  static FToasterEntry? _currentEntry;
  static Timer? _currentTimer;
  static String? _currentMessage;
  static _ActionConfig? _currentAction;

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
      // 同消息重放只替换 action 引用：按钮按下时读取的是最新回调，因此连续
      // 触发同消息时第二次 action 指向最新闭包。已渲染的 label 在 label 变化时
      // 不会重绘（当前用例撤销标签恒定，仅回调需最新）；如需标签热更新需重建
      // toast（TODO）。
      _currentAction = action;
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
    _currentAction = action;
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
        suffixBuilder: _currentAction != null
            ? (context, entry) => FButton(
                variant: FButtonVariant.ghost,
                size: .sm,
                onPress: () {
                  entry.dismiss();
                  _currentAction?.callback();
                },
                // label 在展示时捕获（每 entry 稳定），避免旧 toast 重建时读取
                // 已置空的 `_currentAction` 触发空解引用；仅回调按按下时读取最新值。
                child: Text(action!.label),
              )
            : (context, entry) => FButton.icon(
                variant: FButtonVariant.ghost,
                size: .sm,
                onPress: entry.dismiss,
                child: const Icon(SemanticIcons.actionClose, size: 16),
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
    _currentAction = null;
  }

  static void _reset() {
    _currentTimer?.cancel();
    _currentTimer = null;
    _currentEntry = null;
    _currentMessage = null;
    _currentAction = null;
  }
}

class _ActionConfig {
  const _ActionConfig(this.label, this.callback);

  final String label;
  final VoidCallback callback;
}
