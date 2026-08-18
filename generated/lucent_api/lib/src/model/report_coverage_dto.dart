//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_coverage_dimension_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_coverage_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportCoverageDto {
  /// Returns a new [ReportCoverageDto] instance.
  ReportCoverageDto({
    required this.medication,

    required this.water,

    required this.sleep,
  });

  @JsonKey(name: r'medication', required: true, includeIfNull: false)
  final ReportCoverageDimensionDto medication;

  @JsonKey(name: r'water', required: true, includeIfNull: false)
  final ReportCoverageDimensionDto water;

  @JsonKey(name: r'sleep', required: true, includeIfNull: false)
  final ReportCoverageDimensionDto sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportCoverageDto &&
          other.medication == medication &&
          other.water == water &&
          other.sleep == sleep;

  @override
  int get hashCode => medication.hashCode + water.hashCode + sleep.hashCode;

  factory ReportCoverageDto.fromJson(Map<String, dynamic> json) =>
      _$ReportCoverageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportCoverageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
