//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/user_device_platform.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_device_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterDeviceDto {
  /// Returns a new [RegisterDeviceDto] instance.
  RegisterDeviceDto({
    required this.pushToken,

    required this.platform,

    this.deviceName,

    this.locale,

    this.timezone,

    this.notificationsEnabled = false,
  });

  /// Push notification token (FCM/APNs).
  @JsonKey(name: r'pushToken', required: true, includeIfNull: false)
  final String pushToken;

  /// Device platform.
  @JsonKey(
    name: r'platform',
    required: true,
    includeIfNull: false,
    unknownEnumValue: UserDevicePlatform.unknownDefaultOpenApi,
  )
  final UserDevicePlatform platform;

  /// Human-readable device name.
  @JsonKey(name: r'deviceName', required: false, includeIfNull: false)
  final String? deviceName;

  /// User locale preference.
  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  /// User timezone preference.
  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  /// Whether push notifications are enabled for this device.
  @JsonKey(
    defaultValue: false,
    name: r'notificationsEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? notificationsEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterDeviceDto &&
          other.pushToken == pushToken &&
          other.platform == platform &&
          other.deviceName == deviceName &&
          other.locale == locale &&
          other.timezone == timezone &&
          other.notificationsEnabled == notificationsEnabled;

  @override
  int get hashCode =>
      pushToken.hashCode +
      platform.hashCode +
      deviceName.hashCode +
      locale.hashCode +
      timezone.hashCode +
      notificationsEnabled.hashCode;

  factory RegisterDeviceDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDeviceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
