// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_condition_status.dart';

part 'user_condition_item_dto.g.dart';

@JsonSerializable()
class UserConditionItemDto {
  const UserConditionItemDto({
    required this.id,
    required this.label,
    required this.status,
    required this.diagnosedAt,
    required this.resolvedAt,
    required this.note,
    required this.extras,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserConditionItemDto.fromJson(Map<String, Object?> json) =>
      _$UserConditionItemDtoFromJson(json);

  /// Condition id.
  final String id;

  /// Condition label.
  final String label;

  /// Condition status.
  final UserConditionStatus status;

  /// Diagnosis date in YYYY-MM-DD format.
  final String? diagnosedAt;

  /// Resolved date in YYYY-MM-DD format.
  final String? resolvedAt;

  /// User note for the condition.
  final String? note;

  /// Sparse condition extensions stored in jsonb.
  final dynamic extras;

  /// Created time in ISO 8601 format.
  final String createdAt;

  /// Updated time in ISO 8601 format.
  final String updatedAt;

  Map<String, Object?> toJson() => _$UserConditionItemDtoToJson(this);
}
