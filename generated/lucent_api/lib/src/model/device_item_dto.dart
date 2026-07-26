//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceItemDto {
  /// Returns a new [DeviceItemDto] instance.
  DeviceItemDto({
    required this.id,

    required this.platform,

    this.deviceName,

    required this.notificationsEnabled,

    this.locale,

    this.timezone,

    this.lastSeenAt,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Device record ID.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Device platform.
  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final String platform;

  /// Human-readable device name.
  @JsonKey(name: r'deviceName', required: false, includeIfNull: false)
  final Object? deviceName;

  /// Whether push notifications are enabled.
  @JsonKey(name: r'notificationsEnabled', required: true, includeIfNull: false)
  final bool notificationsEnabled;

  /// User locale preference.
  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final Object? locale;

  /// User timezone preference.
  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final Object? timezone;

  /// ISO 8601 timestamp of last device activity.
  @JsonKey(name: r'lastSeenAt', required: false, includeIfNull: false)
  final Object? lastSeenAt;

  /// ISO 8601 creation timestamp.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// ISO 8601 last-update timestamp.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceItemDto &&
          other.id == id &&
          other.platform == platform &&
          other.deviceName == deviceName &&
          other.notificationsEnabled == notificationsEnabled &&
          other.locale == locale &&
          other.timezone == timezone &&
          other.lastSeenAt == lastSeenAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      platform.hashCode +
      deviceName.hashCode +
      notificationsEnabled.hashCode +
      locale.hashCode +
      timezone.hashCode +
      lastSeenAt.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory DeviceItemDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
