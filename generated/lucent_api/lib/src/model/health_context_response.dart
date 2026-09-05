//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_context_response_conditions.dart';
import 'package:lucent_api/src/model/health_context_response_allergies.dart';
import 'package:lucent_api/src/model/health_context_response_summary.dart';
import 'package:lucent_api/src/model/health_context_response_profile.dart';
import 'package:lucent_api/src/model/health_context_response_current_medicines.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponse {
  /// Returns a new [HealthContextResponse] instance.
  HealthContextResponse({
    required this.summary,

    required this.profile,

    required this.allergies,

    required this.conditions,

    required this.currentMedicines,
  });

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final HealthContextResponseSummary summary;

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final HealthContextResponseProfile profile;

  @JsonKey(name: r'allergies', required: true, includeIfNull: false)
  final List<HealthContextResponseAllergies> allergies;

  @JsonKey(name: r'conditions', required: true, includeIfNull: false)
  final List<HealthContextResponseConditions> conditions;

  @JsonKey(name: r'currentMedicines', required: true, includeIfNull: false)
  final List<HealthContextResponseCurrentMedicines> currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponse &&
          other.summary == summary &&
          other.profile == profile &&
          other.allergies == allergies &&
          other.conditions == conditions &&
          other.currentMedicines == currentMedicines;

  @override
  int get hashCode =>
      summary.hashCode +
      profile.hashCode +
      allergies.hashCode +
      conditions.hashCode +
      currentMedicines.hashCode;

  factory HealthContextResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthContextResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthContextResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
