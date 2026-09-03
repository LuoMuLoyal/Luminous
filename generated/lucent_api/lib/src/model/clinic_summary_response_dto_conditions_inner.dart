//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_conditions_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoConditionsInner {
  /// Returns a new [ClinicSummaryResponseDtoConditionsInner] instance.
  ClinicSummaryResponseDtoConditionsInner({
    required this.label,

    required this.status,

    this.diagnosedYear,
  });

  /// Condition label (e.g. 高血压)
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'status', required: true, includeIfNull: true)
  final String? status;

  @JsonKey(name: r'diagnosedYear', required: false, includeIfNull: false)
  final num? diagnosedYear;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseDtoConditionsInner &&
          other.label == label &&
          other.status == status &&
          other.diagnosedYear == diagnosedYear;

  @override
  int get hashCode =>
      label.hashCode +
      (status == null ? 0 : status.hashCode) +
      (diagnosedYear == null ? 0 : diagnosedYear.hashCode);

  factory ClinicSummaryResponseDtoConditionsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseDtoConditionsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoConditionsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
