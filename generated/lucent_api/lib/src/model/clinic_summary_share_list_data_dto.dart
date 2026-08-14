//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_share_list_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareListDataDto {
  /// Returns a new [ClinicSummaryShareListDataDto] instance.
  ClinicSummaryShareListDataDto({required this.items});

  /// The caller shares, newest first (createdAt desc); revoked shares stay listed.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ClinicSummaryShareListItemDto> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareListDataDto && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory ClinicSummaryShareListDataDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
