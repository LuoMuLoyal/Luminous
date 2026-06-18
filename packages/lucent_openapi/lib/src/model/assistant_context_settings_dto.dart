//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'assistant_context_settings_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantContextSettingsDto {
  /// Returns a new [AssistantContextSettingsDto] instance.
  AssistantContextSettingsDto({
    required this.healthProfile,

    required this.dailyRecords,

    required this.sleepRecords,

    required this.currentMedicines,
  });

  /// Whether the assistant may read stored health profile, allergies, and conditions.
  @JsonKey(name: r'healthProfile', required: true, includeIfNull: false)
  final bool healthProfile;

  /// Whether the assistant may read recent daily records.
  @JsonKey(name: r'dailyRecords', required: true, includeIfNull: false)
  final bool dailyRecords;

  /// Whether the assistant may read sleep records and summaries.
  @JsonKey(name: r'sleepRecords', required: true, includeIfNull: false)
  final bool sleepRecords;

  /// Whether the assistant may read current medicines and medicine-box data.
  @JsonKey(name: r'currentMedicines', required: true, includeIfNull: false)
  final bool currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantContextSettingsDto &&
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

  factory AssistantContextSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantContextSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantContextSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
