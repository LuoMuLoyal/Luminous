//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_refresh_ready_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisRefreshReadyDataDto {
  /// Returns a new [TodayAnalysisRefreshReadyDataDto] instance.
  TodayAnalysisRefreshReadyDataDto({
    required this.status,

    required this.analysis,
  });

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisRefreshReadyDataDtoStatusEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisRefreshReadyDataDtoStatusEnum status;

  @JsonKey(name: r'analysis', required: true, includeIfNull: false)
  final TodayAnalysisDataDto analysis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisRefreshReadyDataDto &&
          other.status == status &&
          other.analysis == analysis;

  @override
  int get hashCode => status.hashCode + analysis.hashCode;

  factory TodayAnalysisRefreshReadyDataDto.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisRefreshReadyDataDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisRefreshReadyDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisRefreshReadyDataDtoStatusEnum {
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisRefreshReadyDataDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
