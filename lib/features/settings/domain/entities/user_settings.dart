/// Assistant context permission settings (read model).
class AssistantContextSettings {
  const AssistantContextSettings({
    required this.healthProfile,
    required this.dailyRecords,
    required this.sleepRecords,
    required this.currentMedicines,
  });

  /// Whether the assistant may read stored health profile, allergies, and conditions.
  final bool healthProfile;

  /// Whether the assistant may read recent daily records.
  final bool dailyRecords;

  /// Whether the assistant may read sleep records and summaries.
  final bool sleepRecords;

  /// Whether the assistant may read current medicines and medicine-box data.
  final bool currentMedicines;
}

/// User privacy/AI settings (read model).
class UserSettings {
  const UserSettings({
    required this.aiSummariesEnabled,
    required this.dataSharingConsent,
    required this.assistantEnabled,
    required this.assistantMemoryEnabled,
    required this.waterTargetCount,
    required this.assistantContext,
    this.updatedAt,
    this.passwordReauthenticationRequired = true,
  });

  /// Allow AI-generated summaries and advice.
  final bool aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  final bool dataSharingConsent;

  /// Allow the authenticated user to use the assistant feature.
  final bool assistantEnabled;

  /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
  final bool assistantMemoryEnabled;

  /// Daily water intake target (number of glasses).
  final int waterTargetCount;

  /// Fine-grained assistant context permissions.
  final AssistantContextSettings assistantContext;

  /// ISO-8601 timestamp of last update.
  final String? updatedAt;

  /// Whether sensitive operations require account password re-authentication.
  final bool passwordReauthenticationRequired;
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
