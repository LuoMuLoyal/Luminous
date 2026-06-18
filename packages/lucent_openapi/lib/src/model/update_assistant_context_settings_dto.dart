//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_assistant_context_settings_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAssistantContextSettingsDto {
  /// Returns a new [UpdateAssistantContextSettingsDto] instance.
  UpdateAssistantContextSettingsDto({
    this.healthProfile,

    this.dailyRecords,

    this.sleepRecords,

    this.currentMedicines,
  });

  /// Allow the assistant to read stored health profile, allergies, and conditions.
  @JsonKey(name: r'healthProfile', required: false, includeIfNull: false)
  final bool? healthProfile;

  /// Allow the assistant to read recent daily records.
  @JsonKey(name: r'dailyRecords', required: false, includeIfNull: false)
  final bool? dailyRecords;

  /// Allow the assistant to read sleep records and summaries.
  @JsonKey(name: r'sleepRecords', required: false, includeIfNull: false)
  final bool? sleepRecords;

  /// Allow the assistant to read current medicines and medicine-box data.
  @JsonKey(name: r'currentMedicines', required: false, includeIfNull: false)
  final bool? currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAssistantContextSettingsDto &&
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

  factory UpdateAssistantContextSettingsDto.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateAssistantContextSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateAssistantContextSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
