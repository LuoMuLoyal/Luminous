//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/context_response_current_medicines.dart';
import 'package:lucent_api/src/model/context_response_summary.dart';
import 'package:lucent_api/src/model/context_response_conditions.dart';
import 'package:lucent_api/src/model/context_response_profile.dart';
import 'package:lucent_api/src/model/context_response_allergies.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'context_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContextResponse {
  /// Returns a new [ContextResponse] instance.
  ContextResponse({
    required this.summary,

    required this.profile,

    required this.allergies,

    required this.conditions,

    required this.currentMedicines,
  });

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final ContextResponseSummary summary;

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final ContextResponseProfile profile;

  @JsonKey(name: r'allergies', required: true, includeIfNull: false)
  final List<ContextResponseAllergies> allergies;

  @JsonKey(name: r'conditions', required: true, includeIfNull: false)
  final List<ContextResponseConditions> conditions;

  @JsonKey(name: r'currentMedicines', required: true, includeIfNull: false)
  final List<ContextResponseCurrentMedicines> currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextResponse &&
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

  factory ContextResponse.fromJson(Map<String, dynamic> json) =>
      _$ContextResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContextResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
