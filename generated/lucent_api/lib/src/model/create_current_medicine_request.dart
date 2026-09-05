//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_current_medicine_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCurrentMedicineRequest {
  /// Returns a new [CreateCurrentMedicineRequest] instance.
  CreateCurrentMedicineRequest({
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
    unknownEnumValue:
        CreateCurrentMedicineRequestSource_Enum.unknownDefaultOpenApi,
  )
  final CreateCurrentMedicineRequestSource_Enum source_;

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
  final String? startedAt;

  /// End date in YYYY-MM-DD format.
  @JsonKey(name: r'endedAt', required: false, includeIfNull: false)
  final String? endedAt;

  /// User note for the medicine.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCurrentMedicineRequest &&
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

  factory CreateCurrentMedicineRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCurrentMedicineRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCurrentMedicineRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Upstream source used to anchor this medicine.
enum CreateCurrentMedicineRequestSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'manual')
  manual(r'manual'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateCurrentMedicineRequestSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
