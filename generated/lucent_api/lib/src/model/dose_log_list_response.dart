//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/dose_log_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoseLogListResponse {
  /// Returns a new [DoseLogListResponse] instance.
  DoseLogListResponse({required this.items, required this.total});

  /// Dose logs for the date.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DoseLogListResponseItems> items;

  /// Total count of dose logs for the date.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogListResponse &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory DoseLogListResponse.fromJson(Map<String, dynamic> json) =>
      _$DoseLogListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
