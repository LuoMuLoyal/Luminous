//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_dose_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateDoseLogRequest {
  /// Returns a new [UpdateDoseLogRequest] instance.
  UpdateDoseLogRequest({this.status, this.doseText, this.note});

  @JsonKey(
    name: r'status',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UpdateDoseLogRequestStatusEnum.unknownDefaultOpenApi,
  )
  final UpdateDoseLogRequestStatusEnum? status;

  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDoseLogRequest &&
          other.status == status &&
          other.doseText == doseText &&
          other.note == note;

  @override
  int get hashCode =>
      status.hashCode +
      (doseText == null ? 0 : doseText.hashCode) +
      (note == null ? 0 : note.hashCode);

  factory UpdateDoseLogRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDoseLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDoseLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum UpdateDoseLogRequestStatusEnum {
  @JsonValue(r'taken')
  taken(r'taken'),
  @JsonValue(r'skipped')
  skipped(r'skipped'),
  @JsonValue(r'missed')
  missed(r'missed'),
  @JsonValue(r'planned')
  planned(r'planned'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateDoseLogRequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
