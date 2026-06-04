//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_list_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_list_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordListResponseDto {
  /// Returns a new [DailyRecordListResponseDto] instance.
  DailyRecordListResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final DailyRecordListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory DailyRecordListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
