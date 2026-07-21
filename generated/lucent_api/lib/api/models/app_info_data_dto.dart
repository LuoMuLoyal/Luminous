// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'app_info_data_dto.g.dart';

@JsonSerializable()
class AppInfoDataDto {
  const AppInfoDataDto({
    required this.name,
    required this.version,
    required this.description,
    required this.buildDate,
    this.minClientVersion,
    this.supportEmail,
  });

  factory AppInfoDataDto.fromJson(Map<String, Object?> json) =>
      _$AppInfoDataDtoFromJson(json);

  final String name;
  final String version;
  final String description;

  /// ISO-8601 build/publish timestamp.
  final String buildDate;
  final String? minClientVersion;
  final String? supportEmail;

  Map<String, Object?> toJson() => _$AppInfoDataDtoToJson(this);
}
