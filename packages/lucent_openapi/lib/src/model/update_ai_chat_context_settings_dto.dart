//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_ai_chat_context_settings_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAiChatContextSettingsDto {
  /// Returns a new [UpdateAiChatContextSettingsDto] instance.
  UpdateAiChatContextSettingsDto({
    this.healthProfile,

    this.dailyRecords,

    this.sleepRecords,

    this.currentMedicines,
  });

  /// Allow AI chat to read stored health profile, allergies, and conditions.
  @JsonKey(name: r'healthProfile', required: false, includeIfNull: false)
  final bool? healthProfile;

  /// Allow AI chat to read recent daily records.
  @JsonKey(name: r'dailyRecords', required: false, includeIfNull: false)
  final bool? dailyRecords;

  /// Allow AI chat to read sleep records and summaries.
  @JsonKey(name: r'sleepRecords', required: false, includeIfNull: false)
  final bool? sleepRecords;

  /// Allow AI chat to read current medicines and medicine-box data.
  @JsonKey(name: r'currentMedicines', required: false, includeIfNull: false)
  final bool? currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAiChatContextSettingsDto &&
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

  factory UpdateAiChatContextSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAiChatContextSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAiChatContextSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
