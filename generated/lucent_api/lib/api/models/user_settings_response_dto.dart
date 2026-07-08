// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_settings_data_dto.dart';

part 'user_settings_response_dto.g.dart';

@JsonSerializable()
class UserSettingsResponseDto {
  const UserSettingsResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory UserSettingsResponseDto.fromJson(Map<String, Object?> json) =>
      _$UserSettingsResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final UserSettingsDataDto data;

  Map<String, Object?> toJson() => _$UserSettingsResponseDtoToJson(this);
}
