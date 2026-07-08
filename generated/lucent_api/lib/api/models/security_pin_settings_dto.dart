// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'security_pin_settings_dto.g.dart';

@JsonSerializable()
class SecurityPinSettingsDto {
  const SecurityPinSettingsDto({
    required this.enabled,
    required this.lastChangedAt,
  });

  factory SecurityPinSettingsDto.fromJson(Map<String, Object?> json) =>
      _$SecurityPinSettingsDtoFromJson(json);

  /// Whether a Security PIN is enabled
  final bool enabled;

  /// ISO-8601 timestamp of last PIN change, null if never set
  final String? lastChangedAt;

  Map<String, Object?> toJson() => _$SecurityPinSettingsDtoToJson(this);
}
