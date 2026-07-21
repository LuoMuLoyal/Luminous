// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_item_dto.g.dart';

@JsonSerializable()
class DeviceItemDto {
  const DeviceItemDto({
    required this.id,
    required this.platform,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.deviceName,
    this.locale,
    this.timezone,
    this.lastSeenAt,
  });

  factory DeviceItemDto.fromJson(Map<String, Object?> json) =>
      _$DeviceItemDtoFromJson(json);

  /// Device record ID.
  final String id;

  /// Device platform.
  final String platform;

  /// Human-readable device name.
  final dynamic deviceName;

  /// Whether push notifications are enabled.
  final bool notificationsEnabled;

  /// User locale preference.
  final dynamic locale;

  /// User timezone preference.
  final dynamic timezone;

  /// ISO 8601 timestamp of last device activity.
  final dynamic lastSeenAt;

  /// ISO 8601 creation timestamp.
  final String createdAt;

  /// ISO 8601 last-update timestamp.
  final String updatedAt;

  Map<String, Object?> toJson() => _$DeviceItemDtoToJson(this);
}
