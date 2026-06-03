//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_current_medicine_item_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserCurrentMedicineItemDto {
  /// Returns a new [UserCurrentMedicineItemDto] instance.
  UserCurrentMedicineItemDto({
    required this.id,

    required this.source_,

    required this.sourceRefId,

    required this.displayName,

    required this.strengthText,

    required this.doseText,

    required this.route,

    required this.startedAt,

    required this.endedAt,

    required this.isCurrent,

    required this.note,

    required this.sourcePayload,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Current medicine id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Upstream source used to anchor this medicine.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineSource.unknownDefaultOpenApi,
  )
  final MedicineSource source_;

  /// Source-specific reference id.
  @JsonKey(name: r'sourceRefId', required: true, includeIfNull: true)
  final Object? sourceRefId;

  /// Display name shown to the user.
  @JsonKey(name: r'displayName', required: true, includeIfNull: false)
  final String displayName;

  /// Strength text.
  @JsonKey(name: r'strengthText', required: true, includeIfNull: true)
  final Object? strengthText;

  /// Dose text.
  @JsonKey(name: r'doseText', required: true, includeIfNull: true)
  final Object? doseText;

  /// Administration route.
  @JsonKey(name: r'route', required: true, includeIfNull: true)
  final Object? route;

  /// Start date in YYYY-MM-DD format.
  @JsonKey(name: r'startedAt', required: true, includeIfNull: true)
  final Object? startedAt;

  /// End date in YYYY-MM-DD format.
  @JsonKey(name: r'endedAt', required: true, includeIfNull: true)
  final Object? endedAt;

  /// Whether the medicine is currently active.
  @JsonKey(name: r'isCurrent', required: true, includeIfNull: false)
  final bool isCurrent;

  /// User note for the medicine.
  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final Object? note;

  /// Original source payload stored in jsonb.
  @JsonKey(name: r'sourcePayload', required: true, includeIfNull: true)
  final Map<String, Object>? sourcePayload;

  /// Created time in ISO 8601 format.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCurrentMedicineItemDto &&
          other.id == id &&
          other.source_ == source_ &&
          other.sourceRefId == sourceRefId &&
          other.displayName == displayName &&
          other.strengthText == strengthText &&
          other.doseText == doseText &&
          other.route == route &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.isCurrent == isCurrent &&
          other.note == note &&
          other.sourcePayload == sourcePayload &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      source_.hashCode +
      (sourceRefId == null ? 0 : sourceRefId.hashCode) +
      displayName.hashCode +
      (strengthText == null ? 0 : strengthText.hashCode) +
      (doseText == null ? 0 : doseText.hashCode) +
      (route == null ? 0 : route.hashCode) +
      (startedAt == null ? 0 : startedAt.hashCode) +
      (endedAt == null ? 0 : endedAt.hashCode) +
      isCurrent.hashCode +
      (note == null ? 0 : note.hashCode) +
      (sourcePayload == null ? 0 : sourcePayload.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory UserCurrentMedicineItemDto.fromJson(Map<String, dynamic> json) =>
      _$UserCurrentMedicineItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserCurrentMedicineItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
