//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_allergy_severity.dart';
import 'package:lucent_openapi/src/model/user_allergy_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_health_context_allergy_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateHealthContextAllergyDto {
  /// Returns a new [CreateHealthContextAllergyDto] instance.
  CreateHealthContextAllergyDto({
    required this.kind,

    required this.label,

    this.reaction,

    this.severity,

    this.note,

    this.recordedAt,
  });

  /// Allergy kind.
  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: UserAllergyKind.unknownDefaultOpenApi,
  )
  final UserAllergyKind kind;

  /// User-visible allergy label.
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Recorded reaction.
  @JsonKey(name: r'reaction', required: false, includeIfNull: false)
  final String? reaction;

  /// Severity level. Defaults to unknown.
  @JsonKey(
    name: r'severity',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UserAllergySeverity.unknownDefaultOpenApi,
  )
  final UserAllergySeverity? severity;

  /// User note for the allergy.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// When this allergy was recorded in ISO 8601 format.
  @JsonKey(name: r'recordedAt', required: false, includeIfNull: false)
  final String? recordedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateHealthContextAllergyDto &&
          other.kind == kind &&
          other.label == label &&
          other.reaction == reaction &&
          other.severity == severity &&
          other.note == note &&
          other.recordedAt == recordedAt;

  @override
  int get hashCode =>
      kind.hashCode +
      label.hashCode +
      reaction.hashCode +
      severity.hashCode +
      note.hashCode +
      recordedAt.hashCode;

  factory CreateHealthContextAllergyDto.fromJson(Map<String, dynamic> json) =>
      _$CreateHealthContextAllergyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHealthContextAllergyDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
