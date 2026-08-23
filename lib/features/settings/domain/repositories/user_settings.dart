import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';

/// Repository interface for reading and updating user settings.
///
/// All methods require an authenticated session.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right.
abstract interface class UserSettingsRepository {
  /// Returns the current user settings.
  TaskEither<LucentFailure, UserSettings> getSettings();

  /// Patches one or more settings fields.
  ///
  /// All parameters are required because the backend expects a full
  /// [UpdateUserSettingsDto]. The [AssistantContextPatch] supports partial
  /// updates at the context level (null fields are not sent).
  TaskEither<LucentFailure, UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  });

  /// Enables the security PIN.
  TaskEither<LucentFailure, UserSettings> enableSecurityPin(String pin);

  /// Changes the security PIN.
  TaskEither<LucentFailure, UserSettings> changeSecurityPin(
    String oldPin,
    String newPin,
  );

  /// Disables the security PIN.
  TaskEither<LucentFailure, UserSettings> disableSecurityPin(String pin);
}
