import '../entities/user_settings.dart';

/// Repository interface for reading and updating user settings.
///
/// All methods require an authenticated session.
abstract interface class UserSettingsRepository {
  /// Returns the current user settings.
  Future<UserSettings> getSettings();

  /// Patches one or more settings fields.
  ///
  /// All parameters are required because the backend expects a full
  /// [UpdateUserSettingsDto]. The [AssistantContextPatch] supports partial
  /// updates at the context level (null fields are not sent).
  Future<UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  });

  /// Enables the security PIN.
  Future<UserSettings> enableSecurityPin(String pin);

  /// Changes the security PIN.
  Future<UserSettings> changeSecurityPin(String oldPin, String newPin);

  /// Disables the security PIN.
  Future<UserSettings> disableSecurityPin(String pin);
}
