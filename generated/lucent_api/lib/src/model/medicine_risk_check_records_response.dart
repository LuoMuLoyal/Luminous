//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_records_response_llm.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponse {
  /// Returns a new [MedicineRiskCheckRecordsResponse] instance.
  MedicineRiskCheckRecordsResponse({required this.static_, required this.llm});

  @JsonKey(name: r'static', required: true, includeIfNull: true)
  final MedicineRiskCheckRecordsResponseStatic? static_;

  @JsonKey(name: r'llm', required: true, includeIfNull: true)
  final MedicineRiskCheckRecordsResponseLlm? llm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponse &&
          other.static_ == static_ &&
          other.llm == llm;

  @override
  int get hashCode =>
      (static_ == null ? 0 : static_.hashCode) +
      (llm == null ? 0 : llm.hashCode);

  factory MedicineRiskCheckRecordsResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
