//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_current_medicine_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCurrentMedicineDto {
  /// Returns a new [CreateCurrentMedicineDto] instance.
  CreateCurrentMedicineDto({
    required this.source_,

    this.sourceRefId,

    required this.displayName,

    this.strengthText,

    this.doseText,

    this.route,

    this.startedAt,

    this.endedAt,

    this.note,
  });

  /// Upstream source used to anchor this medicine.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineSource.unknownDefaultOpenApi,
  )
  final MedicineSource source_;

  /// Source-specific reference id. Required for drugbank and cn sources.
  @JsonKey(name: r'sourceRefId', required: false, includeIfNull: false)
  final String? sourceRefId;

  /// Display name shown to the user.
  @JsonKey(name: r'displayName', required: true, includeIfNull: false)
  final String displayName;

  /// Strength text.
  @JsonKey(name: r'strengthText', required: false, includeIfNull: false)
  final String? strengthText;

  /// Dose text.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  /// Administration route.
  @JsonKey(name: r'route', required: false, includeIfNull: false)
  final String? route;

  /// Start date in YYYY-MM-DD format.
  @JsonKey(name: r'startedAt', required: false, includeIfNull: false)
  final Object? startedAt;

  /// End date in YYYY-MM-DD format.
  @JsonKey(name: r'endedAt', required: false, includeIfNull: false)
  final Object? endedAt;

  /// User note for the medicine.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCurrentMedicineDto &&
          other.source_ == source_ &&
          other.sourceRefId == sourceRefId &&
          other.displayName == displayName &&
          other.strengthText == strengthText &&
          other.doseText == doseText &&
          other.route == route &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.note == note;

  @override
  int get hashCode =>
      source_.hashCode +
      sourceRefId.hashCode +
      displayName.hashCode +
      strengthText.hashCode +
      doseText.hashCode +
      route.hashCode +
      (startedAt == null ? 0 : startedAt.hashCode) +
      (endedAt == null ? 0 : endedAt.hashCode) +
      note.hashCode;

  factory CreateCurrentMedicineDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCurrentMedicineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCurrentMedicineDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
