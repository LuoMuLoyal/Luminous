//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_context_response_dto_allergies_inner.dart';
import 'package:lucent_api/src/model/health_context_response_dto_conditions_inner.dart';
import 'package:lucent_api/src/model/health_context_response_dto_current_medicines_inner.dart';
import 'package:lucent_api/src/model/health_context_response_dto_summary.dart';
import 'package:lucent_api/src/model/health_context_response_dto_profile.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseDto {
  /// Returns a new [HealthContextResponseDto] instance.
  HealthContextResponseDto({
    required this.summary,

    required this.profile,

    required this.allergies,

    required this.conditions,

    required this.currentMedicines,
  });

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final HealthContextResponseDtoSummary summary;

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final HealthContextResponseDtoProfile profile;

  @JsonKey(name: r'allergies', required: true, includeIfNull: false)
  final List<HealthContextResponseDtoAllergiesInner> allergies;

  @JsonKey(name: r'conditions', required: true, includeIfNull: false)
  final List<HealthContextResponseDtoConditionsInner> conditions;

  @JsonKey(name: r'currentMedicines', required: true, includeIfNull: false)
  final List<HealthContextResponseDtoCurrentMedicinesInner> currentMedicines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseDto &&
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

  factory HealthContextResponseDto.fromJson(Map<String, dynamic> json) =>
      _$HealthContextResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthContextResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
