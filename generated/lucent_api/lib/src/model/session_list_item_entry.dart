//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_list_item_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionListItemEntry {
  /// Returns a new [SessionListItemEntry] instance.
  SessionListItemEntry({
    required this.id,

    required this.deviceType,

    required this.deviceName,

    required this.platform,

    required this.lastUsedAt,

    required this.createdAt,

    required this.expiresAt,

    required this.isCurrent,
  });

  /// Session id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'deviceType', required: true, includeIfNull: true)
  final String? deviceType;

  @JsonKey(name: r'deviceName', required: true, includeIfNull: true)
  final String? deviceName;

  @JsonKey(name: r'platform', required: true, includeIfNull: true)
  final String? platform;

  @JsonKey(name: r'lastUsedAt', required: true, includeIfNull: true)
  final String? lastUsedAt;

  /// Created at (ISO-8601)
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Expires at (ISO-8601)
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  /// Whether this is the current session
  @JsonKey(name: r'isCurrent', required: true, includeIfNull: false)
  final bool isCurrent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionListItemEntry &&
          other.id == id &&
          other.deviceType == deviceType &&
          other.deviceName == deviceName &&
          other.platform == platform &&
          other.lastUsedAt == lastUsedAt &&
          other.createdAt == createdAt &&
          other.expiresAt == expiresAt &&
          other.isCurrent == isCurrent;

  @override
  int get hashCode =>
      id.hashCode +
      (deviceType == null ? 0 : deviceType.hashCode) +
      (deviceName == null ? 0 : deviceName.hashCode) +
      (platform == null ? 0 : platform.hashCode) +
      (lastUsedAt == null ? 0 : lastUsedAt.hashCode) +
      createdAt.hashCode +
      expiresAt.hashCode +
      isCurrent.hashCode;

  factory SessionListItemEntry.fromJson(Map<String, dynamic> json) =>
      _$SessionListItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SessionListItemEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
