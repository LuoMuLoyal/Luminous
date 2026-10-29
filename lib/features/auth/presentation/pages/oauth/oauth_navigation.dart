import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';

/// Sanitizes a [value] intended for post-login navigation.
///
/// Returns `null` when the value is empty, a protocol-relative URL, or points
/// back to the login page itself.
String? safeReturnTo(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (!trimmed.startsWith('/') || trimmed.startsWith('//')) return null;
  if (trimmed == Routes.login ||
      trimmed.startsWith('${Routes.login}?') ||
      trimmed.startsWith('${Routes.login}/')) {
    return null;
  }
  return trimmed;
}

/// Navigates to the sanitized [returnTo] target, or falls back to
/// [Routes.home] when [fallbackHome] is true and no safe target exists.
void goAfterLogin(
  BuildContext context, {
  String? returnTo,
  bool fallbackHome = false,
}) {
  final target = safeReturnTo(returnTo);
  if (target != null) {
    context.go(target);
    return;
  }
  if (fallbackHome) context.go(Routes.home);
}
