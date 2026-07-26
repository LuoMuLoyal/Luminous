//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/device_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceListResponseDto {
  /// Returns a new [DeviceListResponseDto] instance.
  DeviceListResponseDto({required this.items});

  /// List of registered devices.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DeviceItemDto> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceListResponseDto && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory DeviceListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
