//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_status_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncStatusData {
  /// Returns a new [TodayAnalysisAsyncStatusData] instance.
  TodayAnalysisAsyncStatusData({required this.status});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisAsyncStatusDataStatusEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisAsyncStatusDataStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncStatusData && other.status == status;

  @override
  int get hashCode => status.hashCode;

  factory TodayAnalysisAsyncStatusData.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisAsyncStatusDataFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisAsyncStatusDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisAsyncStatusDataStatusEnum {
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

  const TodayAnalysisAsyncStatusDataStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
