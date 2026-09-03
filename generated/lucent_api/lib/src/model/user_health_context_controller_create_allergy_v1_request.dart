//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_health_context_controller_create_allergy_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserHealthContextControllerCreateAllergyV1Request {
  /// Returns a new [UserHealthContextControllerCreateAllergyV1Request] instance.
  UserHealthContextControllerCreateAllergyV1Request({
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
    unknownEnumValue: UserHealthContextControllerCreateAllergyV1RequestKindEnum
        .unknownDefaultOpenApi,
  )
  final UserHealthContextControllerCreateAllergyV1RequestKindEnum kind;

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
    unknownEnumValue:
        UserHealthContextControllerCreateAllergyV1RequestSeverityEnum
            .unknownDefaultOpenApi,
  )
  final UserHealthContextControllerCreateAllergyV1RequestSeverityEnum? severity;

  /// User note for the allergy.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// When this allergy was recorded in ISO 8601 format.
  @JsonKey(name: r'recordedAt', required: false, includeIfNull: false)
  final String? recordedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHealthContextControllerCreateAllergyV1Request &&
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

  factory UserHealthContextControllerCreateAllergyV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$UserHealthContextControllerCreateAllergyV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserHealthContextControllerCreateAllergyV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Allergy kind.
enum UserHealthContextControllerCreateAllergyV1RequestKindEnum {
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

  const UserHealthContextControllerCreateAllergyV1RequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Severity level. Defaults to unknown.
enum UserHealthContextControllerCreateAllergyV1RequestSeverityEnum {
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

  const UserHealthContextControllerCreateAllergyV1RequestSeverityEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
