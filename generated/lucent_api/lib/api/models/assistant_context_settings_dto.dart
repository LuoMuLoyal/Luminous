// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assistant_context_settings_dto.g.dart';

@JsonSerializable()
class AssistantContextSettingsDto {
  const AssistantContextSettingsDto({
    required this.healthProfile,
    required this.dailyRecords,
    required this.sleepRecords,
    required this.currentMedicines,
  });

  factory AssistantContextSettingsDto.fromJson(Map<String, Object?> json) =>
      _$AssistantContextSettingsDtoFromJson(json);

  /// Whether the assistant may read stored health profile, allergies, and conditions.
  final bool healthProfile;

  /// Whether the assistant may read recent daily records.
  final bool dailyRecords;

  /// Whether the assistant may read sleep records and summaries.
  final bool sleepRecords;

  /// Whether the assistant may read current medicines and medicine-box data.
  final bool currentMedicines;

  Map<String, Object?> toJson() => _$AssistantContextSettingsDtoToJson(this);
}
