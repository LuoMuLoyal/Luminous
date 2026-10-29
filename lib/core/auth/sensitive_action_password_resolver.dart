import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The subset of user settings a sensitive action needs.
///
/// `lib/core/auth` cannot import `features/settings`, so the setting is read
/// through this thin port. The adapter lives in `lib/app/push_handlers.dart`'s
/// sibling `lib/app/settings_adapters.dart`, which is allowed to see features.
abstract interface class SensitiveActionPolicy {
  /// Whether the user must re-enter the account password before a sensitive
  /// action (e.g. data export, account deletion).
  Future<bool> requiresPasswordReauthentication();
}

/// Composition-root seam: overridden by the app adapter.
final sensitiveActionPolicyProvider = Provider<SensitiveActionPolicy>((ref) {
  throw StateError(
    'sensitiveActionPolicyProvider must be overridden by the composition root '
    '(lib/app) with the feature-backed SensitiveActionPolicy implementation.',
  );
});

/// Resolves the account password for a sensitive action, respecting the
/// user's `passwordReauthenticationRequired` setting.
///
/// Waits for the policy to be ready (i.e. user settings finished loading)
/// before deciding whether to show the password prompt. This avoids the failure
/// mode where settings are still loading and the `?? true` fallback forces a
/// password dialog that OAuth-only users can never satisfy.
///
/// Returns:
/// - The password string (possibly empty `''` if re-auth is not required).
/// - `null` if the user cancelled the prompt or the [context] was unmounted.
///
/// Returns `null` immediately when the widget is no longer mounted.
Future<String?> resolveSensitiveActionPassword(
  WidgetRef ref,
  BuildContext context,
) async {
  // Wait for settings to be ready so we don't fall back to `true` while
  // the policy is still in AsyncLoading state.
  final requiresPassword = await ref
      .read(sensitiveActionPolicyProvider)
      .requiresPasswordReauthentication();
  if (!context.mounted) return null;

  if (!requiresPassword) return '';

  // Default title/message/label are supplied by the dialog itself
  // (see [requestPasswordForSensitiveAction]).
  return ref.read(sensitiveActionPasswordPromptProvider)(context);
}

/// Handles a failure from a sensitive action, showing an actionable toast
/// when the user has no local password (OAuth-only, `AUTH_PASSWORD_NOT_SET`).
///
/// Returns `true` if the failure was handled (toast shown, caller should
/// return early); `false` if the caller should proceed with its own
/// generic error handling.
Future<bool> handleSensitiveActionFailure({
  required BuildContext context,
  required AppLocalizations l10n,
  required Object error,
  required String failurePrefix,
}) async {
  final failure = error is LucentFailure ? error : null;
  if (failure != null && failure.isPasswordNotSet) {
    await Toast.showWithAction(
      context,
      l10n.authPasswordNotSetToast,
      l10n.authPasswordNotSetAction,
      () => context.go(Routes.account),
    );
    return true;
  }
  await Toast.show(
    context,
    '$failurePrefix: ${userMessageFromError(error, l10n: l10n)}',
  );
  return false;
}
