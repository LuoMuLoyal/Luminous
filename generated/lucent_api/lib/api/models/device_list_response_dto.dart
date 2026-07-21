// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_item_dto.dart';

part 'device_list_response_dto.g.dart';

@JsonSerializable()
class DeviceListResponseDto {
  const DeviceListResponseDto({required this.items});

  factory DeviceListResponseDto.fromJson(Map<String, Object?> json) =>
      _$DeviceListResponseDtoFromJson(json);

  /// List of registered devices.
  final List<DeviceItemDto> items;

  Map<String, Object?> toJson() => _$DeviceListResponseDtoToJson(this);
}
