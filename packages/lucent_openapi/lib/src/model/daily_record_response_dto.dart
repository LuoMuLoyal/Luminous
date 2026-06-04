//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordResponseDto {
  /// Returns a new [DailyRecordResponseDto] instance.
  DailyRecordResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final DailyRecordItemDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory DailyRecordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
