import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// Assistant context permission settings (read model).
@freezed
abstract class AssistantContextSettings with _$AssistantContextSettings {
  const factory AssistantContextSettings({
    /// Whether the assistant may read stored health profile, allergies, and conditions.
    required bool healthProfile,

    /// Whether the assistant may read recent daily records.
    required bool dailyRecords,

    /// Whether the assistant may read sleep records and summaries.
    required bool sleepRecords,

    /// Whether the assistant may read current medicines and medicine-box data.
    required bool currentMedicines,
  }) = _AssistantContextSettings;

  factory AssistantContextSettings.fromJson(Map<String, dynamic> json) =>
      _$AssistantContextSettingsFromJson(json);
}

/// User privacy/AI settings (read model).
@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    /// Allow AI-generated summaries and advice.
    required bool aiSummariesEnabled,

    /// Consent to share anonymized data for research.
    required bool dataSharingConsent,

    /// Allow the authenticated user to use the assistant feature.
    required bool assistantEnabled,

    /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
    required bool assistantMemoryEnabled,

    /// Daily water intake target (number of glasses).
    required int waterTargetCount,

    /// Fine-grained assistant context permissions.
    required AssistantContextSettings assistantContext,

    /// ISO-8601 timestamp of last update.
    String? updatedAt,

    /// Whether sensitive operations require account password re-authentication.
    @Default(true) bool passwordReauthenticationRequired,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// Partial update for assistant context permissions.
///
/// Null fields are not updated on the backend.
class AssistantContextPatch {
  const AssistantContextPatch({
    this.healthProfile,
    this.dailyRecords,
    this.sleepRecords,
    this.currentMedicines,
  });

  final bool? healthProfile;
  final bool? dailyRecords;
  final bool? sleepRecords;
  final bool? currentMedicines;
}
