//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/dose_log_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_dose_log_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateDoseLogDto {
  /// Returns a new [UpdateDoseLogDto] instance.
  UpdateDoseLogDto({this.status, this.doseText, this.note});

  @JsonKey(
    name: r'status',
    required: false,
    includeIfNull: false,
    unknownEnumValue: DoseLogStatus.unknownDefaultOpenApi,
  )
  final DoseLogStatus? status;

  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final Object? doseText;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDoseLogDto &&
          other.status == status &&
          other.doseText == doseText &&
          other.note == note;

  @override
  int get hashCode =>
      status.hashCode +
      (doseText == null ? 0 : doseText.hashCode) +
      (note == null ? 0 : note.hashCode);

  factory UpdateDoseLogDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateDoseLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDoseLogDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
