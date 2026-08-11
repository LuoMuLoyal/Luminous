//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_async_response_dto_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncResponseDto {
  /// Returns a new [TodayAnalysisAsyncResponseDto] instance.
  TodayAnalysisAsyncResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final TodayAnalysisAsyncResponseDtoData data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory TodayAnalysisAsyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisAsyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisAsyncResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
