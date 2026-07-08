// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_allergy_item_dto.dart';
import 'user_condition_item_dto.dart';
import 'user_current_medicine_item_dto.dart';
import 'user_health_profile_dto.dart';
import 'user_health_summary_dto.dart';

part 'health_context_data_dto.g.dart';

@JsonSerializable()
class HealthContextDataDto {
  const HealthContextDataDto({
    required this.summary,
    required this.profile,
    required this.allergies,
    required this.conditions,
    required this.currentMedicines,
  });

  factory HealthContextDataDto.fromJson(Map<String, Object?> json) =>
      _$HealthContextDataDtoFromJson(json);

  final UserHealthSummaryDto summary;
  final UserHealthProfileDto profile;
  final List<UserAllergyItemDto> allergies;
  final List<UserConditionItemDto> conditions;
  final List<UserCurrentMedicineItemDto> currentMedicines;

  Map<String, Object?> toJson() => _$HealthContextDataDtoToJson(this);
}
