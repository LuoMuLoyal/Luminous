// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_condition_status.dart';

part 'update_health_context_condition_dto.g.dart';

@JsonSerializable()
class UpdateHealthContextConditionDto {
  const UpdateHealthContextConditionDto({
    required this.label,
    required this.status,
    required this.diagnosedAt,
    required this.note,
  });

  factory UpdateHealthContextConditionDto.fromJson(Map<String, Object?> json) =>
      _$UpdateHealthContextConditionDtoFromJson(json);

  /// Condition label.
  final String label;

  /// Condition status.
  final UserConditionStatus status;

  /// Diagnosis date in YYYY-MM-DD format. Use null to clear.
  final String? diagnosedAt;

  /// User note for the condition. Use null to clear.
  final String? note;

  Map<String, Object?> toJson() =>
      _$UpdateHealthContextConditionDtoToJson(this);
}
