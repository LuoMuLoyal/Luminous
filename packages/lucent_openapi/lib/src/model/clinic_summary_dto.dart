//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/clinic_summary_profile_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryDto {
  /// Returns a new [ClinicSummaryDto] instance.
  ClinicSummaryDto({
    required this.generatedAt,

    required this.dataRange,

    required this.profile,

    required this.allergies,

    required this.conditions,

    required this.currentMedicines,

    this.findings,

    required this.disclaimer,
  });

  /// Generated timestamp
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// Data range (e.g. last_30_days)
  @JsonKey(name: r'dataRange', required: true, includeIfNull: false)
  final String dataRange;

  /// De-identified profile
  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final ClinicSummaryProfileDto profile;

  /// Active allergies
  @JsonKey(name: r'allergies', required: true, includeIfNull: false)
  final List<String> allergies;

  /// Active conditions
  @JsonKey(name: r'conditions', required: true, includeIfNull: false)
  final List<String> conditions;

  /// Current medicines
  @JsonKey(name: r'currentMedicines', required: true, includeIfNull: false)
  final List<String> currentMedicines;

  /// Key findings / notes for the doctor
  @JsonKey(name: r'findings', required: false, includeIfNull: false)
  final List<String>? findings;

  /// Disclaimer text
  @JsonKey(name: r'disclaimer', required: true, includeIfNull: false)
  final String disclaimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryDto &&
          other.generatedAt == generatedAt &&
          other.dataRange == dataRange &&
          other.profile == profile &&
          other.allergies == allergies &&
          other.conditions == conditions &&
          other.currentMedicines == currentMedicines &&
          other.findings == findings &&
          other.disclaimer == disclaimer;

  @override
  int get hashCode =>
      generatedAt.hashCode +
      dataRange.hashCode +
      profile.hashCode +
      allergies.hashCode +
      conditions.hashCode +
      currentMedicines.hashCode +
      findings.hashCode +
      disclaimer.hashCode;

  factory ClinicSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
