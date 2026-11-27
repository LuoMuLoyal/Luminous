import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// Which agent backend the assistant runs on for this user.
///
/// `followOperator` maps to the backend's `default`: the user expresses no
/// preference and the server's `ASSISTANT_AGENT_RUNTIME` decides. The other two
/// override it per user.
///
/// Kept as a local enum rather than the generated
/// `UserSettingsResponseAssistantAgentModeEnum` so `domain/` stays free of the
/// API client (`domain_purity`); the mapper translates at the data boundary.
enum AssistantAgentMode {
  /// Follow the server operator's configured default.
  followOperator('default'),

  /// The hand-written ReAct graph (the proven path).
  graph('graph'),

  /// The deepagents runtime (planning, filesystem, sub-agents).
  deepAgents('deepagents');

  const AssistantAgentMode(this.wireValue);

  /// The value the API expects and returns.
  final String wireValue;

  /// Parses a wire value, falling back to [followOperator] for anything the
  /// client does not know — including `unknown_default_open_api`, which the
  /// generated client emits when the server introduces a mode this build predates.
  static AssistantAgentMode fromWireValue(String? value) {
    for (final mode in AssistantAgentMode.values) {
      if (mode.wireValue == value) return mode;
    }
    return AssistantAgentMode.followOperator;
  }
}

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
    required bool digestEnabled,

    /// Consent to share anonymized data for research.
    required bool dataSharingConsent,

    /// Allow the authenticated user to use the assistant feature.
    required bool assistantEnabled,

    /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
    required bool assistantMemoryEnabled,

    /// Which agent backend the assistant runs on.
    ///
    /// Defaults to [AssistantAgentMode.followOperator] so a cached payload
    /// written before this field existed still decodes.
    @Default(AssistantAgentMode.followOperator)
    AssistantAgentMode assistantAgentMode,

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
