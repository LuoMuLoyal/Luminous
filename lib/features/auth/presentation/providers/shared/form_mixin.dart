import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
