//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_record_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_record_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordResponseDto {
  /// Returns a new [MedicineRiskCheckRecordResponseDto] instance.
  MedicineRiskCheckRecordResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final MedicineRiskCheckRecordDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory MedicineRiskCheckRecordResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
