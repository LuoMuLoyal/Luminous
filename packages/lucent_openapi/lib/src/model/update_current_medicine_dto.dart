//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_current_medicine_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateCurrentMedicineDto {
  /// Returns a new [UpdateCurrentMedicineDto] instance.
  UpdateCurrentMedicineDto({
    this.source_,

    this.sourceRefId,

    this.displayName,

    this.strengthText,

    this.doseText,

    this.route,

    this.startedAt,

    this.endedAt,

    this.note,

    this.isCurrent,
  });

  /// Upstream source.
  @JsonKey(
    name: r'source',
    required: false,
    includeIfNull: false,
    unknownEnumValue: MedicineSource.unknownDefaultOpenApi,
  )
  final MedicineSource? source_;

  /// Source-specific reference id.
  @JsonKey(name: r'sourceRefId', required: false, includeIfNull: false)
  final Object? sourceRefId;

  /// Display name shown to the user.
  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final String? displayName;

  /// Strength text. Use null to clear.
  @JsonKey(name: r'strengthText', required: false, includeIfNull: false)
  final Object? strengthText;

  /// Dose text. Use null to clear.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final Object? doseText;

  /// Administration route. Use null to clear.
  @JsonKey(name: r'route', required: false, includeIfNull: false)
  final Object? route;

  /// Start date in YYYY-MM-DD format. Use null to clear.
  @JsonKey(name: r'startedAt', required: false, includeIfNull: false)
  final Object? startedAt;

  /// End date in YYYY-MM-DD format. Use null to clear.
  @JsonKey(name: r'endedAt', required: false, includeIfNull: false)
  final Object? endedAt;

  /// User note. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  /// Whether the medicine is currently active.
  @JsonKey(name: r'isCurrent', required: false, includeIfNull: false)
  final bool? isCurrent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCurrentMedicineDto &&
          other.source_ == source_ &&
          other.sourceRefId == sourceRefId &&
          other.displayName == displayName &&
          other.strengthText == strengthText &&
          other.doseText == doseText &&
          other.route == route &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.note == note &&
          other.isCurrent == isCurrent;

  @override
  int get hashCode =>
      source_.hashCode +
      (sourceRefId == null ? 0 : sourceRefId.hashCode) +
      displayName.hashCode +
      (strengthText == null ? 0 : strengthText.hashCode) +
      (doseText == null ? 0 : doseText.hashCode) +
      (route == null ? 0 : route.hashCode) +
      (startedAt == null ? 0 : startedAt.hashCode) +
      (endedAt == null ? 0 : endedAt.hashCode) +
      (note == null ? 0 : note.hashCode) +
      isCurrent.hashCode;

  factory UpdateCurrentMedicineDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCurrentMedicineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCurrentMedicineDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
