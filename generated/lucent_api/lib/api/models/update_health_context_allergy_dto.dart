// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_allergy_kind.dart';
import 'user_allergy_severity.dart';

part 'update_health_context_allergy_dto.g.dart';

@JsonSerializable()
class UpdateHealthContextAllergyDto {
  const UpdateHealthContextAllergyDto({
    required this.kind,
    required this.label,
    required this.reaction,
    required this.severity,
    required this.note,
    required this.recordedAt,
    required this.isActive,
  });

  factory UpdateHealthContextAllergyDto.fromJson(Map<String, Object?> json) =>
      _$UpdateHealthContextAllergyDtoFromJson(json);

  /// Allergy kind.
  final UserAllergyKind kind;

  /// User-visible allergy label.
  final String label;

  /// Recorded reaction. Use null to clear.
  final String? reaction;

  /// Severity level.
  final UserAllergySeverity severity;

  /// User note for the allergy. Use null to clear.
  final String? note;

  /// When this allergy was recorded in ISO 8601 format.
  final String? recordedAt;

  /// Whether the allergy is currently active.
  final bool isActive;

  Map<String, Object?> toJson() => _$UpdateHealthContextAllergyDtoToJson(this);
}
