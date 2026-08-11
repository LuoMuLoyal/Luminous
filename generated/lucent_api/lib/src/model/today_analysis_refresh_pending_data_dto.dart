//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_refresh_pending_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisRefreshPendingDataDto {
  /// Returns a new [TodayAnalysisRefreshPendingDataDto] instance.
  TodayAnalysisRefreshPendingDataDto({
    required this.status,

    required this.jobId,
  });

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisRefreshPendingDataDtoStatusEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisRefreshPendingDataDtoStatusEnum status;

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisRefreshPendingDataDto &&
          other.status == status &&
          other.jobId == jobId;

  @override
  int get hashCode => status.hashCode + jobId.hashCode;

  factory TodayAnalysisRefreshPendingDataDto.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisRefreshPendingDataDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisRefreshPendingDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisRefreshPendingDataDtoStatusEnum {
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisRefreshPendingDataDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
