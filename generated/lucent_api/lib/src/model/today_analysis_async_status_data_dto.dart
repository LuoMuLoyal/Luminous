//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_status_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncStatusDataDto {
  /// Returns a new [TodayAnalysisAsyncStatusDataDto] instance.
  TodayAnalysisAsyncStatusDataDto({required this.status});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisAsyncStatusDataDtoStatusEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisAsyncStatusDataDtoStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncStatusDataDto && other.status == status;

  @override
  int get hashCode => status.hashCode;

  factory TodayAnalysisAsyncStatusDataDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisAsyncStatusDataDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisAsyncStatusDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisAsyncStatusDataDtoStatusEnum {
  @JsonValue(r'empty')
  empty(r'empty'),
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'stale')
  stale(r'stale'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisAsyncStatusDataDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
