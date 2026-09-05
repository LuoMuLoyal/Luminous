//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_share_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareListResponse {
  /// Returns a new [ClinicSummaryShareListResponse] instance.
  ClinicSummaryShareListResponse({required this.items});

  /// The caller shares, newest first (createdAt desc); revoked shares stay listed.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ClinicSummaryShareListResponseItems> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareListResponse && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory ClinicSummaryShareListResponse.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
