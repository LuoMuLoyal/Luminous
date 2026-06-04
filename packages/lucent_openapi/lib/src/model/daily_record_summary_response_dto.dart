//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_summary_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryResponseDto {
  /// Returns a new [DailyRecordSummaryResponseDto] instance.
  DailyRecordSummaryResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final DailyRecordSummaryDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory DailyRecordSummaryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordSummaryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordSummaryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
