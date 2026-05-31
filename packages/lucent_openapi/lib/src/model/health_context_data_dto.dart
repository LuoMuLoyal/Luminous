//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_current_medicine_item_dto.dart';
import 'package:lucent_openapi/src/model/user_health_profile_dto.dart';
import 'package:lucent_openapi/src/model/user_allergy_item_dto.dart';
import 'package:lucent_openapi/src/model/user_condition_item_dto.dart';
import 'package:lucent_openapi/src/model/user_health_summary_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_data_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextDataDto {
  /// Returns a new [HealthContextDataDto] instance.
  HealthContextDataDto({

    required  this.summary,

    required  this.profile,

    required  this.allergies,

    required  this.conditions,

    required  this.currentMedicines,
  });

  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final UserHealthSummaryDto summary;



  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final UserHealthProfileDto profile;



  @JsonKey(
    
    name: r'allergies',
    required: true,
    includeIfNull: false,
  )


  final List<UserAllergyItemDto> allergies;



  @JsonKey(
    
    name: r'conditions',
    required: true,
    includeIfNull: false,
  )


  final List<UserConditionItemDto> conditions;



  @JsonKey(
    
    name: r'currentMedicines',
    required: true,
    includeIfNull: false,
  )


  final List<UserCurrentMedicineItemDto> currentMedicines;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HealthContextDataDto &&
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

  factory HealthContextDataDto.fromJson(Map<String, dynamic> json) => _$HealthContextDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthContextDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

