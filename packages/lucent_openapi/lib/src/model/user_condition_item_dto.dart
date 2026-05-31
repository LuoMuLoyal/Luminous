//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_condition_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_condition_item_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserConditionItemDto {
  /// Returns a new [UserConditionItemDto] instance.
  UserConditionItemDto({

    required  this.id,

    required  this.label,

    required  this.status,

    required  this.diagnosedAt,

    required  this.resolvedAt,

    required  this.note,

    required  this.extras,

    required  this.createdAt,

    required  this.updatedAt,
  });

      /// Condition id.
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// Condition label.
  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



      /// Condition status.
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  unknownEnumValue: UserConditionStatus.unknownDefaultOpenApi,
  )


  final UserConditionStatus status;



      /// Diagnosis date in YYYY-MM-DD format.
  @JsonKey(
    
    name: r'diagnosedAt',
    required: true,
    includeIfNull: true,
  )


  final Object? diagnosedAt;



      /// Resolved date in YYYY-MM-DD format.
  @JsonKey(
    
    name: r'resolvedAt',
    required: true,
    includeIfNull: true,
  )


  final Object? resolvedAt;



      /// User note for the condition.
  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: true,
  )


  final Object? note;



      /// Sparse condition extensions stored in jsonb.
  @JsonKey(
    
    name: r'extras',
    required: true,
    includeIfNull: true,
  )


  final Map<String, Object>? extras;



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
    bool operator ==(Object other) => identical(this, other) || other is UserConditionItemDto &&
      other.id == id &&
      other.label == label &&
      other.status == status &&
      other.diagnosedAt == diagnosedAt &&
      other.resolvedAt == resolvedAt &&
      other.note == note &&
      other.extras == extras &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        label.hashCode +
        status.hashCode +
        (diagnosedAt == null ? 0 : diagnosedAt.hashCode) +
        (resolvedAt == null ? 0 : resolvedAt.hashCode) +
        (note == null ? 0 : note.hashCode) +
        (extras == null ? 0 : extras.hashCode) +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory UserConditionItemDto.fromJson(Map<String, dynamic> json) => _$UserConditionItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserConditionItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

