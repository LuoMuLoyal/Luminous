//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_condition_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryConditionDto {
  /// Returns a new [ClinicSummaryConditionDto] instance.
  ClinicSummaryConditionDto({
    required this.label,

    required this.status,

    this.diagnosedYear,
  });

  /// Condition label (e.g. 高血压)
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Current status
  @JsonKey(name: r'status', required: true, includeIfNull: true)
  final String? status;

  /// Year of diagnosis (YYYY)
  @JsonKey(name: r'diagnosedYear', required: false, includeIfNull: false)
  final num? diagnosedYear;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryConditionDto &&
          other.label == label &&
          other.status == status &&
          other.diagnosedYear == diagnosedYear;

  @override
  int get hashCode =>
      label.hashCode +
      (status == null ? 0 : status.hashCode) +
      (diagnosedYear == null ? 0 : diagnosedYear.hashCode);

  factory ClinicSummaryConditionDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryConditionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryConditionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
