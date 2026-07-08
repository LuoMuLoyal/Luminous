// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'app_info_data_dto.dart';

part 'app_info_response_dto.g.dart';

@JsonSerializable()
class AppInfoResponseDto {
  const AppInfoResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AppInfoResponseDto.fromJson(Map<String, Object?> json) =>
      _$AppInfoResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final AppInfoDataDto data;

  Map<String, Object?> toJson() => _$AppInfoResponseDtoToJson(this);
}
