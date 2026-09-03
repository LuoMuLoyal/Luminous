//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_dose_logs_controller_update_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDoseLogsControllerUpdateV1Request {
  /// Returns a new [MedicineDoseLogsControllerUpdateV1Request] instance.
  MedicineDoseLogsControllerUpdateV1Request({
    this.status,

    this.doseText,

    this.note,
  });

  @JsonKey(
    name: r'status',
    required: false,
    includeIfNull: false,
    unknownEnumValue: MedicineDoseLogsControllerUpdateV1RequestStatusEnum
        .unknownDefaultOpenApi,
  )
  final MedicineDoseLogsControllerUpdateV1RequestStatusEnum? status;

  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDoseLogsControllerUpdateV1Request &&
          other.status == status &&
          other.doseText == doseText &&
          other.note == note;

  @override
  int get hashCode =>
      status.hashCode +
      (doseText == null ? 0 : doseText.hashCode) +
      (note == null ? 0 : note.hashCode);

  factory MedicineDoseLogsControllerUpdateV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDoseLogsControllerUpdateV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDoseLogsControllerUpdateV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineDoseLogsControllerUpdateV1RequestStatusEnum {
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

  const MedicineDoseLogsControllerUpdateV1RequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
