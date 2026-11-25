//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_status_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncStatusData {
  /// Returns a new [AnalysisAsyncStatusData] instance.
  AnalysisAsyncStatusData({required this.status});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AnalysisAsyncStatusDataStatusEnum.unknownDefaultOpenApi,
  )
  final AnalysisAsyncStatusDataStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncStatusData && other.status == status;

  @override
  int get hashCode => status.hashCode;

  factory AnalysisAsyncStatusData.fromJson(Map<String, dynamic> json) =>
      _$AnalysisAsyncStatusDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisAsyncStatusDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisAsyncStatusDataStatusEnum {
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

  const AnalysisAsyncStatusDataStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
