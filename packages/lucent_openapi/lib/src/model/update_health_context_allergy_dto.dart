//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_allergy_severity.dart';
import 'package:lucent_openapi/src/model/user_allergy_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_health_context_allergy_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateHealthContextAllergyDto {
  /// Returns a new [UpdateHealthContextAllergyDto] instance.
  UpdateHealthContextAllergyDto({
    this.kind,

    this.label,

    this.reaction,

    this.severity,

    this.note,

    this.recordedAt,

    this.isActive,
  });

  /// Allergy kind.
  @JsonKey(
    name: r'kind',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UserAllergyKind.unknownDefaultOpenApi,
  )
  final UserAllergyKind? kind;

  /// User-visible allergy label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  /// Recorded reaction. Use null to clear.
  @JsonKey(name: r'reaction', required: false, includeIfNull: false)
  final Object? reaction;

  /// Severity level.
  @JsonKey(
    name: r'severity',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UserAllergySeverity.unknownDefaultOpenApi,
  )
  final UserAllergySeverity? severity;

  /// User note for the allergy. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  /// When this allergy was recorded in ISO 8601 format.
  @JsonKey(name: r'recordedAt', required: false, includeIfNull: false)
  final Object? recordedAt;

  /// Whether the allergy is currently active.
  @JsonKey(name: r'isActive', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateHealthContextAllergyDto &&
          other.kind == kind &&
          other.label == label &&
          other.reaction == reaction &&
          other.severity == severity &&
          other.note == note &&
          other.recordedAt == recordedAt &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      kind.hashCode +
      label.hashCode +
      (reaction == null ? 0 : reaction.hashCode) +
      severity.hashCode +
      (note == null ? 0 : note.hashCode) +
      (recordedAt == null ? 0 : recordedAt.hashCode) +
      isActive.hashCode;

  factory UpdateHealthContextAllergyDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateHealthContextAllergyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateHealthContextAllergyDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
