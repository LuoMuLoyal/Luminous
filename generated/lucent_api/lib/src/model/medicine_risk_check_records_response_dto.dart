//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_record_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseDto {
  /// Returns a new [MedicineRiskCheckRecordsResponseDto] instance.
  MedicineRiskCheckRecordsResponseDto({
    required this.static_,

    required this.llm,
  });

  /// Latest static check record, null if never checked
  @JsonKey(name: r'static', required: true, includeIfNull: true)
  final MedicineRiskCheckRecordDto? static_;

  /// Latest LLM check record, null if never checked
  @JsonKey(name: r'llm', required: true, includeIfNull: true)
  final MedicineRiskCheckRecordDto? llm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseDto &&
          other.static_ == static_ &&
          other.llm == llm;

  @override
  int get hashCode =>
      (static_ == null ? 0 : static_.hashCode) +
      (llm == null ? 0 : llm.hashCode);

  factory MedicineRiskCheckRecordsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
