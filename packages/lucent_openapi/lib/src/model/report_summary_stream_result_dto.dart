//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_stream_result_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryStreamResultDto {
  /// Returns a new [ReportSummaryStreamResultDto] instance.
  ReportSummaryStreamResultDto({required this.event, required this.data});

  @JsonKey(
    name: r'event',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportSummaryStreamResultDtoEventEnum.unknownDefaultOpenApi,
  )
  final ReportSummaryStreamResultDtoEventEnum event;

  /// SSE payload object. event=summary => { summary }, event=result => ReportSummaryDataDto-like object, event=error => { message, code?, statusCode? }, event=done => {}.
  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final Map<String, Object> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryStreamResultDto &&
          other.event == event &&
          other.data == data;

  @override
  int get hashCode => event.hashCode + data.hashCode;

  factory ReportSummaryStreamResultDto.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryStreamResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryStreamResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportSummaryStreamResultDtoEventEnum {
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

  const ReportSummaryStreamResultDtoEventEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
