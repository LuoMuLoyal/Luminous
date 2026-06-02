//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/unit_system.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_health_context_profile_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateHealthContextProfileDto {
  /// Returns a new [UpdateHealthContextProfileDto] instance.
  UpdateHealthContextProfileDto({

     this.locale,

     this.timezone,

     this.unitSystem,
  });

      /// Preferred locale. Use null to clear and follow the client default.
  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final Object? locale;



      /// Preferred timezone. Use null to clear.
  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final Object? timezone;



      /// Preferred unit system. Use null to clear.
  @JsonKey(
    
    name: r'unitSystem',
    required: false,
    includeIfNull: false,
  unknownEnumValue: UnitSystem.unknownDefaultOpenApi,
  )


  final UnitSystem? unitSystem;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateHealthContextProfileDto &&
      other.locale == locale &&
      other.timezone == timezone &&
      other.unitSystem == unitSystem;

    @override
    int get hashCode =>
        (locale == null ? 0 : locale.hashCode) +
        (timezone == null ? 0 : timezone.hashCode) +
        (unitSystem == null ? 0 : unitSystem.hashCode);

  factory UpdateHealthContextProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateHealthContextProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateHealthContextProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

