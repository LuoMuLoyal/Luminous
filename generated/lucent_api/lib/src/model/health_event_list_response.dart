//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventListResponse {
  /// Returns a new [HealthEventListResponse] instance.
  HealthEventListResponse({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<HealthEventListResponseItems> items;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventListResponse &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory HealthEventListResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthEventListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
