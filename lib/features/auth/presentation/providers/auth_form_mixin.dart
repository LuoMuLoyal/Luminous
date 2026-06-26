import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared validation helpers for auth forms (register, password reset, etc.).
mixin AuthValidationMixin {
  static final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool isValidEmail(String value) => _emailRegExp.hasMatch(value);

  String? validateEmail(
    String email, {
    required String emailRequired,
    required String emailInvalid,
  }) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return emailRequired;
    }
    return isValidEmail(trimmed) ? null : emailInvalid;
  }

  String? validateCode(String code, {required String codeRequired}) {
    return code.trim().isEmpty ? codeRequired : null;
  }

  String? validatePassword(
    String password, {
    required String passwordRequired,
  }) {
    return password.trim().isEmpty ? passwordRequired : null;
  }

  String? validateConfirmPassword(
    String password,
    String confirmPassword, {
    required String confirmPasswordRequired,
    required String passwordsDoNotMatch,
  }) {
    if (confirmPassword.trim().isEmpty) {
      return confirmPasswordRequired;
    }
    if (confirmPassword != password) {
      return passwordsDoNotMatch;
    }
    return null;
  }
}

/// Shared cooldown timer logic for verification-code buttons.
///
/// The owning notifier must provide getter/setter callbacks because the
/// cooldown state lives in each notifier's distinct [State] type.
mixin CooldownTimerMixin<T> on Notifier<T> {
  Timer? _cooldownTimer;

  void startCooldown(
    int seconds, {
    required int? Function() getCooldownSeconds,
    required void Function(int?) setCooldownSeconds,
  }) {
    _cooldownTimer?.cancel();
    setCooldownSeconds(seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = getCooldownSeconds();
      if (current == null || current <= 1) {
        timer.cancel();
        _cooldownTimer = null;
        setCooldownSeconds(null);
      } else {
        setCooldownSeconds(current - 1);
      }
    });
  }

  void disposeCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }
}
