//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_list_response_dto_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventListResponseDto {
  /// Returns a new [HealthEventListResponseDto] instance.
  HealthEventListResponseDto({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<HealthEventListResponseDtoItemsInner> items;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventListResponseDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory HealthEventListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$HealthEventListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
