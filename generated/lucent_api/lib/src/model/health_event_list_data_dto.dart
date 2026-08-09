//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventListDataDto {
  /// Returns a new [HealthEventListDataDto] instance.
  HealthEventListDataDto({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<HealthEventItemDto> items;

  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventListDataDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory HealthEventListDataDto.fromJson(Map<String, dynamic> json) =>
      _$HealthEventListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
