//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_share_list_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareListResponseDto {
  /// Returns a new [ClinicSummaryShareListResponseDto] instance.
  ClinicSummaryShareListResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final ClinicSummaryShareListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory ClinicSummaryShareListResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryShareListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryShareListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
