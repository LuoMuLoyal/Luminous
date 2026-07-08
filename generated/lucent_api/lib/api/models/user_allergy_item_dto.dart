// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_allergy_kind.dart';
import 'user_allergy_severity.dart';

part 'user_allergy_item_dto.g.dart';

@JsonSerializable()
class UserAllergyItemDto {
  const UserAllergyItemDto({
    required this.id,
    required this.kind,
    required this.label,
    required this.reaction,
    required this.severity,
    required this.isActive,
    required this.note,
    required this.extras,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAllergyItemDto.fromJson(Map<String, Object?> json) =>
      _$UserAllergyItemDtoFromJson(json);

  /// Allergy id.
  final String id;

  /// Allergy kind.
  final UserAllergyKind kind;

  /// User-visible allergy label.
  final String label;

  /// Recorded reaction.
  final String? reaction;

  /// Severity level.
  final UserAllergySeverity severity;

  /// Whether the allergy is currently active.
  final bool isActive;

  /// User note for the allergy.
  final String? note;

  /// Sparse allergy extensions stored in jsonb.
  final dynamic extras;

  /// When this allergy was recorded.
  final String? recordedAt;

  /// Created time in ISO 8601 format.
  final String createdAt;

  /// Updated time in ISO 8601 format.
  final String updatedAt;

  Map<String, Object?> toJson() => _$UserAllergyItemDtoToJson(this);
}
