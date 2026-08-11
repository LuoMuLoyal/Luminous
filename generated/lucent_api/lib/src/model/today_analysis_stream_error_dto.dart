//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_stream_error_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisStreamErrorDto {
  /// Returns a new [TodayAnalysisStreamErrorDto] instance.
  TodayAnalysisStreamErrorDto({
    required this.message,

    this.code,

    this.statusCode,
  });

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final num? code;

  @JsonKey(name: r'statusCode', required: false, includeIfNull: false)
  final num? statusCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisStreamErrorDto &&
          other.message == message &&
          other.code == code &&
          other.statusCode == statusCode;

  @override
  int get hashCode => message.hashCode + code.hashCode + statusCode.hashCode;

  factory TodayAnalysisStreamErrorDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisStreamErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisStreamErrorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
