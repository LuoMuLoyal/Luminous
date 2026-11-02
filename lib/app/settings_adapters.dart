import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/core/providers/session/sensitive_action_resolver.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

/// Feature-backed [SensitiveActionPolicy] registered by the composition root.
///
/// Core only knows "does this action need the password again"; the setting
/// itself is owned by `features/settings`.
class FeatureSensitiveActionPolicy implements SensitiveActionPolicy {
  const FeatureSensitiveActionPolicy(this._readSettings);

  final Future<UserSettings> Function() _readSettings;

  @override
  Future<bool> requiresPasswordReauthentication() async {
    final settings = await _readSettings();
    return settings.passwordReauthenticationRequired;
  }
}

/// Overrides the core [sensitiveActionPolicyProvider] with the feature-backed
/// implementation.
List<Override> settingsProviderOverrides(ProviderContainer container) => [
  sensitiveActionPolicyProvider.overrideWithValue(
    FeatureSensitiveActionPolicy(
      () => container.read(userSettingsControllerProvider.future),
    ),
  ),
];
