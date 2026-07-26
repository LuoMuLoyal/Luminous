//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_pin_settings_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityPinSettingsDto {
  /// Returns a new [SecurityPinSettingsDto] instance.
  SecurityPinSettingsDto({required this.enabled, required this.lastChangedAt});

  /// Whether a Security PIN is enabled
  @JsonKey(name: r'enabled', required: true, includeIfNull: false)
  final bool enabled;

  /// ISO-8601 timestamp of last PIN change, null if never set
  @JsonKey(name: r'lastChangedAt', required: true, includeIfNull: true)
  final String? lastChangedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityPinSettingsDto &&
          other.enabled == enabled &&
          other.lastChangedAt == lastChangedAt;

  @override
  int get hashCode =>
      enabled.hashCode + (lastChangedAt == null ? 0 : lastChangedAt.hashCode);

  factory SecurityPinSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$SecurityPinSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityPinSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
