// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_list_data_dto.dart';

part 'dose_log_list_response_dto.g.dart';

@JsonSerializable()
class DoseLogListResponseDto {
  const DoseLogListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DoseLogListResponseDto.fromJson(Map<String, Object?> json) =>
      _$DoseLogListResponseDtoFromJson(json);

  final num code;
  final String message;
  final DoseLogListDataDto data;

  Map<String, Object?> toJson() => _$DoseLogListResponseDtoToJson(this);
}
