//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_current_medicine_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateCurrentMedicineRequest {
  /// Returns a new [UpdateCurrentMedicineRequest] instance.
  UpdateCurrentMedicineRequest({
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
    unknownEnumValue:
        UpdateCurrentMedicineRequestSource_Enum.unknownDefaultOpenApi,
  )
  final UpdateCurrentMedicineRequestSource_Enum? source_;

  /// Source-specific reference id.
  @JsonKey(name: r'sourceRefId', required: false, includeIfNull: false)
  final String? sourceRefId;

  /// Display name shown to the user.
  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final String? displayName;

  /// Strength text. Use null to clear.
  @JsonKey(name: r'strengthText', required: false, includeIfNull: false)
  final String? strengthText;

  /// Dose text. Use null to clear.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  /// Administration route. Use null to clear.
  @JsonKey(name: r'route', required: false, includeIfNull: false)
  final String? route;

  /// Start date in YYYY-MM-DD format. Use null to clear.
  @JsonKey(name: r'startedAt', required: false, includeIfNull: false)
  final String? startedAt;

  /// End date in YYYY-MM-DD format. Use null to clear.
  @JsonKey(name: r'endedAt', required: false, includeIfNull: false)
  final String? endedAt;

  /// User note. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// Whether the medicine is currently active.
  @JsonKey(name: r'isCurrent', required: false, includeIfNull: false)
  final bool? isCurrent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCurrentMedicineRequest &&
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

  factory UpdateCurrentMedicineRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCurrentMedicineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCurrentMedicineRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Upstream source.
enum UpdateCurrentMedicineRequestSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'manual')
  manual(r'manual'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateCurrentMedicineRequestSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
