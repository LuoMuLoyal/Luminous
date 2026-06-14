//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_stream_result_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisStreamResultDto {
  /// Returns a new [TodayAnalysisStreamResultDto] instance.
  TodayAnalysisStreamResultDto({required this.event, required this.data});

  @JsonKey(
    name: r'event',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisStreamResultDtoEventEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisStreamResultDtoEventEnum event;

  /// SSE payload object. event=summary => { summary }, event=result => TodayAnalysisDataDto-like object, event=error => { message, code?, statusCode? }, event=done => {}.
  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final Map<String, Object> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisStreamResultDto &&
          other.event == event &&
          other.data == data;

  @override
  int get hashCode => event.hashCode + data.hashCode;

  factory TodayAnalysisStreamResultDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisStreamResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisStreamResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisStreamResultDtoEventEnum {
  @JsonValue(r'summary')
  summary(r'summary'),
  @JsonValue(r'result')
  result(r'result'),
  @JsonValue(r'error')
  error(r'error'),
  @JsonValue(r'done')
  done(r'done'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisStreamResultDtoEventEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
