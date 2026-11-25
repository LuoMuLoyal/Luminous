//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_refresh_pending_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisRefreshPendingData {
  /// Returns a new [AnalysisRefreshPendingData] instance.
  AnalysisRefreshPendingData({required this.status, required this.jobId});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisRefreshPendingDataStatusEnum.unknownDefaultOpenApi,
  )
  final AnalysisRefreshPendingDataStatusEnum status;

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisRefreshPendingData &&
          other.status == status &&
          other.jobId == jobId;

  @override
  int get hashCode => status.hashCode + jobId.hashCode;

  factory AnalysisRefreshPendingData.fromJson(Map<String, dynamic> json) =>
      _$AnalysisRefreshPendingDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisRefreshPendingDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisRefreshPendingDataStatusEnum {
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AnalysisRefreshPendingDataStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
