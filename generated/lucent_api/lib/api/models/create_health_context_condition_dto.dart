// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_condition_status.dart';

part 'create_health_context_condition_dto.g.dart';

@JsonSerializable()
class CreateHealthContextConditionDto {
  const CreateHealthContextConditionDto({
    required this.label,
    this.status,
    this.diagnosedAt,
    this.note,
  });

  factory CreateHealthContextConditionDto.fromJson(Map<String, Object?> json) =>
      _$CreateHealthContextConditionDtoFromJson(json);

  /// Condition label.
  final String label;

  /// Condition status. Defaults to active.
  final UserConditionStatus? status;

  /// Diagnosis date in YYYY-MM-DD format.
  final String? diagnosedAt;

  /// User note for the condition.
  final String? note;

  Map<String, Object?> toJson() =>
      _$CreateHealthContextConditionDtoToJson(this);
}
