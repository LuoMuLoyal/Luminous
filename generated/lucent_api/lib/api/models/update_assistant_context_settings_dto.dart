// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_assistant_context_settings_dto.g.dart';

@JsonSerializable()
class UpdateAssistantContextSettingsDto {
  const UpdateAssistantContextSettingsDto({
    this.healthProfile,
    this.dailyRecords,
    this.sleepRecords,
    this.currentMedicines,
  });

  factory UpdateAssistantContextSettingsDto.fromJson(
    Map<String, Object?> json,
  ) => _$UpdateAssistantContextSettingsDtoFromJson(json);

  /// Allow the assistant to read stored health profile, allergies, and conditions.
  final bool? healthProfile;

  /// Allow the assistant to read recent daily records.
  final bool? dailyRecords;

  /// Allow the assistant to read sleep records and summaries.
  final bool? sleepRecords;

  /// Allow the assistant to read current medicines and medicine-box data.
  final bool? currentMedicines;

  Map<String, Object?> toJson() =>
      _$UpdateAssistantContextSettingsDtoToJson(this);
}
