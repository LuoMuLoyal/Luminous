// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_item_dto.dart';

part 'dose_log_response_dto.g.dart';

@JsonSerializable()
class DoseLogResponseDto {
  const DoseLogResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DoseLogResponseDto.fromJson(Map<String, Object?> json) =>
      _$DoseLogResponseDtoFromJson(json);

  final num code;
  final String message;
  final DoseLogItemDto data;

  Map<String, Object?> toJson() => _$DoseLogResponseDtoToJson(this);
}
