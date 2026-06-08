//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_reminder_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderResponseDto {
  /// Returns a new [MedicineReminderResponseDto] instance.
  MedicineReminderResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final MedicineReminderItemDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory MedicineReminderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineReminderResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineReminderResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
