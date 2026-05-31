//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_allergy_severity.dart';
import 'package:lucent_openapi/src/model/user_allergy_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_allergy_item_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserAllergyItemDto {
  /// Returns a new [UserAllergyItemDto] instance.
  UserAllergyItemDto({

    required  this.id,

    required  this.kind,

    required  this.label,

    required  this.reaction,

    required  this.severity,

    required  this.isActive,

    required  this.note,

    required  this.extras,

    required  this.recordedAt,

    required  this.createdAt,

    required  this.updatedAt,
  });

      /// Allergy id.
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// Allergy kind.
  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  unknownEnumValue: UserAllergyKind.unknownDefaultOpenApi,
  )


  final UserAllergyKind kind;



      /// User-visible allergy label.
  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



      /// Recorded reaction.
  @JsonKey(
    
    name: r'reaction',
    required: true,
    includeIfNull: true,
  )


  final Object? reaction;



      /// Severity level.
  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: true,
  unknownEnumValue: UserAllergySeverity.unknownDefaultOpenApi,
  )


  final UserAllergySeverity? severity;



      /// Whether the allergy is currently active.
  @JsonKey(
    
    name: r'isActive',
    required: true,
    includeIfNull: false,
  )


  final bool isActive;



      /// User note for the allergy.
  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: true,
  )


  final Object? note;



      /// Sparse allergy extensions stored in jsonb.
  @JsonKey(
    
    name: r'extras',
    required: true,
    includeIfNull: true,
  )


  final Map<String, Object>? extras;



      /// When this allergy was recorded.
  @JsonKey(
    
    name: r'recordedAt',
    required: true,
    includeIfNull: true,
  )


  final Object? recordedAt;



      /// Created time in ISO 8601 format.
  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;



      /// Updated time in ISO 8601 format.
  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final String updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserAllergyItemDto &&
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

  factory UserAllergyItemDto.fromJson(Map<String, dynamic> json) => _$UserAllergyItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserAllergyItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

