//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_refresh_ready_data_analysis.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_refresh_ready_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisRefreshReadyData {
  /// Returns a new [AnalysisRefreshReadyData] instance.
  AnalysisRefreshReadyData({required this.status, required this.analysis});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AnalysisRefreshReadyDataStatusEnum.unknownDefaultOpenApi,
  )
  final AnalysisRefreshReadyDataStatusEnum status;

  @JsonKey(name: r'analysis', required: true, includeIfNull: false)
  final AnalysisRefreshReadyDataAnalysis analysis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisRefreshReadyData &&
          other.status == status &&
          other.analysis == analysis;

  @override
  int get hashCode => status.hashCode + analysis.hashCode;

  factory AnalysisRefreshReadyData.fromJson(Map<String, dynamic> json) =>
      _$AnalysisRefreshReadyDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisRefreshReadyDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisRefreshReadyDataStatusEnum {
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AnalysisRefreshReadyDataStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
