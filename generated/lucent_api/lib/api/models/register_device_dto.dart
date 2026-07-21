// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_device_platform.dart';

part 'register_device_dto.g.dart';

@JsonSerializable()
class RegisterDeviceDto {
  const RegisterDeviceDto({
    required this.pushToken,
    required this.platform,
    this.notificationsEnabled = false,
    this.deviceName,
    this.locale,
    this.timezone,
  });

  factory RegisterDeviceDto.fromJson(Map<String, Object?> json) =>
      _$RegisterDeviceDtoFromJson(json);

  /// Push notification token (FCM/APNs).
  final String pushToken;

  /// Device platform.
  final UserDevicePlatform platform;

  /// Human-readable device name.
  final String? deviceName;

  /// User locale preference.
  final String? locale;

  /// User timezone preference.
  final String? timezone;

  /// Whether push notifications are enabled for this device.
  final bool notificationsEnabled;

  Map<String, Object?> toJson() => _$RegisterDeviceDtoToJson(this);
}
