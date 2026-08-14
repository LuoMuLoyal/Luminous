//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_coverage_entry_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_coverage_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryCoverageDto {
  /// Returns a new [ClinicSummaryCoverageDto] instance.
  ClinicSummaryCoverageDto({
    required this.checkIns,

    required this.water,

    required this.dose,

    required this.sleep,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: false)
  final ClinicSummaryCoverageEntryDto checkIns;

  @JsonKey(name: r'water', required: true, includeIfNull: false)
  final ClinicSummaryCoverageEntryDto water;

  @JsonKey(name: r'dose', required: true, includeIfNull: false)
  final ClinicSummaryCoverageEntryDto dose;

  @JsonKey(name: r'sleep', required: true, includeIfNull: false)
  final ClinicSummaryCoverageEntryDto sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryCoverageDto &&
          other.checkIns == checkIns &&
          other.water == water &&
          other.dose == dose &&
          other.sleep == sleep;

  @override
  int get hashCode =>
      checkIns.hashCode + water.hashCode + dose.hashCode + sleep.hashCode;

  factory ClinicSummaryCoverageDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryCoverageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryCoverageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
