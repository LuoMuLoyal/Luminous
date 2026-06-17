//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_context_settings_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatContextSettingsDto {
  /// Returns a new [AiChatContextSettingsDto] instance.
  AiChatContextSettingsDto({
    required this.healthProfile,

    required this.dailyRecords,

    required this.sleepRecords,

    required this.currentMedicines,
  });

  /// Whether AI chat may read stored health profile, allergies, and conditions.
  @JsonKey(name: r'healthProfile', required: true, includeIfNull: false)
  final bool healthProfile;

  /// Whether AI chat may read recent daily records.
  @JsonKey(name: r'dailyRecords', required: true, includeIfNull: false)
  final bool dailyRecords;

  /// Whether AI chat may read sleep records and summaries.
  @JsonKey(name: r'sleepRecords', required: true, includeIfNull: false)
  final bool sleepRecords;

  /// Whether AI chat may read current medicines and medicine-box data.
  @JsonKey(name: r'currentMedicines', required: true, includeIfNull: false)
  final bool currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatContextSettingsDto &&
          other.healthProfile == healthProfile &&
          other.dailyRecords == dailyRecords &&
          other.sleepRecords == sleepRecords &&
          other.currentMedicines == currentMedicines;

  @override
  int get hashCode =>
      healthProfile.hashCode +
      dailyRecords.hashCode +
      sleepRecords.hashCode +
      currentMedicines.hashCode;

  factory AiChatContextSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatContextSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatContextSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
