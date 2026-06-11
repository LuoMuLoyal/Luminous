//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/support_resource_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_resource_list_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SupportResourceListDataDto {
  /// Returns a new [SupportResourceListDataDto] instance.
  SupportResourceListDataDto({required this.items, required this.updatedAt});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<SupportResourceDto> items;

  /// ISO-8601 timestamp of last reference data revision.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportResourceListDataDto &&
          other.items == items &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => items.hashCode + updatedAt.hashCode;

  factory SupportResourceListDataDto.fromJson(Map<String, dynamic> json) =>
      _$SupportResourceListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupportResourceListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
