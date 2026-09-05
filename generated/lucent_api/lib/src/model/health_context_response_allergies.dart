//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_allergies.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseAllergies {
  /// Returns a new [HealthContextResponseAllergies] instance.
  HealthContextResponseAllergies({
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

  /// Allergy id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Allergy kind.
  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthContextResponseAllergiesKindEnum.unknownDefaultOpenApi,
  )
  final HealthContextResponseAllergiesKindEnum kind;

  /// User-visible allergy label.
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'reaction', required: true, includeIfNull: true)
  final String? reaction;

  @JsonKey(
    name: r'severity',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        HealthContextResponseAllergiesSeverityEnum.unknownDefaultOpenApi,
  )
  final HealthContextResponseAllergiesSeverityEnum? severity;

  /// Whether the allergy is currently active.
  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final String? note;

  /// Sparse allergy extensions stored in jsonb.
  @JsonKey(name: r'extras', required: true, includeIfNull: true)
  final Object? extras;

  @JsonKey(name: r'recordedAt', required: true, includeIfNull: true)
  final String? recordedAt;

  /// Created time in ISO 8601 format.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseAllergies &&
          other.id == id &&
          other.kind == kind &&
          other.label == label &&
          other.reaction == reaction &&
          other.severity == severity &&
          other.isActive == isActive &&
          other.note == note &&
          other.extras == extras &&
          other.recordedAt == recordedAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      label.hashCode +
      (reaction == null ? 0 : reaction.hashCode) +
      (severity == null ? 0 : severity.hashCode) +
      isActive.hashCode +
      (note == null ? 0 : note.hashCode) +
      (extras == null ? 0 : extras.hashCode) +
      (recordedAt == null ? 0 : recordedAt.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory HealthContextResponseAllergies.fromJson(Map<String, dynamic> json) =>
      _$HealthContextResponseAllergiesFromJson(json);

  Map<String, dynamic> toJson() => _$HealthContextResponseAllergiesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Allergy kind.
enum HealthContextResponseAllergiesKindEnum {
  @JsonValue(r'drug')
  drug(r'drug'),
  @JsonValue(r'food')
  food(r'food'),
  @JsonValue(r'environment')
  environment(r'environment'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthContextResponseAllergiesKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthContextResponseAllergiesSeverityEnum {
  @JsonValue(r'mild')
  mild(r'mild'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'severe')
  severe(r'severe'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthContextResponseAllergiesSeverityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
