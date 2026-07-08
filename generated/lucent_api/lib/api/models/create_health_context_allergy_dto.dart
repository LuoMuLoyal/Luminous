// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_allergy_kind.dart';
import 'user_allergy_severity.dart';

part 'create_health_context_allergy_dto.g.dart';

@JsonSerializable()
class CreateHealthContextAllergyDto {
  const CreateHealthContextAllergyDto({
    required this.kind,
    required this.label,
    this.reaction,
    this.severity,
    this.note,
    this.recordedAt,
  });

  factory CreateHealthContextAllergyDto.fromJson(Map<String, Object?> json) =>
      _$CreateHealthContextAllergyDtoFromJson(json);

  /// Allergy kind.
  final UserAllergyKind kind;

  /// User-visible allergy label.
  final String label;

  /// Recorded reaction.
  final String? reaction;

  /// Severity level. Defaults to unknown.
  final UserAllergySeverity? severity;

  /// User note for the allergy.
  final String? note;

  /// When this allergy was recorded in ISO 8601 format.
  final String? recordedAt;

  Map<String, Object?> toJson() => _$CreateHealthContextAllergyDtoToJson(this);
}
