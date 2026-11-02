//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_record_response_result_findings_mechanism_mechanisms.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_record_response_result_findings_mechanism.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordResponseResultFindingsMechanism {
  /// Returns a new [MedicineRiskCheckRecordResponseResultFindingsMechanism] instance.
  MedicineRiskCheckRecordResponseResultFindingsMechanism({
    required this.status,

    this.mechanisms,
  });

  /// Whether evidence was found, absent, or the graph could not answer.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordResponseResultFindingsMechanismStatusEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordResponseResultFindingsMechanismStatusEnum status;

  /// Present only when status is ok.
  @JsonKey(name: r'mechanisms', required: false, includeIfNull: false)
  final List<MedicineRiskCheckRecordResponseResultFindingsMechanismMechanisms>?
  mechanisms;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordResponseResultFindingsMechanism &&
          other.status == status &&
          other.mechanisms == mechanisms;

  @override
  int get hashCode => status.hashCode + mechanisms.hashCode;

  factory MedicineRiskCheckRecordResponseResultFindingsMechanism.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordResponseResultFindingsMechanismFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordResponseResultFindingsMechanismToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Whether evidence was found, absent, or the graph could not answer.
enum MedicineRiskCheckRecordResponseResultFindingsMechanismStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok'),
  @JsonValue(r'notFound')
  notFound(r'notFound'),
  @JsonValue(r'notConfigured')
  notConfigured(r'notConfigured'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'timeout')
  timeout(r'timeout'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordResponseResultFindingsMechanismStatusEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
