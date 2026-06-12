//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/today_analysis_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisResponseDto {
  /// Returns a new [TodayAnalysisResponseDto] instance.
  TodayAnalysisResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final TodayAnalysisDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory TodayAnalysisResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
