//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_allergy_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAllergyRequest {
  /// Returns a new [UpdateAllergyRequest] instance.
  UpdateAllergyRequest({
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
    unknownEnumValue: UpdateAllergyRequestKindEnum.unknownDefaultOpenApi,
  )
  final UpdateAllergyRequestKindEnum? kind;

  /// User-visible allergy label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  /// Recorded reaction. Use null to clear.
  @JsonKey(name: r'reaction', required: false, includeIfNull: false)
  final String? reaction;

  /// Severity level.
  @JsonKey(
    name: r'severity',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UpdateAllergyRequestSeverityEnum.unknownDefaultOpenApi,
  )
  final UpdateAllergyRequestSeverityEnum? severity;

  /// User note for the allergy. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// When this allergy was recorded in ISO 8601 format.
  @JsonKey(name: r'recordedAt', required: false, includeIfNull: false)
  final String? recordedAt;

  /// Whether the allergy is currently active.
  @JsonKey(name: r'isActive', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAllergyRequest &&
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
      (severity == null ? 0 : severity.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (recordedAt == null ? 0 : recordedAt.hashCode) +
      isActive.hashCode;

  factory UpdateAllergyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAllergyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAllergyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Allergy kind.
enum UpdateAllergyRequestKindEnum {
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

  const UpdateAllergyRequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Severity level.
enum UpdateAllergyRequestSeverityEnum {
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

  const UpdateAllergyRequestSeverityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
